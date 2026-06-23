import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'tracker_controller.dart';

class TrackerView extends GetView<TrackerController> {
  const TrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(settings.isBangla ? 'ইবাদত ট্র্যাকার' : 'Deen Tracker'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final rate = controller.todayCompletionRate;
        final completedCount = controller.todayRecords.values.where((v) => v).length;
        final totalCount = controller.todayRecords.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Today's Progress Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 50.0,
                      lineWidth: 8.0,
                      percent: rate,
                      center: Text(
                        '${(rate * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      progressColor: Colors.white,
                      backgroundColor: Colors.white24,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.isBangla ? 'আজকের অগ্রগতি' : "Today's Progress",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            settings.isBangla
                                ? '$completedCount / $totalCount ইবাদত সম্পন্ন হয়েছে'
                                : '$completedCount / $totalCount activities completed',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Checklist Section Title
              Text(
                settings.isBangla ? 'দৈনিক ইবাদত তালিকা' : 'Daily Checklist',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Checklist Items
              ...controller.todayRecords.keys.map((activity) {
                final isDone = controller.todayRecords[activity] ?? false;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDone
                          ? AppColors.primary
                          : (settings.isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: isDone ? 1.5 : 0.5,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: isDone,
                    onChanged: (val) => controller.toggleRecord(activity),
                    activeColor: AppColors.primary,
                    checkColor: Colors.black,
                    title: Text(
                      _getActivityName(activity, settings.isBangla),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                      ),
                    ),
                    subtitle: Text(
                      _getActivitySubtitle(activity, settings.isBangla),
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                    secondary: Icon(
                      activity == 'Quran' ? Icons.menu_book : Icons.nights_stay_outlined,
                      color: isDone ? AppColors.primary : AppColors.textGrey,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  String _getActivityName(String key, bool isBangla) {
    if (!isBangla) return key == 'Quran' ? 'Quran Reading' : '$key Salah';
    switch (key) {
      case 'Fajr':
        return 'ফজর সালাত';
      case 'Dhuhr':
        return 'যোহর সালাত';
      case 'Asr':
        return 'আসর সালাত';
      case 'Maghrib':
        return 'মাগরিব সালাত';
      case 'Isha':
        return 'এশা সালাত';
      case 'Quran':
        return 'আল-কুরআন তিলাওয়াত';
      default:
        return key;
    }
  }

  String _getActivitySubtitle(String key, bool isBangla) {
    if (!isBangla) return key == 'Quran' ? 'Read or listen today' : 'Perform daily prayer';
    switch (key) {
      case 'Quran':
        return 'আজকে কুরআন পাঠ বা শ্রবণ করুন';
      default:
        return 'দৈনিক ফরজ নামাজ আদায় করুন';
    }
  }
}
