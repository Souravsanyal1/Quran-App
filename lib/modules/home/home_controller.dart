import 'dart:async';
import 'package:get/get.dart';
import '../../core/constants/app_routes.dart';

class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxInt currentHour = DateTime.now().hour.obs;
  Timer? _greetingTimer;

  final List<String> tabs = [
    AppRoutes.home,
    AppRoutes.quran,
    AppRoutes.prayerTime,
    AppRoutes.duas,
  ];

  @override
  void onInit() {
    super.onInit();
    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      currentHour.value = DateTime.now().hour;
    });
  }

  @override
  void onClose() {
    _greetingTimer?.cancel();
    super.onClose();
  }

  void onNavTap(int index) {
    currentIndex.value = index;
  }

  void goToQuran() => Get.toNamed(AppRoutes.quran);
  void goToPrayerTime() => Get.toNamed(AppRoutes.prayerTime);
  void goToQibla() => Get.toNamed(AppRoutes.qibla);
  void goToSalahGuide() => Get.toNamed(AppRoutes.salahGuide);
  void goToNewMuslimGuide() => Get.toNamed(AppRoutes.newMuslimGuide);
  void goToDuas() => Get.toNamed(AppRoutes.duas);
  void goToTasbih() => Get.toNamed(AppRoutes.tasbih);
  void goToTracker() => Get.toNamed(AppRoutes.tracker);
  void goToDonation() => Get.toNamed(AppRoutes.donation);
  void goToSupport() => Get.toNamed(AppRoutes.support);
  void goToSettings() => Get.toNamed(AppRoutes.settings);
  void goToDownload() => Get.toNamed(AppRoutes.quranDownload);
}
