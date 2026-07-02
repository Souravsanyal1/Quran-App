import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../core/constants/app_routes.dart';

import '../settings/settings_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeController extends GetxController {

  final RxInt currentIndex = 0.obs;
  final RxInt currentHour = DateTime.now().hour.obs;
  Timer? _greetingTimer;

  // Showcase Keys
  final GlobalKey quranKey = GlobalKey();
  final GlobalKey prayerKey = GlobalKey();
  final GlobalKey learnKey = GlobalKey();
  final GlobalKey settingsKey = GlobalKey();

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
    
    // Reactive announcement trigger
    final settings = Get.find<SettingsController>();
    everAll([settings.showAnnouncement, settings.announcementId], (_) {
      _checkAndShowAnnouncement();
    });
    
    _checkAndShowAnnouncement();
  }

  void _checkAndShowAnnouncement() async {
    final settings = Get.find<SettingsController>();
    
    // Small delay to ensure UI is ready on first load
    if (Get.isSnackbarOpen || Get.isDialogOpen == true) {
      await Future.delayed(const Duration(milliseconds: 2000));
    } else {
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    if (settings.showAnnouncement.value) {
      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getString('last_announcement_id') ?? '';
      if (lastId != settings.announcementId.value) {
        _showAnnouncementDialog(settings);
      }
    }
  }

  void _showAnnouncementDialog(SettingsController settings) async {
    // If a dialog is already showing, wait or close it
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: settings.isDark ? const Color(0xFF141420) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Image
              if (settings.announcementImageUrl.value.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
                  child: CachedNetworkImage(
                    imageUrl: settings.announcementImageUrl.value,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(height: 150, color: Colors.grey.withOpacity(0.1)),
                  ),
                ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      settings.announcementTitle.value.isEmpty ? '📢 Announcement' : settings.announcementTitle.value,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      settings.announcementBody.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: settings.isDark ? Colors.white70 : Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E35),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                         onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('last_announcement_id', settings.announcementId.value);
                          Get.back();
                          _triggerShowcase();
                        },
                        child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  BuildContext? _showcaseContext;

  void startShowcase(BuildContext context) async {
    _showcaseContext = context;
    final settings = Get.find<SettingsController>();
    final prefs = await SharedPreferences.getInstance();
    final bool isShowcaseDone = prefs.getBool('showcase_done') ?? false;

    if (isShowcaseDone) return;

    // Check if the announcement popup is going to be shown
    final bool willShowAnnouncement = settings.showAnnouncement.value &&
        (prefs.getString('last_announcement_id') ?? '') != settings.announcementId.value;

    if (!willShowAnnouncement) {
      _triggerShowcase();
    }
  }

  void _triggerShowcase() async {
    if (_showcaseContext == null) return;
    final prefs = await SharedPreferences.getInstance();
    final bool isShowcaseDone = prefs.getBool('showcase_done') ?? false;

    if (!isShowcaseDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_showcaseContext != null) {
          try {
            ShowCaseWidget.of(_showcaseContext!).startShowCase([
              quranKey,
              prayerKey,
              learnKey,
              settingsKey,
            ]);
            prefs.setBool('showcase_done', true);
          } catch (e) {
            debugPrint('Failed to start showcase: $e');
          }
        }
      });
    }
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
  void goToDeveloperInfo() => Get.toNamed(AppRoutes.developerInfo);
}
