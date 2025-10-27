import 'package:intl/intl.dart';
import '../models/event_model.dart';

/// Utility class for detecting schedule conflicts between partners
class ConflictDetector {
  /// Check if two events overlap in time
  static bool eventsOverlap(EventModel event1, EventModel event2) {
    // Events overlap if:
    // - event1 starts before event2 ends AND
    // - event2 starts before event1 ends
    return event1.startTime.isBefore(event2.endTime) &&
        event2.startTime.isBefore(event1.endTime);
  }

  /// Find all conflicts for a given event against a list of partner events
  /// Returns list of partner events that conflict with the given event
  static List<EventModel> findConflictsForEvent(
    EventModel event,
    List<EventModel> partnerEvents,
  ) {
    return partnerEvents.where((partnerEvent) {
      // Don't compare an event with itself
      if (event.eventId == partnerEvent.eventId) return false;

      // Check if events belong to different users
      if (event.userId == partnerEvent.userId) return false;

      return eventsOverlap(event, partnerEvent);
    }).toList();
  }

  /// Detect all conflicts in a list of events (user + partner events)
  /// Returns a map of event IDs to their conflicting events
  static Map<String, List<EventModel>> detectAllConflicts(
    List<EventModel> allEvents,
    String currentUserId,
  ) {
    final conflicts = <String, List<EventModel>>{};

    // Split events into user events and partner events
    final userEvents = allEvents.where((e) => e.userId == currentUserId).toList();
    final partnerEvents = allEvents.where((e) => e.userId != currentUserId).toList();

    // Check each user event for conflicts with partner events
    for (final userEvent in userEvents) {
      final eventConflicts = findConflictsForEvent(userEvent, partnerEvents);
      if (eventConflicts.isNotEmpty) {
        conflicts[userEvent.eventId] = eventConflicts;
      }
    }

    return conflicts;
  }

  /// Get a list of all conflict pairs (avoiding duplicates)
  /// Returns list of [userEvent, partnerEvent] pairs
  static List<ConflictPair> getConflictPairs(
    List<EventModel> allEvents,
    String currentUserId,
  ) {
    final pairs = <ConflictPair>[];
    final processedPairs = <String>{};

    final userEvents = allEvents.where((e) => e.userId == currentUserId).toList();
    final partnerEvents = allEvents.where((e) => e.userId != currentUserId).toList();

    for (final userEvent in userEvents) {
      for (final partnerEvent in partnerEvents) {
        if (eventsOverlap(userEvent, partnerEvent)) {
          // Create a unique key to avoid duplicates
          final pairKey = '${userEvent.eventId}_${partnerEvent.eventId}';

          if (!processedPairs.contains(pairKey)) {
            pairs.add(ConflictPair(
              userEvent: userEvent,
              partnerEvent: partnerEvent,
            ));
            processedPairs.add(pairKey);
          }
        }
      }
    }

    return pairs;
  }

  /// Check if a specific event has any conflicts
  static bool hasConflict(
    EventModel event,
    List<EventModel> allEvents,
  ) {
    return allEvents.any((otherEvent) {
      // Skip same event
      if (event.eventId == otherEvent.eventId) return false;

      // Only check against events from different users
      if (event.userId == otherEvent.userId) return false;

      return eventsOverlap(event, otherEvent);
    });
  }

  /// Get conflict summary text for display
  static String getConflictSummary(List<ConflictPair> conflicts) {
    if (conflicts.isEmpty) {
      return 'No scheduling conflicts';
    } else if (conflicts.length == 1) {
      return '1 scheduling conflict detected';
    } else {
      return '${conflicts.length} scheduling conflicts detected';
    }
  }

  /// Calculate overlap duration between two events
  static Duration getOverlapDuration(EventModel event1, EventModel event2) {
    if (!eventsOverlap(event1, event2)) {
      return Duration.zero;
    }

    // Find the latest start time
    final overlapStart = event1.startTime.isAfter(event2.startTime)
        ? event1.startTime
        : event2.startTime;

    // Find the earliest end time
    final overlapEnd = event1.endTime.isBefore(event2.endTime)
        ? event1.endTime
        : event2.endTime;

    return overlapEnd.difference(overlapStart);
  }
}

/// Represents a conflict between user and partner events
class ConflictPair {
  final EventModel userEvent;
  final EventModel partnerEvent;

  ConflictPair({
    required this.userEvent,
    required this.partnerEvent,
  });

  /// Get the overlap duration for this conflict
  Duration get overlapDuration {
    return ConflictDetector.getOverlapDuration(userEvent, partnerEvent);
  }

  /// Get formatted overlap time range
  String get overlapTimeRange {
    // Find the latest start time
    final overlapStart = userEvent.startTime.isAfter(partnerEvent.startTime)
        ? userEvent.startTime
        : partnerEvent.startTime;

    // Find the earliest end time
    final overlapEnd = userEvent.endTime.isBefore(partnerEvent.endTime)
        ? userEvent.endTime
        : partnerEvent.endTime;

    final hours = overlapDuration.inHours;
    final minutes = overlapDuration.inMinutes.remainder(60);

    // Format duration
    String duration;
    if (hours > 0 && minutes > 0) {
      duration = '$hours hr $minutes min';
    } else if (hours > 0) {
      duration = '$hours hr';
    } else {
      duration = '$minutes min';
    }

    // Format time range
    final startTime = DateFormat('h:mm a').format(overlapStart);
    final endTime = DateFormat('h:mm a').format(overlapEnd);

    return '$duration ($startTime - $endTime)';
  }
}
