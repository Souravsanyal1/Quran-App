import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';

class SettingsController extends GetxController {
  static const String _keyTheme = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyFontSize = 'font_size';
  static const String _keyAzan = 'azan_enabled';
  static const String _keyQari = 'selected_qari';
  static const String _keyNotifications = 'fcm_enabled';

  final RxString themeMode = 'dark'.obs;
  final RxString language = 'en'.obs;
  final RxDouble arabicFontSize = 24.0.obs;
  final RxDouble translationFontSize = 14.0.obs;
  final RxBool azanEnabled = true.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxString selectedQari = 'ar.alafasy'.obs;

  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    themeMode.value = _prefs?.getString(_keyTheme) ?? 'dark';
    language.value = _prefs?.getString(_keyLanguage) ?? 'en';
    arabicFontSize.value = _prefs?.getDouble(_keyFontSize) ?? 24.0;
    azanEnabled.value = _prefs?.getBool(_keyAzan) ?? true;
    notificationsEnabled.value = _prefs?.getBool(_keyNotifications) ?? true;
    selectedQari.value = _prefs?.getString(_keyQari) ?? 'ar.alafasy';
    _applyTheme();
    
    // Sync FCM state on startup
    await NotificationService.instance.toggleFCM(notificationsEnabled.value);
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
  }

  Future<void> setArabicFontSize(double size) async {
    arabicFontSize.value = size;
    await _prefs?.setDouble(_keyFontSize, size);
  }

  Future<void> setTranslationFontSize(double size) async {
    translationFontSize.value = size;
  }

  Future<void> setAzanEnabled(bool enabled) async {
    azanEnabled.value = enabled;
    await _prefs?.setBool(_keyAzan, enabled);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled.value = enabled;
    await _prefs?.setBool(_keyNotifications, enabled);
    await NotificationService.instance.toggleFCM(enabled);
  }

  Future<void> setQari(String qariId) async {
    selectedQari.value = qariId;
    await _prefs?.setString(_keyQari, qariId);
  }

  bool get isBangla => language.value == 'bn';
  bool get isDark => themeMode.value == 'dark';

  /// Toggle between dark and light
  void toggleTheme() {
    setTheme(isDark ? 'light' : 'dark');
  }
}
