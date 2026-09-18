import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler required by Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('FCM Background message received: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // High importance notification channel ID with sound enabled
  static const String _channelId = 'kalyan_alerts_channel';
  static const String _channelName = 'Kalyan Alerts & Results';
  static const String _channelDescription =
      'High priority notifications for market results, sessions, and game alerts with sound.';

  // Android Notification Channel with sound & vibration
  static final AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDescription,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
  );

  bool _isInitialized = false;
  String? _fcmToken;

  /// Returns the current device FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Push Notifications and Flutter Local Notifications
  Future<void> initialize({
    Function(String? payload)? onNotificationTapped,
  }) async {
    if (_isInitialized) return;

    // 1. Initialize Local Notifications Plugin
    await _initLocalNotifications(onNotificationTapped);

    // 2. Initialize Firebase Messaging with Graceful Fallback
    await _initFirebaseMessaging(onNotificationTapped);

    _isInitialized = true;
  }

  /// Setup local notifications with high-priority sound channel
  Future<void> _initLocalNotifications(
    Function(String? payload)? onNotificationTapped,
  ) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked with payload: ${response.payload}');
        onNotificationTapped?.call(response.payload);
      },
    );

    // Create Notification Channel for Android
    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(_androidChannel);
      // Request Android 13+ POST_NOTIFICATIONS permission
      await androidImplementation.requestNotificationsPermission();
    }
  }

  /// Setup Firebase Messaging, permission requests, and listeners
  Future<void> _initFirebaseMessaging(
    Function(String? payload)? onNotificationTapped,
  ) async {
    try {
      // Ensure Firebase Core is initialized
      await Firebase.initializeApp();

      final FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Request notification permissions (iOS & Android 13+)
      final NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
          'Firebase Messaging permission status: ${settings.authorizationStatus}');

      // Enable Foreground Presentation for Sound and Alert
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Retrieve and log the FCM Device Token
      try {
        _fcmToken = await messaging.getToken();
        debugPrint('====== FCM DEVICE TOKEN ======');
        debugPrint(_fcmToken ?? 'Unable to retrieve FCM token');
        debugPrint('==============================');
      } catch (e) {
        debugPrint('Could not fetch FCM token: $e');
      }

      // Handle token refreshes
      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token refreshed: $newToken');
      });

      // --- FOREGROUND LISTENER ---
      // When notification arrives while the app is OPEN, display it using Local Notifications with sound
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground message received: ${message.messageId}');

        final notification = message.notification;
        final String title = notification?.title ??
            message.data['title'] ??
            'Market Alert';
        final String body = notification?.body ??
            message.data['body'] ??
            'New result or session update is available.';
        final String payload = message.data['route'] ??
            message.data['payload'] ??
            message.messageId ??
            '';

        // Show local notification with sound & vibration
        showNotification(
          title: title,
          body: body,
          payload: payload,
        );
      });

      // --- BACKGROUND/TERMINATED TAP LISTENERS ---
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM Notification tapped from background: ${message.data}');
        final payload = message.data['route'] ?? message.data['payload'];
        onNotificationTapped?.call(payload);
      });

      // Check if app was opened directly from a terminated state notification
      final RemoteMessage? initialMessage =
          await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
            'FCM Notification opened app from terminated state: ${initialMessage.data}');
        final payload =
            initialMessage.data['route'] ?? initialMessage.data['payload'];
        onNotificationTapped?.call(payload);
      }
    } catch (e) {
      debugPrint(
          'Firebase Messaging initialization info (safe fallback): $e');
    }
  }

  /// Show a high-priority local notification with sound and vibration
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    final notificationId = id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Kalyan Live',
      ),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  /// Subscribe to a specific Firebase Messaging topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      debugPrint('Subscribed to FCM topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a Firebase Messaging topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from FCM topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }
}
