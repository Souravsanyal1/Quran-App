import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_routes.dart';
import '../../services/notification_service.dart';
import '../../firebase_options.dart';

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
