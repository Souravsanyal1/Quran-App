import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      // 1. Initialize Timezones (Mobile only)
      if (!kIsWeb) {
        try {
          tz.initializeTimeZones();
          final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).toString();
          try {
            tz.setLocalLocation(tz.getLocation(timeZoneName));
          } catch (_) {
            tz.setLocalLocation(tz.UTC);
          }
        } catch (e) {
          tz.setLocalLocation(tz.UTC);
        }

        // 2. Initialize local notifications
        const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
        const iosInit = DarwinInitializationSettings();
        const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

        await _localNotifications.initialize(
          initSettings,
          onDidReceiveNotificationResponse: (response) {
            Get.toNamed('/notifications');
          },
        );

        // 3. Create Android notification channels
        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
            
        await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
          'high_importance_channel',
          'Announcements',
          importance: Importance.high,
        ));
        
        await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
          'azan_channel',
          'Azan Notifications',
          importance: Importance.max,
          playSound: true,
        ));

        await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
          'dua_channel',
          'Daily Dua Reminder',
          importance: Importance.high,
          playSound: true,
        ));

        // 4. Request permissions
        if (Platform.isAndroid) {
          final status = await Permission.notification.status;
          if (!status.isGranted) {
            await Permission.notification.request();
          }
        }
        await _requestExactAlarmPermission();
      }

      // 5. Handle foreground FCM messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final notification = message.notification;
        final data = message.data;
        final String? imageUrl = data['imageUrl'] ?? data['image'];

        if (notification != null) {
          if (!kIsWeb) {
            BigPictureStyleInformation? bigPicture;
            if (imageUrl != null && imageUrl.isNotEmpty) {
              final String filePath = await _downloadAndSaveFile(imageUrl, 'notification_img');
              bigPicture = BigPictureStyleInformation(
                FilePathAndroidBitmap(filePath),
                largeIcon: FilePathAndroidBitmap(filePath),
                contentTitle: notification.title,
                summaryText: notification.body,
              );
            }

            await _localNotifications.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  'high_importance_channel',
                  'Important',
                  icon: '@mipmap/ic_launcher',
                  styleInformation: bigPicture,
                ),
                iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
              ),
            );
          }
          
          _storeNotification(
            title: notification.title ?? 'New Notification',
            body: notification.body ?? '',
            imageUrl: imageUrl,
            type: _detectType(message.data),
          );
        }
      });

      // 6. Handle background message tap
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

      // 7. Run FCM init in background
      _initFCMInBackground();

      // 8. Real-time Firestore Broadcast Listener (Workaround for Cloud Functions)
      _listenToFirestoreBroadcasts();

      _initialized = true;
    } catch (e) {
      _logger.e('Error during local notification init: $e');
    }
  }

  void _listenToFirestoreBroadcasts() {
    if (kIsWeb) return; 
    
    final startTime = DateTime.now();
    FirebaseFirestore.instance
        .collection('broadcast_notifications')
        .where('sentAt', isGreaterThan: startTime)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _showLocalNotificationFromData(data);
            _storeNotification(
              title: data['title'] ?? 'Announcement',
              body: data['body'] ?? '',
              imageUrl: data['imageUrl'],
              type: 'fcm',
            );
          }
        }
      }
    });
  }

  Future<void> _showLocalNotificationFromData(Map<String, dynamic> data) async {
    if (kIsWeb) return;

    final String title = data['title'] ?? 'New Notification';
    final String body = data['body'] ?? '';
    final String? imageUrl = data['imageUrl'];

    BigPictureStyleInformation? bigPicture;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final String filePath = await _downloadAndSaveFile(imageUrl, 'broadcast_img_${DateTime.now().millisecond}');
        bigPicture = BigPictureStyleInformation(
          FilePathAndroidBitmap(filePath),
          largeIcon: FilePathAndroidBitmap(filePath),
        );
      } catch (e) {
        debugPrint('Error downloading broadcast image: $e');
      }
    }

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Announcements',
          channelDescription: 'General app announcements',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: bigPicture,
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
    );
  }

  Future<void> _requestExactAlarmPermission() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool canSchedule = await androidPlugin?.canScheduleExactNotifications() ?? true;
      if (!canSchedule) {
        await androidPlugin?.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('Error requesting exact alarm permission: $e');
    }
  }

  Future<void> requestBatteryOptimization() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (e) {
      debugPrint('Error requesting battery optimization: $e');
    }
  }

  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return true;
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
    if (kIsWeb) return '';
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> _initFCMInBackground() async {
    try {
      final settings = await _fcm.requestPermission(alert: true, badge: true, sound: true);
      final token = await _fcm.getToken();
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

  Future<void> scheduleAzanNotifications(Map<String, dynamic> timings) async {
    await scheduleWeeklyAzanNotifications([
      {
        'date': DateTime.now(),
        'timings': timings,
      }
    ]);
  }

  Future<void> scheduleWeeklyAzanNotifications(List<Map<String, dynamic>> weeklyTimings) async {
    if (kIsWeb || !_initialized) return;
    await cancelAzanNotifications();

    final keys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final Map<String, int> baseIds = {'Fajr': 1001, 'Dhuhr': 1002, 'Asr': 1003, 'Maghrib': 1004, 'Isha': 1005};
    final Map<String, int> baseReminderIds = {'Fajr': 2001, 'Dhuhr': 2002, 'Asr': 2003, 'Maghrib': 2004, 'Isha': 2005};

    final Map<String, String> namesBn = {'Fajr': 'ফজর', 'Dhuhr': 'যোহর', 'Asr': 'আসর', 'Maghrib': 'মাগরিব', 'Isha': 'ইশা'};
    final Map<String, String> namesBnPossessive = {'Fajr': 'ফজরের', 'Dhuhr': 'যোহরের', 'Asr': 'আসরের', 'Maghrib': 'মাগরিবের', 'Isha': 'ইশার'};

    bool bn = true;
    try { bn = Get.find<SettingsController>().language.value == 'bn'; } catch (_) {}

    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    bool canUseExactAlarms = await androidPlugin?.canScheduleExactNotifications() ?? true;
    final scheduleMode = canUseExactAlarms ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;

    const notifDetails = NotificationDetails(
      android: AndroidNotificationDetails('azan_channel', 'Azan Notifications', importance: Importance.max, priority: Priority.high, playSound: true),
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );

    for (int dayOffset = 0; dayOffset < weeklyTimings.length; dayOffset++) {
      final dayData = weeklyTimings[dayOffset];
      final DateTime date = dayData['date'] as DateTime;
      final Map<String, dynamic> timings = dayData['timings'] as Map<String, dynamic>;

      for (var k in keys) {
        try {
          if (timings[k] == null) continue;
          if (!(prefs.getBool('azan_notification_$k') ?? true)) continue;

          final cleanTime = timings[k].toString().split(' ')[0];
          final timeParts = cleanTime.split(':');
          var prayerTime = DateTime(date.year, date.month, date.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
          
          if (dayOffset == 0 && prayerTime.isBefore(now)) continue;

          final tzPrayerTime = tz.TZDateTime.from(prayerTime, tz.local);
          final int notifId = baseIds[k]! + (dayOffset * 10);
          final int reminderId = baseReminderIds[k]! + (dayOffset * 10);

          await _localNotifications.zonedSchedule(
            notifId,
            bn ? '🕌 ${namesBn[k]} নামাজের সময় হয়েছে' : '🕌 $k prayer time',
            bn ? 'ওজু করে রেডি হোন এবং এখনই ${namesBnPossessive[k]} নামাজ আদায় করুন।' : 'Perform wudu and offer $k prayer now.',
            tzPrayerTime,
            notifDetails,
            androidScheduleMode: scheduleMode,
          );

          final reminderTime = prayerTime.subtract(const Duration(minutes: 30));
          if (reminderTime.isAfter(now)) {
            await _localNotifications.zonedSchedule(
              reminderId,
              bn ? '⏰ ${namesBn[k]} নামাজ ৩০ মিনিট পরে' : '⏰ $k prayer in 30m',
              bn ? 'আর মাত্র ৩০ মিনিট বাকি! প্রস্তুত হন।' : 'Only 30 minutes left! Get ready.',
              tz.TZDateTime.from(reminderTime, tz.local),
              notifDetails,
              androidScheduleMode: scheduleMode,
            );
          }
        } catch (e) { _logger.e('Azan Error: $e'); }
      }
    }
  }

  Future<void> cancelAzanNotifications() async {
    if (kIsWeb) return;
    for (int i = 0; i < 7; i++) {
      final ids = [1001, 1002, 1003, 1004, 1005, 2001, 2002, 2003, 2004, 2005].map((id) => id + (i * 10));
      for (var id in ids) { await _localNotifications.cancel(id); }
    }
  }

  static const int _duaNotifIdBase = 3001;

  Future<void> scheduleDuaReminder(TimeOfDay time) async {
    if (kIsWeb) return;
    await cancelDuaReminder();
    bool bn = Get.find<SettingsController>().language.value == 'bn';
    final now = DateTime.now();

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    bool canUseExactAlarms = await androidPlugin?.canScheduleExactNotifications() ?? true;

    final List<String> duasBn = ['সকালের দোয়া', 'রিজিকের দোয়া', 'ক্ষমার দোয়া', 'শান্তির দোয়া', 'হেদায়েতের দোয়া'];
    final List<String> duasEn = ['Morning Dua', 'Rizq Dua', 'Forgiveness', 'Peace Dua', 'Guidance'];

    for (int i = 0; i < 7; i++) {
      final targetDate = now.add(Duration(days: i));
      var scheduledDate = DateTime(targetDate.year, targetDate.month, targetDate.day, time.hour, time.minute);
      if (i == 0 && scheduledDate.isBefore(now)) scheduledDate = scheduledDate.add(const Duration(days: 7));

      await _localNotifications.zonedSchedule(
        _duaNotifIdBase + i,
        bn ? '📿 দৈনিক দোয়ার স্মরণ' : '📿 Daily Dua Reminder',
        bn ? duasBn[scheduledDate.day % duasBn.length] : duasEn[scheduledDate.day % duasEn.length],
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(android: AndroidNotificationDetails('dua_channel', 'Dua Reminder', importance: Importance.high, playSound: true)),
        androidScheduleMode: canUseExactAlarms ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelDuaReminder() async {
    if (kIsWeb) return;
    for (int i = 0; i < 7; i++) { await _localNotifications.cancel(_duaNotifIdBase + i); }
  }
}
