import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/notification_api_provider.dart';
import '../core/api/support_api_provider.dart';
import '../core/services/cloudinary_service.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/support_repository.dart';
import '../data/repositories/quran_repository.dart';
import '../data/providers/quran_api_provider.dart';
import '../modules/settings/settings_controller.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/notifications/notifications_controller.dart';
import '../modules/prayer_time/prayer_time_controller.dart';
import '../services/audio_player_service.dart';

/// Global dependency injection — registered once for the entire app lifetime
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.putAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance(),
      permanent: true,
    );

    // Services
    Get.put<CloudinaryService>(CloudinaryService(), permanent: true);

    // API Providers
    Get.lazyPut<QuranApiProvider>(() => QuranApiProvider(), fenix: true);
    Get.lazyPut<NotificationApiProvider>(() => NotificationApiProvider(), fenix: true);
    Get.lazyPut<SupportApiProvider>(() => SupportApiProvider(), fenix: true);

    // Repositories
    Get.lazyPut<QuranRepository>(() => QuranRepository(), fenix: true);
    Get.lazyPut<NotificationRepository>(() => NotificationRepository(Get.find()), fenix: true);
    Get.lazyPut<SupportRepository>(() => SupportRepository(Get.find()), fenix: true);

    // Settings (needed globally for theme/language)
    Get.put<SettingsController>(SettingsController(), permanent: true);

    // Auth Controller
    Get.put<AuthController>(AuthController(), permanent: true);

    // Notifications (needed globally so FCM messages can be stored from anywhere)
    Get.put<NotificationsController>(NotificationsController(Get.find()), permanent: true);

    // Audio player service — permanent singleton so background playback
    // continues when the user navigates away or minimises the app
    Get.putAsync<AudioPlayerService>(
      () async => AudioPlayerService().init(),
      permanent: true,
    );

    // Prayer time controller — permanent singleton so notifications are scheduled on startup
    Get.put<PrayerTimeController>(PrayerTimeController(), permanent: true);
  }
}

