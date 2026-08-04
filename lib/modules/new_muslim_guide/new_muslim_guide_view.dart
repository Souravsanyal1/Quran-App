import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'package:quran_app/widgets/shimmer_loading.dart';
import 'new_muslim_guide_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _GuideTheme {
  _GuideTheme._();
  static const Color emerald = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark = Color(0xFF0D3B1E);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C97A);
  static const Color goldSoft = Color(0xFFFFF8E7);
  static const Color darkSurface = Color(0xFF141420);
  static const Color darkCard = Color(0xFF1E1E2E);
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard = Color(0xFFFFFFFF);
}

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
        backgroundColor:
            isDark ? _GuideTheme.darkSurface : _GuideTheme.lightSurface,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              leading: AppBackButton(color: Colors.white),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isBn ? 'নতুন মুসলিম গাইড' : 'New Muslim Guide',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    height: 2,
                    width: 32,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: _GuideTheme.goldLight,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              pinned: true,
              floating: true,
              forceElevated: true,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      _GuideTheme.emeraldDark,
                      _GuideTheme.emerald,
                      _GuideTheme.emeraldLight
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: const Border(
                      bottom: BorderSide(color: _GuideTheme.gold, width: 1.5)),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                        opacity: 0.05,
                        child: CustomPaint(painter: _StarPatternPainter())),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Container(
                  color: isDark
                      ? _GuideTheme.darkSurface
                      : _GuideTheme.lightSurface,
                  child: TabBar(
                    isScrollable: true,
                    indicatorColor: _GuideTheme.emerald,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: _GuideTheme.emerald,
                    unselectedLabelColor:
                        isDark ? AppColors.textGrey : AppColors.textMuted,
                    labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700, fontSize: 12.5),
                    unselectedLabelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500, fontSize: 12.5),
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(
                          icon: const Icon(Icons.favorite_rounded, size: 18),
                          text: isBn ? 'কালেমা ও ঈমান' : 'Shahada & Iman'),
                      Tab(
                          icon: const Icon(Icons.checklist_rounded, size: 18),
                          text: isBn ? 'লাইফস্টাইল' : 'Lifestyle'),
                      Tab(
                          icon: const Icon(Icons.water_drop_rounded, size: 18),
                          text: isBn ? 'ওযুর নিয়ম' : 'Wudu Steps'),
                      Tab(
                          icon: const Icon(Icons.mosque_rounded, size: 18),
                          text: isBn ? 'নামাজের নিয়ম' : 'Salah Steps'),
                      Tab(
                          icon: const Icon(Icons.menu_book_rounded, size: 18),
                          text: isBn ? 'ছোট সূরা' : 'Short Surahs'),
                      Tab(
                          icon: const Icon(Icons.restaurant_rounded, size: 18),
                          text: isBn ? 'হালাল-হারাম' : 'Halal & Haram'),
                    ],
                  ),
                ),
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

  // ── Reusable: Welcome Header ─────────────────────────────────────────────
  Widget _welcomeHeader(SettingsController settings, String titleEn,
      String titleBn, String subEn, String subBn) {
    final isBn = settings.isBangla;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _GuideTheme.emeraldDark,
            _GuideTheme.emerald,
            _GuideTheme.emeraldLight
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _GuideTheme.emerald.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(Icons.auto_awesome_outlined,
                size: 70, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            left: -10,
            top: -10,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBn ? titleBn : titleEn,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                height: 2,
                width: 36,
                margin: const EdgeInsets.only(top: 8, bottom: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [_GuideTheme.goldLight, _GuideTheme.gold]),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Text(
                isBn ? subBn : subEn,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section Title ────────────────────────────────────────────────────────
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_GuideTheme.gold, _GuideTheme.goldLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 17, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ── Content Card ─────────────────────────────────────────────────────────
  Widget _contentCard(bool isDark,
      {required Widget child, Color? accentColor}) {
    final accent = accentColor ?? _GuideTheme.emerald;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? _GuideTheme.darkCard : _GuideTheme.lightCard,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: accent.withValues(alpha: isDark ? 0.1 : 0.08)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.04 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── Tab 1: Shahada & Pillars ─────────────────────────────────────────────
  Widget _buildShahadaAndPillars(
      BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;
    final isBn = settings.isBangla;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _welcomeHeader(
              settings,
              'Welcome to Islam',
              'ইসলামে স্বাগতম',
              'As-Salamu Alaykum! Allah blessed you with the greatest gift. This guide will walk you through your first steps as a Muslim, in shaa Allah.',
              'আসসালামু আলাইকুম! আল্লাহ আপনাকে সবচেয়ে বড় নিয়ামত দিয়েছেন। এই গাইড আপনাকে একজন মুসলিম হিসেবে প্রথম পদক্ষেপগুলোতে সাহায্য করবে, ইনশাআল্লাহ।'),
          ...controller.essentialBeliefs.map((belief) {
            return _contentCard(isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        isBn ? belief['titleBn']! : belief['titleEn']!,
                        style: GoogleFonts.poppins(
                            color: _GuideTheme.emerald,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                      if (belief.containsKey('arabic')) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? _GuideTheme.gold.withValues(alpha: 0.04)
                                : _GuideTheme.goldSoft.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: _GuideTheme.gold
                                    .withValues(alpha: isDark ? 0.1 : 0.15)),
                          ),
                          child: Obx(() => Text(
                                belief['arabic']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.amiri(
                                  fontSize: settings.arabicFontSize.value,
                                  color: isDark
                                      ? _GuideTheme.goldLight
                                      : _GuideTheme.gold,
                                  height: 1.8,
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isBn
                              ? 'উচ্চারণ: ${belief['translitBn']}'
                              : 'Transliteration: ${belief['translitEn'] ?? belief['translitBn']}',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textGrey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        isBn
                            ? belief['meaningBn'] ?? belief['descBn']!
                            : (belief['descEn'] ??
                                belief['meaningEn'] ??
                                belief['titleEn']!),
                        style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.textDark,
                            height: 1.5),
                        textAlign: belief.containsKey('arabic')
                            ? TextAlign.center
                            : TextAlign.left,
                      ),
                    ],
                  ),
                ));
          }),
          const SizedBox(height: 8),
          _sectionTitle(
              isBn ? 'ইসলামের ৫টি মূল স্তম্ভ' : 'The 5 Pillars of Islam'),
          _buildPillarItem(
              settings,
              '1',
              Icons.record_voice_over_rounded,
              isBn ? 'শাহাদাহ (ঈমান)' : 'Shahadah (Faith)',
              isBn
                  ? 'আল্লাহর একত্ববাদ ও রাসূলের উপর বিশ্বাস স্থাপন।'
                  : 'Belief in oneness of Allah and His messenger.',
              const [_GuideTheme.emerald, _GuideTheme.emeraldLight]),
          _buildPillarItem(
              settings,
              '2',
              Icons.mosque_rounded,
              isBn ? 'সালাত (নামাজ)' : 'Salah (Prayer)',
              isBn
                  ? 'প্রতিদিন ৫ ওয়াক্ত নামাজ আদায় করা।'
                  : 'Performing the five daily prayers.',
              const [Color(0xFF5C6BC0), Color(0xFF7986CB)]),
          _buildPillarItem(
              settings,
              '3',
              Icons.volunteer_activism_rounded,
              isBn ? 'যাকাত (দান)' : 'Zakat (Almsgiving)',
              isBn
                  ? 'সম্পদশালীদের জন্য প্রতি বছর নির্দিষ্ট অংশ দান।'
                  : 'Giving portion of wealth to needy annually.',
              const [Color(0xFFE65100), Color(0xFFFF8A00)]),
          _buildPillarItem(
              settings,
              '4',
              Icons.nights_stay_rounded,
              isBn ? 'সাওম (রোজা)' : 'Sawm (Fasting)',
              isBn
                  ? 'পবিত্র রমজান মাসে রোজা রাখা।'
                  : 'Fasting during the holy month of Ramadan.',
              const [Color(0xFF6A1B9A), Color(0xFF9C27B0)]),
          _buildPillarItem(
              settings,
              '5',
              Icons.flight_takeoff_rounded,
              isBn ? 'হজ (তীর্থযাত্রা)' : 'Hajj (Pilgrimage)',
              isBn
                  ? 'সামর্থ্যবানদের জন্য জীবনে অন্তত একবার মক্কায় হজ করা।'
                  : 'Pilgrimage to Makkah once in lifetime if able.',
              const [Color(0xFFB8860B), Color(0xFFD4A524)]),
        ],
      ),
    );
  }

  Widget _buildPillarItem(SettingsController settings, String num,
      IconData icon, String title, String desc, List<Color> gradientColors) {
    final isDark = settings.isDark;
    return _contentCard(isDark,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          title: Text(title,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                  fontSize: 14.5)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(desc,
                style: GoogleFonts.poppins(
                    color: AppColors.textGrey, fontSize: 12, height: 1.4)),
          ),
        ));
  }

  // ── Tab 2: Lifestyle ─────────────────────────────────────────────────────
  Widget _buildLifestyle(BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;
    final isBn = settings.isBangla;
    if (controller.dailyLifestyle.isEmpty)
      return _emptyState(
          settings, isBn ? 'কোনো তথ্য পাওয়া যায়নি' : 'No items found');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.dailyLifestyle.length,
      itemBuilder: (context, index) {
        final item = controller.dailyLifestyle[index];
        return _contentCard(isDark,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        _GuideTheme.emerald,
                        _GuideTheme.emeraldLight
                      ]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isBn ? item['titleBn']! : item['titleEn']!,
                          style: GoogleFonts.poppins(
                              color: _GuideTheme.emerald,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      const SizedBox(height: 8),
                      Text(
                          isBn
                              ? item['descBn']!
                              : (item['descEn'] ?? item['titleEn']!),
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.75)
                                  : AppColors.textDark,
                              height: 1.5)),
                    ],
                  )),
                ],
              ),
            ));
      },
    );
  }

  // ── Tab 3: Wudu Steps ────────────────────────────────────────────────────
  Widget _buildWuduSteps(BuildContext context, SettingsController settings) {
    final isBn = settings.isBangla;
    final isDark = settings.isDark;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.wuduSteps.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final step = controller.wuduSteps[index];
        return _contentCard(isDark,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_GuideTheme.gold, _GuideTheme.goldLight]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: _GuideTheme.gold.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Text(step.stepNumber.toString(),
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isBn ? step.titleBn : step.titleEn,
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? Colors.white : AppColors.textDark)),
                      const SizedBox(height: 6),
                      Text(isBn ? step.descBn : step.descEn,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.65)
                                  : AppColors.textDark.withValues(alpha: 0.7),
                              height: 1.5)),
                    ],
                  )),
                ],
              ),
            ));
      },
    );
  }

  // ── Tab 4: Salah Steps ───────────────────────────────────────────────────
  Widget _buildSalahSteps(BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;
    final isBn = settings.isBangla;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _welcomeHeader(
              settings,
              'Salah Steps & Rakah Rules',
              'নামাজ আদায়ের নিয়ম ও রাকাতসমূহ',
              'Salah (prayer) is performed in units called Rakahs. Below you will learn how each Rakah is structured and how to complete them.',
              'নামাজ কয়েকটি নির্দিষ্ট ইউনিটে বিভক্ত যাকে "রাকাত" বলা হয়। নামাজের প্রতিটি রাকাত কিভাবে সম্পন্ন করতে হয় এবং রাকাতের বিবরণ নিচে দেওয়া হলো।'),
          _sectionTitle(
              isBn ? 'রাকাত শেষ করার নিয়মাবলি' : 'How to Complete Each Rakah'),
          ...controller.rakahRules.map((rule) => _contentCard(isDark,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isBn ? rule['titleBn']! : rule['titleEn']!,
                          style: GoogleFonts.poppins(
                              color: _GuideTheme.emerald,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      const SizedBox(height: 8),
                      Text(isBn ? rule['descBn']! : rule['descEn']!,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.75)
                                  : AppColors.textDark,
                              height: 1.5)),
                    ]),
              ))),
          const SizedBox(height: 12),
          _sectionTitle(isBn ? 'নামাজ আদায়ের ধাপসমূহ' : 'Salah Posture Steps'),
          ...controller.salahSteps.map((step) => _contentCard(isDark,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            _GuideTheme.emerald,
                            _GuideTheme.emeraldLight
                          ]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(step.stepNumber.toString(),
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(isBn ? step.titleBn : step.titleEn,
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textDark)),
                            const SizedBox(height: 6),
                            Text(isBn ? step.descBn : step.descEn,
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.65)
                                        : AppColors.textDark
                                            .withValues(alpha: 0.7),
                                    height: 1.5)),
                            if (step.arabic != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? _GuideTheme.gold.withValues(alpha: 0.04)
                                      : _GuideTheme.goldSoft
                                          .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: _GuideTheme.gold.withValues(
                                          alpha: isDark ? 0.1 : 0.15)),
                                ),
                                child: Column(children: [
                                  Obx(() => Text(step.arabic!,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.amiri(
                                          fontSize:
                                              settings.arabicFontSize.value - 2,
                                          color: isDark
                                              ? _GuideTheme.goldLight
                                              : _GuideTheme.gold,
                                          height: 1.8,
                                          fontWeight: FontWeight.w700))),
                                  const SizedBox(height: 6),
                                  Text(
                                      isBn
                                          ? 'উচ্চারণ: ${step.translit}'
                                          : 'Transliteration: ${step.translit}',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          fontStyle: FontStyle.italic,
                                          color: AppColors.textGrey),
                                      textAlign: TextAlign.center),
                                  if (step.meaning != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                        isBn
                                            ? 'অর্থ: ${step.meaning}'
                                            : 'Meaning: ${step.meaning}',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white
                                                    .withValues(alpha: 0.7)
                                                : AppColors.textDark),
                                        textAlign: TextAlign.center),
                                  ],
                                ]),
                              ),
                            ],
                          ])),
                    ]),
              ))),
        ],
      ),
    );
  }

  // ── Tab 5: Short Surahs ──────────────────────────────────────────────────
  Widget _buildShortSurahs(BuildContext context, SettingsController settings) {
    final isDark = settings.isDark;
    final isBn = settings.isBangla;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.shortSurahs.length,
      itemBuilder: (context, index) {
        final surah = controller.shortSurahs[index];
        return _contentCard(isDark,
            accentColor: _GuideTheme.gold,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Surah name badge
                    Center(
                        child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          _GuideTheme.emerald,
                          _GuideTheme.emeraldLight
                        ]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                          isBn
                              ? surah['nameBn']!
                              : (surah['nameEn'] ?? 'Surah'),
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    )),
                    const SizedBox(height: 16),
                    // Arabic
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? _GuideTheme.gold.withValues(alpha: 0.04)
                            : _GuideTheme.goldSoft.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: _GuideTheme.gold
                                .withValues(alpha: isDark ? 0.1 : 0.15)),
                      ),
                      child: Obx(() => Text(
                            surah['arabic']!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.amiri(
                                fontSize: settings.arabicFontSize.value,
                                color: isDark
                                    ? _GuideTheme.goldLight
                                    : _GuideTheme.gold,
                                height: 1.8,
                                fontWeight: FontWeight.w700),
                          )),
                    ),
                    const SizedBox(height: 12),
                    Text(
                        isBn
                            ? 'উচ্চারণ: ${surah['translit']}'
                            : 'Transliteration: ${surah['translit']}',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textGrey),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                        isBn
                            ? 'অর্থ: ${surah['meaning']}'
                            : 'Meaning: ${surah['meaning']}',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            height: 1.5,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.75)
                                : AppColors.textDark),
                        textAlign: TextAlign.center),
                  ]),
            ));
      },
    );
  }

  // ── Tab 6: Halal & Haram ─────────────────────────────────────────────────
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
              'হালাল (অনুমোদিত) ও হারাম (নিষিদ্ধ) বিষয়গুলো জানা একজন মুসলিমের দৈনন্দিন জীবনের জন্য অপরিহার্য।'),
          if (controller.halalHaramItems.isEmpty)
            _emptyState(settings,
                isBn ? 'তথ্য যুক্ত করা হচ্ছে...' : 'Content coming soon')
          else
            ...controller.halalHaramItems.map((item) {
              final bool isHalal = item['type'] == 'halal';
              final gradColors = isHalal
                  ? [const Color(0xFF2E7D32), const Color(0xFF4CAF50)]
                  : [const Color(0xFFC62828), const Color(0xFFE53935)];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: isDark ? _GuideTheme.darkCard : _GuideTheme.lightCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: gradColors.first
                          .withValues(alpha: isDark ? 0.15 : 0.12)),
                  boxShadow: [
                    BoxShadow(
                        color: gradColors.first.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradColors),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                              isHalal
                                  ? Icons.check_rounded
                                  : Icons.close_rounded,
                              color: Colors.white,
                              size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(isBn ? item['titleBn']! : item['titleEn']!,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.5,
                                      color: isDark
                                          ? (isHalal
                                              ? Colors.green[300]
                                              : Colors.red[300])
                                          : gradColors.first)),
                              const SizedBox(height: 6),
                              Text(isBn ? item['descBn']! : item['descEn']!,
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : AppColors.textDark)),
                            ])),
                      ]),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _emptyState(SettingsController settings, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded,
              size: 48, color: _GuideTheme.gold.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Text(message,
              style:
                  GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Star Pattern Painter ─────────────────────────────────────────────────────
class _StarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    const step = 30.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar(canvas, paint, Offset(x, y), 8);
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * (math.pi / 180);
      final radius = i.isEven ? r : r * 0.4;
      final point = Offset(center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle));
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarPatternPainter old) => false;
}
