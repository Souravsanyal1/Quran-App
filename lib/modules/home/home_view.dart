import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'home_controller.dart';
import 'widgets/home_dashboard.dart';
import 'widgets/app_drawer.dart';
import 'widgets/floating_support_button.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const AppDrawer(),
      floatingActionButton: const FloatingSupportButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Obx(() => _buildBody(controller.currentIndex.value)),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final settings = Get.find<SettingsController>();
    return AppBar(
      backgroundColor: AppColors.bgDark,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textWhite),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Obx(() => Text(
            settings.isBangla ? 'কুরআন অ্যাপ' : 'Quran App',
            style: const TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          )),
      actions: [
        Obx(() {
          final settings = Get.find<SettingsController>();
          return IconButton(
            icon: Icon(
              settings.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: AppColors.textGrey,
            ),
            onPressed: settings.toggleTheme,
          );
        }),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textGrey),
          onPressed: () {},
        ),
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

  Widget _buildBottomNav() {
    final settings = Get.find<SettingsController>();
    final bool bn = settings.isBangla;

    return Obx(
      () => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(
            top: BorderSide(color: AppColors.borderDark, width: 0.5),
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
          unselectedItemColor: AppColors.textMuted,
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
      ),
    );
  }
}
