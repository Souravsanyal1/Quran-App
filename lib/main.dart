import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] title=${message.notification?.title}');
}

Future<void> main() async {
  try {
    debugPrint('--- APP STARTING ---');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('Binding initialized');

    // Parallelize core initializations to optimize start-up time
    SharedPreferences? prefsInstance;
    await Future.wait([
      GetStorage.init(),
      Future(() async {
        try {
          debugPrint('Initializing Firebase...');
          if (Firebase.apps.isEmpty) {
            await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            );
          } else {
            Firebase.app();
          }
          debugPrint('Firebase initialized successfully');
        } catch (e) {
          debugPrint('Firebase init error: $e');
        }
      }),
      Future(() async {
        try {
          prefsInstance = await SharedPreferences.getInstance();
        } catch (e) {
          debugPrint('Prefs error: $e');
        }
      }),
      if (!kIsWeb)
        JustAudioBackground.init(
          androidNotificationChannelId: 'com.quranapp.quran_app.channel.audio',
          androidNotificationChannelName: 'Quran Recitation',
          androidNotificationOngoing: true,
        ),
    ]);
    debugPrint('Core initializations complete');

    // 3. Mobile Specific Plugins (Guarded & Unawaited for performance)
    if (!kIsWeb) {
      Future(() async {
        try {
          await MobileAds.instance.initialize();
        } catch (e) {
          debugPrint('MobileAds init error: $e');
        }
      });
      
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      );
    }

    // 4. Load Theme (Safe check)
    String savedTheme = 'dark';
    if (prefsInstance != null) {
      savedTheme = prefsInstance!.getString('theme_mode') ?? 'dark';
    }

    runApp(QuranApp(savedTheme: savedTheme));
  } catch (e, stack) {
    debugPrint('CRITICAL STARTUP ERROR: $e');
    debugPrint(stack.toString());
    // Fallback startup
    runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('App Initialization Failed')))));
  }
}
