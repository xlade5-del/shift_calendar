import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/event_model.dart';
import '../models/sync_queue_model.dart';
import 'database_helper.dart';
import 'firestore_service.dart';

/// Service to manage offline mode and synchronization
/// Handles queueing operations when offline and syncing when connectivity returns
class OfflineSyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isSyncing = false;

  /// Start monitoring connectivity and auto-sync
  void startMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Also start periodic sync timer (every 30 seconds)
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      processSyncQueue();
    });
  }

  /// Stop monitoring
  void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final isConnected = results.any(
      (result) =>
          result != ConnectivityResult.none &&
          result != ConnectivityResult.bluetooth,
    );

    if (isConnected && !_isSyncing) {
      // Connectivity restored, process sync queue
      processSyncQueue();
    }
  }

  /// Check if device has connectivity
  Future<bool> hasConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.any(
      (result) =>
          result != ConnectivityResult.none &&
          result != ConnectivityResult.bluetooth,
    );
  }

  // ==================== EVENT OPERATIONS WITH OFFLINE SUPPORT ====================

  /// Create event (online or queue if offline)
  Future<void> createEvent(EventModel event) async {
    // Always cache locally first
    await _dbHelper.cacheEvent(event);

    if (await hasConnectivity()) {
      try {
        // Try to create in Firestore
        await _firestoreService.createEvent(event);
      } catch (e) {
        // If failed, add to sync queue
        await _queueOperation(SyncOperation.create, event);
        rethrow;
      }
    } else {
      // Offline: add to sync queue
      await _queueOperation(SyncOperation.create, event);
    }
  }

  /// Update event (online or queue if offline)
  Future<void> updateEvent(EventModel event) async {
    // Update local cache
    await _dbHelper.updateCachedEvent(event);

    if (await hasConnectivity()) {
      try {
        // Try to update in Firestore
        await _firestoreService.updateEvent(event);
      } catch (e) {
        // If failed, add to sync queue
        await _queueOperation(SyncOperation.update, event);
        rethrow;
      }
    } else {
      // Offline: add to sync queue
      await _queueOperation(SyncOperation.update, event);
    }
  }

  /// Delete event (online or queue if offline)
  Future<void> deleteEvent(String eventId) async {
    // Get event from cache first
    final event = await _dbHelper.getCachedEvent(eventId);
    if (event == null) return;

    // Delete from local cache
    await _dbHelper.deleteCachedEvent(eventId);

    if (await hasConnectivity()) {
      try {
        // Try to delete from Firestore
        await _firestoreService.deleteEvent(eventId);
      } catch (e) {
        // If failed, add to sync queue
        await _queueOperation(SyncOperation.delete, event);
        rethrow;
      }
    } else {
      // Offline: add to sync queue
      await _queueOperation(SyncOperation.delete, event);
    }
  }

  /// Get events (from cache if offline, sync from Firestore if online)
  Future<List<EventModel>> getEventsForMonth({
    required String userId,
    required DateTime monthStart,
  }) async {
    if (await hasConnectivity()) {
      try {
        // Get from Firestore
        final events =
            await _firestoreService.getMonthEvents(userId, monthStart);

        // Update cache
        await _dbHelper.cacheEvents(events);

        return events;
      } catch (e) {
        // If failed, fallback to cache
        return await _getCachedEventsForMonth(userId, monthStart);
      }
    } else {
      // Offline: get from cache
      return await _getCachedEventsForMonth(userId, monthStart);
    }
  }

  /// Get cached events for a month
  Future<List<EventModel>> _getCachedEventsForMonth(
    String userId,
    DateTime monthStart,
  ) async {
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0, 23, 59);
    return await _dbHelper.getCachedEventsForRange(
      userId: userId,
      start: monthStart,
      end: monthEnd,
    );
  }

  // ==================== SYNC QUEUE MANAGEMENT ====================

  /// Add operation to sync queue
  Future<void> _queueOperation(
    SyncOperation operation,
    EventModel event,
  ) async {
    final queueItem = SyncQueueModel(
      operation: operation,
      eventData: event,
      timestamp: DateTime.now(),
      status: SyncStatus.pending,
    );

    await _dbHelper.addToSyncQueue(queueItem);
  }

  /// Process sync queue (exponential backoff)
  Future<void> processSyncQueue() async {
    if (_isSyncing) return;
    if (!await hasConnectivity()) return;

    _isSyncing = true;

    try {
      final pendingItems = await _dbHelper.getPendingSyncItems();

      for (final item in pendingItems) {
        try {
          // Update status to syncing
          await _dbHelper.updateSyncItem(
            item.copyWith(status: SyncStatus.syncing),
          );

          // Process based on operation type
          bool success = false;
          switch (item.operation) {
            case SyncOperation.create:
              await _firestoreService.createEvent(item.eventData);
              success = true;
              break;

            case SyncOperation.update:
              await _firestoreService.updateEvent(item.eventData);
              success = true;
              break;

            case SyncOperation.delete:
              await _firestoreService.deleteEvent(item.eventData.eventId);
              success = true;
              break;
          }

          if (success) {
            // Remove from queue
            await _dbHelper.deleteSyncItem(item.id!);
          }
        } catch (e) {
          // Exponential backoff
          final newRetryCount = item.retryCount + 1;

          if (newRetryCount >= 6) {
            // Max retries reached (1s, 2s, 4s, 8s, 16s, 32s)
            await _dbHelper.updateSyncItem(
              item.copyWith(
                status: SyncStatus.failed,
                errorMessage: e.toString(),
              ),
            );
          } else {
            // Increment retry count and reset to pending
            await _dbHelper.updateSyncItem(
              item.copyWith(
                status: SyncStatus.pending,
                retryCount: newRetryCount,
              ),
            );

            // Wait before next retry (exponential backoff)
            final delaySeconds = (1 << newRetryCount); // 2^n seconds
            await Future.delayed(Duration(seconds: delaySeconds));
          }
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Get sync queue status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final stats = await _dbHelper.getDatabaseStats();
    final pendingItems = await _dbHelper.getPendingSyncItems();
    final failedItems = await _dbHelper.getFailedSyncItems();

    return {
      'cachedEvents': stats['cachedEvents'],
      'pendingSync': stats['pendingSync'],
      'failedSync': stats['failedSync'],
      'isOnline': await hasConnectivity(),
      'isSyncing': _isSyncing,
      'pendingOperations': pendingItems.map((item) {
        return {
          'operation': item.operation.name,
          'title': item.eventData.title,
          'retryCount': item.retryCount,
        };
      }).toList(),
      'failedOperations': failedItems.map((item) {
        return {
          'operation': item.operation.name,
          'title': item.eventData.title,
          'error': item.errorMessage,
        };
      }).toList(),
    };
  }

  /// Retry all failed sync items
  Future<void> retryFailed() async {
    await _dbHelper.retryFailedSyncItems();
    await processSyncQueue();
  }

  /// Clear sync queue
  Future<void> clearQueue() async {
    await _dbHelper.clearSyncQueue();
  }

  /// Force sync all events from Firestore
  Future<void> forceSyncFromFirestore({
    required String userId,
    required DateTime monthStart,
  }) async {
    if (!await hasConnectivity()) {
      throw Exception('No connectivity available');
    }

    try {
      final events =
          await _firestoreService.getMonthEvents(userId, monthStart);
      await _dbHelper.cacheEvents(events);
    } catch (e) {
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
  }
}
