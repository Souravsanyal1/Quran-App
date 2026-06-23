import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'prayer_time_controller.dart';

class PrayerTimeView extends GetView<PrayerTimeController> {
  const PrayerTimeView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(settings.isBangla ? 'নামাজের সময়সূচী' : 'Prayer Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => controller.onInit(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final now = DateTime.now();
        final dateString = DateFormat('EEEE, d MMMM y').format(now);
        final dateBangla = _translateToBanglaDate(dateString);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Next Prayer Banner Card
              _buildCountdownCard(settings, settings.isBangla ? dateBangla : dateString),
              const SizedBox(height: 24),
              
              // Location info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    controller.locationName.value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Prayer List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.prayerTimes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
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
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              settings.isBangla ? 'পরবর্তী নামাজ' : 'Next Prayer',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
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
              style: const TextStyle(color: Colors.white54, fontSize: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isNext
            ? prayerColor.withValues(alpha: 0.12)
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
              Icon(icon, color: isNext ? prayerColor : AppColors.textGrey, size: 24),
              const SizedBox(width: 16),
              Text(
                _translatePrayerName(name, settings.isBangla),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
            ],
          ),
          Text(
            _translateTime(time, settings.isBangla),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isNext ? prayerColor : (isDark ? AppColors.textWhite : AppColors.textDark),
            ),
          ),
        ],
      ),
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
    // Replace English digits with Bangla digits, and AM/PM
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
    // Basic day/month name translation
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
