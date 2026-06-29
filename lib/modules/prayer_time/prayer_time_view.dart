import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/app_back_button.dart';
import 'prayer_time_controller.dart';

class PrayerTimeView extends GetView<PrayerTimeController> {
  const PrayerTimeView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.themeMode.value == 'dark';
      final bn = settings.language.value == 'bn';

      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF141420) : const Color(0xFFFAF8F5),
        body: Obx(() {
          if (controller.isLoading.value) {
            return _PrayerLoadingWidget(isDark: isDark, bn: bn);
          }

          return Stack(
            children: [
              // 1. Background Layers (Gradient, Glow, and Mosque Silhouette)
              _buildScreenBackground(context, isDark),

              // 2. Scrollable Body Contents
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Navigation Bar
                      _buildHeader(context, isDark, bn, settings),
                      const SizedBox(height: 8),

                      // Centered Location Dropdown Pill
                      _buildLocationPill(isDark, bn),
                      const SizedBox(height: 12),

                      // Premium Next Prayer Card with Arc Semicircle Progress
                      _buildNextPrayerCard(context, bn),
                      const SizedBox(height: 8),

                      // Today's Prayer Times Card
                      _buildTodayPrayerTimesCard(context, isDark, bn, settings),
                      
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

  // ── Background Decorator ───────────────────────────────────────────────────
  Widget _buildScreenBackground(BuildContext context, bool isDark) {
    final Color glowColor = isDark
        ? const Color(0xFF1B5E35).withOpacity(0.12)
        : const Color(0xFFFFF4E0).withOpacity(0.8);
    final Color silhouetteColor = isDark
        ? const Color(0xFF1A2A20)
        : const Color(0xFFE2EDE8);

    return Stack(
      children: [
        // 1. Background Gradient
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

        // 2. Sunrise / Moon Glow (Top Right)
        Positioned(
          top: -100,
          right: -50,
          width: 320,
          height: 320,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glowColor,
                  glowColor.withOpacity(0.0),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),

        // 3. Mosque Silhouette (Across middle-top background)
        Positioned(
          top: MediaQuery.of(context).size.height * 0.06,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.35,
          child: CustomPaint(
            painter: _MosqueBackgroundPainter(
              color: silhouetteColor,
            ),
          ),
        ),
      ],
    );
  }

  // ── Header Navigation Bar ──────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool isDark, bool bn, SettingsController settings) {
    final Color headerFg = isDark ? Colors.white : const Color(0xFF0D3B1E);
    final Color headerFgMuted = isDark
        ? Colors.white.withOpacity(0.6)
        : const Color(0xFF1B5E35).withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Back Button
          AppBackButton(color: headerFg),

          // Center Title + Subtitle
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bn ? 'নামাজের সময়সূচী' : 'Prayer Times',
                  style: GoogleFonts.philosopher(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: headerFg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bn ? 'আসসালামু আলাইকুম' : 'Assalamu Alaikum',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: headerFgMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Right Bell Icon (Triggers settings sheet)
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: headerFg,
              size: 24,
            ),
            onPressed: () {
              _showCalculationMethodSheet(context, settings);
            },
          ),
        ],
      ),
    );
  }

  // ── Centered Location Dropdown Pill ────────────────────────────────────────
  Widget _buildLocationPill(bool isDark, bool bn) {
    final Color pillBg = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFF1B5E35).withOpacity(0.08);
    final Color pillText = isDark ? Colors.white : const Color(0xFF1B5E35);

    return Center(
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.locationMap),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFF1B5E35).withOpacity(0.1),
              width: 1,
            ),
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
              Icon(Icons.keyboard_arrow_down_rounded, color: pillText, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Premium Next Prayer Card ───────────────────────────────────────────────
  Widget _buildNextPrayerCard(BuildContext context, bool bn) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0D3B1E),
              Color(0xFF1B5E35),
              Color(0xFF2E7D52),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D3B1E).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bn ? 'পরবর্তী নামাজ' : 'Next Prayer',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(() => Text(
                        _translatePrayerName(controller.nextPrayerName.value, bn),
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                        controller.periodTimeRemaining.value,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFE8C97A),
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      )),
                  const SizedBox(height: 8),
                  Obx(() {
                    final nextName = controller.nextPrayerName.value;
                    final timeStr = controller.prayerTimes[nextName] ?? '';
                    final formattedTime = _formatPrayerTime(timeStr, bn);
                    
                    final String dayAndMonth = DateFormat('d MMMM yyyy').format(DateTime.now());
                    final String formattedGregorian = _translateGregorianDate(dayAndMonth, bn);
                    
                    return Text(
                      '$formattedTime • $formattedGregorian',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        controller.hijriDateStr.value,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFFF8E7).withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                ],
              ),
            ),

            // Right CustomPaint solar arc progress
            const SizedBox(width: 8),
            Obx(() => CustomPaint(
                  size: const Size(130, 110),
                  painter: SunArcPathPainter(
                    progress: controller.periodProgress.value,
                    pathColor: Colors.white,
                    sunColor: const Color(0xFFE8C97A),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ── Today's Prayer Times Card ──────────────────────────────────────────────
  Widget _buildTodayPrayerTimesCard(BuildContext context, bool isDark, bool bn, SettingsController settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bn ? 'আজকের নামাজের সময়' : "Today's Prayer Times",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF0D3B1E),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: isDark ? Colors.white60 : const Color(0xFF1B5E35),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _translateGregorianDate(DateFormat('d MMM yyyy').format(DateTime.now()), bn),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : const Color(0xFF1B5E35),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF1B5E35),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Prayer List
            _buildPrayerList(context, settings, isDark, bn),

            const SizedBox(height: 16),
            Divider(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
            const SizedBox(height: 12),

            // Makruh footer
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Text(
                        controller.makruhTimeStr.value,
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.white60 : const Color(0xFF2E7D52),
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      )),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Calculation method selector
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => _showCalculationMethodSheet(context, settings),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                          Icons.settings_suggest_rounded,
                          color: Color(0xFF1B5E35),
                          size: 15),
                      const SizedBox(width: 6),
                      Obx(() {
                        final methodId = controller.calculationMethod.value;
                        final name = bn
                            ? PrayerTimeController.calculationMethodsBn[methodId]!
                            : PrayerTimeController.calculationMethods[methodId]!;
                        return Flexible(
                          child: Text(
                            name,
                            style: GoogleFonts.poppins(
                              color: isDark ? Colors.white60 : const Color(0xFF2E7D52),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

  // ── Dynamic Prayer List Builder ────────────────────────────────────────────
  Widget _buildPrayerList(BuildContext context, SettingsController settings, bool isDark, bool bn) {
    final List<Map<String, dynamic>> items = [
      {
        'key': 'Fajr',
        'nameEn': 'Fajr',
        'nameBn': 'ফজর',
        'time': controller.prayerTimes['Fajr'] ?? '',
        'icon': Icons.wb_twilight_rounded,
        'bgLight': const Color(0xFFE3F2FD),
        'bgDark': const Color(0xFF0D2535),
        'fg': const Color(0xFF1E88E5),
        'isPrayer': true,
      },
      {
        'key': 'Sunrise',
        'nameEn': 'Sunrise',
        'nameBn': 'সূর্যোদয়',
        'time': controller.sunriseTimeStr.value,
        'icon': Icons.wb_sunny_rounded,
        'bgLight': const Color(0xFFFFF3E0),
        'bgDark': const Color(0xFF35220D),
        'fg': const Color(0xFFFB8C00),
        'isPrayer': false,
      },
      {
        'key': 'Dhuhr',
        'nameEn': 'Dhuhr',
        'nameBn': 'যোহর',
        'time': controller.prayerTimes['Dhuhr'] ?? '',
        'icon': Icons.wb_sunny_outlined,
        'bgLight': const Color(0xFFE8F5E9),
        'bgDark': const Color(0xFF0D3517),
        'fg': const Color(0xFF43A047),
        'isPrayer': true,
      },
      {
        'key': 'Asr',
        'nameEn': 'Asr',
        'nameBn': 'আসর',
        'time': controller.prayerTimes['Asr'] ?? '',
        'icon': Icons.wb_cloudy_rounded,
        'bgLight': const Color(0xFFEDE7F6),
        'bgDark': const Color(0xFF220D35),
        'fg': const Color(0xFF5E35B1),
        'isPrayer': true,
      },
      {
        'key': 'Maghrib',
        'nameEn': 'Maghrib',
        'nameBn': 'মাগরিব',
        'time': controller.prayerTimes['Maghrib'] ?? '',
        'icon': Icons.wb_twilight_outlined,
        'bgLight': const Color(0xFFFBE9E7),
        'bgDark': const Color(0xFF35120D),
        'fg': const Color(0xFFF4511E),
        'isPrayer': true,
      },
      {
        'key': 'Isha',
        'nameEn': 'Isha',
        'nameBn': 'ইশা',
        'time': controller.prayerTimes['Isha'] ?? '',
        'icon': Icons.nights_stay_rounded,
        'bgLight': const Color(0xFFECEFF1),
        'bgDark': const Color(0xFF1E272C),
        'fg': const Color(0xFF546E7A),
        'isPrayer': true,
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final key = item['key'] as String;
        final name = bn ? item['nameBn'] as String : item['nameEn'] as String;
        final rawTime = item['time'] as String;
        final isPrayer = item['isPrayer'] as bool;
        final isNext = controller.nextPrayerName.value == key;
        
        final formattedTime = _formatPrayerTime(rawTime, bn);
        
        final itemBg = isDark ? item['bgDark'] as Color : item['bgLight'] as Color;
        final itemFg = item['fg'] as Color;
        
        final isHighlight = isNext && isPrayer;
        
        return Container(
          decoration: BoxDecoration(
            color: isHighlight
                ? (isDark ? const Color(0xFF1B5E35).withOpacity(0.2) : const Color(0xFFE8F5E9))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              // Left Icon Container
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: itemBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: itemFg,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              
              // Name
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                    fontSize: 15,
                    color: isHighlight
                        ? (isDark ? Colors.white : const Color(0xFF0D3B1E))
                        : (isDark ? Colors.white80 : Colors.black87),
                  ),
                ),
              ),
              
              // Time
              Text(
                formattedTime,
                style: GoogleFonts.poppins(
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14.5,
                  color: isHighlight
                      ? (isDark ? Colors.white : const Color(0xFF0D3B1E))
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
              const SizedBox(width: 16),
              
              // Right Action Widget
              SizedBox(
                width: 32,
                height: 32,
                child: !isPrayer
                    ? Icon(
                        Icons.do_not_disturb_alt_rounded,
                        color: isDark ? Colors.white24 : Colors.black12,
                        size: 18,
                      )
                    : isHighlight
                        ? Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B5E35),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          )
                        : Obx(() {
                            final isAlertEnabled = controller.azanNotifications[key] ?? true;
                            return IconButton(
                              icon: Icon(
                                isAlertEnabled
                                    ? Icons.notifications_none_rounded
                                    : Icons.notifications_off_outlined,
                                color: isAlertEnabled
                                    ? (isDark ? Colors.white54 : Colors.black54)
                                    : (isDark ? Colors.white24 : Colors.black12),
                                size: 18,
                              ),
                              onPressed: () {
                                controller.toggleAzanNotification(key);
                                Get.snackbar(
                                  settings.isBangla ? 'নোটিফিকেশন পরিবর্তিত' : 'Alert Changed',
                                  settings.isBangla
                                      ? '$name নামাজের জন্য অ্যালার্ট ${isAlertEnabled ? 'বন্ধ' : 'চালু'} করা হয়েছে।'
                                      : 'Alert for $key prayer has been ${isAlertEnabled ? 'disabled' : 'enabled'}.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFF1B5E35).withOpacity(0.9),
                                  colorText: Colors.white,
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            );
                          }),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Calculation Method Selector Sheet ──────────────────────────────────────
  void _showCalculationMethodSheet(BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;
    final bn = settings.isBangla;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              bn ? 'হিসাব পদ্ধতি নির্বাচন করুন' : 'Select Calculation Method',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: PrayerTimeController.calculationMethods.keys.map((methodId) {
                  final name = bn
                      ? PrayerTimeController.calculationMethodsBn[methodId]!
                      : PrayerTimeController.calculationMethods[methodId]!;
                  return Obx(() {
                    final isSelected = controller.calculationMethod.value == methodId;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF1B5E35)
                              : (isDark ? AppColors.textWhite : AppColors.textDark),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1B5E35), size: 20)
                          : null,
                      onTap: () {
                        controller.setCalculationMethod(methodId);
                      },
                    );
                  });
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            const SizedBox(height: 8),
            Text(
              bn ? 'আসরের ওয়াক্ত গণনা পদ্ধতি' : 'Asr Time Calculation School',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Obx(() {
              final isHanafi = controller.asrSchool.value == 1;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  bn ? 'হানাফী (আসরের ওয়াক্ত পরে শুরু হয়)' : 'Hanafi (Asr starts later)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isHanafi ? FontWeight.bold : FontWeight.normal,
                    color: isHanafi
                        ? const Color(0xFF1B5E35)
                        : (isDark ? AppColors.textWhite : AppColors.textDark),
                  ),
                ),
                trailing: isHanafi
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1B5E35), size: 20)
                    : null,
                onTap: () {
                  controller.setAsrSchool(1);
                },
              );
            }),
            Obx(() {
              final isStandard = controller.asrSchool.value == 0;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  bn
                      ? 'শাফেয়ী / সাধারণ (আসরের ওয়াক্ত আগে শুরু হয়)'
                      : 'Shafi\'i / Standard (Asr starts earlier)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isStandard ? FontWeight.bold : FontWeight.normal,
                    color: isStandard
                        ? const Color(0xFF1B5E35)
                        : (isDark ? AppColors.textWhite : AppColors.textDark),
                  ),
                ),
                trailing: isStandard
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1B5E35), size: 20)
                    : null,
                onTap: () {
                  controller.setAsrSchool(0);
                },
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                bn ? 'ঠিক আছে' : 'OK',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ── Local Helpers ──────────────────────────────────────────────────────────
  String _formatPrayerTime(String time12h, bool isBangla) {
    if (time12h.isEmpty) return '--:--';
    if (!isBangla) return time12h;
    
    String formatted = time12h
        .replaceAll('0', '০').replaceAll('1', '১').replaceAll('2', '২')
        .replaceAll('3', '৩').replaceAll('4', '৪').replaceAll('5', '৫')
        .replaceAll('6', '৬').replaceAll('7', '৭').replaceAll('8', '৮')
        .replaceAll('9', '৯');

    if (formatted.toUpperCase().contains('AM')) {
      formatted = formatted.toUpperCase().replaceAll('AM', 'এএম');
    } else if (formatted.toUpperCase().contains('PM')) {
      formatted = formatted.toUpperCase().replaceAll('PM', 'পিএম');
    }
    return formatted;
  }

  String _translatePrayerName(String name, bool isBangla) {
    if (!isBangla) return name;
    switch (name) {
      case 'Fajr':
        return 'ফজর';
      case 'Sunrise':
        return 'সূর্যোদয়';
      case 'Dhuhr':
        return 'যোহর';
      case 'Asr':
        return 'আসর';
      case 'Maghrib':
        return 'মাগরিব';
      case 'Isha':
        return 'ইশা';
      default:
        return name;
    }
  }

  String _translateGregorianDate(String date, bool isBangla) {
    if (!isBangla) return date;
    return date
        .replaceAll('January', 'জানুয়ারি')
        .replaceAll('February', 'ফেব্রুয়ারি')
        .replaceAll('March', 'মার্চ')
        .replaceAll('April', 'এপ্রিল')
        .replaceAll('May', 'মে')
        .replaceAll('June', 'জুন')
        .replaceAll('July', 'জুলাই')
        .replaceAll('August', 'আগস্ট')
        .replaceAll('September', 'সেপ্টেম্বর')
        .replaceAll('October', 'অক্টোবর')
        .replaceAll('November', 'নভেম্বর')
        .replaceAll('December', 'ডিসেম্বর')
        .replaceAll('Jan', 'জানু')
        .replaceAll('Feb', 'ফেব্রু')
        .replaceAll('Mar', 'মার্চ')
        .replaceAll('Apr', 'এপ্রিল')
        .replaceAll('May', 'মে')
        .replaceAll('Jun', 'জুন')
        .replaceAll('Jul', 'জুলাই')
        .replaceAll('Aug', 'আগস্ট')
        .replaceAll('Sep', 'সেপ্টে')
        .replaceAll('Oct', 'অক্টো')
        .replaceAll('Nov', 'নভে')
        .replaceAll('Dec', 'ডিসে')
        .replaceAll('0', '০')
        .replaceAll('1', '১')
        .replaceAll('2', '২')
        .replaceAll('3', '৩')
        .replaceAll('4', '৪')
        .replaceAll('5', '৫')
        .replaceAll('6', '৬')
        .replaceAll('7', '৭')
        .replaceAll('8', '৮')
        .replaceAll('9', '৯');
  }
}

// ── Mosque Background Custom Painter ─────────────────────────────────────────
class _MosqueBackgroundPainter extends CustomPainter {
  final Color color;

  _MosqueBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Start drawing bottom left
    path.moveTo(0, h);

    // Far left minaret
    path.lineTo(0, h * 0.7);
    path.lineTo(w * 0.08, h * 0.7);
    path.lineTo(w * 0.08, h * 0.55);
    path.quadraticBezierTo(w * 0.1, h * 0.51, w * 0.12, h * 0.55);
    path.lineTo(w * 0.12, h * 0.7);
    path.lineTo(w * 0.18, h * 0.7);

    // Left dome
    path.lineTo(w * 0.18, h * 0.65);
    path.quadraticBezierTo(w * 0.28, h * 0.55, w * 0.38, h * 0.65);
    path.lineTo(w * 0.38, h * 0.75);

    // Middle main dome
    path.lineTo(w * 0.38, h * 0.55);
    path.cubicTo(w * 0.42, h * 0.45, w * 0.46, h * 0.38, w * 0.5, h * 0.35); // spire tip
    path.cubicTo(w * 0.54, h * 0.38, w * 0.58, h * 0.45, w * 0.62, h * 0.55);
    path.lineTo(w * 0.62, h * 0.75);

    // Right dome
    path.lineTo(w * 0.62, h * 0.65);
    path.quadraticBezierTo(w * 0.72, h * 0.55, w * 0.82, h * 0.65);
    path.lineTo(w * 0.82, h * 0.7);

    // Far right minaret
    path.lineTo(w * 0.88, h * 0.7);
    path.lineTo(w * 0.88, h * 0.55);
    path.quadraticBezierTo(w * 0.9, h * 0.51, w * 0.92, h * 0.55);
    path.lineTo(w * 0.92, h * 0.7);
    path.lineTo(w, h * 0.7);

    path.lineTo(w, h);
    path.close();

    canvas.drawPath(path, paint);

    // Draw some stylized birds flying in the background
    final birdPaint = Paint()
      ..color = color.withOpacity(color.opacity * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    _drawBird(canvas, w * 0.15, h * 0.22, 10, birdPaint);
    _drawBird(canvas, w * 0.22, h * 0.17, 7, birdPaint);
    _drawBird(canvas, w * 0.78, h * 0.15, 12, birdPaint);
    _drawBird(canvas, w * 0.85, h * 0.20, 9, birdPaint);
  }

  void _drawBird(Canvas canvas, double x, double y, double size, Paint paint) {
    final path = Path()
      ..moveTo(x - size, y + size * 0.2)
      ..quadraticBezierTo(x - size * 0.5, y - size * 0.5, x, y)
      ..quadraticBezierTo(x + size * 0.5, y - size * 0.5, x + size, y + size * 0.2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MosqueBackgroundPainter oldDelegate) => oldDelegate.color != color;
}

// ── Sun Arc Path Painter for Next Prayer Card ────────────────────────────────
class SunArcPathPainter extends CustomPainter {
  final double progress;
  final Color pathColor;
  final Color sunColor;

  SunArcPathPainter({
    required this.progress,
    required this.pathColor,
    required this.sunColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Define control points for the bezier arc
    final p0 = Offset(16, h - 8);
    final p1 = Offset(w / 2, 8);
    final p2 = Offset(w - 16, h - 8);

    // 1. Draw mosque dome silhouette at the bottom of the card
    final domePaint = Paint()
      ..color = pathColor.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    final domePath = Path();
    domePath.moveTo(16, h);
    domePath.lineTo(16, h - 16);
    domePath.quadraticBezierTo(w * 0.25, h - 24, w * 0.35, h - 16);
    domePath.cubicTo(w * 0.42, h - 38, w * 0.58, h - 38, w * 0.65, h - 16);
    domePath.quadraticBezierTo(w * 0.75, h - 24, w * 0.84, h - 16);
    domePath.lineTo(w - 16, h);
    domePath.close();
    canvas.drawPath(domePath, domePaint);

    // 2. Draw dashed path for the sun
    final pathPaint = Paint()
      ..color = pathColor.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const segments = 40;
    for (int i = 0; i < segments; i++) {
      if (i % 2 == 0) {
        final tStart = i / segments;
        final tEnd = (i + 1) / segments;
        final start = _getBezierPoint(p0, p1, p2, tStart);
        final end = _getBezierPoint(p0, p1, p2, tEnd);
        canvas.drawLine(start, end, pathPaint);
      }
    }

    // 3. Draw nodes (dots representing prayer times) along the path
    final nodePaint = Paint()
      ..color = pathColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    final nodeBorderPaint = Paint()
      ..color = pathColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final nodePositions = [0.0, 0.25, 0.5, 0.75, 1.0];
    for (final t in nodePositions) {
      final pos = _getBezierPoint(p0, p1, p2, t);
      canvas.drawCircle(pos, 3.5, nodePaint);
      canvas.drawCircle(pos, 4.5, nodeBorderPaint);
    }

    // 4. Draw active sun position
    final sunPos = _getBezierPoint(p0, p1, p2, progress);

    // Glow effect
    final glowPaint = Paint()
      ..color = sunColor.withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(sunPos, 14, glowPaint);

    // Sun core
    final sunCorePaint = Paint()
      ..color = sunColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunPos, 5.5, sunCorePaint);

    // Sun rays
    final rayPaint = Paint()
      ..color = sunColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const rayCount = 8;
    const rayLength = 11.5;
    const rayStart = 7.5;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi) / rayCount;
      final startOffset = Offset(math.cos(angle) * rayStart, math.sin(angle) * rayStart);
      final endOffset = Offset(math.cos(angle) * rayLength, math.sin(angle) * rayLength);
      canvas.drawLine(sunPos + startOffset, sunPos + endOffset, rayPaint);
    }
  }

  Offset _getBezierPoint(Offset p0, Offset p1, Offset p2, double t) {
    final x = (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx;
    final y = (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy;
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant SunArcPathPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.pathColor != pathColor ||
      oldDelegate.sunColor != sunColor;
}

// ── Prayer Loading Widget Shimmer ────────────────────────────────────────────
class _PrayerLoadingWidget extends StatefulWidget {
  final bool isDark;
  final bool bn;
  const _PrayerLoadingWidget({required this.isDark, required this.bn});

  @override
  State<_PrayerLoadingWidget> createState() => _PrayerLoadingWidgetState();
}

class _PrayerLoadingWidgetState extends State<_PrayerLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;
  int _step = 0;
  static const _steps = [0.15, 0.40, 0.65, 0.85, 1.0];

  final List<String> _statusBn = [
    'অবস্থান শনাক্ত করা হচ্ছে...',
    'নামাজের সময় লোড হচ্ছে...',
    'ডেটা প্রক্রিয়া করা হচ্ছে...',
    'নোটিফিকেশন সেট করা হচ্ছে...',
    'প্রস্তুত!',
  ];
  final List<String> _statusEn = [
    'Detecting location...',
    'Loading prayer times...',
    'Processing data...',
    'Setting notifications...',
    'Ready!',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnim = Tween<double>(begin: 0.0, end: _steps[0]).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
    _advanceStep();
  }

  void _advanceStep() async {
    for (int i = 0; i < _steps.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _step = i + 1;
        _progressAnim = Tween<double>(
          begin: _steps[i],
          end: _steps[i + 1],
        ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
      });
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? AppColors.bgDark : const Color(0xFFFCFBEF);

    return Container(
      color: bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShimmerLoading.circular(height: 40, width: 40),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading.rounded(height: 18, width: 150),
                      const SizedBox(height: 6),
                      ShimmerLoading.rounded(height: 14, width: 100),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              Center(
                child: Column(
                  children: [
                    ShimmerLoading.circular(height: 150, width: 150),
                    const SizedBox(height: 24),
                    ShimmerLoading.rounded(height: 24, width: 120),
                    const SizedBox(height: 12),
                    ShimmerLoading.rounded(height: 16, width: 80),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerLoading.rounded(height: 36, width: 120, borderRadius: 18),
                  const SizedBox(width: 12),
                  ShimmerLoading.rounded(height: 36, width: 140, borderRadius: 18),
                ],
              ),
              const Spacer(),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: List.generate(5, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ShimmerLoading.circular(height: 24, width: 24),
                            const SizedBox(width: 16),
                            ShimmerLoading.rounded(height: 16, width: 80),
                          ],
                        ),
                        ShimmerLoading.rounded(height: 16, width: 100),
                      ],
                    ),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
