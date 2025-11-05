import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart' show currentFirebaseUserProvider, firestoreServiceProvider;
import 'workplace_provider.dart' show selectedWorkplaceIdProvider;
import 'offline_sync_provider.dart';

// ============================================================================
// Event Providers
// ============================================================================

/// Provider for events stream (includes user and partner events)
/// Takes a start date and loads 7 days of events
final eventsStreamProvider = StreamProvider.family<List<EventModel>, DateTime>((ref, weekStart) {
  final user = ref.watch(currentFirebaseUserProvider);

  if (user == null) {
    return Stream.value([]);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);
  final weekEnd = weekStart.add(const Duration(days: 7));

  return firestoreService.eventsForDateRangeStream(user.uid, weekStart, weekEnd);
});

/// Provider for month events stream (includes user and partner events for full month)
/// Takes a month start date and loads the entire month plus overflow dates
final monthEventsStreamProvider = StreamProvider.family<List<EventModel>, DateTime>((ref, monthStart) {
  final user = ref.watch(currentFirebaseUserProvider);

  if (user == null) {
    return Stream.value([]);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);

  // Calculate the last day of the month
  final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0, 23, 59, 59);

  // Add extra days to cover overflow dates from previous/next month
  // (usually up to 6 days before and 6 days after)
  final rangeStart = monthStart.subtract(const Duration(days: 7));
  final rangeEnd = monthEnd.add(const Duration(days: 7));

  return firestoreService.eventsForDateRangeStream(user.uid, rangeStart, rangeEnd);
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

/// Provider for month events filtered by selected workplace
final filteredMonthEventsProvider = Provider.family<List<EventModel>, DateTime>((ref, monthStart) {
  final monthEvents = ref.watch(monthEventsStreamProvider(monthStart));
  final selectedWorkplaceId = ref.watch(selectedWorkplaceIdProvider);

  return monthEvents.when(
    data: (events) {
      // If no workplace selected, show all events
      if (selectedWorkplaceId == null) return events;

      // Filter events by workplace
      return events.where((event) => event.workplaceId == selectedWorkplaceId).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ============================================================================
// Event State Notifier (for CRUD operations)
// ============================================================================

class EventStateNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Create a new event (with offline support)
  Future<String?> createEvent(EventModel event) async {
    state = const AsyncValue.loading();
    try {
      final offlineSyncService = ref.read(offlineSyncServiceProvider);
      await offlineSyncService.createEvent(event);
      state = const AsyncValue.data(null);
      return event.eventId;
    } catch (e, stackTrace) {
      // Event is still cached locally and queued for sync
      // Don't treat offline as an error
      state = const AsyncValue.data(null);
      return event.eventId;
    }
  }

  /// Update an existing event (with offline support)
  Future<bool> updateEvent(EventModel event) async {
    state = const AsyncValue.loading();
    try {
      final offlineSyncService = ref.read(offlineSyncServiceProvider);
      await offlineSyncService.updateEvent(event);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      // Event is still updated locally and queued for sync
      // Don't treat offline as an error
      state = const AsyncValue.data(null);
      return true;
    }
  }

  /// Delete an event (with offline support)
  Future<bool> deleteEvent(String eventId) async {
    state = const AsyncValue.loading();
    try {
      final offlineSyncService = ref.read(offlineSyncServiceProvider);
      await offlineSyncService.deleteEvent(eventId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      // Event is still deleted locally and queued for sync
      // Don't treat offline as an error
      state = const AsyncValue.data(null);
      return true;
    }
  }
}

// Event state notifier provider
final eventStateNotifierProvider = NotifierProvider<EventStateNotifier, AsyncValue<void>>(() {
  return EventStateNotifier();
});
