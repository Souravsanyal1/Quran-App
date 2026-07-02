import 'package:get/get.dart';

import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_controller.dart';
import '../modules/splash/maintenance_update_views.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/admin/admin_view.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/onboarding/onboarding_controller.dart';
import '../modules/home/home_view.dart';
import '../modules/home/home_controller.dart';
import '../modules/admin_dashboard/admin_dashboard_view.dart';
import '../modules/admin_dashboard/admin_dashboard_binding.dart';
import '../modules/quran/quran_view.dart';
import '../modules/quran/quran_controller.dart';
import '../modules/quran/widgets/now_playing_view.dart';
import '../modules/surah_details/surah_details_view.dart';
import '../modules/surah_details/surah_details_controller.dart';
import '../modules/para_details/para_details_view.dart';
import '../modules/para_details/para_details_controller.dart';
import '../modules/quran_download/quran_download_view.dart';
import '../modules/quran_download/quran_download_controller.dart';
import '../modules/prayer_time/prayer_time_view.dart';
import '../modules/new_muslim_guide/new_muslim_guide_view.dart';
import '../modules/new_muslim_guide/new_muslim_guide_controller.dart';
import '../modules/namaz_guide/namaz_guide_view.dart';
import '../modules/namaz_guide/namaz_guide_binding.dart';
import '../modules/namaz_guide_2/namaz_guide_2_view.dart';
import '../modules/namaz_guide_2/namaz_guide_2_binding.dart';
import '../modules/duas/duas_view.dart';
import '../modules/duas/duas_controller.dart';
import '../modules/tasbih/tasbih_view.dart';
import '../modules/tasbih/tasbih_controller.dart';
import '../modules/qibla/qibla_view.dart';
import '../modules/qibla/qibla_controller.dart';
import '../modules/tracker/tracker_view.dart';
import '../modules/tracker/tracker_controller.dart';
import '../modules/donation/donation_view.dart';
import '../modules/donation/donation_controller.dart';
import '../modules/support/support_center_view.dart';
import '../modules/support/support_view.dart';
import '../modules/support/support_form_view.dart';
import '../modules/support/support_binding.dart';
import '../modules/settings/settings_view.dart';
import '../modules/settings/settings_controller.dart';
import '../modules/settings/n8n_config_view.dart';
import '../modules/settings/n8n_config_controller.dart';
import '../modules/notifications/notifications_view.dart';
import '../modules/prayer_time/location_map_view.dart';
import '../modules/developer_info/developer_info_view.dart';
import '../modules/developer_info/developer_info_controller.dart';
import '../core/constants/app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => AuthController())),
    ),
    GetPage(
      name: AppRoutes.admin,
      page: () => const AdminView(),
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
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.salahGuide,
      page: () => const NamazGuideView(),
      binding: NamazGuideBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.salahGuide2,
      page: () => const NamazGuide2View(),
      binding: NamazGuide2Binding(),
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
       binding: BindingsBuilder(() => Get.lazyPut(() => DonationController())),
       transition: Transition.rightToLeft,
     ),
    GetPage(
      name: AppRoutes.support,
      page: () => const SupportCenterView(),
      binding: SupportBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/support-chat',
      page: () => const SupportChatView(),
      binding: SupportBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/support-form',
      page: () => const SupportFormView(),
      binding: SupportBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SettingsController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.locationMap,
      page: () => const LocationMapView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.developerInfo,
      page: () => const DeveloperInfoView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => DeveloperInfoController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.n8nConfig,
      page: () => const N8nConfigView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => N8nConfigController())),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.maintenance,
      page: () => const MaintenanceView(),
    ),
    GetPage(
      name: AppRoutes.forceUpdate,
      page: () => const ForceUpdateView(),
    ),
    GetPage(
      name: AppRoutes.nowPlaying,
      page: () => const NowPlayingView(),
      transition: Transition.downToUp,
    ),
  ];
}
