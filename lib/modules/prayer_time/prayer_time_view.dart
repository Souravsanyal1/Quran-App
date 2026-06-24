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

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(bn ? 'নামাজের সময়সূচী' : 'Prayer Times'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final now = DateTime.now();
        final dateString = DateFormat('EEEE, d MMMM y').format(now);
        final dateBangla = _translateToBanglaDate(dateString);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Next Prayer Banner Card
              _buildCountdownCard(settings, bn ? dateBangla : dateString),
              const SizedBox(height: 20),

              // ── Location Control Panel ─────────────────────────────────────
              Card(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bn ? 'বর্তমান অবস্থান' : 'Current Location',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Obx(() => Text(
                                      controller.locationName.value,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textWhite : AppColors.textDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                              ],
                            ),
                          ),
                          // Select on Map Button
                          IconButton(
                            icon: const Icon(Icons.map_rounded, color: AppColors.primary),
                            tooltip: bn ? 'ম্যাপে খুঁজুন' : 'Select on Map',
                            onPressed: () => Get.toNamed(AppRoutes.locationMap),
                          ),
                          // GPS Auto-detect Button
                          IconButton(
                            icon: Icon(
                              Icons.gps_fixed_rounded,
                              color: controller.isManualLocation.value
                                  ? AppColors.textGrey
                                  : AppColors.primary,
                            ),
                            tooltip: bn ? 'জিপিএস অটো-ডিটেক্ট' : 'Auto Detect GPS',
                            onPressed: () {
                              controller.resetToGPS();
                              Get.snackbar(
                                bn ? 'জিপিএস রিলোড হচ্ছে' : 'GPS Reloading',
                                bn
                                    ? 'অটোমেটিক জিপিএস লোকেশন রিফ্রেশ করা হচ্ছে।'
                                    : 'Refreshing location automatically via GPS.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.9),
                                colorText: isDark ? Colors.black : Colors.white,
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 16, thickness: 0.5),
                      // ── Calculation Method Button ──────────────────────────
                      InkWell(
                        onTap: () => _showCalculationMethodBottomSheet(context, settings),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.settings_suggest_rounded, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    bn ? 'হিসাব পদ্ধতি' : 'Calculation Method',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textWhite : AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Obx(() {
                                    final methodId = controller.calculationMethod.value;
                                    final name = bn
                                        ? PrayerTimeController.calculationMethodsBn[methodId]!
                                        : PrayerTimeController.calculationMethods[methodId]!;
                                    return Text(
                                      name.length > 22 ? '${name.substring(0, 20)}...' : name,
                                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                    );
                                  }),
                                  const Icon(Icons.keyboard_arrow_right_rounded, color: AppColors.textGrey),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Prayer List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.prayerTimes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final key = controller.prayerTimes.keys.elementAt(index);
                  final time = controller.prayerTimes[key]!;
                  final isNext = controller.nextPrayerName.value == key;

                  return _buildPrayerItem(context, settings, key, time, isNext);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCountdownCard(SettingsController settings, String formattedDate) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.nightGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              formattedDate,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              settings.isBangla ? 'পরবর্তী নামাজ' : 'Next Prayer',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Obx(() => Text(
                  _translatePrayerName(controller.nextPrayerName.value, settings.isBangla),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                )),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Obx(() => Text(
                    controller.nextPrayerTimeRemaining.value,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  )),
            ),
            const SizedBox(height: 8),
            Text(
              settings.isBangla ? 'বাকি আছে' : 'remaining',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerItem(BuildContext context, SettingsController settings, String name, String time, bool isNext) {
    final isDark = settings.isDark;

    // Choose specific color for each prayer highlight
    Color prayerColor = AppColors.primary;
    IconData icon = Icons.wb_sunny;

    switch (name) {
      case 'Fajr':
        prayerColor = AppColors.fajr;
        icon = Icons.bedtime;
        break;
      case 'Sunrise':
        prayerColor = AppColors.dhuhr;
        icon = Icons.wb_twilight;
        break;
      case 'Dhuhr':
        prayerColor = AppColors.dhuhr;
        icon = Icons.wb_sunny;
        break;
      case 'Asr':
        prayerColor = AppColors.asr;
        icon = Icons.filter_drama;
        break;
      case 'Maghrib':
        prayerColor = AppColors.maghrib;
        icon = Icons.wb_twilight;
        break;
      case 'Isha':
        prayerColor = AppColors.isha;
        icon = Icons.nights_stay;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNext
            ? prayerColor.withValues(alpha: 0.1)
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext
              ? prayerColor
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isNext ? 1.5 : 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: isNext ? prayerColor : AppColors.textGrey, size: 22),
              const SizedBox(width: 14),
              Text(
                _translatePrayerName(name, settings.isBangla),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                _translateTime(time, settings.isBangla),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isNext ? prayerColor : (isDark ? AppColors.textWhite : AppColors.textDark),
                ),
              ),
              const SizedBox(width: 8),
              // Bell Notification Toggle (Hide for Sunrise)
              if (name != 'Sunrise')
                Obx(() {
                  final isAlertEnabled = controller.azanNotifications[name] ?? true;
                  return IconButton(
                    icon: Icon(
                      isAlertEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_outlined,
                      color: isAlertEnabled ? prayerColor : AppColors.textGrey,
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
                        backgroundColor: prayerColor.withValues(alpha: 0.9),
                        colorText: isDark ? Colors.black : Colors.white,
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                })
              else
                const SizedBox(width: 28), // Placeholder spacer to align with other rows
            ],
          ),
        ],
      ),
    );
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
        return 'এশা';
      default:
        return name;
    }
  }

  String _translateTime(String time, bool isBangla) {
    if (!isBangla) return time;
    var res = time
        .replaceAll('0', '০')
        .replaceAll('1', '১')
        .replaceAll('2', '২')
        .replaceAll('3', '৩')
        .replaceAll('4', '৪')
        .replaceAll('5', '৫')
        .replaceAll('6', '৬')
        .replaceAll('7', '৭')
        .replaceAll('8', '৮')
        .replaceAll('9', '৯')
        .replaceAll('AM', 'ভোর/সকাল')
        .replaceAll('PM', 'দুপুর/বিকাল/রাত');
    return res;
  }

  String _translateToBanglaDate(String date) {
    var res = date
        .replaceAll('Monday', 'সোমবার')
        .replaceAll('Tuesday', 'মঙ্গলবার')
        .replaceAll('Wednesday', 'বুধবার')
        .replaceAll('Thursday', 'বৃহস্পতিবার')
        .replaceAll('Friday', 'শুক্রবার')
        .replaceAll('Saturday', 'শনিবার')
        .replaceAll('Sunday', 'রবিবার')
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
