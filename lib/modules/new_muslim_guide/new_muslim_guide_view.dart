import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'new_muslim_guide_controller.dart';

class NewMuslimGuideView extends GetView<NewMuslimGuideController> {
  const NewMuslimGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text(settings.isBangla ? 'নতুন মুসলিম গাইড' : 'New Muslim Guide'),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: settings.isBangla ? 'কালেমা ও স্তম্ভ' : 'Shahada & Pillars'),
              Tab(text: settings.isBangla ? 'ওযুর নিয়মাবলী' : 'Wudu Steps'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildShahadaAndPillars(context, settings),
            _buildWuduSteps(context, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildShahadaAndPillars(BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Shahada Card
          Card(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      settings.isBangla ? 'কালিমা শাহাদাত' : 'The Shahada',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'أَشْهَدُ أَنْ لَا إِلٰهَ إِلَّا اللهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Uthmanic',
                      fontSize: settings.arabicFontSize.value,
                      color: AppColors.primary,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    settings.isBangla
                        ? 'উচ্চারণ: আশহাদু আল্লা ইলাহা ইল্লাল্লাহু ওয়া আশহাদু আন্না মুহাম্মাদান আবদুহু ওয়া রাসুলুহু।'
                        : 'Transliteration: Ash-hadu alla ilaha illallah, wa ash-hadu anna Muhammadan \'abduhu wa Rasuluh.',
                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textGrey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    settings.isBangla
                        ? 'অনুবাদ: আমি সাক্ষ্য দিচ্ছি যে, আল্লাহ ছাড়া কোনো উপাস্য নেই এবং আমি আরও সাক্ষ্য দিচ্ছি যে, মুহাম্মদ (সাঃ) তাঁর বান্দা ও রাসুল।'
                        : 'Translation: I bear witness that there is no god but Allah, and I bear witness that Muhammad is His servant and messenger.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textWhite : AppColors.textDark,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 5 Pillars of Islam Title
          Text(
            settings.isBangla ? 'ইসলামের ৫টি মূল স্তম্ভ' : 'The 5 Pillars of Islam',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 5 Pillars Vertical list
          _buildPillarItem(settings, '1', settings.isBangla ? 'শাহাদাহ (ঈমান)' : 'Shahadah (Faith)', settings.isBangla ? 'আল্লাহর একত্ববাদ ও রাসূলের উপর বিশ্বাস স্থাপন।' : 'Belief in oneness of Allah and His messenger.'),
          const SizedBox(height: 10),
          _buildPillarItem(settings, '2', settings.isBangla ? 'সালাত (নামাজ)' : 'Salah (Prayer)', settings.isBangla ? 'প্রতিদিন ৫ ওয়াক্ত নামাজ আদায় করা।' : 'Performing the five daily prayers.'),
          const SizedBox(height: 10),
          _buildPillarItem(settings, '3', settings.isBangla ? 'যাকাত (দান)' : 'Zakat (Almsgiving)', settings.isBangla ? 'সম্পদশালীদের জন্য প্রতি বছর নির্দিষ্ট অংশ দান।' : 'Giving portion of wealth to needy annually.'),
          const SizedBox(height: 10),
          _buildPillarItem(settings, '4', settings.isBangla ? 'সাওম (রোজা)' : 'Sawm (Fasting)', settings.isBangla ? 'পবিত্র রমজান মাসে রোজা রাখা।' : 'Fasting during the holy month of Ramadan.'),
          const SizedBox(height: 10),
          _buildPillarItem(settings, '5', settings.isBangla ? 'হজ (তীর্থযাত্রা)' : 'Hajj (Pilgrimage)', settings.isBangla ? 'সামর্থ্যবানদের জন্য জীবনে অন্তত একবার মক্কায় হজ করা।' : 'Pilgrimage to Makkah once in lifetime if able.'),
        ],
      ),
    );
  }

  Widget _buildPillarItem(SettingsController settings, String num, String title, String desc) {
    final isDark = settings.isDark;
    return Card(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            num,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textWhite : AppColors.textDark,
          ),
        ),
        subtitle: Text(desc, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
      ),
    );
  }

  Widget _buildWuduSteps(BuildContext context, SettingsController settings) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.wuduSteps.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final step = controller.wuduSteps[index];
        final isDark = settings.isDark;
        
        return Card(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step circle
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Text(
                    step.stepNumber.toString(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.isBangla ? step.titleBn : step.titleEn,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textWhite : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        settings.isBangla ? step.descBn : step.descEn,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textGrey : AppColors.textDark.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
