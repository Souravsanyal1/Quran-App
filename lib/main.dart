import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

/// FCM background message handler — MUST be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] title=${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register FCM background handler BEFORE any Firebase call
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize background audio playback controls
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.quranapp.quran_app.channel.audio',
    androidNotificationChannelName: 'Quran Recitation',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );

  // Portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Load initial theme mode from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final String savedTheme = prefs.getString('theme_mode') ?? 'dark';

  // NOTE: NotificationService.instance.init() is called in SplashController
  // after Firebase.initializeApp() — do NOT call it here.

  runApp(QuranApp(savedTheme: savedTheme));
}
