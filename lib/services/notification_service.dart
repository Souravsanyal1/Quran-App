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
import 'package:shared_preferences/shared_preferences.dart';

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

    // Notification IDs — at prayer time
    final Map<String, int> ids = {
      'Fajr': 1001,
      'Dhuhr': 1002,
      'Asr': 1003,
      'Maghrib': 1004,
      'Isha': 1005,
    };

    // Notification IDs — 30-min reminder
    final Map<String, int> reminderIds = {
      'Fajr': 2001,
      'Dhuhr': 2002,
      'Asr': 2003,
      'Maghrib': 2004,
      'Isha': 2005,
    };

    // Bengali prayer names in possessive form (e.g. "ফজরের")
    final Map<String, String> namesBnPossessive = {
      'Fajr': 'ফজরের',
      'Dhuhr': 'যোহরের',
      'Asr': 'আসরের',
      'Maghrib': 'মাগরিবের',
      'Isha': 'ইশার',
    };

    final settings = Get.find<SettingsController>();
    // Read language live so rescheduling always picks up the latest setting
    final bn = settings.language.value == 'bn';
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    // Check if exact alarms are permitted (Android 12+ / API 31+).
    // Fall back to inexact scheduling if the permission is not granted.
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    bool canUseExactAlarms = true;
    try {
      final permitted = await androidPlugin?.canScheduleExactNotifications();
      canUseExactAlarms = permitted ?? true;
    } catch (_) {
      canUseExactAlarms = false;
    }

    final scheduleMode = canUseExactAlarms
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    if (!canUseExactAlarms) {
      _logger.w(
          'Exact alarms not permitted — falling back to inexact scheduling. '
          'Notifications may arrive a few minutes late.');
    }

    const notifDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'azan_channel',
        'Azan Notifications',
        channelDescription:
            'This channel is used for prayer time (Azan) notifications.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    for (var k in keys) {
      try {
        if (timings[k] == null) continue;

        // Check if individual prayer notification is enabled
        final bool isPrayerEnabled =
            prefs.getBool('azan_notification_$k') ?? true;
        if (!isPrayerEnabled) {
          _logger.i('Notification for $k is disabled, skipping');
          continue;
        }

        final cleanTime = timings[k].toString().split(' ')[0];
        final timeParts = cleanTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        var prayerTime = DateTime(now.year, now.month, now.day, hour, minute);

        // If the prayer time has already passed today, schedule for tomorrow
        if (prayerTime.isBefore(now)) {
          prayerTime = prayerTime.add(const Duration(days: 1));
        }

        final tzPrayerTime = tz.TZDateTime.from(prayerTime, tz.local);

        // ── 1. At-prayer-time notification ────────────────────────────────
        final title = bn
            ? '${namesBnPossessive[k]} নামাজের সময় শুরু'
            : '$k prayer time has started';
        final body = bn
            ? 'আযান হচ্ছে, এখনই নামাজের প্রস্তুতি নিন।'
            : 'The adhan is called. Prepare yourself for prayer.';

        await _localNotifications.zonedSchedule(
          id: ids[k]!,
          title: title,
          body: body,
          scheduledDate: tzPrayerTime,
          notificationDetails: notifDetails,
          androidScheduleMode: scheduleMode,
        );
        _logger.i(
            'Scheduled Azan for $k at $tzPrayerTime (exact: $canUseExactAlarms)');

        // ── 2. 30-minute reminder notification ────────────────────────────
        final reminderTime = prayerTime.subtract(const Duration(minutes: 30));

        // Only schedule the reminder if it's still in the future
        if (reminderTime.isAfter(now)) {
          final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

          final reminderTitle = bn
              ? '${namesBnPossessive[k]} নামাজ ৩০ মিনিট পরে'
              : '$k prayer in 30 minutes';
          final reminderBody = bn
              ? 'আর মাত্র ৩০ মিনিট বাকি, ওজু করুন এবং প্রস্তুত হন।'
              : 'Only 30 minutes left. Perform wudu and get ready.';

          await _localNotifications.zonedSchedule(
            id: reminderIds[k]!,
            title: reminderTitle,
            body: reminderBody,
            scheduledDate: tzReminderTime,
            notificationDetails: notifDetails,
            androidScheduleMode: scheduleMode,
          );
          _logger.i('Scheduled 30-min reminder for $k at $tzReminderTime');
        } else {
          _logger.i(
              '30-min reminder for $k skipped (reminder time already passed)');
        }
      } catch (e) {
        _logger.e('Error scheduling Azan for $k: $e');
      }
    }
  }

  /// Cancels all scheduled Azan and reminder notifications.
  Future<void> cancelAzanNotifications() async {
    // At-prayer-time IDs: 1001-1005
    // 30-minute reminder IDs: 2001-2005
    final List<int> ids = [1001, 1002, 1003, 1004, 1005,
                           2001, 2002, 2003, 2004, 2005];
    for (var id in ids) {
      await _localNotifications.cancel(id: id);
    }
    _logger.i('Cancelled all Azan and reminder notifications');
  }

  /// Fires an immediate test notification to verify the notification pipeline.
  Future<void> showTestNotification() async {
    try {
      final bool bn = Get.find<SettingsController>().language.value == 'bn';
      final String title =
          bn ? 'ফজরের নামাজের সময় শুরু' : 'Fajr prayer time has started';
      final String body = bn
          ? 'আযান হচ্ছে, এখনই নামাজের প্রস্তুতি নিন।'
          : 'The adhan is called. Prepare yourself for prayer.';

      await _localNotifications.show(
        id: 9999,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'azan_channel',
            'Azan Notifications',
            channelDescription:
                'This channel is used for prayer time (Azan) notifications.',
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
      );
      _logger.i('Test notification sent (bn: $bn)');
    } catch (e) {
      _logger.e('Error sending test notification: $e');
    }
  }
}

