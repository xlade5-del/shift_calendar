import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing push notifications via FCM/APNs
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'velloshift_high_importance', // id
    'VelloShift Notifications', // name
    description: 'This channel is used for important shift notifications.',
    importance: Importance.high,
  );

  /// Initialize FCM and local notifications
  Future<void> initialize() async {
    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('NotificationService: Permission granted: ${settings.authorizationStatus}');

    // Initialize local notifications for Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Configure FCM for foreground notifications on Android
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // Check if app was opened from a terminated state notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessageTap(initialMessage);
    }

    print('NotificationService: Initialized successfully');
  }

  /// Get FCM token for this device
  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print('NotificationService: FCM Token: $token');
      return token;
    } catch (e) {
      print('NotificationService: Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to Firestore for the current user
  Future<void> saveTokenToFirestore(String userId) async {
    final token = await getToken();
    if (token == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
      print('NotificationService: FCM token saved to Firestore');
    } catch (e) {
      print('NotificationService: Error saving token to Firestore: $e');
    }
  }

  /// Listen to FCM token refresh
  void listenToTokenRefresh(String userId) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('NotificationService: Token refreshed: $newToken');
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': newToken,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Check if current time is within quiet hours for a specific user
  Future<bool> _isQuietHours(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) return false;

      final settings = doc.data()?['notificationSettings'] as Map<String, dynamic>?;
      if (settings == null) return false;

      final quietHoursEnabled = settings['quietHoursEnabled'] ?? false;
      if (!quietHoursEnabled) return false;

      final startTimeStr = settings['quietHoursStart'] as String?;
      final endTimeStr = settings['quietHoursEnd'] as String?;

      if (startTimeStr == null || endTimeStr == null) return false;

      // Parse quiet hours times
      final startParts = startTimeStr.split(':');
      final endParts = endTimeStr.split(':');

      final now = DateTime.now();
      final currentMinutes = now.hour * 60 + now.minute;

      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      // Handle cases where quiet hours span midnight (e.g., 22:00 - 07:00)
      if (startMinutes > endMinutes) {
        // Quiet hours span midnight
        return currentMinutes >= startMinutes || currentMinutes < endMinutes;
      } else {
        // Quiet hours within same day
        return currentMinutes >= startMinutes && currentMinutes < endMinutes;
      }
    } catch (e) {
      print('NotificationService: Error checking quiet hours: $e');
      return false; // On error, don't suppress notifications
    }
  }

  /// Handle foreground messages (when app is open)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('NotificationService: Foreground message received');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    // Check if recipient has quiet hours enabled
    final userId = message.data['recipientId'];
    if (userId != null) {
      final inQuietHours = await _isQuietHours(userId);
      if (inQuietHours) {
        print('NotificationService: Suppressing notification during quiet hours');
        return; // Don't show notification during quiet hours
      }
    }

    // Show local notification
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: message.data['route'],
      );
    }
  }

  /// Handle notification tap from background/terminated state
  void _handleBackgroundMessageTap(RemoteMessage message) {
    print('NotificationService: Background notification tapped');
    print('Data: ${message.data}');

    // TODO: Navigate to specific screen based on message.data['route']
    // This will be implemented when we have navigation service
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('NotificationService: Local notification tapped');
    print('Payload: ${response.payload}');

    // TODO: Navigate to specific screen based on payload
  }

  /// Send notification to a specific user (via their FCM token)
  /// This would typically be called from a Cloud Function, not from the app
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    // This is a placeholder - actual implementation would be in Cloud Functions
    // Cloud Functions would:
    // 1. Get user's FCM token from Firestore
    // 2. Use Firebase Admin SDK to send notification
    // 3. Handle delivery and errors
    print('NotificationService: Would send notification to user $userId');
    print('Title: $title, Body: $body');
  }

  /// Show local notification (no FCM required)
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('BackgroundHandler: Handling background message');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');

  // Process the message
  // Note: Can't show UI here, but can update local database
}
