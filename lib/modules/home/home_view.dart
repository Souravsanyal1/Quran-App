import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../modules/notifications/notifications_controller.dart';
import '../../core/constants/app_routes.dart';
import 'home_controller.dart';
import 'widgets/home_dashboard.dart';
import 'widgets/app_drawer.dart';
import 'widgets/floating_support_button.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Obx(() {
      return Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(context, settings),
        drawer: const AppDrawer(),
        floatingActionButton: const FloatingSupportButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: _buildBody(controller.currentIndex.value),
        bottomNavigationBar: _buildBottomNav(context, settings),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;
    return AppBar(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu_rounded, color: isDark ? AppColors.textWhite : AppColors.textDark),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        settings.isBangla ? 'কুরআন অ্যাপ' : 'Quran App',
        style: TextStyle(
          color: isDark ? AppColors.textWhite : AppColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: isDark ? AppColors.textGrey : AppColors.textDark.withValues(alpha: 0.7),
          ),
          onPressed: settings.toggleTheme,
        ),
        // Notification bell with unread badge
        Obx(() {
          final notifCtrl = Get.isRegistered<NotificationsController>()
              ? Get.find<NotificationsController>()
              : null;
          final unread = notifCtrl?.unreadCount.value ?? 0;
          return Stack(
            children: [
              IconButton(
                icon: Icon(
                  unread > 0
                      ? Icons.notifications_rounded
                      : Icons.notifications_outlined,
                  color: unread > 0
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textGrey
                          : AppColors.textDark.withValues(alpha: 0.7)),
                ),
                onPressed: () => Get.toNamed(AppRoutes.notifications),
              ),
              if (unread > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const HomeDashboard();
      case 1:
        // Navigate to Quran — use push so it's a separate page
        return const HomeDashboard(); // placeholder; nav happens via tab
      case 2:
        return const HomeDashboard();
      case 3:
        return const HomeDashboard();
      default:
        return const HomeDashboard();
    }
  }

  Widget _buildBottomNav(BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;
    final bool bn = settings.isBangla;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: (i) {
          controller.onNavTap(i);
          if (i == 1) controller.goToQuran();
          if (i == 2) controller.goToPrayerTime();
          if (i == 3) controller.goToDuas();
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark ? AppColors.textMuted : AppColors.textDark.withOpacity(0.4),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: bn ? 'হোম' : 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_rounded),
            label: bn ? 'কুরআন' : 'Quran',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.access_time_rounded),
            label: bn ? 'নামাজ' : 'Prayer',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.volunteer_activism_rounded),
            label: bn ? 'দোয়া' : "Du'a",
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_rounded),
            label: bn ? 'আরো' : 'More',
          ),
        ],
      ),
    );
  }
}
