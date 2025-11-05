import 'dart:convert';
import 'event_model.dart';

/// Represents the type of operation in the sync queue
enum SyncOperation {
  create,
  update,
  delete,
}

/// Represents the status of a sync queue item
enum SyncStatus {
  pending,
  syncing,
  failed,
}

/// Model for sync queue entries
/// Stores pending changes to be synced when connectivity returns
class SyncQueueModel {
  final int? id; // SQLite auto-increment ID
  final SyncOperation operation;
  final EventModel eventData;
  final DateTime timestamp;
  final int retryCount;
  final SyncStatus status;
  final String? errorMessage;

  const SyncQueueModel({
    this.id,
    required this.operation,
    required this.eventData,
    required this.timestamp,
    this.retryCount = 0,
    this.status = SyncStatus.pending,
    this.errorMessage,
  });

  /// Convert enum to string for database storage
  static String operationToString(SyncOperation operation) {
    switch (operation) {
      case SyncOperation.create:
        return 'create';
      case SyncOperation.update:
        return 'update';
      case SyncOperation.delete:
        return 'delete';
    }
  }

  /// Convert string to enum from database
  static SyncOperation operationFromString(String value) {
    switch (value) {
      case 'create':
        return SyncOperation.create;
      case 'update':
        return SyncOperation.update;
      case 'delete':
        return SyncOperation.delete;
      default:
        throw ArgumentError('Unknown sync operation: $value');
    }
  }

  /// Convert enum to string for database storage
  static String statusToString(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.syncing:
        return 'syncing';
      case SyncStatus.failed:
        return 'failed';
    }
  }

  /// Convert string to enum from database
  static SyncStatus statusFromString(String value) {
    switch (value) {
      case 'pending':
        return SyncStatus.pending;
      case 'syncing':
        return SyncStatus.syncing;
      case 'failed':
        return SyncStatus.failed;
      default:
        throw ArgumentError('Unknown sync status: $value');
    }
  }

  /// Convert to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operation': operationToString(operation),
      'event_data': jsonEncode(eventData.toJson()),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'retry_count': retryCount,
      'status': statusToString(status),
      'error_message': errorMessage,
    };
  }

  /// Create from SQLite Map
  factory SyncQueueModel.fromMap(Map<String, dynamic> map) {
    return SyncQueueModel(
      id: map['id'] as int?,
      operation: operationFromString(map['operation'] as String),
      eventData: EventModel.fromJson(jsonDecode(map['event_data'] as String)),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      retryCount: map['retry_count'] as int? ?? 0,
      status: statusFromString(map['status'] as String),
      errorMessage: map['error_message'] as String?,
    );
  }

  /// Create a copy with updated fields
  SyncQueueModel copyWith({
    int? id,
    SyncOperation? operation,
    EventModel? eventData,
    DateTime? timestamp,
    int? retryCount,
    SyncStatus? status,
    String? errorMessage,
  }) {
    return SyncQueueModel(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      eventData: eventData ?? this.eventData,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'SyncQueueModel(id: $id, operation: $operation, status: $status, retryCount: $retryCount)';
  }
}
