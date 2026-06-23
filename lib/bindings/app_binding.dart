import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/quran_repository.dart';
import '../data/providers/quran_api_provider.dart';
import '../modules/settings/settings_controller.dart';
import '../modules/notifications/notifications_controller.dart';

/// Global dependency injection — registered once for the entire app lifetime
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.putAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance(),
      permanent: true,
    );

    // API Providers
    Get.lazyPut<QuranApiProvider>(() => QuranApiProvider(), fenix: true);

    // Repositories
    Get.lazyPut<QuranRepository>(() => QuranRepository(), fenix: true);

    // Settings (needed globally for theme/language)
    Get.put<SettingsController>(SettingsController(), permanent: true);

    // Notifications (needed globally so FCM messages can be stored from anywhere)
    Get.put<NotificationsController>(NotificationsController(), permanent: true);
  }
}

