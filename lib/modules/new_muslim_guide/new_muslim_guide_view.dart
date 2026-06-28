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
    final isDark = settings.isDark;

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              backgroundColor: isDark ? AppColors.bgDark : AppColors.surfaceLight,
              leading: AppBackButton(color: isDark ? AppColors.textWhite : AppColors.textDark),
              title: Text(
                isBn ? 'নতুন মুসলিম গাইড' : 'New Muslim Guide',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textWhite : AppColors.textDark,
                ),
              ),
              pinned: true,
              floating: true,
              forceElevated: true,
              elevation: 0.5,
              shadowColor: isDark ? AppColors.borderDark : AppColors.borderLight,
              bottom: TabBar(
                isScrollable: true,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark ? AppColors.textGrey : AppColors.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                tabs: [
                  Tab(icon: const Icon(Icons.favorite_rounded, size: 18), text: isBn ? 'কালেমা ও ঈমান' : 'Shahada & Iman'),
                  Tab(icon: const Icon(Icons.checklist_rounded, size: 18), text: isBn ? 'লাইফস্টাইল' : 'Lifestyle'),
                  Tab(icon: const Icon(Icons.water_drop_rounded, size: 18), text: isBn ? 'ওযুর নিয়ম' : 'Wudu Steps'),
                  Tab(icon: const Icon(Icons.mosque_rounded, size: 18), text: isBn ? 'নামাজের নিয়ম' : 'Salah Steps'),
                  Tab(icon: const Icon(Icons.menu_book_rounded, size: 18), text: isBn ? 'ছোট সূরা' : 'Short Surahs'),
                  Tab(icon: const Icon(Icons.restaurant_rounded, size: 18), text: isBn ? 'হালাল-হারাম' : 'Halal & Haram'),
                ],
              ),
            ),
          ],
          body: Obx(() {
            if (controller.isLoading.value) {
              return ShimmerList(itemCount: 5, height: 120);
            }
            return TabBarView(
              children: [
                _buildShahadaAndPillars(context, settings),
                _buildLifestyle(context, settings),
                _buildWuduSteps(context, settings),
                _buildSalahSteps(context, settings),
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
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.auto_awesome_outlined,
              size: 80,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBn ? titleBn : titleEn,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isBn ? subBn : subEn,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
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
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.orange.withValues(alpha: 0.05))
                        .withValues(alpha: isDark ? 0.15 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isBn ? belief['titleBn']! : belief['titleEn']!,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16.5, letterSpacing: 0.2),
                    ),
                    if (belief.containsKey('arabic')) ...[
                      const SizedBox(height: 16),
                      Text(
                        belief['arabic']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Uthmanic',
                          fontSize: settings.arabicFontSize.value,
                          color: AppColors.primary,
                          height: 1.8,
                          shadows: [
                            Shadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isBn ? 'উচ্চারণ: ${belief['translitBn']}' : 'Transliteration: ${belief['translitEn'] ?? belief['translitBn']}',
                        style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: AppColors.textGrey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Text(
                      isBn ? belief['meaningBn'] ?? belief['descBn']! : (belief['descEn'] ?? belief['meaningEn'] ?? belief['titleEn']!),
                      style: TextStyle(fontSize: 14, color: isDark ? AppColors.textWhite : AppColors.textDark, height: 1.5),
                      textAlign: belief.containsKey('arabic') ? TextAlign.center : TextAlign.left,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 3.5,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isBn ? 'ইসলামের ৫টি মূল স্তম্ভ' : 'The 5 Pillars of Islam',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.orange.withValues(alpha: 0.05))
                    .withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
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
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.orange.withValues(alpha: 0.05))
                    .withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isBn ? surah['nameBn']! : (surah['nameEn'] ?? 'Surah'),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 17),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  surah['arabic']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Uthmanic',
                    fontSize: settings.arabicFontSize.value,
                    color: AppColors.primary,
                    height: 1.8,
                    shadows: [
                      Shadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isBn ? 'উচ্চারণ: ${surah['translit']}' : 'Transliteration: ${surah['translit']}',
                  style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: AppColors.textGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  isBn ? 'অর্থ: ${surah['meaning']}' : 'Meaning: ${surah['meaning']}',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: isDark ? AppColors.textWhite : AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalahSteps(BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;
    final isBn = settings.isBangla;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _welcomeHeader(
            settings,
            'Salah Steps & Rakah Rules',
            'নামাজ আদায়ের নিয়ম ও রাকাতসমূহ',
            'Salah (prayer) is performed in units called Rakahs. Below you will learn how each Rakah is structured and how to complete them.',
            'নামাজ কয়েকটি নির্দিষ্ট ইউনিটে বিভক্ত যাকে "রাকাত" বলা হয়। নামাজের প্রতিটি রাকাত কিভাবে সম্পন্ন করতে হয় এবং রাকাতের বিবরণ নিচে দেওয়া হলো।',
          ),
          
          // Section 1: Rakah Completion rules
          Row(
            children: [
              Container(
                width: 3.5,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isBn ? 'রাকাত শেষ করার নিয়মাবলি' : 'How to Complete Each Rakah',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...controller.rakahRules.map((rule) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.orange.withValues(alpha: 0.03))
                        .withValues(alpha: isDark ? 0.12 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? rule['titleBn']! : rule['titleEn']!,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isBn ? rule['descBn']! : rule['descEn']!,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? AppColors.textWhite : AppColors.textDark,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          
          const SizedBox(height: 16),
          
          // Section 2: Postures step-by-step
          Row(
            children: [
              Container(
                width: 3.5,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isBn ? 'নামাজ আদায়ের ধাপসমূহ' : 'Salah Posture Steps',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...controller.salahSteps.map((step) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.orange.withValues(alpha: 0.04))
                        .withValues(alpha: isDark ? 0.15 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
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
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? step.titleBn : step.titleEn,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textWhite : AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isBn ? step.descBn : step.descEn,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textGrey : AppColors.textDark.withValues(alpha: 0.75),
                              height: 1.45,
                            ),
                          ),
                          if (step.arabic != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                  width: 0.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    step.arabic!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Uthmanic',
                                      fontSize: settings.arabicFontSize.value - 2,
                                      color: AppColors.primary,
                                      height: 1.8,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isBn ? 'উচ্চারণ: ${step.translit}' : 'Transliteration: ${step.translit}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.textGrey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (step.meaning != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      isBn ? 'অর্থ: ${step.meaning}' : 'Meaning: ${step.meaning}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textWhite : AppColors.textDark,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
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
              final accentColor = isHalal ? Colors.green : Colors.red;
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.35),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isHalal ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: accentColor,
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? item['titleBn']! : item['titleEn']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? (isHalal ? Colors.green[300] : Colors.red[300]) : (isHalal ? Colors.green[800] : Colors.red[800]),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isBn ? item['descBn']! : item['descEn']!,
                              style: TextStyle(fontSize: 13, height: 1.45, color: isDark ? AppColors.textWhite : AppColors.textDark),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.orange.withValues(alpha: 0.03))
                .withValues(alpha: isDark ? 0.12 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textWhite : AppColors.textDark,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(desc, style: const TextStyle(color: AppColors.textGrey, fontSize: 12, height: 1.35)),
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

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.orange.withValues(alpha: 0.05))
                    .withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
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
                      fontSize: 15,
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
                          color: isDark ? AppColors.textGrey : AppColors.textDark.withValues(alpha: 0.75),
                          height: 1.45,
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
          Icon(Icons.inbox_rounded, size: 48, color: AppColors.textGrey.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textGrey)),
        ],
      ),
    );
  }
}
