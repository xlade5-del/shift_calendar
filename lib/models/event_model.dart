import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a calendar event/shift in the system
class EventModel {
  final String eventId;
  final String userId; // Owner of the event
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;
  final String color; // Hex color string (e.g., "#FF5722")
  final EventSource source;
  final String? icalUid; // For iCal synced events
  final int version; // For conflict resolution
  final String? workplaceId; // Optional workplace association
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.eventId,
    required this.userId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.notes,
    required this.color,
    required this.source,
    this.icalUid,
    this.version = 1,
    this.workplaceId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create EventModel from Firestore document
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return EventModel(
      eventId: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
      color: data['color'] as String,
      source: EventSource.fromString(data['source'] as String),
      icalUid: data['icalUid'] as String?,
      version: data['version'] as int? ?? 1,
      workplaceId: data['workplaceId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert EventModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'notes': notes,
      'color': color,
      'source': source.toString().split('.').last,
      'icalUid': icalUid,
      'version': version,
      'workplaceId': workplaceId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert EventModel to JSON (for SQLite storage)
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userId': userId,
      'title': title,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'notes': notes,
      'color': color,
      'source': source.toString().split('.').last,
      'icalUid': icalUid,
      'version': version,
      'workplaceId': workplaceId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create EventModel from JSON (for SQLite retrieval)
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int),
      notes: json['notes'] as String?,
      color: json['color'] as String,
      source: EventSource.fromString(json['source'] as String),
      icalUid: json['icalUid'] as String?,
      version: json['version'] as int? ?? 1,
      workplaceId: json['workplaceId'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }

  /// Create a copy of this event with updated fields
  EventModel copyWith({
    String? eventId,
    String? userId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    String? color,
    EventSource? source,
    String? icalUid,
    int? version,
    String? workplaceId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      color: color ?? this.color,
      source: source ?? this.source,
      icalUid: icalUid ?? this.icalUid,
      version: version ?? this.version,
      workplaceId: workplaceId ?? this.workplaceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get duration of the event
  Duration get duration => endTime.difference(startTime);

  /// Check if event is all-day (starts at midnight and is 24+ hours)
  bool get isAllDay {
    return startTime.hour == 0 &&
        startTime.minute == 0 &&
        duration.inHours >= 24;
  }

  /// Check if event is currently happening
  bool get isNow {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Check if event is in the past
  bool get isPast => DateTime.now().isAfter(endTime);

  /// Check if event is in the future
  bool get isFuture => DateTime.now().isBefore(startTime);
}

/// Source of the event (manual entry, iCal import, etc.)
enum EventSource {
  manual,
  ical,
  google,
  apple;

  static EventSource fromString(String source) {
    switch (source.toLowerCase()) {
      case 'manual':
        return EventSource.manual;
      case 'ical':
        return EventSource.ical;
      case 'google':
        return EventSource.google;
      case 'apple':
        return EventSource.apple;
      default:
        return EventSource.manual;
    }
  }
}
