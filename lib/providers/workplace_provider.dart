import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workplace_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

/// Provider for workplaces stream
final workplacesStreamProvider = StreamProvider.autoDispose<List<WorkplaceModel>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    return Stream.value([]);
  }

  final firestoreService = FirestoreService();
  return firestoreService.userWorkplacesStream(user.uid);
});

/// State notifier for selected workplace ID
class SelectedWorkplaceIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? workplaceId) {
    state = workplaceId;
  }
}

/// Provider for selected workplace ID
final selectedWorkplaceIdProvider = NotifierProvider<SelectedWorkplaceIdNotifier, String?>(
  () => SelectedWorkplaceIdNotifier(),
);

/// Provider for getting the selected workplace
final selectedWorkplaceProvider = Provider<WorkplaceModel?>((ref) {
  final workplacesAsync = ref.watch(workplacesStreamProvider);
  final selectedId = ref.watch(selectedWorkplaceIdProvider);

  return workplacesAsync.when(
    data: (workplaces) {
      if (selectedId == null && workplaces.isNotEmpty) {
        // Auto-select first workplace if none selected
        Future.microtask(() {
          ref.read(selectedWorkplaceIdProvider.notifier).select(workplaces.first.workplaceId);
        });
        return workplaces.first;
      }
      if (selectedId == null) return null;

      try {
        return workplaces.firstWhere((w) => w.workplaceId == selectedId);
      } catch (e) {
        // If workplace not found, return first one or null
        return workplaces.isNotEmpty ? workplaces.first : null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for workplace operations
final workplaceOperationsProvider = Provider<WorkplaceOperations>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  return WorkplaceOperations(
    firestoreService: FirestoreService(),
    userId: user?.uid ?? '',
  );
});

/// Class to handle workplace operations
class WorkplaceOperations {
  final FirestoreService firestoreService;
  final String userId;

  WorkplaceOperations({
    required this.firestoreService,
    required this.userId,
  });

  /// Create a new workplace
  Future<WorkplaceModel> createWorkplace(String name, int order) async {
    return await firestoreService.createWorkplace(
      userId: userId,
      name: name,
      order: order,
    );
  }

  /// Update a workplace name
  Future<void> updateWorkplaceName(String workplaceId, String name) async {
    return await firestoreService.updateWorkplace(workplaceId, name: name);
  }

  /// Delete a workplace
  Future<void> deleteWorkplace(String workplaceId) async {
    return await firestoreService.deleteWorkplace(workplaceId);
  }

  /// Reorder workplaces
  Future<void> reorderWorkplaces(List<WorkplaceModel> workplaces) async {
    return await firestoreService.reorderWorkplaces(workplaces);
  }

  /// Initialize default workplaces for a new user
  Future<List<WorkplaceModel>> initializeDefaultWorkplaces() async {
    return await firestoreService.initializeDefaultWorkplaces(userId);
  }
}
