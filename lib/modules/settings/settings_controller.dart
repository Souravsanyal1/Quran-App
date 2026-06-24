import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';
import '../../modules/prayer_time/prayer_time_controller.dart';
import 'package:permission_handler/permission_handler.dart';

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

  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
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
      final granted = await NotificationService.instance.requestNotificationPermission();
      if (!granted) {
        azanEnabled.value = false;
        await _prefs?.setBool(_keyAzan, false);
        return;
      }
    }
    azanEnabled.value = enabled;
    await _prefs?.setBool(_keyAzan, enabled);
    if (enabled) {
      // Re-schedule if prayer times are already loaded
      try {
        final prayerController = Get.find<PrayerTimeController>();
        if (prayerController.prayerTimes.isNotEmpty) {
          // Re-fetch to trigger scheduling with current timings
          await prayerController.loadPrayerTimes();
        }
      } catch (_) {}
    } else {
      await NotificationService.instance.cancelAzanNotifications();
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      final granted = await NotificationService.instance.requestNotificationPermission();
      if (!granted) {
        notificationsEnabled.value = false;
        await _prefs?.setBool(_keyNotifications, false);
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
  }

  Future<void> setBackgroundPlay(bool enabled) async {
    backgroundPlayEnabled.value = enabled;
    await _prefs?.setBool(_keyBackgroundPlay, enabled);
    if (enabled) {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
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
}
