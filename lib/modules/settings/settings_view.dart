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
      ),
      body: Obx(() {
        final bn = controller.isBangla;
        final isDark = controller.isDark;
        final textColor = isDark ? AppColors.textWhite : AppColors.textDark;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                Slider(
                  value: controller.arabicFontSize.value,
                  min: 16,
                  max: 40,
                  divisions: 12,
                  label: controller.arabicFontSize.value.toStringAsFixed(0),
                  onChanged: controller.setArabicFontSize,
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
                  title: bn ? 'কারী নির্বাচন' : 'Select Qari',
                  subtitle: AppUrls.qariList.firstWhere(
                      (q) => q['id'] == controller.selectedQari.value,
                      orElse: () => {'name': 'Unknown'})['name']!,
                ),
                ...AppUrls.qariList.map((qari) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: controller.selectedQari.value == qari['id']
                                ? AppColors.primary
                                : AppColors.textMuted,
                            width: 2,
                          ),
                        ),
                        child: controller.selectedQari.value == qari['id']
                            ? Container(
                                margin: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        qari['name']!,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => controller.setQari(qari['id']!),
                    )),
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

            const SizedBox(height: 32),
            Text(
              'Quran App v1.0.0\nMade with ❤️ for the Ummah',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        );
      }),
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

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))
          : null,
      trailing: trailing,
    );
  }
}
