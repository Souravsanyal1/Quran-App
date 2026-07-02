import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../data/models/notification_model.dart';
import '../data/models/notification_config_model.dart';
import '../data/repositories/notification_repository.dart';
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

        await _localNotifications.initialize(
          settings: initSettings,
          onDidReceiveNotificationResponse: (response) {
            Get.toNamed('/notifications');
          },
        );

        final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel('high_importance_channel', 'Announcements', importance: Importance.high));
        await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel('azan_channel', 'Azan Notifications', importance: Importance.max, playSound: true));
        await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel('dua_channel', 'Daily Dua Reminder', importance: Importance.high, playSound: true));

        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          Permission.notification.status.then((status) {
            if (!status.isGranted) {
              Permission.notification.request();
            }
          }).catchError((e) {
            _logger.w('Failed to check/request notification permission: $e');
          });
        }
        _requestExactAlarmPermission(); // Run asynchronously without awaiting
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

            await _localNotifications.show(
              id: notification.hashCode,
              title: notification.title,
              body: notification.body,
              notificationDetails: NotificationDetails(
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

    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails('high_importance_channel', 'Announcements', channelDescription: 'General app announcements', importance: Importance.high, priority: Priority.high, styleInformation: bigPicture),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
    );
  }

  Future<void> _requestExactAlarmPermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final bool canSchedule = await androidPlugin?.canScheduleExactNotifications() ?? true;
      if (!canSchedule) {
        await androidPlugin?.requestExactAlarmsPermission();
      }
    } catch (_) {}
  }

  Future<void> requestBatteryOptimization() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (_) {}
  }

  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return true;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        return result.isGranted;
      }
      return true;
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? granted = await _localNotifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  String _detectType(Map<String, dynamic> data) {
    if (data.containsKey('prayer')) return 'prayer';
    if (data['type'] == 'support_reply') return 'support';
    return 'fcm';
  }

  void _storeNotification({required String title, required String body, String? imageUrl, String type = 'fcm'}) {
    try {
      Get.find<NotificationsController>().addNotification(AppNotification(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        category: _mapTypeToCategory(type),
        priority: NotificationPriority.high,
      ));
    } catch (_) {}
  }

  NotificationCategory _mapTypeToCategory(String type) {
    switch (type) {
      case 'prayer': return NotificationCategory.prayer;
      case 'quran': return NotificationCategory.quran;
      case 'support': return NotificationCategory.support;
      default: return NotificationCategory.general;
    }
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
      final token = await _fcm.getToken();
      if (token != null) {
        _logger.i('FCM Token: $token');
        await _updateTokenInFirestore(token);
      }
      await toggleFCM(Get.find<SettingsController>().notificationsEnabled.value);
    } catch (_) {}
  }

  Future<void> _updateTokenInFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      // Check if admin
      final adminDoc = await FirebaseFirestore.instance.collection('admins').doc(user.uid).get();
      if (adminDoc.exists) {
        await adminDoc.reference.update({'fcmToken': token});
      }
      
      // Also update in users collection if applicable (depending on your DB structure)
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      _logger.w('Failed to update FCM token: $e');
    }
  }

  Future<void> toggleFCM(bool enabled) async {
    try {
      if (enabled) {
        await _fcm.subscribeToTopic('all');
      } else {
        await _fcm.unsubscribeFromTopic('all');
      }
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
          if (timings[k] == null || !(prefs.getBool('azan_notification_$k') ?? true)) {
            continue;
          }
          final timeParts = timings[k].toString().split(' ')[0].split(':');
          var pTime = DateTime((dayData['date'] as DateTime).year, (dayData['date'] as DateTime).month, (dayData['date'] as DateTime).day, int.parse(timeParts[0]), int.parse(timeParts[1]));
          if (dayOffset == 0 && pTime.isBefore(now)) {
            continue;
          }
          final tzTime = tz.TZDateTime.from(pTime, tz.local);
          await _localNotifications.zonedSchedule(
            id: 1000 + dayOffset * 10 + k.length,
            title: bn ? '🕌 নামাজের সময়' : '🕌 Prayer Time',
            body: bn ? 'নামাজ আদায় করুন' : 'Offer prayer now',
            scheduledDate: tzTime,
            notificationDetails: notifDetails,
            androidScheduleMode: scheduleMode,
          );
        } catch (_) {}
      }
    }
  }

  Future<void> cancelAzanNotifications() async {
    if (kIsWeb) return;
    for (int i = 0; i < 70; i++) {
      await _localNotifications.cancel(id: 1000 + i);
    }
  }

  Future<void> cancelDuaReminder() async {
    if (kIsWeb) return;
    for (int i = 0; i < 7; i++) {
      await _localNotifications.cancel(id: 3001 + i);
    }
  }

  // --- Remote Config Integration ---

  Future<void> applyGlobalConfigs(Map<String, NotificationCategoryConfig> configs) async {
    if (kIsWeb) return;

    // 1. Prayer Reminder
    final prayer = configs['prayer'];
    if (prayer != null) {
      if (!prayer.enabled) {
        await cancelAzanNotifications();
      } else {
        // Re-scheduling Azan would normally happen via PrayerTimeController
      }
    }

    // 2. Daily Dua Reminder
    final dua = configs['daily_dua'];
    if (dua != null) {
      if (!dua.enabled) {
        await cancelDuaReminder();
      } else {
        final settings = Get.find<SettingsController>();
        await scheduleDuaReminder(
          TimeOfDay(hour: settings.duaReminderHour.value, minute: settings.duaReminderMinute.value),
          title: dua.title.isNotEmpty ? dua.title : null,
          body: dua.message.isNotEmpty ? dua.message : null,
        );
      }
    }
    
    _scheduleSimpleDaily(3100, configs['daily_quran'], 'daily_quran');
    _scheduleSimpleDaily(3200, configs['morning'], 'morning');
    _scheduleSimpleDaily(3300, configs['evening'], 'evening');
    _scheduleSimpleDaily(3400, configs['friday'], 'friday', weekly: true);
    _scheduleSimpleDaily(3500, configs['ramadan'], 'ramadan');
  }

  Future<void> _scheduleSimpleDaily(int baseId, NotificationCategoryConfig? config, String key, {bool weekly = false}) async {
    if (config == null || !config.enabled || config.time == null) {
      for (int i = 0; i < 7; i++) await _localNotifications.cancel(id: baseId + i);
      return;
    }

    try {
      final timeParts = config.time!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      final now = DateTime.now();
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      bool canUseExactAlarms = await androidPlugin?.canScheduleExactNotifications() ?? true;

      for (int i = 0; i < 7; i++) {
        final targetDate = now.add(Duration(days: i));
        if (weekly && targetDate.weekday != DateTime.friday) continue;

        var sDate = DateTime(targetDate.year, targetDate.month, targetDate.day, hour, minute);
        if (sDate.isBefore(now)) {
          if (weekly) sDate = sDate.add(const Duration(days: 7));
          else sDate = sDate.add(const Duration(days: 1));
        }
        
        await _localNotifications.zonedSchedule(
          id: baseId + i,
          title: config.title,
          body: config.message,
          scheduledDate: tz.TZDateTime.from(sDate, tz.local),
          notificationDetails: const NotificationDetails(android: AndroidNotificationDetails('high_importance_channel', 'Reminders')),
          androidScheduleMode: canUseExactAlarms ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (_) {}
  }

  Future<void> scheduleDuaReminder(TimeOfDay time, {String? title, String? body}) async {
    if (kIsWeb) return;
    await cancelDuaReminder();
    final now = DateTime.now();
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    bool canUseExactAlarms = await androidPlugin?.canScheduleExactNotifications() ?? true;

    for (int i = 0; i < 7; i++) {
      final targetDate = now.add(Duration(days: i));
      var sDate = DateTime(targetDate.year, targetDate.month, targetDate.day, time.hour, time.minute);
      if (i == 0 && sDate.isBefore(now)) {
        sDate = sDate.add(const Duration(days: 7));
      }
      await _localNotifications.zonedSchedule(
        id: 3001 + i,
        title: title ?? '📿 Daily Dua',
        body: body ?? 'Remember Allah',
        scheduledDate: tz.TZDateTime.from(sDate, tz.local),
        notificationDetails: const NotificationDetails(android: AndroidNotificationDetails('dua_channel', 'Dua', importance: Importance.high, playSound: true)),
        androidScheduleMode: canUseExactAlarms ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> applyCustomNotifications(List<CustomNotificationConfig> list) async {
    if (kIsWeb) return;
    
    for (int i = 0; i < 1000; i++) await _localNotifications.cancel(id: 5000 + i);

    final now = DateTime.now();
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    bool canUseExactAlarms = await androidPlugin?.canScheduleExactNotifications() ?? true;

    int counter = 0;
    for (var config in list) {
      if (!config.isActive) continue;
      if (config.endDate != null && now.isAfter(config.endDate!)) continue;
      if (counter >= 1000) break;

      try {
        final timeParts = config.scheduleTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        for (int i = 0; i < 7; i++) {
          DateTime sDate;
          if (config.repeat == 'once') {
            sDate = DateTime(config.startDate.year, config.startDate.month, config.startDate.day, hour, minute);
            if (i > 0 || sDate.isBefore(now)) break;
          } else if (config.repeat == 'daily') {
            sDate = now.add(Duration(days: i));
            sDate = DateTime(sDate.year, sDate.month, sDate.day, hour, minute);
          } else if (config.repeat == 'weekly') {
            sDate = now.add(Duration(days: i * 7));
            int diff = config.startDate.weekday - sDate.weekday;
            if (diff < 0) diff += 7;
            sDate = sDate.add(Duration(days: diff));
            sDate = DateTime(sDate.year, sDate.month, sDate.day, hour, minute);
          } else {
            sDate = DateTime(now.year, now.month + i, config.startDate.day, hour, minute);
          }

          if (sDate.isBefore(now)) continue;
          if (config.endDate != null && sDate.isAfter(config.endDate!)) break;

          await _localNotifications.zonedSchedule(
            id: 5000 + counter,
            title: config.title,
            body: config.message,
            scheduledDate: tz.TZDateTime.from(sDate, tz.local),
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel', 
                'Custom Alerts',
                priority: config.priority == 'high' ? Priority.high : Priority.defaultPriority,
              )
            ),
            androidScheduleMode: canUseExactAlarms ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
          );
          counter++;
          if (config.repeat == 'once' || counter >= 1000) break;
        }
      } catch (_) {}
    }
  }
}
