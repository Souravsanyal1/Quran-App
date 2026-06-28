import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/shimmer_loading.dart';
import 'prayer_time_controller.dart';

class PrayerTimeView extends GetView<PrayerTimeController> {
  const PrayerTimeView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    // Wrap everything in Obx so the whole page rebuilds whenever
    // themeMode OR language changes — the two reactive sources used here.
    return Obx(() {
      final isDark = settings.themeMode.value == 'dark';
      final bn = settings.language.value == 'bn';
      final now = DateTime.now();

      // ── Theme-aware colours ───────────────────────────────────────────────
      final Color headerFg = isDark ? Colors.white : Colors.black87;
      final Color headerFgMuted = isDark
          ? Colors.white.withValues(alpha: 0.6)
          : Colors.black.withValues(alpha: 0.6);

      final Color gaugeTextColor =
          isDark ? Colors.white : const Color(0xFF14302E);
      final Color gaugeTextMuted = isDark
          ? Colors.white.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.5);
      final Color gaugeProgressColor =
          isDark ? AppColors.primary : const Color(0xFF14302E);
      final Color gaugeTrackColor = isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.black.withValues(alpha: 0.08);

      final Color pillBg = isDark
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.black.withValues(alpha: 0.08);
      final Color pillText = isDark ? Colors.white : Colors.black87;
      final Color pillTextMuted = isDark ? Colors.white70 : Colors.black54;
      final Color pillDivider = isDark
          ? Colors.white.withValues(alpha: 0.2)
          : Colors.black.withValues(alpha: 0.2);

      final Color sheetBg =
          isDark ? const Color(0xFF161A22) : const Color(0xFFF7F7F7);

      final Color sheetTextMuted = isDark ? Colors.white60 : Colors.black54;

      // Date strings (non-reactive, computed once per rebuild)
      final String dayOfWeek = DateFormat('EEEE').format(now);
      final String dayAndMonth = DateFormat('d MMMM yyyy').format(now);
      final String formattedGregorian =
          _translateGregorianDate(dayAndMonth, bn);

      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFFCFBEF),
        body: Obx(() {
          if (controller.isLoading.value) {
            return _PrayerLoadingWidget(isDark: isDark, bn: bn);
          }

          return Stack(
            children: [
              // ── Background Gradient (Top Half) ──────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [
                              Color(0xFF0D1B2A),
                              Color(0xFF1B3A4B),
                              Color(0xFF1A3C34),
                            ]
                          : const [
                              Color(0xFFFFF59D),
                              Color(0xFFFFD54F),
                              Color(0xFFFFC107),
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // ── Main Body ───────────────────────────────────────────────
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header — back button + dates only
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: headerFg,
                              size: 20,
                            ),
                            onPressed: () => Get.back(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.calendar_month_outlined,
                              color: headerFg, size: 26),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => Text(
                                      controller.hijriDateStr.value.isNotEmpty
                                          ? '${_translateDayShort(dayOfWeek, bn)}, ${controller.hijriDateStr.value}'
                                          : '${_translateDayShort(dayOfWeek, bn)}, -- --',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: headerFg,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                const SizedBox(height: 2),
                                Text(
                                  '$formattedGregorian, ${controller.bengaliDateStr}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: headerFgMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Arc Countdown Gauge Semicircle
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 10,
                            child: SizedBox(
                              width: 220,
                              height: 120,
                              child: Obx(() => CustomPaint(
                                    painter: ArcProgressPainter(
                                      progress:
                                          controller.periodProgress.value,
                                      trackColor: gaugeTrackColor,
                                      progressColor: gaugeProgressColor,
                                    ),
                                  )),
                            ),
                          ),
                          Positioned(
                            top: 45,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(() => Text(
                                      controller.periodName.value,
                                      style: TextStyle(
                                        color: gaugeTextColor,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                const SizedBox(height: 4),
                                Obx(() => Text(
                                      controller.isPeriodActive.value
                                          ? (bn ? 'শেষ হতে বাকি' : 'time remaining')
                                          : (bn ? 'শুরু হতে বাকি' : 'time until start'),
                                      style: TextStyle(
                                        color: gaugeTextMuted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                const SizedBox(height: 4),
                                Obx(() => Text(
                                      controller.periodTimeRemaining.value,
                                      style: TextStyle(
                                        color: gaugeTextColor,
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

                    // 3. Location + Sunrise/Sunset Pills Row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Location pill
                          Flexible(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () =>
                                  Get.toNamed(AppRoutes.locationMap),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: pillBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on_rounded,
                                        color: pillText, size: 15),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Obx(() {
                                        final name = controller
                                            .locationName.value
                                            .split(',')[0];
                                        return Text(
                                          name,
                                          style: TextStyle(
                                            color: pillText,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        );
                                      }),
                                    ),
                                    Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: pillText,
                                        size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Sunrise / Sunset pill
                          Flexible(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: pillBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.wb_sunny_outlined,
                                        color: pillText, size: 14),
                                    const SizedBox(width: 3),
                                    Text('↑ ',
                                        style: TextStyle(
                                            color: pillTextMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                    Obx(() => Text(
                                          _formatTimeWithoutAmPm(
                                              controller
                                                  .sunriseTimeStr.value,
                                              bn),
                                          style: TextStyle(
                                              color: pillText,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Text('|',
                                          style: TextStyle(
                                              color: pillDivider)),
                                    ),
                                    Icon(Icons.wb_twilight_outlined,
                                        color: pillText, size: 14),
                                    const SizedBox(width: 3),
                                    Text('↓ ',
                                        style: TextStyle(
                                            color: pillTextMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                    Obx(() => Text(
                                          _formatTimeWithoutAmPm(
                                              controller
                                                  .sunsetTimeStr.value,
                                              bn),
                                          style: TextStyle(
                                              color: pillText,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 4. Bottom Timings Sheet
                    Container(
                      decoration: BoxDecoration(
                        color: sheetBg,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.prayerTimes.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 18),
                            itemBuilder: (context, index) {
                              final key = controller.prayerTimes.keys
                                  .elementAt(index);
                              final time = controller.prayerTimes[key]!;
                              final isNext =
                                  controller.nextPrayerName.value == key;
                              return _buildPrayerItem(
                                  settings, isDark, bn, key, time, isNext);
                            },
                          ),
                          const SizedBox(height: 16),

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
                                      style: TextStyle(
                                        color: sheetTextMuted,
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    )),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Calculation method selector
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () =>
                                  _showCalculationMethodSheet(context, settings),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                        Icons.settings_suggest_rounded,
                                        color: AppColors.primary,
                                        size: 16),
                                    const SizedBox(width: 6),
                                    Obx(() {
                                      final methodId = controller
                                          .calculationMethod.value;
                                      final name = bn
                                          ? PrayerTimeController
                                              .calculationMethodsBn[
                                                  methodId]!
                                          : PrayerTimeController
                                              .calculationMethods[
                                                  methodId]!;
                                      return Flexible(
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                              color: sheetTextMuted,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold),
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
                  ],
                ),
              ),
            ],
          );
        }),
      );
    });
  }

  Widget _buildPrayerItem(SettingsController settings, bool isDark, bool bn, String name,
      String time, bool isNext) {
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

    final rangeStr = _getPrayerRange(name, bn);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon,
                  color: isNext ? AppColors.primary : (isDark ? Colors.white70 : Colors.black54), size: 24),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  _translatePrayerName(name, bn),
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                    color: isNext ? AppColors.primary : (isDark ? Colors.white : Colors.black87),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            Text(
              rangeStr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                color: isNext ? AppColors.primary : (isDark ? Colors.white : Colors.black87),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 16),
            Obx(() {
              final isAlertEnabled =
                  controller.azanNotifications[name] ?? true;
              return IconButton(
                icon: Icon(
                  isAlertEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_outlined,
                  color: isAlertEnabled
                      ? (isNext ? AppColors.primary : (isDark ? Colors.white70 : Colors.black54))
                      : (isDark ? Colors.white24 : Colors.black12),
                  size: 20,
                ),
                onPressed: () {
                  controller.toggleAzanNotification(name);
                  Get.snackbar(
                    settings.isBangla
                        ? 'নোটিফিকেশন পরিবর্তিত'
                        : 'Alert Changed',
                    settings.isBangla
                        ? '${_translatePrayerName(name, true)} নামাজের জন্য অ্যালার্ট ${isAlertEnabled ? 'বন্ধ' : 'চালু'} করা হয়েছে।'
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
    final start = controller.prayerTimes[name] ?? '';
    if (start.isEmpty) return '';

    String end = '';
    switch (name) {
      case 'Fajr':
        end = controller.sunriseTimeStr.value;
        break;
      case 'Dhuhr':
        end = controller.prayerTimes['Asr'] ?? '';
        break;
      case 'Asr':
        end = controller.prayerTimes['Maghrib'] ?? '';
        break;
      case 'Maghrib':
        end = controller.prayerTimes['Isha'] ?? '';
        break;
      case 'Isha':
        end = controller.prayerTimes['Fajr'] ?? '';
        break;
    }

    if (end.isEmpty) {
      return _formatPrayerTime(start, isBangla);
    }

    return '${_formatPrayerTime(start, isBangla)} - ${_formatPrayerTime(end, isBangla)}';
  }

  String _formatPrayerTime(String time12h, bool isBangla) {
    // Strip AM/PM for compact display so prayer names are never truncated
    final clean = time12h
        .replaceAll(' AM', '')
        .replaceAll(' PM', '')
        .replaceAll(' am', '')
        .replaceAll(' pm', '')
        .trim();
    return isBangla ? controller.toBanglaDigits(clean) : clean;
  }

  void _showCalculationMethodSheet(
      BuildContext context, SettingsController settings) {
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
              bn
                  ? 'হিসাব পদ্ধতি নির্বাচন করুন'
                  : 'Select Calculation Method',
              style: TextStyle(
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
                children: PrayerTimeController.calculationMethods.keys
                    .map((methodId) {
                  final name = bn
                      ? PrayerTimeController
                          .calculationMethodsBn[methodId]!
                      : PrayerTimeController
                          .calculationMethods[methodId]!;
                  return Obx(() {
                    final isSelected =
                        controller.calculationMethod.value == methodId;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.textWhite
                                  : AppColors.textDark),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.primary, size: 20)
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
              bn
                  ? 'আসরের ওয়াক্ত গণনা পদ্ধতি'
                  : 'Asr Time Calculation School',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Hanafi option
            Obx(() {
              final isHanafi = controller.asrSchool.value == 1;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  bn ? 'হানাফী (আসরের ওয়াক্ত পরে শুরু হয়)' : 'Hanafi (Asr starts later)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isHanafi ? FontWeight.bold : FontWeight.normal,
                    color: isHanafi
                        ? AppColors.primary
                        : (isDark ? AppColors.textWhite : AppColors.textDark),
                  ),
                ),
                trailing: isHanafi
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 20)
                    : null,
                onTap: () {
                  controller.setAsrSchool(1);
                },
              );
            }),
            // Shafi'i / Standard option
            Obx(() {
              final isStandard = controller.asrSchool.value == 0;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: Text(
                  bn
                      ? 'শাফেয়ী / সাধারণ (আসরের ওয়াক্ত আগে শুরু হয়)'
                      : 'Shafi\'i / Standard (Asr starts earlier)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isStandard ? FontWeight.bold : FontWeight.normal,
                    color: isStandard
                        ? AppColors.primary
                        : (isDark ? AppColors.textWhite : AppColors.textDark),
                  ),
                ),
                trailing: isStandard
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 20)
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                bn ? 'ঠিক আছে' : 'OK',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _formatTimeWithoutAmPm(String time12h, bool isBangla) {
    final clean =
        time12h.replaceAll(' AM', '').replaceAll(' PM', '').trim();
    return isBangla ? controller.toBanglaDigits(clean) : clean;
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



  /// Short weekday label used in the compact prayer-time header.
  String _translateDayShort(String day, bool isBangla) {
    if (!isBangla) return day.length >= 3 ? day.substring(0, 3) : day;
    switch (day) {
      case 'Monday':
        return 'সোম';
      case 'Tuesday':
        return 'মঙ্গল';
      case 'Wednesday':
        return 'বুধ';
      case 'Thursday':
        return 'বৃহঃ';
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

// ── Prayer Loading Widget ──────────────────────────────────────────────────────
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
              // Header Shimmer
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
              const SizedBox(height: 60),
              
              // Gauge Shimmer
              Center(
                child: Column(
                  children: [
                    ShimmerLoading.circular(height: 180, width: 180),
                    const SizedBox(height: 24),
                    ShimmerLoading.rounded(height: 24, width: 120),
                    const SizedBox(height: 12),
                    ShimmerLoading.rounded(height: 16, width: 80),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              
              // Pills Shimmer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerLoading.rounded(height: 36, width: 120, borderRadius: 18),
                  const SizedBox(width: 12),
                  ShimmerLoading.rounded(height: 36, width: 140, borderRadius: 18),
                ],
              ),
              const Spacer(),
              
              // Bottom List Shimmer
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

// ── Arc Progress Painter ───────────────────────────────────────────────────────
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

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi,
        math.pi, false, paintTrack);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi,
        math.pi * progress, false, paintProgress);
  }

  @override
  bool shouldRepaint(covariant ArcProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
