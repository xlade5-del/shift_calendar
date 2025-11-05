import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/offline_sync_service.dart';

/// Provider for offline sync service singleton
final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final service = OfflineSyncService();

  // Start monitoring connectivity
  service.startMonitoring();

  // Cleanup when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for sync status
final syncStatusProvider = StreamProvider<Map<String, dynamic>>((ref) async* {
  final syncService = ref.watch(offlineSyncServiceProvider);

  // Emit sync status every 5 seconds
  while (true) {
    await Future.delayed(const Duration(seconds: 5));
    final status = await syncService.getSyncStatus();
    yield status;
  }
});

/// Provider to check if device is online
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final syncService = ref.watch(offlineSyncServiceProvider);

  // Check connectivity every 3 seconds
  while (true) {
    final isOnline = await syncService.hasConnectivity();
    yield isOnline;
    await Future.delayed(const Duration(seconds: 3));
  }
});

/// Provider for pending sync count
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final syncService = ref.watch(offlineSyncServiceProvider);
  final status = await syncService.getSyncStatus();
  return status['pendingSync'] as int? ?? 0;
});

/// Provider for cached events count
final cachedEventsCountProvider = FutureProvider<int>((ref) async {
  final syncService = ref.watch(offlineSyncServiceProvider);
  final status = await syncService.getSyncStatus();
  return status['cachedEvents'] as int? ?? 0;
});
