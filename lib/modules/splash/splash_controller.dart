import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_routes.dart';
import '../../services/notification_service.dart';
import '../../modules/prayer_time/prayer_time_controller.dart';
import '../settings/settings_controller.dart';

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
      statusMessage.value = 'Preparing local storage...';
      progress.value = 0.15;

      // Initialize SharedPreferences first (which is fast since it is cached)
      final prefs = await SharedPreferences.getInstance();

      statusMessage.value = 'Setting up services...';
      progress.value = 0.40;

      // Run non-interdependent services in parallel
      await Future.wait([
        // 1. Hive Local Storage
        Future(() async {
          final appDocDir = await getApplicationDocumentsDirectory();
          await Hive.initFlutter(appDocDir.path);
        }),
        
        // 2. Notification Service Initialization
        NotificationService.instance.init(),
        
        // 3. Check for maintenance or updates
        _checkUpdateAndMaintenance(),
        
        // 4. Load prayer times
        Future(() async {
          try {
            final prayerController = Get.find<PrayerTimeController>();
            await prayerController.loadPrayerTimes();
          } catch (_) {}
        }),
      ]);

      // If update or maintenance views have taken over, stop execution here
      if (Get.currentRoute == AppRoutes.maintenance || Get.currentRoute == AppRoutes.forceUpdate) {
        return;
      }

      progress.value = 0.85;

      // Perform background/asynchronous setup tasks that shouldn't block routing
      // 1. Battery optimization prompt
      final bool batteryAsked = prefs.getBool('battery_opt_asked') ?? false;
      if (!batteryAsked) {
        prefs.setBool('battery_opt_asked', true);
        NotificationService.instance.requestBatteryOptimization();
      }

      // 2. Restore daily dua reminder
      final bool duaEnabled = prefs.getBool('dua_reminder_enabled') ?? false;
      if (duaEnabled) {
        final int h = prefs.getInt('dua_reminder_hour') ?? 8;
        final int m = prefs.getInt('dua_reminder_minute') ?? 0;
        NotificationService.instance.scheduleDuaReminder(
          TimeOfDay(hour: h, minute: m),
        );
      }

      // Step 3: Loading complete (85% -> 100%)
      statusMessage.value = 'Ready!';
      progress.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 100));

      final onboardingDone = prefs.getBool(_onboardingKey) ?? false;
      if (!onboardingDone) {
        Get.offAllNamed(AppRoutes.onboarding);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      statusMessage.value = 'Initialization error: $e';
      Get.log('Initialization error: $e');
      await Future.delayed(const Duration(seconds: 3));
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }

  Future<void> _checkUpdateAndMaintenance() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('update_config')
          .get()
          .timeout(const Duration(milliseconds: 1500));

      if (doc.exists) {
        final data = doc.data()!;
        
        // Sync with SettingsController so it has the data immediately
        try {
          final settings = Get.find<SettingsController>();
          settings.updateMaintenanceFromData(data);
        } catch (e) {
          Get.log('Error syncing maintenance data: $e');
        }
        
        // 1. Check Maintenance Mode
        bool isMaintenanceActive = data['maintenanceMode'] == true;
        if (data['maintenanceEndTime'] != null) {
          final endTime = (data['maintenanceEndTime'] as Timestamp).toDate();
          if (DateTime.now().isAfter(endTime)) {
            isMaintenanceActive = false;
          }
        }

        if (isMaintenanceActive) {
          Get.offAllNamed(AppRoutes.maintenance);
          return;
        }

        // 2. Check Force Update
        if (data['forceUpdate'] == true) {
          final packageInfo = await PackageInfo.fromPlatform();
          final int currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
          final int requiredBuildNumber = data['buildNumber'] ?? 0;

          if (currentBuildNumber < requiredBuildNumber) {
            Get.offAllNamed(AppRoutes.forceUpdate);
            return;
          }
        }
      }
    } catch (e) {
      Get.log('Maintenance/Update check skipped due to error: $e');
      // We don't block the app if the check fails (e.g. no internet)
      // unless we want it to be super strict.
    }
  }
}
