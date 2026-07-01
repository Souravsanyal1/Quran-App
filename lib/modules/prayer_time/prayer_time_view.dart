import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'prayer_time_controller.dart';

// ── Design Tokens (matches Duas & Azkar screen) ─────────────────────────────
class _PTheme {
  _PTheme._();
  static const Color emerald      = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark  = Color(0xFF0D3B1E);
  static const Color gold         = Color(0xFFC9A84C);
  static const Color goldLight    = Color(0xFFE8C97A);
  static const Color goldSoft     = Color(0xFFFFF8E7);
  static const Color darkSurface  = Color(0xFF141420);
  static const Color darkCard     = Color(0xFF1E1E2E);
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard    = Color(0xFFFFFFFF);
}

// ── View ────────────────────────────────────────────────────────────────
class PrayerTimeView extends GetView<PrayerTimeController> {
  const PrayerTimeView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.isDark;
      final bn = settings.isBangla;
      final scaffoldBg = isDark ? _PTheme.darkSurface : _PTheme.lightSurface;
      final nextPrayer = controller.prayers.isNotEmpty
          ? controller.prayers[controller.nextPrayerIndex.value]
          : null;

      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          leading: const AppBackButton(color: Colors.white),
          elevation: 0,
          flexibleSpace: ClipRect(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_PTheme.emeraldDark, _PTheme.emerald, _PTheme.emeraldLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(bottom: BorderSide(color: _PTheme.gold, width: 1.5)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -10,
                    bottom: -25,
                    child: Icon(
                      Icons.mosque,
                      size: 90,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: -15,
                    child: Icon(
                      Icons.star_half_rounded,
                      size: 50,
                      color: _PTheme.gold.withValues(alpha: 0.06),
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: Text(
            bn ? 'নামাজের সময়সূচি' : 'Prayer Times',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Location + Date header ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.locationMap),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: _PTheme.gold, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        controller.locationName.value,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppColors.textDark,
                          decoration: TextDecoration.underline,
                          decorationColor: _PTheme.gold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_location_alt_outlined, color: _PTheme.gold, size: 16),
                    ],
                  ),
                ),
                Text(
                  controller.hijriDate.value,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : AppColors.textGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Next prayer countdown hero card ─────────────────────
            if (nextPrayer != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_PTheme.emeraldDark, _PTheme.emerald, _PTheme.emeraldLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _PTheme.gold.withValues(alpha: 0.6), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: _PTheme.emerald.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      top: -10,
                      child: Icon(Icons.mosque, size: 90, color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          bn ? 'পরবর্তী নামাজ' : 'NEXT PRAYER',
                          style: GoogleFonts.poppins(
                            color: _PTheme.goldLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bn ? nextPrayer.nameBn : nextPrayer.nameEn,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.formatTime(nextPrayer.time, bn),
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time_rounded, color: _PTheme.gold, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                controller.formatCountdown(controller.countdown.value, bn),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 22),

            Text(
              bn ? 'আজকের নামাজ' : "Today's Schedule",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),

            // ── Prayer list ──────────────────────────────────────────
            ...List.generate(controller.prayers.length, (index) {
              final p = controller.prayers[index];
              final isActive = index == controller.activePrayerIndex.value;
              final isNext = index == controller.nextPrayerIndex.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? _PTheme.darkCard : _PTheme.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isNext
                        ? _PTheme.gold
                        : (isDark ? _PTheme.emerald.withValues(alpha: 0.15) : _PTheme.emerald.withValues(alpha: 0.08)),
                    width: isNext ? 1.4 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _PTheme.emerald.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? const LinearGradient(colors: [_PTheme.emerald, _PTheme.emeraldLight])
                              : null,
                          color: isActive ? null : (isDark ? _PTheme.darkSurface : _PTheme.goldSoft),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          p.icon,
                          color: isActive ? Colors.white : _PTheme.emerald,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  bn ? p.nameBn : p.nameEn,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.5,
                                    color: isDark ? Colors.white : AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _PTheme.emerald.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      bn ? 'চলমান' : 'Current',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _PTheme.emerald,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              p.arabicName,
                              style: TextStyle(
                                fontFamily: 'Uthmanic',
                                fontSize: 13,
                                color: isDark ? _PTheme.goldLight : _PTheme.emerald.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        controller.formatTime(p.time, bn),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isNext
                              ? _PTheme.gold
                              : (isDark ? Colors.white70 : AppColors.textDark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}
