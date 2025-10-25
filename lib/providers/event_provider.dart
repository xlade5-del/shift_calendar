import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

// ============================================================================
// Event Providers
// ============================================================================

/// Provider for events stream (includes user and partner events)
final eventsStreamProvider = StreamProvider.family<List<EventModel>, DateTime>((ref, weekStart) {
  final user = ref.watch(currentFirebaseUserProvider);

  if (user == null) {
    return Stream.value([]);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  final weekEnd = weekStart.add(const Duration(days: 7));

  return firestoreService.eventsForDateRangeStream(user.uid, weekStart, weekEnd);
});

/// Provider for events for a specific week (one-time fetch)
final eventsForWeekProvider = FutureProvider.family<List<EventModel>, DateTime>((ref, weekStart) async {
  final user = ref.watch(currentFirebaseUserProvider);

  if (user == null) return [];

  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getEventsForWeek(user.uid, weekStart);
});

/// Provider for all user events
final userEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final user = ref.watch(currentFirebaseUserProvider);

  if (user == null) return [];

  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getUserEvents(user.uid);
});

/// Provider for combined events (user + partner)
final combinedEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final user = ref.watch(currentFirebaseUserProvider);

  if (user == null) return [];

  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getCombinedEvents(user.uid);
});

// ============================================================================
// Event State Notifier (for CRUD operations)
// ============================================================================

class EventStateNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Create a new event
  Future<String?> createEvent(EventModel event) async {
    state = const AsyncValue.loading();
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final eventId = await firestoreService.createEvent(event);
      state = const AsyncValue.data(null);
      return eventId;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return null;
    }
  }

  /// Update an existing event
  Future<bool> updateEvent(EventModel event) async {
    state = const AsyncValue.loading();
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateEvent(event);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  /// Delete an event
  Future<bool> deleteEvent(String eventId) async {
    state = const AsyncValue.loading();
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.deleteEvent(eventId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}

// Event state notifier provider
final eventStateNotifierProvider = NotifierProvider<EventStateNotifier, AsyncValue<void>>(() {
  return EventStateNotifier();
});
