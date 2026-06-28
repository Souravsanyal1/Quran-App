import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'package:quran_app/widgets/shimmer_loading.dart';
import 'new_muslim_guide_controller.dart';

class NewMuslimGuideView extends GetView<NewMuslimGuideController> {
  const NewMuslimGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isBn = settings.isBangla;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              leading: const AppBackButton(),
              title: Text(isBn ? 'নতুন মুসলিম গাইড' : 'New Muslim Guide'),
              pinned: true,
              floating: true,
              forceElevated: true,
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: const Icon(Icons.favorite_rounded, size: 18), text: isBn ? 'কালেমা ও ঈমান' : 'Shahada & Iman'),
                  Tab(icon: const Icon(Icons.checklist_rounded, size: 18), text: isBn ? 'লাইফস্টাইল' : 'Lifestyle'),
                  Tab(icon: const Icon(Icons.water_drop_rounded, size: 18), text: isBn ? 'ওযুর নিয়ম' : 'Wudu Steps'),
                  Tab(icon: const Icon(Icons.menu_book_rounded, size: 18), text: isBn ? 'ছোট সূরা' : 'Short Surahs'),
                  Tab(icon: const Icon(Icons.restaurant_rounded, size: 18), text: isBn ? 'হালাল-হারাম' : 'Halal & Haram'),
                ],
              ),
            ),
          ],
          body: Obx(() {
            if (controller.isLoading.value) {
              return  ShimmerList(itemCount: 5, height: 120);
            }
            return TabBarView(
              children: [
                _buildShahadaAndPillars(context, settings),
                _buildLifestyle(context, settings),
                _buildWuduSteps(context, settings),
                _buildShortSurahs(context, settings),
                _buildHalalHaram(context, settings),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ---------- Reusable: Welcome header ----------
  Widget _welcomeHeader(SettingsController settings, String titleEn, String titleBn, String subEn, String subBn) {
    final isBn = settings.isBangla;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isBn ? titleBn : titleEn, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(isBn ? subBn : subEn, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildShahadaAndPillars(BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;
    final isBn = settings.isBangla;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _welcomeHeader(
            settings,
            'Welcome to Islam',
            'ইসলামে স্বাগতম',
            'As-Salamu Alaykum! Allah blessed you with the greatest gift. This guide will walk you through your first steps as a Muslim, in shaa Allah.',
            'আসসালামু আলাইকুম! আল্লাহ আপনাকে সবচেয়ে বড় নিয়ামত দিয়েছেন। এই গাইড আপনাকে একজন মুসলিম হিসেবে প্রথম পদক্ষেপগুলোতে সাহায্য করবে, ইনশাআল্লাহ।',
          ),
          ...controller.essentialBeliefs.map((belief) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
              ),
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isBn ? belief['titleBn']! : belief['titleEn']!,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    if (belief.containsKey('arabic')) ...[
                      const SizedBox(height: 16),
                      Text(
                        belief['arabic']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Uthmanic', fontSize: settings.arabicFontSize.value, color: AppColors.primary, height: 1.8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isBn ? 'উচ্চারণ: ${belief['translitBn']}' : 'Transliteration: ${belief['translitEn'] ?? belief['translitBn']}',
                        style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textGrey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      isBn ? belief['meaningBn'] ?? belief['descBn']! : (belief['descEn'] ?? belief['meaningEn'] ?? belief['titleEn']!),
                      style: TextStyle(fontSize: 14, color: isDark ? AppColors.textWhite : AppColors.textDark, height: 1.4),
                      textAlign: belief.containsKey('arabic') ? TextAlign.center : TextAlign.left,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 4, height: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                isBn ? 'ইসলামের ৫টি মূল স্তম্ভ' : 'The 5 Pillars of Islam',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPillarItem(settings, '1', Icons.record_voice_over_rounded, isBn ? 'শাহাদাহ (ঈমান)' : 'Shahadah (Faith)', isBn ? 'আল্লাহর একত্ববাদ ও রাসূলের উপর বিশ্বাস স্থাপন।' : 'Belief in oneness of Allah and His messenger.'),
          _buildPillarItem(settings, '2', Icons.mosque_rounded, isBn ? 'সালাত (নামাজ)' : 'Salah (Prayer)', isBn ? 'প্রতিদিন ৫ ওয়াক্ত নামাজ আদায় করা।' : 'Performing the five daily prayers.'),
          _buildPillarItem(settings, '3', Icons.volunteer_activism_rounded, isBn ? 'যাকাত (দান)' : 'Zakat (Almsgiving)', isBn ? 'সম্পদশালীদের জন্য প্রতি বছর নির্দিষ্ট অংশ দান।' : 'Giving portion of wealth to needy annually.'),
          _buildPillarItem(settings, '4', Icons.nights_stay_rounded, isBn ? 'সাওম (রোজা)' : 'Sawm (Fasting)', isBn ? 'পবিত্র রমজান মাসে রোজা রাখা।' : 'Fasting during the holy month of Ramadan.'),
          _buildPillarItem(settings, '5', Icons.flight_takeoff_rounded, isBn ? 'হজ (তীর্থযাত্রা)' : 'Hajj (Pilgrimage)', isBn ? 'সামর্থ্যবানদের জন্য জীবনে অন্তত একবার মক্কায় হজ করা।' : 'Pilgrimage to Makkah once in lifetime if able.'),
        ],
      ),
    );
  }

  Widget _buildLifestyle(BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;
    final isBn = settings.isBangla;

    if (controller.dailyLifestyle.isEmpty) {
      return _emptyState(settings, isBn ? 'কোনো তথ্য পাওয়া যায়নি' : 'No items found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.dailyLifestyle.length,
      itemBuilder: (context, index) {
        final item = controller.dailyLifestyle[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
          ),
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isBn ? item['titleBn']! : item['titleEn']!,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isBn ? item['descBn']! : (item['descEn'] ?? item['titleEn']!),
                  style: TextStyle(fontSize: 14, color: isDark ? AppColors.textWhite : AppColors.textDark, height: 1.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildShortSurahs(BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;
    final isBn = settings.isBangla;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.shortSurahs.length,
      itemBuilder: (context, index) {
        final surah = controller.shortSurahs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
          ),
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(isBn ? surah['nameBn']! : (surah['nameEn'] ?? 'Surah'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text(surah['arabic']!, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Uthmanic', fontSize: settings.arabicFontSize.value, color: AppColors.primary, height: 1.8)),
                const SizedBox(height: 12),
                Text(isBn ? 'উচ্চারণ: ${surah['translit']}' : 'Transliteration: ${surah['translit']}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textGrey), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(isBn ? 'অর্থ: ${surah['meaning']}' : 'Meaning: ${surah['meaning']}', style: const TextStyle(fontSize: 13, height: 1.4), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- NEW TAB: Halal & Haram ----------
  Widget _buildHalalHaram(BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;
    final isBn = settings.isBangla;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _welcomeHeader(
            settings,
            'Halal & Haram Basics',
            'হালাল ও হারামের মূলনীতি',
            'Understanding what is permissible (halal) and forbidden (haram) is essential for daily life as a Muslim.',
            'হালাল (অনুমোদিত) ও হারাম (নিষিদ্ধ) বিষয়গুলো জানা একজন মুসলিমের দৈনন্দিন জীবনের জন্য অপরিহার্য।',
          ),
          if (controller.halalHaramItems.isEmpty)
            _emptyState(settings, isBn ? 'তথ্য যুক্ত করা হচ্ছে...' : 'Content coming soon')
          else
            ...controller.halalHaramItems.map((item) {
              final bool isHalal = item['type'] == 'halal';
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: isHalal ? Colors.green.withOpacity(0.4) : Colors.red.withOpacity(0.4), width: 1),
                ),
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isHalal ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: isHalal ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? item['titleBn']! : item['titleEn']!,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isHalal ? Colors.green[700] : Colors.red[700]),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isBn ? item['descBn']! : item['descEn']!,
                              style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? AppColors.textWhite : AppColors.textDark),
                            ),
                          ],
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
  }


  Widget _buildPillarItem(SettingsController settings, String num, IconData icon, String title, String desc) {
    final isDark = settings.isDark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textWhite : AppColors.textDark,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(desc, style: const TextStyle(color: AppColors.textGrey, fontSize: 12, height: 1.3)),
        ),
      ),
    );
  }

  Widget _buildWuduSteps(BuildContext context, SettingsController settings) {
    final isBn = settings.isBangla;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.wuduSteps.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final step = controller.wuduSteps[index];
        final isDark = settings.isDark;

        return Card(
          elevation: 0,
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
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? step.titleBn : step.titleEn,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textWhite : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isBn ? step.descBn : step.descEn,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textGrey : AppColors.textDark.withOpacity(0.7),
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

  Widget _emptyState(SettingsController settings, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: AppColors.textGrey.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textGrey)),
        ],
      ),
    );
  }
}
