import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
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
      // Initialize Timezones
      try {
        tz.initializeTimeZones();
        // flutter_timezone may return a TimezoneInfo object in v5+; use toString()
        final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).toString();
        try {
          tz.setLocalLocation(tz.getLocation(timeZoneName));
          _logger.i('Timezone initialized to: $timeZoneName');
        } catch (_) {
          tz.setLocalLocation(tz.UTC);
        }
      } catch (e) {
        _logger.e('Error initializing timezone, fallback to UTC: $e');
        tz.setLocalLocation(tz.UTC);
      }

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

      // Create separate Android channel for Azan notifications
      const azanChannel = AndroidNotificationChannel(
        'azan_channel',
        'Azan Notifications',
        description: 'This channel is used for prayer time (Azan) notifications.',
        importance: Importance.max,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(azanChannel);

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

  /// Schedules daily local notifications for the 5 prayers.
  Future<void> scheduleAzanNotifications(Map<String, dynamic> timings) async {
    await cancelAzanNotifications();

    final keys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final Map<String, int> ids = {
      'Fajr': 1001,
      'Dhuhr': 1002,
      'Asr': 1003,
      'Maghrib': 1004,
      'Isha': 1005,
    };

    final Map<String, String> namesBn = {
      'Fajr': 'ফজর',
      'Dhuhr': 'যোহর',
      'Asr': 'আসর',
      'Maghrib': 'মাগরিব',
      'Isha': 'ইশা',
    };

    final settings = Get.find<SettingsController>();
    final bn = settings.isBangla;
    final now = DateTime.now();

    for (var k in keys) {
      try {
        if (timings[k] == null) continue;
        final cleanTime = timings[k].toString().split(' ')[0];
        final timeParts = cleanTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

        // If the prayer time has already passed today, schedule it for tomorrow
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

        final title = bn ? '${namesBn[k]} নামাজের সময়' : 'Time for $k Prayer';
        final body = bn
            ? 'হাইয়া আলাস-সালাহ, নামাজের সময় হয়েছে।'
            : "Hayya 'alas-Salah, it is time for prayer.";

        await _localNotifications.zonedSchedule(
          id: ids[k]!,
          title: title,
          body: body,
          scheduledDate: tzScheduledDate,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'azan_channel',
              'Azan Notifications',
              channelDescription: 'This channel is used for prayer time (Azan) notifications.',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        _logger.i('Scheduled Azan for $k at $tzScheduledDate');
      } catch (e) {
        _logger.e('Error scheduling Azan for $k: $e');
      }
    }
  }

  /// Cancels all scheduled Azan notifications.
  Future<void> cancelAzanNotifications() async {
    final List<int> ids = [1001, 1002, 1003, 1004, 1005];
    for (var id in ids) {
      await _localNotifications.cancel(id: id);
    }
    _logger.i('Cancelled all Azan notifications');
  }
}
