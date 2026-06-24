import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../modules/settings/settings_controller.dart';
import 'prayer_time_controller.dart';

class PrayerTimeView extends GetView<PrayerTimeController> {
  const PrayerTimeView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;
    final bn = settings.isBangla;
    final now = DateTime.now();

    // Format week day and Gregorian month in Bangla if active
    final String dayOfWeek = DateFormat('EEEE').format(now);
    final String dayAndMonth = DateFormat('d MMMM').format(now);
    final String shortDayOfWeek = _translateDayShort(dayOfWeek, bn);
    final String formattedGregorian = _translateGregorianDate(dayAndMonth, bn);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFFCFBEF),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return Stack(
          children: [
            // ── Background Sunset Gradient (Top Half) ────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.52,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFF59D), // Light warm yellow
                      Color(0xFFFFD54F), // Gold/Amber
                      Color(0xFFFFC107), // Deep amber sunset
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // ── Main Scrollable Body ─────────────────────────────────────────
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header (Date Info, Donation & Bell Icons)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Side: Date Calendar Info
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                              onPressed: () => Get.back(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.calendar_month_outlined, color: Colors.black87, size: 26),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => Text(
                                      controller.hijriDateStr.value.isNotEmpty
                                          ? '$shortDayOfWeek, ${controller.hijriDateStr.value.split(',')[0].trim()}'
                                          : '$shortDayOfWeek, -- --',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    )),
                                const SizedBox(height: 2),
                                Text(
                                  '$formattedGregorian, ${bn ? controller.bengaliDateStr : "Bengali date"}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Right Side: Action Icons
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.volunteer_activism_rounded, color: Colors.black87, size: 24),
                              onPressed: () => Get.toNamed(AppRoutes.donation),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Badge(
                                label: Text(bn ? '৩' : '3'),
                                backgroundColor: const Color(0xFFE91E63),
                                child: const Icon(Icons.notifications_rounded, color: Colors.black87, size: 25),
                              ),
                              onPressed: () => Get.toNamed(AppRoutes.notifications),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 2. Arc Countdown Gauge Semicircle
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Semicircle Sized Gauge
                        Positioned(
                          top: 10,
                          child: SizedBox(
                            width: 220,
                            height: 120,
                            child: CustomPaint(
                              painter: ArcProgressPainter(
                                progress: controller.periodProgress.value,
                                trackColor: Colors.black.withValues(alpha: 0.08),
                                progressColor: const Color(0xFF14302E), // Dark forest/green-black from reference image
                              ),
                            ),
                          ),
                        ),
                        // Overlay Text Inside Semicircle
                        Positioned(
                          top: 45,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Obx(() => Text(
                                    controller.periodName.value,
                                    style: const TextStyle(
                                      color: Color(0xFF14302E),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                              const SizedBox(height: 4),
                              Text(
                                bn ? 'শেষ হতে বাকি' : 'time remaining',
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    controller.periodTimeRemaining.value,
                                    style: const TextStyle(
                                      color: Color(0xFF14302E),
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Location and Sunrise/Sunset Pills Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Location Selector Pill
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.locationMap),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_rounded, color: Colors.black87, size: 16),
                                const SizedBox(width: 6),
                                Obx(() {
                                  final name = controller.locationName.value.split(',')[0];
                                  return Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black87, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Sunrise / Sunset Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wb_sunny_outlined, color: Colors.black87, size: 15),
                              const SizedBox(width: 4),
                              Text(
                                bn ? 'সূর্যোদয়: ' : 'Sunrise: ',
                                style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Obx(() => Text(
                                    _formatTimeWithoutAmPm(controller.sunriseTimeStr.value, bn),
                                    style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                                  )),
                              const SizedBox(width: 8),
                              Text('|', style: TextStyle(color: Colors.black.withValues(alpha: 0.15))),
                              const SizedBox(width: 8),
                              const Icon(Icons.wb_twilight_outlined, color: Colors.black87, size: 15),
                              const SizedBox(width: 4),
                              Text(
                                bn ? 'সূর্যাস্ত: ' : 'Sunset: ',
                                style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Obx(() => Text(
                                    _formatTimeWithoutAmPm(controller.sunsetTimeStr.value, bn),
                                    style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. Bottom Timings Sheet
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161A22) : const Color(0xFF1E252B), // Dark premium background matching reference
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Timings List
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.prayerTimes.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 18),
                          itemBuilder: (context, index) {
                            final key = controller.prayerTimes.keys.elementAt(index);
                            final time = controller.prayerTimes[key]!;
                            final isNext = controller.nextPrayerName.value == key;
                            
                            return _buildRedesignedPrayerItem(context, settings, key, time, isNext);
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Makruh Timing Status footer
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
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Calculation Methods Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () => _showCalculationMethodBottomSheet(context, settings),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.settings_suggest_rounded, color: AppColors.primary, size: 16),
                                  const SizedBox(width: 6),
                                  Obx(() {
                                    final methodId = controller.calculationMethod.value;
                                    final name = bn
                                        ? PrayerTimeController.calculationMethodsBn[methodId]!
                                        : PrayerTimeController.calculationMethods[methodId]!;
                                    return Text(
                                      name.length > 25 ? '${name.substring(0, 23)}...' : name,
                                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
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
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRedesignedPrayerItem(BuildContext context, SettingsController settings, String name, String time, bool isNext) {
    // Icons & Colors matching the dark layout
    IconData icon = Icons.wb_sunny_outlined;
    switch (name) {
      case 'Fajr':
        icon = Icons.filter_drama_outlined;
        break;
      case 'Dhuhr':
        icon = Icons.wb_sunny_outlined;
        break;
      case 'Asr':
        icon = Icons.wb_sunny_rounded;
        break;
      case 'Maghrib':
        icon = Icons.cloud_queue_rounded;
        break;
      case 'Isha':
        icon = Icons.nights_stay_outlined;
        break;
    }

    final bn = settings.isBangla;
    final rangeStr = _getPrayerRange(name, bn);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Prayer Icon + Name
        Row(
          children: [
            Icon(
              icon,
              color: isNext ? AppColors.primary : Colors.white70,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              _translatePrayerName(name, bn),
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                color: isNext ? AppColors.primary : Colors.white,
              ),
            ),
          ],
        ),

        // Range timings + Alert bell icon
        Row(
          children: [
            Text(
              rangeStr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                color: isNext ? AppColors.primary : Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 16),
            Obx(() {
              final isAlertEnabled = controller.azanNotifications[name] ?? true;
              return IconButton(
                icon: Icon(
                  isAlertEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_outlined,
                  color: isAlertEnabled ? (isNext ? AppColors.primary : Colors.white70) : Colors.white24,
                  size: 20,
                ),
                onPressed: () {
                  controller.toggleAzanNotification(name);
                  Get.snackbar(
                    settings.isBangla ? 'নোটিফিকেশন পরিবর্তিত' : 'Alert Changed',
                    settings.isBangla
                        ? '${_translatePrayerName(name, true)} নামাজের জন্য অ্যালার্ট ${isAlertEnabled ? 'বন্ধ' : 'চালু'} করা হয়েছে।'
                        : 'Alert for $name prayer has been ${isAlertEnabled ? 'disabled' : 'enabled'}.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.9),
                    colorText: Colors.black,
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            }),
          ],
        ),
      ],
    );
  }

  String _getPrayerRange(String name, bool isBangla) {
    if (controller.rawPrayerTimings.isEmpty) return '';

    String formatTime(String key) {
      final val = controller.rawPrayerTimings[key] ?? '';
      if (val.isEmpty) return '';
      final parts = val.split(' ')[0].split(':');
      final hour24 = int.parse(parts[0]);
      final minute = parts[1];
      
      final hour12 = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);
      final paddedHour = hour12.toString().padLeft(2, '0');
      
      return '$paddedHour:$minute';
    }

    final fajr = formatTime('Fajr');
    final sunrise = formatTime('Sunrise');
    final dhuhr = formatTime('Dhuhr');
    final asr = formatTime('Asr');
    final maghrib = formatTime('Maghrib');
    final isha = formatTime('Isha');

    String range = '';
    switch (name) {
      case 'Fajr':
        range = '$fajr - $sunrise';
        break;
      case 'Dhuhr':
        range = '$dhuhr - $asr';
        break;
      case 'Asr':
        range = '$asr - $maghrib';
        break;
      case 'Maghrib':
        range = '$maghrib - $isha';
        break;
      case 'Isha':
        range = '$isha - $fajr';
        break;
      default:
        range = '';
    }

    return isBangla ? controller.toBanglaDigits(range) : range;
  }

  void _showCalculationMethodBottomSheet(BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;
    final bn = settings.isBangla;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.textWhite : AppColors.textDark),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                          : null,
                      onTap: () {
                        controller.setCalculationMethod(methodId);
                        Get.back();
                      },
                    );
                  });
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _formatTimeWithoutAmPm(String time12h, bool isBangla) {
    final clean = time12h.replaceAll(' AM', '').replaceAll(' PM', '').trim();
    return isBangla ? controller.toBanglaDigits(clean) : clean;
  }

  String _translatePrayerName(String name, bool isBangla) {
    if (!isBangla) return name;
    switch (name) {
      case 'Fajr':
        return 'ফজর';
      case 'Sunrise':
        return 'সূর্যোদয়';
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

  String _translateDayShort(String day, bool isBangla) {
    if (!isBangla) return day;
    switch (day) {
      case 'Monday':
        return 'সোম';
      case 'Tuesday':
        return 'মঙ্গল';
      case 'Wednesday':
        return 'বুধ';
      case 'Thursday':
        return 'বৃহস্পতি';
      case 'Friday':
        return 'শুক্র';
      case 'Saturday':
        return 'শনি';
      case 'Sunday':
        return 'রবি';
      default:
        return day;
    }
  }

  String _translateGregorianDate(String date, bool isBangla) {
    if (!isBangla) return date;
    var res = date
        .replaceAll('January', 'জানুয়ারি')
        .replaceAll('February', 'ফেব্রুয়ারি')
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
    return res;
  }
}

// ── Custom Arc Progress Painter Gauge ────────────────────────────────────────
class ArcProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  ArcProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final paintTrack = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final paintProgress = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    // Semicircular track (180 degrees arc pointing up)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      paintTrack,
    );

    // Semicircular progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * progress,
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant ArcProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
