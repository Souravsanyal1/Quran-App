import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_routes.dart';
import '../settings/settings_controller.dart';
import 'prayer_time_controller.dart';

// ─── App Colors ───────────────────────────────────────────────────────────────
class AppColors {
  static const Color primaryGreen = Color(0xFF1B5E35);
  static const Color darkGreen = Color(0xFF0D3B1E);
  static const Color deepGreen = Color(0xFF072413);
  static const Color gold = Color(0xFFFFD700);

  static Color surfaceDark = const Color(0xFF1E1E2E);
  static Color surfaceLight = Colors.white;
  static Color bgDark = const Color(0xFF141420);
  static Color textWhite = Colors.white;
  static Color textDark = const Color(0xFF0D3B1E);
  static Color borderDark = Colors.white12;
  static Color borderLight = Colors.black12;
}

// ─── Main View ────────────────────────────────────────────────────────────────
class PrayerTimeView extends StatelessWidget {
  const PrayerTimeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controllers if not already registered
    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController());
    }
    if (!Get.isRegistered<PrayerTimeController>()) {
      Get.put(PrayerTimeController());
    }

    final settings = Get.find<SettingsController>();
    final controller = Get.find<PrayerTimeController>();

    return Obx(() {
      final isDark = settings.themeMode.value == 'dark';
      final bn = settings.language.value == 'bn';

      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF141420) : const Color(0xFFFAF8F5),
        body: Obx(() {
          if (controller.isLoading.value) {
            return _PrayerLoadingWidget(isDark: isDark, bn: bn);
          }
          return Stack(
            children: [
              _buildScreenBackground(context, isDark),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context, isDark, bn, settings, controller),
                      const SizedBox(height: 8),
                      _buildLocationPill(isDark, bn, controller),
                      const SizedBox(height: 12),
                      _buildNextPrayerCard(context, bn, controller),
                      const SizedBox(height: 8),
                      _buildTodayPrayerTimesCard(
                          context, isDark, bn, settings, controller),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      );
    });
  }

  // ── Background ─────────────────────────────────────────────────────────────
  Widget _buildScreenBackground(BuildContext context, bool isDark) {
    final glowColor = isDark
        ? const Color(0xFF1B5E35).withOpacity(0.12)
        : const Color(0xFFFFF4E0).withOpacity(0.8);
    final silhouetteColor =
        isDark ? const Color(0xFF1A2A20) : const Color(0xFFE2EDE8);

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [
                        Color(0xFF0F1915),
                        Color(0xFF14201A),
                        Color(0xFF141420),
                      ]
                    : const [
                        Color(0xFFEDF5F1),
                        Color(0xFFFAFBF9),
                        Colors.white,
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        // Sun glow top-right
        Positioned(
          top: -100,
          right: -50,
          width: 320,
          height: 320,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [glowColor, glowColor.withOpacity(0.0)],
              ),
            ),
          ),
        ),
        // Mosque silhouette
        Positioned(
          top: MediaQuery.of(context).size.height * 0.06,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.35,
          child: Opacity(
            opacity: isDark ? 0.08 : 0.13,
            child: CustomPaint(
              painter: _MosqueSilhouettePainter(color: silhouetteColor),
            ),
          ),
        ),
        // Flying birds
        Positioned(
          top: MediaQuery.of(context).size.height * 0.13,
          left: 36,
          child: _BirdsWidget(
              color:
                  isDark ? const Color(0xFF4A7C5E) : const Color(0xFF5A8A6A)),
        ),
        // Sun circle top-right
        Positioned(
          top: MediaQuery.of(context).size.height * 0.06,
          right: 30,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFFFFF4E0).withOpacity(0.18)
                  : const Color(0xFFFFF4E0).withOpacity(0.95),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFF4E0).withOpacity(0.5),
                  blurRadius: 24,
                  spreadRadius: 8,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    bool bn,
    SettingsController settings,
    PrayerTimeController controller,
  ) {
    final fg = isDark ? Colors.white : AppColors.darkGreen;
    final fgMuted = isDark
        ? Colors.white.withOpacity(0.6)
        : AppColors.primaryGreen.withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button with premium circle
          _iconBtn(
            Icons.arrow_back_ios_new_rounded,
            fg,
            isDark,
            () => Get.back(),
          ),

          // Center title
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bn ? 'নামাজের সময়সূচী' : 'Prayer Times',
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bn ? 'আসসালামু আলাইকুম' : 'Assalamu Alaikum',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: fgMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

          // Bell with premium circle (Redirects to notifications)
          _iconBtn(
            Icons.notifications_none_rounded,
            fg,
            isDark,
            () => Get.toNamed(AppRoutes.notifications),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, bool isDark, VoidCallback onTap) {
    final btnBg = isDark
        ? Colors.white.withOpacity(0.08)
        : AppColors.primaryGreen.withOpacity(0.06);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : AppColors.primaryGreen.withOpacity(0.1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: btnBg,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ── Location Pill ──────────────────────────────────────────────────────────
  Widget _buildLocationPill(
      bool isDark, bool bn, PrayerTimeController controller) {
    final pillBg = isDark
        ? Colors.white.withOpacity(0.08)
        : AppColors.primaryGreen.withOpacity(0.08);
    final pillText = isDark ? Colors.white : AppColors.primaryGreen;
    final borderColor =
        isDark ? Colors.white10 : AppColors.primaryGreen.withOpacity(0.12);

    return Center(
      child: GestureDetector(
        onTap: () {}, // Navigate to location picker
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_rounded, color: pillText, size: 16),
              const SizedBox(width: 6),
              Obx(() {
                final name = controller.locationName.value.split(',')[0];
                return Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: pillText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: pillText, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Next Prayer Card ───────────────────────────────────────────────────────
  Widget _buildNextPrayerCard(
      BuildContext context, bool bn, PrayerTimeController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 240, // Slightly reduced to be more compact
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF072413),
              Color(0xFF0D3B1E),
              Color(0xFF1B5E35),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF072413).withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Horizon Mosque Watermark (Bottom Anchored)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.18,
                child: Image.asset(
                  'assets/images/mosque_silhouette.png',
                  color: Colors.white,
                  fit: BoxFit.fitWidth,
                  height: 100,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
            
            // Content Overlay
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  // Left: Countdown & Labels
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                          ),
                          child: Text(
                            bn ? 'পরবর্তী নামাজ' : 'UPCOMING PRAYER',
                            style: GoogleFonts.poppins(
                              color: AppColors.gold,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(() => Text(
                          _translatePrayer(controller.nextPrayerName.value, bn),
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 30, // Reduced from 32
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        )),
                        const SizedBox(height: 2),
                        Obx(() => FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            controller.periodTimeRemaining.value,
                            style: (bn ? GoogleFonts.hindSiliguri : GoogleFonts.poppins)(
                              color: AppColors.gold,
                              fontSize: bn ? 32 : 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: bn ? 2.0 : 1.2,
                            ),
                          ),
                        )),
                        const SizedBox(height: 12),
                        // Small Time & Date Pill
                        Obx(() {
                          final t = controller.prayerTimes[controller.nextPrayerName.value] ?? '';
                          final formattedDate = DateFormat('dd MMM yyyy', bn ? 'bn' : 'en').format(controller.selectedDate.value);
                          return Row(
                            children: [
                              Icon(Icons.access_time_rounded, color: Colors.white.withOpacity(0.6), size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '$t  •  $formattedDate',
                                  style: (bn ? GoogleFonts.hindSiliguri : GoogleFonts.poppins)(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: bn ? 12 : 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  // Right: Sun/Moon Animation & Hijri
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() {
                          final prog = controller.dayNightProgress.value;
                          final isDay = controller.isDayTime.value;

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: prog),
                            duration: const Duration(milliseconds: 1600),
                            curve: Curves.easeInOutCubic,
                            builder: (_, val, __) => CustomPaint(
                              size: const Size(110, 90), // Reduced from 130, 110
                              painter: SunArcPainter(
                                progress: val,
                                pathColor: Colors.white.withOpacity(0.45),
                                sunColor: !isDay ? Colors.white : AppColors.gold,
                                isNight: !isDay,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            controller.hijriDateStr.value,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 9, // Reduced from 10
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Today's Prayer Times Card ──────────────────────────────────────────────
  Widget _buildTodayPrayerTimesCard(
    BuildContext context,
    bool isDark,
    bool bn,
    SettingsController settings,
    PrayerTimeController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Card header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    bn ? 'আজকের নামাজের সময়' : "Today's Prayer Times",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : AppColors.darkGreen,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.selectedDate.value,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (ctx, child) => Theme(
                        data: isDark
                            ? ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: AppColors.gold,
                                  onPrimary: AppColors.darkGreen,
                                  surface: AppColors.surfaceDark,
                                  onSurface: Colors.white,
                                ),
                                dialogBackgroundColor: AppColors.surfaceDark,
                              )
                            : ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primaryGreen,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: AppColors.darkGreen,
                                ),
                                dialogBackgroundColor: Colors.white,
                              ),
                        child: child!,
                      ),
                    );
                    if (picked != null) controller.selectDate(picked);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 14,
                            color: isDark
                                ? Colors.white60
                                : AppColors.primaryGreen),
                        const SizedBox(width: 6),
                        Obx(() {
                          final formattedDate = DateFormat('dd MMM yyyy', bn ? 'bn' : 'en').format(controller.selectedDate.value);
                          return Text(
                            formattedDate,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: isDark
                                ? Colors.white60
                                : AppColors.primaryGreen),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Prayer list ──
            _PrayerListWidget(
                isDark: isDark,
                bn: bn,
                settings: settings,
                controller: controller),

            const SizedBox(height: 14),
            Divider(
                color:
                    isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
            const SizedBox(height: 12),

            // ── Makruh warning ──
            Obx(() {
              final txt = controller.makruhTimeStr.value;
              if (txt.isEmpty) return const SizedBox.shrink();
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2E1C0A).withOpacity(0.4)
                      : const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.amber.withOpacity(0.15)
                        : Colors.amber.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.amber, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        txt,
                        style: GoogleFonts.poppins(
                          color: isDark
                              ? Colors.amber.shade200
                              : const Color(0xFF6D4C41),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // ── Calculation method ──
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () =>
                    _showCalcMethodSheet(context, settings, controller),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.settings_suggest_rounded,
                          color: AppColors.primaryGreen, size: 15),
                      const SizedBox(width: 6),
                      Obx(() {
                        final id = controller.calculationMethod.value;
                        final name = bn
                            ? PrayerTimeController.calculationMethodsBn[id]!
                            : PrayerTimeController.calculationMethods[id]!;
                        return Text(
                          name,
                          style: GoogleFonts.poppins(
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF2E7D52),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Calculation Method Bottom Sheet ────────────────────────────────────────
  void _showCalcMethodSheet(
    BuildContext context,
    SettingsController settings,
    PrayerTimeController controller,
  ) {
    final isDark = settings.isDark;
    final bn = settings.isBangla;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              bn ? 'হিসাব পদ্ধতি নির্বাচন করুন' : 'Select Calculation Method',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children:
                    PrayerTimeController.calculationMethods.keys.map((id) {
                  final name = bn
                      ? PrayerTimeController.calculationMethodsBn[id]!
                      : PrayerTimeController.calculationMethods[id]!;
                  return Obx(() {
                    final selected = controller.calculationMethod.value == id;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal,
                          color: selected
                              ? AppColors.primaryGreen
                              : (isDark ? Colors.white : AppColors.darkGreen),
                        ),
                      ),
                      trailing: selected
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.primaryGreen, size: 20)
                          : null,
                      onTap: () => controller.setCalculationMethod(id),
                    );
                  });
                }).toList(),
              ),
            ),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 8),
            Text(
              bn ? 'আসরের ওয়াক্ত গণনা পদ্ধতি' : 'Asr Time Calculation School',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final isHanafi = controller.asrSchool.value == 1;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  bn
                      ? 'হানাফী (আসরের ওয়াক্ত পরে শুরু হয়)'
                      : 'Hanafi (Asr starts later)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isHanafi ? FontWeight.bold : FontWeight.normal,
                    color: isHanafi
                        ? AppColors.primaryGreen
                        : (isDark ? Colors.white : AppColors.darkGreen),
                  ),
                ),
                trailing: isHanafi
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primaryGreen, size: 20)
                    : null,
                onTap: () => controller.setAsrSchool(1),
              );
            }),
            Obx(() {
              final isStd = controller.asrSchool.value == 0;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  bn
                      ? "শাফেয়ী / সাধারণ (আসরের ওয়াক্ত আগে শুরু হয়)"
                      : "Shafi'i / Standard (Asr starts earlier)",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isStd ? FontWeight.bold : FontWeight.normal,
                    color: isStd
                        ? AppColors.primaryGreen
                        : (isDark ? Colors.white : AppColors.darkGreen),
                  ),
                ),
                trailing: isStd
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primaryGreen, size: 20)
                    : null,
                onTap: () => controller.setAsrSchool(0),
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                bn ? 'ঠিক আছে' : 'OK',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _translatePrayer(String name, bool bn) {
    if (!bn) return name;
    const map = {
      'Fajr': 'ফজর',
      'Sunrise': 'সূর্যোদয়',
      'Dhuhr': 'যোহর',
      'Asr': 'আসর',
      'Maghrib': 'মাগরিব',
      'Isha': 'ইশা',
    };
    return map[name] ?? name;
  }
}

// ─── Prayer List Widget ───────────────────────────────────────────────────────
class _PrayerListWidget extends StatelessWidget {
  final bool isDark;
  final bool bn;
  final SettingsController settings;
  final PrayerTimeController controller;

  const _PrayerListWidget({
    required this.isDark,
    required this.bn,
    required this.settings,
    required this.controller,
  });

  static const _prayers = [
    {
      'key': 'Fajr',
      'nameEn': 'Fajr',
      'nameBn': 'ফজর',
      'icon': Icons.wb_twilight_rounded,
      'bgLight': Color(0xFFE3F2FD),
      'bgDark': Color(0xFF0D2535),
      'fg': Color(0xFF1E88E5),
      'isPrayer': true,
    },
    {
      'key': 'Sunrise',
      'nameEn': 'Sunrise',
      'nameBn': 'সূর্যোদয়',
      'icon': Icons.wb_sunny_rounded,
      'bgLight': Color(0xFFFFF3E0),
      'bgDark': Color(0xFF35220D),
      'fg': Color(0xFFFB8C00),
      'isPrayer': false,
    },
    {
      'key': 'Dhuhr',
      'nameEn': 'Dhuhr',
      'nameBn': 'যোহর',
      'icon': Icons.wb_sunny_outlined,
      'bgLight': Color(0xFFE8F5E9),
      'bgDark': Color(0xFF0D3517),
      'fg': Color(0xFF43A047),
      'isPrayer': true,
    },
    {
      'key': 'Asr',
      'nameEn': 'Asr',
      'nameBn': 'আসর',
      'icon': Icons.wb_cloudy_rounded,
      'bgLight': Color(0xFFEDE7F6),
      'bgDark': Color(0xFF220D35),
      'fg': Color(0xFF5E35B1),
      'isPrayer': true,
    },
    {
      'key': 'Maghrib',
      'nameEn': 'Maghrib',
      'nameBn': 'মাগরিব',
      'icon': Icons.wb_twilight_outlined,
      'bgLight': Color(0xFFFBE9E7),
      'bgDark': Color(0xFF35120D),
      'fg': Color(0xFFF4511E),
      'isPrayer': true,
    },
    {
      'key': 'Isha',
      'nameEn': 'Isha',
      'nameBn': 'ইশা',
      'icon': Icons.nights_stay_rounded,
      'bgLight': Color(0xFFECEFF1),
      'bgDark': Color(0xFF1E272C),
      'fg': Color(0xFF546E7A),
      'isPrayer': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final nextName = controller.nextPrayerName.value;
      return Column(
        children: List.generate(_prayers.length, (i) {
          final item = _prayers[i];
          final key = item['key'] as String;
          final name = bn ? item['nameBn'] as String : item['nameEn'] as String;
          final isPrayer = item['isPrayer'] as bool;
          final isNext = nextName == key;
          final isHighlight = isNext && isPrayer;
          final icon = item['icon'] as IconData;
          final iconBg =
              isDark ? item['bgDark'] as Color : item['bgLight'] as Color;
          final iconFg = item['fg'] as Color;

          final rawTime = key == 'Sunrise'
              ? controller.sunriseTimeStr.value
              : (controller.prayerTimes[key] ?? '');

          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: isHighlight
                  ? (isDark
                      ? AppColors.primaryGreen.withOpacity(0.15)
                      : const Color(0xFFE8F5E9))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHighlight
                    ? AppColors.gold.withOpacity(0.32)
                    : Colors.transparent,
                width: 1.2,
              ),
              boxShadow: isHighlight
                  ? [
                      BoxShadow(
                        color: AppColors.primaryGreen
                            .withOpacity(isDark ? 0.2 : 0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconFg, size: 18),
                  ),
                  const SizedBox(width: 14),

                  // Name
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight:
                            isHighlight ? FontWeight.bold : FontWeight.w500,
                        color: isHighlight
                            ? (isDark ? Colors.white : AppColors.darkGreen)
                            : (isDark
                                ? Colors.white.withOpacity(0.8)
                                : Colors.black87),
                      ),
                    ),
                  ),

                  // Time
                  Text(
                    rawTime.isEmpty ? '--:--' : rawTime,
                    style: GoogleFonts.poppins(
                      fontSize: 14.5,
                      fontWeight:
                          isHighlight ? FontWeight.bold : FontWeight.w500,
                      color: isHighlight
                          ? (isDark ? Colors.white : AppColors.darkGreen)
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Bell / action
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: !isPrayer
                        ? Icon(
                            Icons.do_not_disturb_alt_rounded,
                            color: isDark ? Colors.white24 : Colors.black12,
                            size: 18,
                          )
                        : Obx(() {
                            final on =
                                controller.azanNotifications[key] ?? true;
                            if (isHighlight) {
                              return GestureDetector(
                                onTap: () {
                                  controller.toggleAzanNotification(key);
                                  Get.snackbar(
                                    on ? 'Alert Off' : 'Alert On',
                                    '$key prayer alert ${on ? 'disabled' : 'enabled'}.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor:
                                        AppColors.primaryGreen.withOpacity(0.9),
                                    colorText: Colors.white,
                                  );
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    on
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_off_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              );
                            }
                            return GestureDetector(
                              onTap: () {
                                controller.toggleAzanNotification(key);
                                Get.snackbar(
                                  on ? 'Alert Off' : 'Alert On',
                                  '$key prayer alert ${on ? 'disabled' : 'enabled'}.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor:
                                      AppColors.primaryGreen.withOpacity(0.9),
                                  colorText: Colors.white,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: on
                                      ? (isDark ? Colors.white.withOpacity(0.08) : AppColors.primaryGreen.withOpacity(0.06))
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: on
                                        ? AppColors.primaryGreen.withOpacity(0.2)
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  on
                                      ? Icons.notifications_none_rounded
                                      : Icons.notifications_off_outlined,
                                  color: on
                                      ? (isDark ? Colors.white70 : AppColors.primaryGreen)
                                      : (isDark ? Colors.white24 : Colors.black12),
                                  size: 18,
                                ),
                              ),
                            );
                          }),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    });
  }
}

// ─── Sun Arc Painter ──────────────────────────────────────────────────────────
class SunArcPainter extends CustomPainter {
  final double progress;
  final Color pathColor;
  final Color sunColor;
  final bool isNight;

  const SunArcPainter({
    required this.progress,
    required this.pathColor,
    required this.sunColor,
    this.isNight = false,
  });

  Offset _bez(Offset p0, Offset p1, Offset p2, double t) {
    final x =
        (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx;
    final y =
        (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy;
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p0 = Offset(16, h - 16);
    final p1 = Offset(w / 2, 16);
    final p2 = Offset(w - 16, h - 16);

    // Cleaner dashed arc path
    final dashPaint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
      
    final Path path = Path();
    path.moveTo(p0.dx, p0.dy);
    path.quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);
    
    // Draw dashed effect manually for better control
    for (double i = 0; i < 1.0; i += 0.05) {
      final start = _bez(p0, p1, p2, i);
      final end = _bez(p0, p1, p2, i + 0.025);
      canvas.drawLine(start, end, dashPaint);
    }

    // Node dots for prayer sequence (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha)
    final nodeFill = Paint()
      ..color = pathColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    for (final t in [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]) {
      final p = _bez(p0, p1, p2, t);
      canvas.drawCircle(p, 2.5, nodeFill);
    }

    // Baseline
    canvas.drawLine(
      Offset(10, h - 16),
      Offset(w - 10, h - 16),
      Paint()
        ..color = pathColor.withOpacity(0.4)
        ..strokeWidth = 1.5,
    );

    // Current Position (Sun or Moon)
    final pos = _bez(p0, p1, p2, progress);
    
    if (isNight) {
      // Realistic Crescent Moon
      canvas.drawCircle(
        pos,
        16,
        Paint()
          ..color = Colors.white.withOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      
      final moonPaint = Paint()..color = Colors.white;
      
      // Draw moon as a path (crescent shape)
      final moonPath = Path.combine(
        PathOperation.difference,
        Path()..addOval(Rect.fromCircle(center: pos, radius: 11)),
        Path()..addOval(Rect.fromCircle(center: pos + const Offset(-3.5, -2.5), radius: 11)),
      );
      canvas.drawPath(moonPath, moonPaint);
    } else {
      // Sun
      // Glow
      canvas.drawCircle(
        pos,
        14,
        Paint()
          ..color = sunColor.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // Core
      canvas.drawCircle(pos, 6, Paint()..color = sunColor);
      // Rays
      final rayPaint = Paint()
        ..color = sunColor.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < 8; i++) {
        final angle = i * 2 * math.pi / 8;
        canvas.drawLine(
          pos + Offset(math.cos(angle) * 8, math.sin(angle) * 8),
          pos + Offset(math.cos(angle) * 12, math.sin(angle) * 12),
          rayPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(SunArcPainter old) =>
      old.progress != progress ||
      old.pathColor != pathColor ||
      old.sunColor != sunColor ||
      old.isNight != isNight;
}

// ─── Mosque Silhouette Painter ────────────────────────────────────────────────
class _MosqueSilhouettePainter extends CustomPainter {
  final Color color;
  const _MosqueSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.68)
      ..lineTo(w * 0.07, h * 0.68)
      ..lineTo(w * 0.07, h * 0.52)
      ..quadraticBezierTo(w * 0.095, h * 0.47, w * 0.12, h * 0.52)
      ..lineTo(w * 0.12, h * 0.68)
      ..lineTo(w * 0.18, h * 0.68)
      ..lineTo(w * 0.18, h * 0.62)
      ..quadraticBezierTo(w * 0.28, h * 0.52, w * 0.38, h * 0.62)
      ..lineTo(w * 0.38, h * 0.72)
      ..lineTo(w * 0.38, h * 0.52)
      ..cubicTo(w * 0.43, h * 0.42, w * 0.47, h * 0.35, w * 0.5, h * 0.32)
      ..cubicTo(w * 0.53, h * 0.35, w * 0.57, h * 0.42, w * 0.62, h * 0.52)
      ..lineTo(w * 0.62, h * 0.72)
      ..lineTo(w * 0.62, h * 0.62)
      ..quadraticBezierTo(w * 0.72, h * 0.52, w * 0.82, h * 0.62)
      ..lineTo(w * 0.82, h * 0.68)
      ..lineTo(w * 0.88, h * 0.68)
      ..lineTo(w * 0.88, h * 0.52)
      ..quadraticBezierTo(w * 0.905, h * 0.47, w * 0.93, h * 0.52)
      ..lineTo(w * 0.93, h * 0.68)
      ..lineTo(w, h * 0.68)
      ..lineTo(w, h)
      ..close();

    canvas.drawPath(path, p);

    // Crescent on main dome
    final crescentPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final crescentX = w * 0.5;
    final crescentY = h * 0.28;
    final tip = Path()
      ..moveTo(crescentX, crescentY - 12)
      ..lineTo(crescentX - 3, crescentY)
      ..lineTo(crescentX + 3, crescentY)
      ..close();
    canvas.drawPath(tip, crescentPaint);
  }

  @override
  bool shouldRepaint(_MosqueSilhouettePainter old) => old.color != color;
}

// ─── Birds Widget ─────────────────────────────────────────────────────────────
class _BirdsWidget extends StatelessWidget {
  final Color color;
  const _BirdsWidget({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(80, 40),
      painter: _BirdsPainter(color: color),
    );
  }
}

class _BirdsPainter extends CustomPainter {
  final Color color;
  const _BirdsPainter({required this.color});

  void _bird(Canvas c, double x, double y, double s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(x - s, y + s * 0.2)
      ..quadraticBezierTo(x - s * 0.5, y - s * 0.5, x, y)
      ..quadraticBezierTo(x + s * 0.5, y - s * 0.5, x + s, y + s * 0.2);
    c.drawPath(path, p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _bird(canvas, 10, 20, 9);
    _bird(canvas, 28, 12, 7);
    _bird(canvas, 50, 18, 10);
    _bird(canvas, 68, 8, 6);
  }

  @override
  bool shouldRepaint(_BirdsPainter old) => old.color != color;
}

// ─── Loading Shimmer ──────────────────────────────────────────────────────────
class _PrayerLoadingWidget extends StatefulWidget {
  final bool isDark;
  final bool bn;
  const _PrayerLoadingWidget({required this.isDark, required this.bn});

  @override
  State<_PrayerLoadingWidget> createState() => _PrayerLoadingWidgetState();
}

class _PrayerLoadingWidgetState extends State<_PrayerLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _shimmer = Tween(begin: -1.0, end: 2.0).animate(_anim);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _box(double w, double h, {double r = 8}) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        return Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            gradient: LinearGradient(
              begin: Alignment(_shimmer.value - 1, 0),
              end: Alignment(_shimmer.value + 1, 0),
              colors: widget.isDark
                  ? [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.05),
                    ]
                  : [
                      Colors.black.withOpacity(0.04),
                      Colors.black.withOpacity(0.09),
                      Colors.black.withOpacity(0.04),
                    ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _box(40, 40, r: 20),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _box(150, 18),
                const SizedBox(height: 6),
                _box(100, 14),
              ]),
            ]),
            const SizedBox(height: 40),
            Center(
              child: Column(children: [
                _box(150, 150, r: 75),
                const SizedBox(height: 20),
                _box(120, 24),
                const SizedBox(height: 10),
                _box(80, 16),
              ]),
            ),
            const Spacer(),
            ...List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      _box(24, 24, r: 12),
                      const SizedBox(width: 16),
                      _box(80, 16),
                    ]),
                    _box(100, 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Entry Point (for standalone testing) ────────────────────────────────────
void main() {
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prayer Times',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primaryGreen,
      ),
      home: const PrayerTimeView(),
    ),
  );
}
