import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_urls.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(controller.isBangla ? 'সেটিংস' : 'Settings')),
        elevation: 0,
      ),
      body: Obx(() {
        final bn = controller.isBangla;
        final isDark = controller.isDark;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Premium Header Card
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bn ? 'পছন্দসমূহ' : 'Preferences',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bn 
                              ? 'আপনার অভিজ্ঞতা কাস্টমাইজ করুন' 
                              : 'Customize your Quranic experience',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _SectionHeader(title: bn ? 'সাধারণ' : 'General'),

            // Language toggle
            _SettingsCard(
              isDark: isDark,
              children: [
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.language_rounded,
                  title: bn ? 'ভাষা' : 'Language',
                  subtitle: controller.language.value == 'bn' ? 'বাংলা' : 'English',
                  trailing: Switch(
                    value: controller.isBangla,
                    onChanged: (val) => controller.setLanguage(val ? 'bn' : 'en'),
                  ),
                ),
              ],
            ),

            _SectionHeader(title: bn ? 'থিম' : 'Appearance'),

            // Theme
            _SettingsCard(
              isDark: isDark,
              children: [
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.dark_mode_rounded,
                  title: bn ? 'ডার্ক মোড' : 'Dark Mode',
                  trailing: Switch(
                    value: controller.isDark,
                    onChanged: (_) => controller.toggleTheme(),
                  ),
                ),
              ],
            ),

            _SectionHeader(title: bn ? 'কুরআন' : 'Quran'),

            // Font size
            _SettingsCard(
              isDark: isDark,
              children: [
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.text_fields_rounded,
                  title: bn ? 'আরবি ফন্ট সাইজ' : 'Arabic Font Size',
                  subtitle: controller.arabicFontSize.value.toStringAsFixed(0),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Slider(
                    value: controller.arabicFontSize.value,
                    min: 16,
                    max: 40,
                    divisions: 12,
                    activeColor: AppColors.primary,
                    inactiveColor: isDark ? AppColors.borderDark : AppColors.borderLight,
                    label: controller.arabicFontSize.value.toStringAsFixed(0),
                    onChanged: controller.setArabicFontSize,
                  ),
                ),
                // Live preview container
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        bn ? 'ফন্ট সাইজ প্রিভিউ:' : 'Font Size Preview:',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Uthmanic',
                          fontSize: controller.arabicFontSize.value,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            _SectionHeader(title: bn ? 'অডিও' : 'Audio'),

            // Qari selection
            _SettingsCard(
              isDark: isDark,
              children: [
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.record_voice_over_rounded,
                  title: bn ? 'কারী নির্বাচন করুন' : 'Select Qari',
                  subtitle: AppUrls.qariList.firstWhere(
                      (q) => q['id'] == controller.selectedQari.value,
                      orElse: () => {'name': 'Unknown'})['name']!,
                  onTap: () => _showQariSelectionBottomSheet(context, controller, bn),
                ),
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.play_circle_fill_rounded,
                  title: bn ? 'ব্যাকগ্রাউন্ডে অডিও প্লে করুন' : 'Play Audio in Background',
                  subtitle: bn
                      ? 'অ্যাপ বন্ধ বা স্ক্রিন লক থাকলেও অডিও সচল রাখবে'
                      : 'Keep playing audio when screen is locked or app is in background',
                  trailing: Switch(
                    value: controller.backgroundPlayEnabled.value,
                    onChanged: controller.setBackgroundPlay,
                  ),
                ),
              ],
            ),

            _SectionHeader(title: bn ? 'নোটিফিকেশন' : 'Notifications'),

            _SettingsCard(
              isDark: isDark,
              children: [
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.notifications_active_rounded,
                  title: bn ? 'পুশ নোটিফিকেশন (FCM)' : 'Push Notifications (FCM)',
                  trailing: Switch(
                    value: controller.notificationsEnabled.value,
                    onChanged: controller.setNotificationsEnabled,
                  ),
                ),
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.notifications_rounded,
                  title: bn ? 'আযান নোটিফিকেশন' : 'Azan Notification',
                  trailing: Switch(
                    value: controller.azanEnabled.value,
                    onChanged: controller.setAzanEnabled,
                  ),
                ),
              ],
            ),

            _SectionHeader(title: bn ? 'দৈনিক দোয়া' : 'Daily Dua'),

            _SettingsCard(
              isDark: isDark,
              children: [
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.auto_awesome_rounded,
                  title: bn ? 'দৈনিক দোয়ার রিমাইন্ডার' : 'Daily Dua Reminder',
                  subtitle: bn
                      ? 'প্রতিদিন নির্দিষ্ট সময়ে দোয়ার নোটিফিকেশন'
                      : 'Get a daily dua notification at your chosen time',
                  trailing: Switch(
                    value: controller.duaReminderEnabled.value,
                    onChanged: controller.setDuaReminderEnabled,
                  ),
                ),
                if (controller.duaReminderEnabled.value)
                  _SettingsTile(
                    isDark: isDark,
                    icon: Icons.schedule_rounded,
                    title: bn ? 'রিমাইন্ডারের সময়' : 'Reminder Time',
                    subtitle: () {
                      final h = controller.duaReminderHour.value;
                      final m = controller.duaReminderMinute.value;
                      final tod = TimeOfDay(hour: h, minute: m);
                      return tod.format(context);
                    }(),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: controller.duaReminderHour.value,
                          minute: controller.duaReminderMinute.value,
                        ),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                              primary: AppColors.primary,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        if (!context.mounted) return;
                        // Capture context-dependent value before async gap
                        final formattedTime = picked.format(context);
                        await controller.setDuaReminderTime(picked);
                        Get.snackbar(
                          bn ? 'রিমাইন্ডার সেট' : 'Reminder Set',
                          bn
                              ? 'প্রতিদিন $formattedTime এ দোয়ার নোটিফিকেশন আসবে'
                              : 'You will receive a dua reminder daily at $formattedTime',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.9),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                        );
                      }
                    },
                  ),
              ],
            ),

            const SizedBox(height: 32),
            Text(
              'Quran App v1.0.0\nMade with ❤️ for the Ummah',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }

  void _showQariSelectionBottomSheet(BuildContext context, SettingsController controller, bool bn) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: controller.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(
            color: controller.isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: controller.isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              bn ? 'কারী নির্বাচন করুন' : 'Select Qari',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: controller.isDark ? AppColors.textWhite : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView(
                shrinkWrap: true,
                children: AppUrls.qariList.map((qari) {
                  final isSelected = controller.selectedQari.value == qari['id'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (controller.isDark ? AppColors.borderDark : AppColors.borderLight),
                        width: isSelected ? 1 : 0.5,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: Icon(
                        Icons.record_voice_over_rounded,
                        color: isSelected ? AppColors.primary : AppColors.textGrey,
                      ),
                      title: Text(
                        qari['name']!,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : (controller.isDark ? AppColors.textWhite : AppColors.textDark),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                          : null,
                      onTap: () {
                        controller.setQari(qari['id']!);
                        Get.back();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isDark;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.textWhite : AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: isDark ? AppColors.textGrey : AppColors.textMuted,
                )
              : null),
    );
  }
}
