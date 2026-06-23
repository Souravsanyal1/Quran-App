import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../modules/settings/settings_controller.dart';
import '../home_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final home = Get.find<HomeController>();

    return Obx(() {
      final bool bn = settings.isBangla;
      final isDark = settings.isDark;

      return Drawer(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        child: Column(
          children: [
            // Header
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    bn ? 'কুরআন অ্যাপ' : 'Quran App',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    bn ? 'পড়ুন · শুনুন · চিন্তা করুন' : 'Read · Listen · Reflect',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerSection(title: bn ? 'কুরআন' : 'Quran', children: [
                    _DrawerItem(
                      icon: Icons.menu_book_rounded,
                      label: bn ? 'কুরআন পড়ুন' : 'Read Quran',
                      onTap: () { Get.back(); home.goToQuran(); },
                    ),
                    _DrawerItem(
                      icon: Icons.download_rounded,
                      label: bn ? 'কুরআন ডাউনলোড' : 'Download Quran',
                      onTap: () { Get.back(); home.goToDownload(); },
                    ),
                  ]),
                  _DrawerSection(title: bn ? 'নামাজ' : 'Prayer', children: [
                    _DrawerItem(
                      icon: Icons.access_time_rounded,
                      label: bn ? 'নামাজের সময়' : 'Prayer Times',
                      onTap: () { Get.back(); home.goToPrayerTime(); },
                    ),
                    _DrawerItem(
                      icon: Icons.explore_rounded,
                      label: bn ? 'কিবলা দিক' : 'Qibla Direction',
                      onTap: () { Get.back(); home.goToQibla(); },
                    ),
                    _DrawerItem(
                      icon: Icons.self_improvement_rounded,
                      label: bn ? 'নামাজ শিখুন' : 'Learn Salah',
                      onTap: () { Get.back(); home.goToSalahGuide(); },
                    ),
                  ]),
                  _DrawerSection(title: bn ? 'শিক্ষা' : 'Learning', children: [
                    _DrawerItem(
                      icon: Icons.school_rounded,
                      label: bn ? 'নতুন মুসলিম গাইড' : 'New Muslim Guide',
                      onTap: () { Get.back(); home.goToNewMuslimGuide(); },
                    ),
                    _DrawerItem(
                      icon: Icons.volunteer_activism_rounded,
                      label: bn ? 'দোয়া ও আযকার' : "Du'a & Azkar",
                      onTap: () { Get.back(); home.goToDuas(); },
                    ),
                    _DrawerItem(
                      icon: Icons.radio_button_checked_rounded,
                      label: bn ? 'তাসবীহ' : 'Tasbih Counter',
                      onTap: () { Get.back(); home.goToTasbih(); },
                    ),
                  ]),
                  _DrawerSection(title: bn ? 'ট্র্যাকিং' : 'Tracking', children: [
                    _DrawerItem(
                      icon: Icons.track_changes_rounded,
                      label: bn ? 'আমার ট্র্যাকার' : 'My Tracker',
                      onTap: () { Get.back(); home.goToTracker(); },
                    ),
                  ]),
                  _DrawerSection(title: bn ? 'কমিউনিটি' : 'Community', children: [
                    _DrawerItem(
                      icon: Icons.favorite_rounded,
                      label: bn ? 'ডোনেশন' : 'Donation',
                      color: AppColors.error,
                      onTap: () { Get.back(); home.goToDonation(); },
                    ),
                    _DrawerItem(
                      icon: Icons.support_agent_rounded,
                      label: bn ? 'সাপোর্ট' : 'Support',
                      onTap: () { Get.back(); home.goToSupport(); },
                    ),
                  ]),
                  _DrawerSection(title: bn ? 'অ্যাপ' : 'App', children: [
                    _DrawerItem(
                      icon: Icons.settings_rounded,
                      label: bn ? 'সেটিংস' : 'Settings',
                      onTap: () { Get.back(); home.goToSettings(); },
                    ),
                    _DrawerItem(
                      icon: isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      label: isDark
                          ? (bn ? 'লাইট মোড' : 'Light Mode')
                          : (bn ? 'ডার্ক মোড' : 'Dark Mode'),
                      onTap: settings.toggleTheme,
                    ),
                  ]),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Quran App v1.0.0\nMade with ❤️ for the Ummah',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppColors.textMuted : AppColors.textDark.withValues(alpha: 0.5),
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DrawerSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textMuted : AppColors.textDark.withValues(alpha: 0.5),
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...children,
        Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, thickness: 0.5),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;
    return ListTile(
      leading: Icon(icon, color: color ?? (isDark ? AppColors.textGrey : AppColors.textDark.withValues(alpha: 0.7)), size: 20),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? AppColors.textWhite : AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      dense: true,
    );
  }
}
