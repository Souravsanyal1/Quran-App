import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/app_binding.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';

class QuranApp extends StatelessWidget {
  final String savedTheme;
  const QuranApp({super.key, required this.savedTheme});

  @override
  Widget build(BuildContext context) {
    ThemeMode initialThemeMode;
    switch (savedTheme) {
      case 'light':
        initialThemeMode = ThemeMode.light;
        break;
      case 'dark':
        initialThemeMode = ThemeMode.dark;
        break;
      default:
        initialThemeMode = ThemeMode.system;
    }

    return GetMaterialApp(
      title: 'Quran App',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: initialThemeMode,

      // Routing
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,

      // Global dependencies
      initialBinding: AppBinding(),

      // Default transition
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // Locale
      locale: const Locale('en'),
      fallbackLocale: const Locale('en'),
    );
  }
}
