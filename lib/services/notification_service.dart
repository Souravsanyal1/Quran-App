import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // 1. Request permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    _logger.i('Notification permission status: ${settings.authorizationStatus}');

    // 2. Initialize local notifications for foreground alerts
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification click when app is open
      },
    );

    // 3. Create Android notification channel
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Handle foreground messages
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

    // 5. Get FCM Token
    try {
      final token = await _fcm.getToken();
      _logger.i('FCM Token: $token');
    } catch (e) {
      _logger.e('Error getting FCM token: $e');
    }

    _initialized = true;
  }

  Future<void> toggleFCM(bool enabled) async {
    if (enabled) {
      await _fcm.subscribeToTopic('all');
      await _fcm.subscribeToTopic('daily_hadith');
    } else {
      await _fcm.unsubscribeFromTopic('all');
      await _fcm.unsubscribeFromTopic('daily_hadith');
    }
  }
}
