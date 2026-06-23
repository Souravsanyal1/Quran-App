import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/app_binding.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Quran App',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

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
