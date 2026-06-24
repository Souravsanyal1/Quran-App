import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_routes.dart';
import '../../services/notification_service.dart';
import '../../firebase_options.dart';
import '../../modules/prayer_time/prayer_time_controller.dart';

class SplashController extends GetxController {
  static const String _onboardingKey = 'onboarding_done';

  final RxDouble progress = 0.0.obs;
  final RxString statusMessage = 'Starting...'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // Step 1: Firebase Configuration (0% -> 25%)
      statusMessage.value = 'Connecting to Firebase...';
      progress.value = 0.10;
      // Guard: only initialize if not already done (e.g. when woken by FCM background isolate)
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      progress.value = 0.30;
      await Future.delayed(const Duration(milliseconds: 60));

      // Step 2: Hive Local Storage (25% -> 50%)
      statusMessage.value = 'Preparing local storage...';
      final appDocDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocDir.path);
      progress.value = 0.55;
      await Future.delayed(const Duration(milliseconds: 60));

      // Step 3: SharedPreferences & Notifications (50% -> 80%)
      statusMessage.value = 'Setting up services...';
      final prefs = await SharedPreferences.getInstance();
      await NotificationService.instance.init();

      // Now that NotificationService is initialized, reschedule azan notifications.
      // PrayerTimeController.onInit() ran before init() completed (AppBinding
      // registers it before splash), so scheduling was silently skipped then.
      try {
        final prayerController = Get.find<PrayerTimeController>();
        await prayerController.loadPrayerTimes();
      } catch (_) {}

      // Request battery optimization exemption once on first launch
      final bool batteryAsked = prefs.getBool('battery_opt_asked') ?? false;
      if (!batteryAsked) {
        await prefs.setBool('battery_opt_asked', true);
        await NotificationService.instance.requestBatteryOptimization();
      }

      // Restore daily dua reminder if it was enabled
      final bool duaEnabled = prefs.getBool('dua_reminder_enabled') ?? false;
      if (duaEnabled) {
        final int h = prefs.getInt('dua_reminder_hour') ?? 8;
        final int m = prefs.getInt('dua_reminder_minute') ?? 0;
        await NotificationService.instance.scheduleDuaReminder(
          TimeOfDay(hour: h, minute: m),
        );
      }

      progress.value = 0.85;
      await Future.delayed(const Duration(milliseconds: 60));

      // Step 4: Loading complete (80% -> 100%)
      statusMessage.value = 'Ready!';
      progress.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 100));

      final onboardingDone = prefs.getBool(_onboardingKey) ?? false;
      if (onboardingDone) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.onboarding);
      }
    } catch (e) {
      statusMessage.value = 'Initialization error: $e';
      Get.log('Initialization error: $e');
      // If error occurs, fallback after a short delay so the user is not locked out
      await Future.delayed(const Duration(seconds: 3));
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
