import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'home_controller.dart';
import 'widgets/app_drawer.dart';
import 'widgets/home_dashboard.dart';
import 'widgets/floating_support_button.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.isDark;
      final bool bn = settings.isBangla;

      return Scaffold(
        backgroundColor:
            isDark ? AppColors.bgDark : AppColors.bgLight,
        drawer: const AppDrawer(),
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, size: 24),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              tooltip: bn ? 'মেনু' : 'Menu',
            ),
          ),
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                bn ? 'কুরআন অ্যাপ' : 'Quran App',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
              onPressed: settings.toggleTheme,
              tooltip: isDark
                  ? (bn ? 'লাইট মোড' : 'Light Mode')
                  : (bn ? 'ডার্ক মোড' : 'Dark Mode'),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: const HomeDashboard(),
        floatingActionButton: const FloatingSupportButton(),
      );
    });
  }
}