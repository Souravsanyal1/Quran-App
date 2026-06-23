import 'package:get/get.dart';

import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_controller.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/onboarding/onboarding_controller.dart';
import '../modules/home/home_view.dart';
import '../modules/home/home_controller.dart';
import '../modules/quran/quran_view.dart';
import '../modules/quran/quran_controller.dart';
import '../modules/surah_details/surah_details_view.dart';
import '../modules/surah_details/surah_details_controller.dart';
import '../modules/para_details/para_details_view.dart';
import '../modules/para_details/para_details_controller.dart';
import '../modules/quran_download/quran_download_view.dart';
import '../modules/quran_download/quran_download_controller.dart';
import '../modules/prayer_time/prayer_time_view.dart';
import '../modules/prayer_time/prayer_time_controller.dart';
import '../modules/salah_guide/salah_guide_view.dart';
import '../modules/salah_guide/salah_guide_controller.dart';
import '../modules/new_muslim_guide/new_muslim_guide_view.dart';
import '../modules/new_muslim_guide/new_muslim_guide_controller.dart';
import '../modules/duas/duas_view.dart';
import '../modules/duas/duas_controller.dart';
import '../modules/tasbih/tasbih_view.dart';
import '../modules/tasbih/tasbih_controller.dart';
import '../modules/qibla/qibla_view.dart';
import '../modules/qibla/qibla_controller.dart';
import '../modules/tracker/tracker_view.dart';
import '../modules/tracker/tracker_controller.dart';
import '../modules/donation/donation_view.dart';
import '../modules/support/support_view.dart';
import '../modules/support/support_controller.dart';
import '../modules/settings/settings_view.dart';
import '../modules/settings/settings_controller.dart';
import '../core/constants/app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SplashController())),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => OnboardingController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => HomeController())),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.quran,
      page: () => const QuranView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => QuranController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.surahDetails,
      page: () => const SurahDetailsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SurahDetailsController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.paraDetails,
      page: () => const ParaDetailsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ParaDetailsController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.quranDownload,
      page: () => const QuranDownloadView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => QuranDownloadController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.prayerTime,
      page: () => const PrayerTimeView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => PrayerTimeController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.salahGuide,
      page: () => const SalahGuideView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SalahGuideController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.newMuslimGuide,
      page: () => const NewMuslimGuideView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => NewMuslimGuideController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.duas,
      page: () => const DuasView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => DuasController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.tasbih,
      page: () => const TasbihView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => TasbihController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.qibla,
      page: () => const QiblaView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => QiblaController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.tracker,
      page: () => const TrackerView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => TrackerController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.donation,
      page: () => const DonationView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.support,
      page: () => const SupportView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SupportController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SettingsController())),
      transition: Transition.rightToLeft,
    ),
  ];
}
