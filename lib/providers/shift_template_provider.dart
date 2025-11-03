import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shift_template_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

/// Provider for user's shift templates stream (real-time updates)
final userShiftTemplatesProvider = StreamProvider.autoDispose<List<ShiftTemplate>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;

  if (user == null) {
    return Stream.value([]);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.userShiftTemplatesStream(user.uid);
});

/// Provider for creating a shift template
final createShiftTemplateProvider = Provider<Future<String> Function(ShiftTemplate)>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return (template) => firestoreService.createShiftTemplate(template);
});

/// Provider for updating a shift template
final updateShiftTemplateProvider = Provider<Future<void> Function(ShiftTemplate)>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return (template) => firestoreService.updateShiftTemplate(template);
});

/// Provider for deleting a shift template
final deleteShiftTemplateProvider = Provider<Future<void> Function(String)>((ref) {
  final firestoreService = ref.read(firestoreServiceProvider);
  return (templateId) => firestoreService.deleteShiftTemplate(templateId);
});
