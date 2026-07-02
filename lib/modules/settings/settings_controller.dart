import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import '../../core/constants/app_routes.dart';
import '../../services/notification_service.dart';
import '../auth/auth_controller.dart';
import '../notifications/notifications_controller.dart';
import '../../data/repositories/notification_repository.dart';
import '../../core/api/notification_api_provider.dart';
import '../../data/models/notification_config_model.dart';
import '../../services/audio_player_service.dart';
import '../../modules/prayer_time/prayer_time_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsController extends GetxController {
  static const String _keyTheme = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyFontSize = 'font_size';
  static const String _keyAzan = 'azan_enabled';
  static const String _keyQari = 'selected_qari';
  static const String _keyNotifications = 'fcm_enabled';
  static const String _keyBackgroundPlay = 'background_play_enabled';

  final RxString themeMode = 'dark'.obs;
  final RxString language = 'bn'.obs; // Default: Bangla
  final RxDouble arabicFontSize = 24.0.obs;
  final RxDouble translationFontSize = 14.0.obs;
  final RxBool azanEnabled = true.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxString selectedQari = 'ar.alafasy'.obs;
  final RxBool backgroundPlayEnabled = false.obs;
  final RxBool isLoading = true.obs;
  final Rxn<DateTime> maintenanceEndTime = Rxn<DateTime>();
  final Rx<DateTime> currentTime = DateTime.now().obs;

  // Announcement
  final RxBool showAnnouncement = false.obs;
  final RxString announcementTitle = ''.obs;
  final RxString announcementBody = ''.obs;
  final RxString announcementImageUrl = ''.obs;
  final RxString announcementId = ''.obs;

  // Feature Toggles
  final RxBool isNamazGuideActive = false.obs;
  final RxBool isLiveSupportBotEnabled = true.obs;

  Timer? _maintenanceTimer;
  Timer? _clockTimer;

  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _listenToMaintenanceMode();
    _listenToRemoteNotificationConfigs();
    _startClockTimer();
  }

  void _listenToRemoteNotificationConfigs() {
    final repo = NotificationRepository(NotificationApiProvider());
    
    repo.streamGlobalConfigs().listen((configs) {
      NotificationService.instance.applyGlobalConfigs(configs);
    });

    repo.streamCustomNotifications().listen((list) {
      NotificationService.instance.applyCustomNotifications(list);
    });
  }

  void _startClockTimer() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTime.value = DateTime.now();
    });
  }

  @override
  void onClose() {
    _maintenanceTimer?.cancel();
    _clockTimer?.cancel();
    super.onClose();
  }

  void _listenToMaintenanceMode() {
    FirebaseFirestore.instance
        .collection('app_settings')
        .doc('update_config')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          updateMaintenanceFromData(data);
          
          // 2. Check Force Update (Optional: can also be instant if we want to be strict)
          if (data['forceUpdate'] == true) {
            final packageInfo = await PackageInfo.fromPlatform();
            final int currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
            final int requiredBuild = data['buildNumber'] ?? 0;
            if (currentBuild < requiredBuild && Get.currentRoute != AppRoutes.forceUpdate) {
              Get.offAllNamed(AppRoutes.forceUpdate);
            }
          }
        }
      }
    });
  }

  void updateMaintenanceFromData(Map<String, dynamic> data) {
    // 1. Check Maintenance Mode
    bool isMaintenanceActive = data['maintenanceMode'] == true;
    
    // 2. Load Announcement & Feature Toggles
    showAnnouncement.value = data['showAnnouncement'] ?? false;
    announcementTitle.value = data['announcementTitle'] ?? '';
    announcementBody.value = data['announcementBody'] ?? '';
    announcementImageUrl.value = data['announcementImageUrl'] ?? '';
    announcementId.value = data['announcementId'] ?? '';
    isNamazGuideActive.value = data['isNamazGuideActive'] ?? false;
    isLiveSupportBotEnabled.value = data['isLiveSupportBotEnabled'] ?? true;

    if (data['maintenanceEndTime'] != null) {
      final endTime = data['maintenanceEndTime'];
      if (endTime is Timestamp) {
        maintenanceEndTime.value = endTime.toDate();
      } else if (endTime is DateTime) {
        maintenanceEndTime.value = endTime;
      }
    } else {
      maintenanceEndTime.value = null;
    }

    if (isMaintenanceActive && maintenanceEndTime.value != null) {
      if (DateTime.now().isAfter(maintenanceEndTime.value!)) {
        isMaintenanceActive = false;
      }
    }

    _handleMaintenanceNavigation(isMaintenanceActive);
  }

  void _handleMaintenanceNavigation(bool isMaintenanceActive) {
    if (isMaintenanceActive) {
      bool isUserAdmin = false;
      try {
        isUserAdmin = Get.find<AuthController>().isAdmin.value;
      } catch (_) {}

      if (!isUserAdmin && Get.currentRoute != AppRoutes.maintenance) {
        Get.offAllNamed(AppRoutes.maintenance);
      }
      _startMaintenanceCheckTimer();
    } else {
      _maintenanceTimer?.cancel();
      if (Get.currentRoute == AppRoutes.maintenance) {
        Get.offAllNamed(AppRoutes.splash);
      }
    }
  }

  void _startMaintenanceCheckTimer() {
    _maintenanceTimer?.cancel();
    if (maintenanceEndTime.value == null) return;

    _maintenanceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (maintenanceEndTime.value != null && DateTime.now().isAfter(maintenanceEndTime.value!)) {
        timer.cancel();
        _handleMaintenanceNavigation(false);
      }
    });
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    themeMode.value = _prefs?.getString(_keyTheme) ?? 'dark';
    language.value = _prefs?.getString(_keyLanguage) ?? 'bn'; // Default: Bangla
    arabicFontSize.value = _prefs?.getDouble(_keyFontSize) ?? 24.0;
    azanEnabled.value = _prefs?.getBool(_keyAzan) ?? true;
    notificationsEnabled.value = _prefs?.getBool(_keyNotifications) ?? true;
    selectedQari.value = _prefs?.getString(_keyQari) ?? 'ar.alafasy';
    backgroundPlayEnabled.value = _prefs?.getBool(_keyBackgroundPlay) ?? false;
    _applyTheme();
    Get.updateLocale(Locale(language.value));
    // Load dua reminder settings
    await loadDuaReminder();
    isLoading.value = false;
  }

  void _applyTheme() {
    switch (themeMode.value) {
      case 'dark':
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case 'light':
        Get.changeThemeMode(ThemeMode.light);
        break;
      default:
        Get.changeThemeMode(ThemeMode.system);
    }
  }

  Future<void> setTheme(String mode) async {
    themeMode.value = mode;
    await _prefs?.setString(_keyTheme, mode);
    _applyTheme();
  }

  Future<void> setLanguage(String lang) async {
    language.value = lang;
    await _prefs?.setString(_keyLanguage, lang);
    Get.updateLocale(Locale(lang));

    // Reschedule Azan notifications so they pick up the new language
    try {
      final prayerController = Get.find<PrayerTimeController>();
      if (prayerController.rawPrayerTimings.isNotEmpty) {
        await NotificationService.instance
            .scheduleAzanNotifications(prayerController.rawPrayerTimings);
      }
    } catch (_) {}
  }

  Future<void> setArabicFontSize(double size) async {
    arabicFontSize.value = size;
    await _prefs?.setDouble(_keyFontSize, size);
  }

  Future<void> setTranslationFontSize(double size) async {
    translationFontSize.value = size;
  }

  Future<void> setAzanEnabled(bool enabled) async {
    if (enabled) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        azanEnabled.value = false;
        await _prefs?.setBool(_keyAzan, false);
        showPermissionExplanationDialog(
          title: isBangla ? 'আযানের নোটিফিকেশন অনুমতি' : 'Azan Notification Permission',
          explanation: isBangla
              ? 'সঠিক সময়ে আযানের নোটিফিকেশন শোনার জন্য বিজ্ঞপ্তির অনুমতি দেওয়া আবশ্যক।'
              : 'Azan notification permission is required to sound alerts at the correct prayer times.',
          icon: Icons.notifications_active_outlined,
          onGrant: () async {
            final result = await Permission.notification.request();
            if (result.isGranted) {
              azanEnabled.value = true;
              await _prefs?.setBool(_keyAzan, true);
              try {
                final prayerController = Get.find<PrayerTimeController>();
                if (prayerController.prayerTimes.isNotEmpty) {
                  await prayerController.loadPrayerTimes();
                }
              } catch (_) {}
            } else {
              Get.snackbar(
                isBangla ? 'অনুমতি অস্বীকৃত' : 'Permission Denied',
                isBangla ? 'বিজ্ঞপ্তির অনুমতি ছাড়া আযান অ্যালার্ট চালু করা সম্ভব নয়।' : 'Cannot enable Azan alerts without permission.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withValues(alpha: 0.8),
                colorText: Colors.white,
              );
            }
          },
        );
        return;
      }
    }

    azanEnabled.value = enabled;
    await _prefs?.setBool(_keyAzan, enabled);
    if (enabled) {
      try {
        final prayerController = Get.find<PrayerTimeController>();
        if (prayerController.prayerTimes.isNotEmpty) {
          await prayerController.loadPrayerTimes();
        }
      } catch (_) {}
    } else {
      await NotificationService.instance.cancelAzanNotifications();
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        notificationsEnabled.value = false;
        await _prefs?.setBool(_keyNotifications, false);
        showPermissionExplanationDialog(
          title: isBangla ? 'বিজ্ঞপ্তির অনুমতি প্রয়োজন' : 'Notification Permission Required',
          explanation: isBangla
              ? 'আপনাকে অ্যাপের গুরুত্বপূর্ণ আপডেট ও নোটিফিকেশন পাঠাতে বিজ্ঞপ্তির অনুমতি প্রয়োজন।'
              : 'Notification permission is required to send you important updates and notifications.',
          icon: Icons.notifications_active_outlined,
          onGrant: () async {
            final result = await Permission.notification.request();
            if (result.isGranted) {
              notificationsEnabled.value = true;
              await _prefs?.setBool(_keyNotifications, true);
              await NotificationService.instance.toggleFCM(true);
            } else {
              Get.snackbar(
                isBangla ? 'অনুমতি অস্বীকৃত' : 'Permission Denied',
                isBangla ? 'বিজ্ঞপ্তির অনুমতি ছাড়া নোটিফিকেশন চালু করা সম্ভব নয়।' : 'Cannot enable notifications without permission.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withValues(alpha: 0.8),
                colorText: Colors.white,
              );
            }
          },
        );
        return;
      }
    }

    notificationsEnabled.value = enabled;
    await _prefs?.setBool(_keyNotifications, enabled);
    await NotificationService.instance.toggleFCM(enabled);
  }

  Future<void> setQari(String qariId) async {
    selectedQari.value = qariId;
    await _prefs?.setString(_keyQari, qariId);
    
    try {
      final audioService = Get.find<AudioPlayerService>();
      if (audioService.isPlaying.value || audioService.player.processingState != ProcessingState.idle) {
        // Preference saved.
      }
    } catch (_) {}
  }

  Future<void> setBackgroundPlay(bool enabled) async {
    if (enabled) {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        backgroundPlayEnabled.value = false;
        await _prefs?.setBool(_keyBackgroundPlay, false);
        showPermissionExplanationDialog(
          title: isBangla ? 'ব্যাকগ্রাউন্ড প্লে অনুমতি' : 'Background Play Permission',
          explanation: isBangla
              ? 'স্ক্রিন অফ থাকা অবস্থায় বা অন্য অ্যাপ ব্যবহারের সময় প্লেয়ার সচল রাখতে ব্যাটারি অপ্টিমাইজেশন নিষ্ক্রিয় করার অনুমতি দিন।'
              : 'Allow disabling battery optimization to keep the audio player active when the screen is off or when using other apps.',
          icon: Icons.battery_saver_outlined,
          onGrant: () async {
            final result = await Permission.ignoreBatteryOptimizations.request();
            if (result.isGranted) {
              backgroundPlayEnabled.value = true;
              await _prefs?.setBool(_keyBackgroundPlay, true);
            } else {
              Get.snackbar(
                isBangla ? 'অনুমতি অস্বীকৃত' : 'Permission Denied',
                isBangla ? 'ব্যাটারি অপ্টিমাইজেশন নিষ্ক্রিয় না করলে ব্যাকগ্রাউন্ড প্লে কাজ করবে না।' : 'Background play will not work without battery optimization exemption.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withValues(alpha: 0.8),
                colorText: Colors.white,
              );
            }
          },
        );
        return;
      }
    }

    backgroundPlayEnabled.value = enabled;
    await _prefs?.setBool(_keyBackgroundPlay, enabled);
  }

  void showPermissionExplanationDialog({
    required String title,
    required String explanation,
    required IconData icon,
    required VoidCallback onGrant,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF141420),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFC9A84C).withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B5E35).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E35).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFC9A84C),
                  size: 56,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                explanation,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white60,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white10),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        isBangla ? 'বাতিল' : 'Cancel',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        onGrant();
                      },
                      child: Text(
                        isBangla ? 'অনুমতি দিন' : 'Grant',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Daily Dua Reminder ────────────────────────────────────────────────────
  static const String _keyDuaReminderEnabled = 'dua_reminder_enabled';
  static const String _keyDuaReminderHour = 'dua_reminder_hour';
  static const String _keyDuaReminderMinute = 'dua_reminder_minute';

  final RxBool duaReminderEnabled = false.obs;
  final RxInt duaReminderHour = 8.obs;
  final RxInt duaReminderMinute = 0.obs;

  Future<void> loadDuaReminder() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    duaReminderEnabled.value = prefs.getBool(_keyDuaReminderEnabled) ?? false;
    duaReminderHour.value = prefs.getInt(_keyDuaReminderHour) ?? 8;
    duaReminderMinute.value = prefs.getInt(_keyDuaReminderMinute) ?? 0;
  }

  Future<void> setDuaReminderEnabled(bool enabled) async {
    if (enabled) {
      final granted = await NotificationService.instance.requestNotificationPermission();
      if (!granted) {
        duaReminderEnabled.value = false;
        final prefs = _prefs ?? await SharedPreferences.getInstance();
        await prefs.setBool(_keyDuaReminderEnabled, false);
        return;
      }
    }
    duaReminderEnabled.value = enabled;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(_keyDuaReminderEnabled, enabled);
    if (enabled) {
      await NotificationService.instance.scheduleDuaReminder(
        TimeOfDay(hour: duaReminderHour.value, minute: duaReminderMinute.value),
      );
    } else {
      await NotificationService.instance.cancelDuaReminder();
    }
  }

  Future<void> setDuaReminderTime(TimeOfDay time) async {
    duaReminderHour.value = time.hour;
    duaReminderMinute.value = time.minute;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setInt(_keyDuaReminderHour, time.hour);
    await prefs.setInt(_keyDuaReminderMinute, time.minute);
    if (duaReminderEnabled.value) {
      await NotificationService.instance.scheduleDuaReminder(time);
    }
  }

  Future<void> requestBatteryOptimization() async {
    await NotificationService.instance.requestBatteryOptimization();
  }

  bool get isBangla => language.value == 'bn';
  bool get isDark => themeMode.value == 'dark';

  /// Toggle between dark and light
  void toggleTheme() {
    setTheme(isDark ? 'light' : 'dark');
  }

  Future<void> checkNamazGuideAccessAndNavigate(String route) async {
    final auth = Get.find<AuthController>();
    
    // 1. Check if feature is globally active from admin settings
    if (isNamazGuideActive.value) {
      Get.toNamed(route);
      return;
    }

    // 2. If not globally active, check if user is admin
    if (auth.isAdmin.value) {
      Get.toNamed(route);
      return;
    }

    // 3. Check for individual user access
    final currentUser = auth.user.value;
    if (currentUser == null) {
      _showComingSoonDialog();
      return;
    }

    isLoading.value = true;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data()?['hasNamazGuideAccess'] == true) {
        isLoading.value = false;
        Get.toNamed(route);
        return;
      }
    } catch (e) {
      Get.log('Error checking Namaz Guide access: $e');
    } finally {
      isLoading.value = false;
    }

    _showComingSoonDialog();
  }

  void _showComingSoonDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF141420),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFC9A84C).withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B5E35).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E35).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_clock_outlined,
                  color: Color(0xFFC9A84C),
                  size: 64,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isBangla ? 'নামাজ শিক্ষা (Coming Soon)' : 'Namaz Guide (Coming Soon)',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isBangla
                    ? 'এই ফিচারটি বর্তমানে বন্ধ আছে এবং শীঘ্রই সবার জন্য উন্মুক্ত করা হবে। অনুগ্রহ করে অপেক্ষা করুন।'
                    : 'This feature is currently under development and will be available to everyone soon. Please check back later.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.back(),
                child: Text(
                  isBangla ? 'ঠিক আছে' : 'OK',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
