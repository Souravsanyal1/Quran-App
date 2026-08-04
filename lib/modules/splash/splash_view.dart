import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'splash_controller.dart';

class _SplashTheme {
  static const Color emerald = Color(0xFF1B5E35);
  static const Color emeraldDark = Color(0xFF0D3B1E);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C97A);
  static const Color inkDark = Color(0xFF141420);
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_SplashTheme.emeraldDark, _SplashTheme.inkDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _SplashTheme.gold.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -60,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _SplashTheme.emerald.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo container
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          _SplashTheme.emerald,
                          _SplashTheme.emeraldDark
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: _SplashTheme.gold, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _SplashTheme.emerald.withValues(alpha: 0.4),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 56,
                      color: _SplashTheme.goldLight,
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 32),

                  // Bismillah
                  const Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: TextStyle(
                      fontSize: 24,
                      color: _SplashTheme.goldLight,
                      fontFamily: 'Uthmanic',
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 16),

                  // App name
                  const Text(
                    'Qurania',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  )
                      .animate(delay: 600.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 8),

                  const Text(
                    'Read · Listen · Reflect',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                      letterSpacing: 3,
                    ),
                  ).animate(delay: 800.ms).fadeIn(duration: 500.ms),

                  const SizedBox(height: 50),

                  // Progress & Status section
                  Obx(() {
                    final percentage =
                        (controller.progress.value * 100).toInt();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48.0),
                      child: Column(
                        children: [
                          // Progress Bar
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: controller.progress.value,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.08),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    _SplashTheme.gold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Status & Percentage Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  controller.statusMessage.value,
                                  style: const TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '$percentage%',
                                style: const TextStyle(
                                  color: _SplashTheme.gold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  })
                      .animate(delay: const Duration(milliseconds: 200))
                      .fadeIn(duration: 400.ms),
                ],
              ),
            ),

            // Version at bottom
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: const Text(
                'Version 1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ).animate(delay: const Duration(seconds: 1)).fadeIn(),
            ),
          ],
        ),
      ),
    );
  }
}
