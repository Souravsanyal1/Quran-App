import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app.dart';

/// FCM background message handler — MUST be a top-level function
/// (not inside a class) so it runs in a separate isolate.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // NOTE: Firebase is already initialized by the platform channel at this point.
  // We cannot access GetX controllers here (separate isolate),
  // so we simply acknowledge receipt. The message will be visible
  // via onMessageOpenedApp when the user taps the notification.
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

  runApp(const QuranApp());
}
