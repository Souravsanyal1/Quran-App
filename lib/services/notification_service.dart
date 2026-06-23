import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../modules/notifications/notification_model.dart';
import '../modules/notifications/notifications_controller.dart';
import '../modules/settings/settings_controller.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    try {
      // 1. Initialize local notifications for foreground alerts
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings =
          InitializationSettings(android: androidInit, iOS: iosInit);

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          // Navigate to notifications page when notification is tapped
          Get.toNamed('/notifications');
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
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 3. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          // Show system notification
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
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
          );

          // Also store in-app notification
          _storeNotification(
            title: notification.title ?? 'New Notification',
            body: notification.body ?? '',
            type: _detectType(message.data),
          );
        }
      });

      // 4. Handle background message tap (app was in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          _storeNotification(
            title: notification.title ?? 'New Notification',
            body: notification.body ?? '',
            type: _detectType(message.data),
          );
          Get.toNamed('/notifications');
        }
      });

      // 5. Run permission request and FCM token retrieval asynchronously
      _initFCMInBackground();

      _initialized = true;
    } catch (e) {
      _logger.e('Error during local notification init: $e');
    }
  }

  /// Detect notification type from FCM data payload
  String _detectType(Map<String, dynamic> data) {
    if (data.containsKey('prayer')) return 'prayer';
    if (data.containsKey('hadith')) return 'hadith';
    if (data.containsKey('quran')) return 'quran';
    return 'fcm';
  }

  /// Store a notification in the in-app store
  void _storeNotification({
    required String title,
    required String body,
    String type = 'fcm',
  }) {
    try {
      final controller = Get.find<NotificationsController>();
      controller.addNotification(AppNotification(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        receivedAt: DateTime.now(),
        type: type,
      ));
    } catch (_) {
      // Controller not yet registered — store once it's available
    }
  }

  Future<void> _initFCMInBackground() async {
    try {
      // 1. Request permission
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _logger.i(
          'Notification permission status: ${settings.authorizationStatus}');

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
