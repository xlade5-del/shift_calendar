import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

/// Provider for NotificationService singleton
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for FCM token
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return await notificationService.getToken();
});
