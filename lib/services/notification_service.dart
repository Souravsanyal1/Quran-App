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
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    try {
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

        const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
        const iosInit = DarwinInitializationSettings();
        const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

        // Cast to dynamic to avoid web compiler errors with positional arguments
        await (_localNotifications as dynamic).initialize(
          initSettings,
          onDidReceiveNotificationResponse: (response) {
            Get.toNamed('/notifications');
          },
        );

        final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel('high_importance_channel', 'Announcements', importance: Importance.high));
        await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel('azan_channel', 'Azan Notifications', importance: Importance.max, playSound: true));
        await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel('dua_channel', 'Daily Dua Reminder', importance: Importance.high, playSound: true));

        if (Platform.isAndroid) {
          final status = await Permission.notification.status;
          if (!status.isGranted) await Permission.notification.request();
        }
        await _requestExactAlarmPermission();
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final notification = message.notification;
        final data = message.data;
        final String? imageUrl = data['imageUrl'] ?? data['image'];

        if (notification != null) {
          if (!kIsWeb) {
            BigPictureStyleInformation? bigPicture;
            if (imageUrl != null && imageUrl.isNotEmpty) {
              try {
                final String filePath = await _downloadAndSaveFile(imageUrl, 'notification_img');
                bigPicture = BigPictureStyleInformation(FilePathAndroidBitmap(filePath), largeIcon: FilePathAndroidBitmap(filePath), contentTitle: notification.title, summaryText: notification.body);
              } catch (_) {}
            }

            await (_localNotifications as dynamic).show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails('high_importance_channel', 'Important', icon: '@mipmap/ic_launcher', styleInformation: bigPicture),
                iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
              ),
            );
          }
          
          _storeNotification(title: notification.title ?? 'New Notification', body: notification.body ?? '', imageUrl: imageUrl, type: _detectType(message.data));
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          _storeNotification(title: notification.title ?? 'New Notification', body: notification.body ?? '', imageUrl: message.data['imageUrl'] ?? message.data['image'], type: _detectType(message.data));
          Get.toNamed('/notifications');
        }
      });

      _initFCMInBackground();
      _listenToFirestoreBroadcasts();
      _initialized = true;
    } catch (e) {
      _logger.e('Notification Init Error: $e');
    }
  }

  void _listenToFirestoreBroadcasts() {
    if (kIsWeb) return; 
    final startTime = DateTime.now();
    FirebaseFirestore.instance.collection('broadcast_notifications').where('sentAt', isGreaterThan: startTime).snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _showLocalNotificationFromData(data);
            _storeNotification(title: data['title'] ?? 'Announcement', body: data['body'] ?? '', imageUrl: data['imageUrl'], type: 'fcm');
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
        bigPicture = BigPictureStyleInformation(FilePathAndroidBitmap(filePath), largeIcon: FilePathAndroidBitmap(filePath));
      } catch (_) {}
    }

    await (_localNotifications as dynamic).show(
      DateTime.now().millisecond,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails('high_importance_channel', 'Announcements', channelDescription: 'General app announcements', importance: Importance.high, priority: Priority.high, styleInformation: bigPicture),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
    );
  }

  Future<void> _requestExactAlarmPermission() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool canSchedule = await androidPlugin?.canScheduleExactNotifications() ?? true;
      if (!canSchedule) await androidPlugin?.requestExactAlarmsPermission();
    } catch (_) {}
  }

  Future<void> requestBatteryOptimization() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) await Permission.ignoreBatteryOptimizations.request();
    } catch (_) {}
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
      final bool? granted = await (_localNotifications as dynamic).resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  String _detectType(Map<String, dynamic> data) {
    if (data.containsKey('prayer')) return 'prayer';
    return 'fcm';
  }

  void _storeNotification({required String title, required String body, String? imageUrl, String type = 'fcm'}) {
    try {
      Get.find<NotificationsController>().addNotification(AppNotification(id: '${DateTime.now().millisecondsSinceEpoch}', title: title, body: body, imageUrl: imageUrl, receivedAt: DateTime.now(), type: type));
    } catch (_) {}
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    if (kIsWeb) return '';
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> _initFCMInBackground() async {
    try {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
      await toggleFCM(Get.find<SettingsController>().notificationsEnabled.value);
    } catch (_) {}
  }

  Future<void> toggleFCM(bool enabled) async {
    try {
      if (enabled) await _fcm.subscribeToTopic('all');
      else await _fcm.unsubscribeFromTopic('all');
    } catch (_) {}
  }

  Future<void> scheduleAzanNotifications(Map<String, dynamic> timings) async {
    await scheduleWeeklyAzanNotifications([{'date': DateTime.now(), 'timings': timings}]);
  }

  Future<void> scheduleWeeklyAzanNotifications(List<Map<String, dynamic>> weeklyTimings) async {
    if (kIsWeb || !_initialized) return;
    await cancelAzanNotifications();
    bool bn = Get.find<SettingsController>().language.value == 'bn';
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    bool canUseExactAlarms = await androidPlugin?.canScheduleExactNotifications() ?? true;
    final scheduleMode = canUseExactAlarms ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;

    const notifDetails = NotificationDetails(
      android: AndroidNotificationDetails('azan_channel', 'Azan Notifications', importance: Importance.max, priority: Priority.high, playSound: true),
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );

    for (int dayOffset = 0; dayOffset < weeklyTimings.length; dayOffset++) {
      final dayData = weeklyTimings[dayOffset];
      final Map<String, dynamic> timings = dayData['timings'] as Map<String, dynamic>;
      for (var k in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
        try {
          if (timings[k] == null || !(prefs.getBool('azan_notification_$k') ?? true)) continue;
          final timeParts = timings[k].toString().split(' ')[0].split(':');
          var pTime = DateTime((dayData['date'] as DateTime).year, (dayData['date'] as DateTime).month, (dayData['date'] as DateTime).day, int.parse(timeParts[0]), int.parse(timeParts[1]));
          if (dayOffset == 0 && pTime.isBefore(now)) continue;
          final tzTime = tz.TZDateTime.from(pTime, tz.local);
          await (_localNotifications as dynamic).zonedSchedule(1000 + dayOffset * 10 + k.length, bn ? '🕌 নামাজের সময়' : '🕌 Prayer Time', bn ? 'নামাজ আদায় করুন' : 'Offer prayer now', tzTime, notifDetails, androidScheduleMode: scheduleMode);
        } catch (_) {}
      }
    }
  }

  Future<void> cancelAzanNotifications() async {
    if (kIsWeb) return;
    for (int i = 0; i < 70; i++) await (_localNotifications as dynamic).cancel(1000 + i);
  }

  Future<void> scheduleDuaReminder(TimeOfDay time) async {
    if (kIsWeb) return;
    await cancelDuaReminder();
    final now = DateTime.now();
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    bool canUseExactAlarms = await androidPlugin?.canScheduleExactNotifications() ?? true;

    for (int i = 0; i < 7; i++) {
      final targetDate = now.add(Duration(days: i));
      var sDate = DateTime(targetDate.year, targetDate.month, targetDate.day, time.hour, time.minute);
      if (i == 0 && sDate.isBefore(now)) sDate = sDate.add(const Duration(days: 7));
      await (_localNotifications as dynamic).zonedSchedule(3001 + i, '📿 Daily Dua', 'Remember Allah', tz.TZDateTime.from(sDate, tz.local), const NotificationDetails(android: AndroidNotificationDetails('dua_channel', 'Dua', importance: Importance.high, playSound: true)), androidScheduleMode: canUseExactAlarms ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  Future<void> cancelDuaReminder() async {
    if (kIsWeb) return;
    for (int i = 0; i < 7; i++) await (_localNotifications as dynamic).cancel(3001 + i);
  }
}
