import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

  /// Whether [init] has completed successfully.
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize Timezones
      try {
        tz.initializeTimeZones();
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

      // 1. Initialize local notifications
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          Get.toNamed('/notifications');
        },
      );

      // 2. Create Android notification channels
      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      const azanChannel = AndroidNotificationChannel(
        'azan_channel',
        'Azan Notifications',
        description: 'Prayer time (Azan) notifications.',
        importance: Importance.max,
        playSound: true,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(azanChannel);

      const duaChannel = AndroidNotificationChannel(
        'dua_channel',
        'Daily Dua Reminder',
        description: 'Daily dua reminder notifications.',
        importance: Importance.high,
        playSound: true,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(duaChannel);

      // 3. Request permissions
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          _logger.i('Requesting notification permission...');
          await Permission.notification.request();
        }
      }
      await _requestExactAlarmPermission();

      // 4. Handle foreground FCM messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final notification = message.notification;
        final data = message.data;
        final String? imageUrl = data['imageUrl'] ?? data['image'];

        if (notification != null) {
          BigPictureStyleInformation? bigPictureStyleInformation;
          
          if (imageUrl != null && imageUrl.isNotEmpty) {
            final String filePath = await _downloadAndSaveFile(imageUrl, 'notification_img');
            bigPictureStyleInformation = BigPictureStyleInformation(
              FilePathAndroidBitmap(filePath),
              largeIcon: FilePathAndroidBitmap(filePath),
              contentTitle: notification.title,
              summaryText: notification.body,
            );
          }

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
                styleInformation: bigPictureStyleInformation,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
          );
          _storeNotification(
            title: notification.title ?? 'New Notification',
            body: notification.body ?? '',
            imageUrl: imageUrl,
            type: _detectType(message.data),
          );
        }
      });

      // 5. Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          _storeNotification(
            title: notification.title ?? 'New Notification',
            body: notification.body ?? '',
            imageUrl: message.data['imageUrl'] ?? message.data['image'],
            type: _detectType(message.data),
          );
          Get.toNamed('/notifications');
        }
      });

      // 6. Run FCM init in background
      _initFCMInBackground();

      _initialized = true;
    } catch (e) {
      _logger.e('Error during local notification init: $e');
    }
  }

  /// Request SCHEDULE_EXACT_ALARM permission on Android 12+ (API 31+)
  Future<void> _requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;
    try {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool canSchedule = await androidPlugin?.canScheduleExactNotifications() ?? true;
      if (!canSchedule) {
        _logger.w('Exact alarms not permitted — requesting via system settings');
        await androidPlugin?.requestExactAlarmsPermission();
      }
    } catch (e) {
      _logger.e('Error requesting exact alarm permission: $e');
    }
  }

  /// Request battery optimization exemption so background notifications are reliable
  Future<void> requestBatteryOptimization() async {
    if (!Platform.isAndroid) return;
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
        _logger.i('Battery optimization exemption requested');
      }
    } catch (e) {
      _logger.e('Error requesting battery optimization: $e');
    }
  }

  /// Request notifications permission at runtime (especially Android 13+)
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        return result.isGranted;
      }
      return true;
    } else if (Platform.isIOS) {
      final bool? granted = await _localNotifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  String _detectType(Map<String, dynamic> data) {
    if (data.containsKey('prayer')) return 'prayer';
    if (data.containsKey('quran')) return 'quran';
    return 'fcm';
  }

  void _storeNotification({
    required String title,
    required String body,
    String? imageUrl,
    String type = 'fcm',
  }) {
    try {
      final controller = Get.find<NotificationsController>();
      controller.addNotification(AppNotification(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        imageUrl: imageUrl,
        receivedAt: DateTime.now(),
        type: type,
      ));
    } catch (_) {}
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> _initFCMInBackground() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _logger.i('Notification permission status: ${settings.authorizationStatus}');

      final token = await _fcm.getToken();
      _logger.i('FCM Token: $token');

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
      } else {
        await _fcm.unsubscribeFromTopic('all');
      }
    } catch (e) {
      _logger.e('Error toggling FCM subscriptions: $e');
    }
  }

  // ── Prayer Azan Notifications ─────────────────────────────────────────────

  /// Schedules daily local notifications for the 5 prayers (single day fallback).
  Future<void> scheduleAzanNotifications(Map<String, dynamic> timings) async {
    await scheduleWeeklyAzanNotifications([
      {
        'date': DateTime.now(),
        'timings': timings,
      }
    ]);
  }

  /// Schedules weekly local notifications for the 5 prayers for the next 7 days.
  Future<void> scheduleWeeklyAzanNotifications(List<Map<String, dynamic>> weeklyTimings) async {
    if (!_initialized) {
      _logger.w('NotificationService not yet initialized — skipping azan scheduling. Will be rescheduled after init.');
      return;
    }
    await cancelAzanNotifications();

    final keys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    final Map<String, int> baseIds = {
      'Fajr': 1001,
      'Dhuhr': 1002,
      'Asr': 1003,
      'Maghrib': 1004,
      'Isha': 1005,
    };

    final Map<String, int> baseReminderIds = {
      'Fajr': 2001,
      'Dhuhr': 2002,
      'Asr': 2003,
      'Maghrib': 2004,
      'Isha': 2005,
    };

    // Bengali prayer names
    final Map<String, String> namesBn = {
      'Fajr': 'ফজর',
      'Dhuhr': 'যোহর',
      'Asr': 'আসর',
      'Maghrib': 'মাগরিব',
      'Isha': 'ইশা',
    };

    final Map<String, String> namesBnPossessive = {
      'Fajr': 'ফজরের',
      'Dhuhr': 'যোহরের',
      'Asr': 'আসরের',
      'Maghrib': 'মাগরিবের',
      'Isha': 'ইশার',
    };

    SettingsController? settings;
    bool bn = true; // Default Bangla
    try {
      settings = Get.find<SettingsController>();
      bn = settings.language.value == 'bn';
    } catch (_) {}

    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
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

    const notifDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'azan_channel',
        'Azan Notifications',
        channelDescription: 'Prayer time (Azan) notifications.',
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

    for (int dayOffset = 0; dayOffset < weeklyTimings.length; dayOffset++) {
      final dayData = weeklyTimings[dayOffset];
      final DateTime date = dayData['date'] as DateTime;
      final Map<String, dynamic> timings = dayData['timings'] as Map<String, dynamic>;

      for (var k in keys) {
        try {
          if (timings[k] == null) continue;

          final bool isPrayerEnabled = prefs.getBool('azan_notification_$k') ?? true;
          if (!isPrayerEnabled) continue;

          final cleanTime = timings[k].toString().split(' ')[0];
          final timeParts = cleanTime.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          var prayerTime = DateTime(date.year, date.month, date.day, hour, minute);
          
          // If scheduling for today and the time has already passed, skip it
          if (dayOffset == 0 && prayerTime.isBefore(now)) {
            continue;
          }

          final tzPrayerTime = tz.TZDateTime.from(prayerTime, tz.local);

          // Unique IDs for each day and prayer
          final int notifId = baseIds[k]! + (dayOffset * 10);
          final int reminderId = baseReminderIds[k]! + (dayOffset * 10);

          // ── At-prayer-time notification ──────────────────────────────────
          final title = bn
              ? '🕌 ${namesBn[k]} নামাজের সময় হয়েছে'
              : '🕌 $k prayer time has started';
          final body = bn
              ? 'ওজু করে রেডি হোন এবং এখনই ${namesBnPossessive[k]} নামাজ আদায় করুন।'
              : 'Perform wudu and offer $k prayer now. Do not delay!';

          await _localNotifications.zonedSchedule(
            id: notifId,
            title: title,
            body: body,
            scheduledDate: tzPrayerTime,
            notificationDetails: notifDetails,
            androidScheduleMode: scheduleMode,
          );
          _logger.i('Scheduled Azan for $k (Day $dayOffset) at $tzPrayerTime (ID: $notifId)');

          // ── 30-minute reminder ───────────────────────────────────────────
          final reminderTime = prayerTime.subtract(const Duration(minutes: 30));
          if (reminderTime.isAfter(now)) {
            final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

            final reminderTitle = bn
                ? '⏰ ${namesBn[k]} নামাজ ৩০ মিনিট পরে'
                : '⏰ $k prayer in 30 minutes';
            final reminderBody = bn
                ? 'আর মাত্র ৩০ মিনিট বাকি! ওজু করুন এবং প্রস্তুত হন।'
                : 'Only 30 minutes left! Perform wudu and get ready.';

            await _localNotifications.zonedSchedule(
              id: reminderId,
              title: reminderTitle,
              body: reminderBody,
              scheduledDate: tzReminderTime,
              notificationDetails: notifDetails,
              androidScheduleMode: scheduleMode,
            );
            _logger.i('Scheduled Reminder for $k (Day $dayOffset) at $tzReminderTime (ID: $reminderId)');
          }
        } catch (e) {
          _logger.e('Error scheduling Azan/Reminder for $k on Day $dayOffset: $e');
        }
      }
    }
  }

  /// Cancels all scheduled Azan and reminder notifications.
  Future<void> cancelAzanNotifications() async {
    for (int i = 0; i < 7; i++) {
      final List<int> ids = [
        1001 + (i * 10), 1002 + (i * 10), 1003 + (i * 10), 1004 + (i * 10), 1005 + (i * 10),
        2001 + (i * 10), 2002 + (i * 10), 2003 + (i * 10), 2004 + (i * 10), 2005 + (i * 10),
      ];
      for (var id in ids) {
        await _localNotifications.cancel(id: id);
      }
    }
    _logger.i('Cancelled all scheduled Azan and reminder notifications');
  }

  // ── Daily Dua Reminder ────────────────────────────────────────────────────

  static const int _duaNotifIdBase = 3001;

  /// Schedules daily rotating dua reminders for the next 7 days.
  Future<void> scheduleDuaReminder(TimeOfDay time) async {
    await cancelDuaReminder();

    bool bn = true;
    try {
      final settings = Get.find<SettingsController>();
      bn = settings.language.value == 'bn';
    } catch (_) {}

    final now = DateTime.now();

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    bool canUseExactAlarms = true;
    try {
      final permitted = await androidPlugin?.canScheduleExactNotifications();
      canUseExactAlarms = permitted ?? true;
    } catch (_) {
      canUseExactAlarms = false;
    }

    // Daily duas list
    final List<String> duasBn = [
      'সকালের দোয়া: "اللَّهُمَّ بِكَ أَصْبَحْنَا" — হে আল্লাহ, তোমার মাধ্যমে আমরা সকালে উপনীত হলাম।',
      'রিজিকের দোয়া: "اللَّهُمَّ ارْزُقْنِي رِزْقًا حَلَالًا" — হে আল্লাহ, আমাকে হালাল রিজিক দাও।',
      'ক্ষমার দোয়া: "أَسْتَغْفِرُ اللَّهَ" — আমি আল্লাহর কাছে ক্ষমা চাই।',
      'শান্তির দোয়া: "اللَّهُمَّ أَنْتَ السَّلَامُ" — হে আল্লাহ, তুমিই শান্তি।',
      'হেদায়েতের দোয়া: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً" — আমাদের দুনিয়া ও আখিরাতে কল্যাণ দাও।',
    ];

    final List<String> duasEn = [
      'Morning Dua: "اللَّهُمَّ بِكَ أَصْبَحْنَا" — O Allah, by You we reach the morning.',
      'Rizq Dua: "اللَّهُمَّ ارْزُقْنِي رِزْقًا حَلَالًا" — O Allah, grant me halal provision.',
      'Forgiveness: "أَسْتَغْفِرُ اللَّهَ" — I seek forgiveness from Allah.',
      'Peace Dua: "اللَّهُمَّ أَنْتَ السَّلَامُ" — O Allah, You are Peace.',
      'Guidance: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً" — Grant us good in this world and hereafter.',
    ];

    for (int i = 0; i < 7; i++) {
      final targetDate = now.add(Duration(days: i));
      var scheduledDate = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day,
        time.hour,
        time.minute,
      );

      // If scheduled time is in the past for today, schedule it for the same time next week (day 7)
      if (i == 0 && scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);
      final int idx = scheduledDate.day % duasBn.length;
      final int notifId = _duaNotifIdBase + i;

      await _localNotifications.zonedSchedule(
        id: notifId,
        title: bn ? '📿 দৈনিক দোয়ার স্মরণ' : '📿 Daily Dua Reminder',
        body: bn ? duasBn[idx] : duasEn[idx],
        scheduledDate: tzScheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'dua_channel',
            'Daily Dua Reminder',
            channelDescription: 'Daily dua reminder notifications.',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: canUseExactAlarms
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
    _logger.i('Scheduled 7-day daily rotating dua reminders at ${time.hour}:${time.minute}');
  }

  /// Cancels all scheduled daily dua reminders.
  Future<void> cancelDuaReminder() async {
    for (int i = 0; i < 7; i++) {
      await _localNotifications.cancel(id: _duaNotifIdBase + i);
    }
    _logger.i('Cancelled all scheduled dua reminders');
  }
}
