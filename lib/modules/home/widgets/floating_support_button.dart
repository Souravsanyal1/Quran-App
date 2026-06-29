import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_routes.dart';
import '../../../modules/settings/settings_controller.dart';

// ── Design Tokens (aligned with home_view _QTheme) ───────────────────────────
const Color _emerald = Color(0xFF1B5E35);
const Color _emeraldLight = Color(0xFF2E7D52);
const Color _gold = Color(0xFFC9A84C);
const Color _goldLight = Color(0xFFE8C97A);

/// Floating support/chat button that persists across the home shell.
///
/// Premium pill-shaped FAB with emerald-gold gradient, subtle glow,
/// and a gentle pulse animation on the icon to draw attention.
class FloatingSupportButton extends StatelessWidget {
  const FloatingSupportButton({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final bn = settings.isBangla;
      final isDark = settings.isDark;

      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.support),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [_emerald.withValues(alpha: 0.9), _emeraldLight.withValues(alpha: 0.85)]
                  : [_emerald, _emeraldLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _goldLight.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _emerald.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: _gold.withValues(alpha: 0.1),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing icon
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: _goldLight,
                  size: 18,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.08, 1.08),
                    duration: 1500.ms,
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(width: 10),
              Text(
                bn ? 'সাহায্য' : 'Help',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
