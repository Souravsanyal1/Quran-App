import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../settings/settings_controller.dart';
import '../../auth/auth_controller.dart';
import '../../admin/admin_view.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final auth = Get.find<AuthController>();

    return Drawer(
      child: Container(
        color: settings.isDark ? AppColors.surfaceDark : Colors.white,
        child: Column(
          children: [
            _buildHeader(context, settings, auth),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildItem(
                    icon: Icons.home_rounded,
                    title: settings.isBangla ? 'হোম' : 'Home',
                    onTap: () => Get.back(),
                  ),
                  _buildItem(
                    icon: Icons.menu_book_rounded,
                    title: settings.isBangla ? 'আল-কুরআন' : 'Al-Quran',
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.quran);
                    },
                  ),
                  _buildItem(
                    icon: Icons.access_time_filled_rounded,
                    title: settings.isBangla ? 'নামাজের সময়' : 'Prayer Times',
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.prayerTime);
                    },
                  ),
                  _buildItem(
                    icon: Icons.explore_rounded,
                    title: settings.isBangla ? 'কিবলা কম্পাস' : 'Qibla Finder',
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.qibla);
                    },
                  ),
                  Obx(() {
                    if (auth.isAdmin.value) {
                      return _buildItem(
                        icon: Icons.admin_panel_settings_rounded,
                        title: settings.isBangla ? 'অ্যাডমিন ড্যাশবোর্ড' : 'Admin Dashboard',
                        onTap: () {
                          Get.back();
                          Get.toNamed(AppRoutes.adminDashboard);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  _buildItem(
                    icon: Icons.auto_stories_rounded,
                    title: settings.isBangla ? 'শিক্ষা ও গাইড' : 'Learning & Guide',
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.newMuslimGuide);
                    },
                  ),
                  _buildItem(
                    icon: Icons.menu_book_outlined,
                    title: settings.isBangla ? 'নামাজ শিক্ষা' : 'Namaz Guide',
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.salahGuide);
                    },
                  ),
                  const Divider(indent: 20, endIndent: 20, height: 30),
                  _buildItem(
                    icon: Icons.settings_rounded,
                    title: settings.isBangla ? 'সেটিংস' : 'Settings',
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.settings);
                    },
                  ),
                  _buildItem(
                    icon: Icons.info_outline_rounded,
                    title: settings.isBangla ? 'ডেভেলপার তথ্য' : 'Developer Info',
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.developerInfo);
                    },
                  ),
                  _buildItem(
                    icon: Icons.contact_support_rounded,
                    title: settings.isBangla ? 'সাপোর্ট' : 'Support',
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.support);
                    },
                  ),
                ],
              ),
            ),
            _buildFooter(auth, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SettingsController settings, AuthController auth) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 10,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                settings.isBangla ? 'কুরআন অ্যাপ' : 'Quran App',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Obx(() => Text(
                auth.user.value?.email ?? (settings.isBangla ? 'মেহমান ইউজার' : 'Guest User'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              )),
            ],
          ),
          Positioned(
            top: -10,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 24),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildFooter(AuthController auth, SettingsController settings) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: settings.isDark ? Colors.grey : Colors.black54,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
