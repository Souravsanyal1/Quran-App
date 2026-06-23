import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../modules/settings/settings_controller.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      // 1. Initialize local notifications for foreground alerts
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
      
      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          // Handle notification click when app is open
        },
      );

      // 2. Create Android notification channel
      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 3. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        final android = message.notification?.android;

        if (notification != null && android != null) {
          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      });

      // 4. Run permission request and FCM token retrieval asynchronously in background
      _initFCMInBackground();
      
      _initialized = true;
    } catch (e) {
      _logger.e('Error during local notification init: $e');
    }
  }

  Future<void> _initFCMInBackground() async {
    try {
      // 1. Request permission (does not block splash screen)
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _logger.i('Notification permission status: ${settings.authorizationStatus}');

      // 2. Get FCM Token
      final token = await _fcm.getToken();
      _logger.i('FCM Token: $token');

      // 3. Sync topic subscriptions based on user settings
      final settingsController = Get.find<SettingsController>();
      await toggleFCM(settingsController.notificationsEnabled.value);
    } catch (e) {
      _logger.e('Error during background FCM initialization: $e');
    }
  }

  Future<void> toggleFCM(bool enabled) async {
    try {
      if (enabled) {
        await _fcm.subscribeToTopic('all');
        await _fcm.subscribeToTopic('daily_hadith');
      } else {
        await _fcm.unsubscribeFromTopic('all');
        await _fcm.unsubscribeFromTopic('daily_hadith');
      }
    } catch (e) {
      _logger.e('Error toggling FCM subscriptions: $e');
    }
  }
}
