import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../modules/settings/settings_controller.dart';
import '../home_controller.dart';
import '../banner_controller.dart';

// ── Dashboard Design Tokens ──────────────────────────────────────────────────
class _DashTheme {
  _DashTheme._();

  static const Color emerald = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark = Color(0xFF0D3B1E);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C97A);
  static const Color goldSoft = Color(0xFFFFF8E7);
  static const Color cream = Color(0xFFF8F4EF);

  // Dark mode surfaces
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkCard = Color(0xFF252538);
  static const Color darkBorder = Color(0xFF33334A);

  static LinearGradient get greetingGradient => const LinearGradient(
        colors: [emerald, emeraldLight, Color(0xFF3A9D6A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get greetingGradientDark => const LinearGradient(
        colors: [Color(0xFF142B3C), Color(0xFF1B3A4B), Color(0xFF1D4E5F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final homeController = Get.find<HomeController>();

    return Obx(() {
      final bool bn = settings.isBangla;
      final isDark = settings.isDark;
      final currentHour = homeController.currentHour.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting Card ────────────────────────────────────────────
            _GreetingCard(
                    isBangla: bn, currentHour: currentHour, isDark: isDark)
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: -0.08, curve: Curves.easeOutCubic),

            const SizedBox(height: 28),

            // ── Quick Access Section ─────────────────────────────────────
            _SectionHeader(
              title: bn ? 'দ্রুত অ্যাক্সেস' : 'Quick Access',
              isDark: isDark,
            ).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 14),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.92,
              children: [
                _QuickActionCard(
                  showcaseKey: homeController.quranKey,
                  showcaseTitle: bn ? 'কুরআন' : 'Quran',
                  showcaseDesc: bn
                      ? 'এখান থেকে কুরআন পড়ুন'
                      : 'Read the Holy Quran from here',
                  icon: Icons.menu_book_rounded,
                  label: bn ? 'কুরআন' : 'Quran',
                  gradient: const [Color(0xFF1B5E35), Color(0xFF2E7D52)],
                  route: AppRoutes.quran,
                ),
                _QuickActionCard(
                  showcaseKey: homeController.prayerKey,
                  showcaseTitle: bn ? 'নামাজ' : 'Prayer',
                  showcaseDesc: bn
                      ? 'আজকের নামাজের সময় দেখুন'
                      : 'Check today\'s prayer times',
                  icon: Icons.access_time_rounded,
                  label: bn ? 'নামাজ' : 'Prayer',
                  gradient: const [Color(0xFF5C6BC0), Color(0xFF7986CB)],
                  route: AppRoutes.prayerTime,
                ),
                _QuickActionCard(
                  icon: Icons.explore_rounded,
                  label: bn ? 'কিবলা' : 'Qibla',
                  gradient: const [Color(0xFF00897B), Color(0xFF26A69A)],
                  route: AppRoutes.qibla,
                ),
                _QuickActionCard(
                  showcaseKey: homeController.learnKey,
                  showcaseTitle: bn ? 'শিক্ষা' : 'Learn',
                  showcaseDesc: bn
                      ? 'নতুন মুসলিমদের জন্য শিক্ষা'
                      : 'Step-by-step education for new Muslims',
                  icon: Icons.school_rounded,
                  label: bn ? 'শিক্ষা ও গাইড' : 'Learn & Guide',
                  gradient: const [Color(0xFF0288D1), Color(0xFF29B6F6)],
                  route: AppRoutes.newMuslimGuide,
                ),
                _QuickActionCard(
                  icon: Icons.volunteer_activism_rounded,
                  label: bn ? 'দোয়া' : "Du'a",
                  gradient: const [Color(0xFFE65100), Color(0xFFFF8A00)],
                  route: AppRoutes.duas,
                ),
                _QuickActionCard(
                  icon: Icons.radio_button_checked_rounded,
                  label: bn ? 'তাসবীহ' : 'Tasbih',
                  gradient: const [Color(0xFFB8860B), Color(0xFFD4A524)],
                  route: AppRoutes.tasbih,
                ),
                _QuickActionCard(
                  icon: Icons.track_changes_rounded,
                  label: bn ? 'ট্র্যাকার' : 'Tracker',
                  gradient: const [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  route: AppRoutes.tracker,
                ),
                // _QuickActionCard(
                //   icon: Icons.menu_book_outlined,
                //   label: bn ? 'নামাজ শিক্ষা' : 'Namaz Guide',
                //   gradient: const [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                //   route: AppRoutes.salahGuide,
                // ),
                _QuickActionCard(
                  icon: Icons.menu_book_rounded,
                  label: bn ? 'নামাজ শিক্ষা' : 'Namaz Guide',
                  gradient: const [Color(0xFF00796B), Color(0xFF009688)],
                  route: AppRoutes.salahGuide2,
                  badgeText: bn ? 'শীঘ্রই' : 'Soon',
                ),
                _QuickActionCard(
                  showcaseKey: homeController.settingsKey,
                  showcaseTitle: bn ? 'প্রোফাইল' : 'Profile',
                  showcaseDesc: bn
                      ? 'সেটিংস ও প্রগ্রেস দেখুন'
                      : 'View your settings and progress',
                  icon: Icons.settings_rounded,
                  label: bn ? 'সেটিংস' : 'Settings',
                  gradient: const [Color(0xFF455A64), Color(0xFF78909C)],
                  route: AppRoutes.settings,
                ),
              ].asMap().entries.map((entry) {
                return entry.value
                    .animate(delay: (150 + entry.key * 60).ms)
                    .fadeIn()
                    .scale(
                        begin: const Offset(0.85, 0.85),
                        curve: Curves.easeOutBack);
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ── Custom Ad Banner ──────────────────────────────────────────
            _CustomAdBanner(isBangla: bn).animate(delay: 500.ms).fadeIn(),

            const SizedBox(height: 28),

            // ── Daily Verse Card ──────────────────────────────────────────
            _DailyVerseCard(isBangla: bn)
                .animate(delay: 600.ms)
                .fadeIn()
                .slideY(begin: 0.05),

            const SizedBox(height: 80), // FAB space
          ],
        ),
      );
    });
  }
}

// ── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_DashTheme.gold, _DashTheme.goldLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textDark,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ── Greeting Card ────────────────────────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  final bool isBangla;
  final int currentHour;
  final bool isDark;

  const _GreetingCard({
    required this.isBangla,
    required this.currentHour,
    required this.isDark,
  });

  String _getGreeting() {
    if (currentHour < 5)
      return isBangla ? 'আস-সালামু আলাইকুম' : 'Assalamu Alaikum';
    if (currentHour < 12) return isBangla ? 'সুপ্রভাত' : 'Good Morning';
    if (currentHour < 17) return isBangla ? 'শুভ অপরাহ্ন' : 'Good Afternoon';
    if (currentHour < 20) return isBangla ? 'শুভ সন্ধ্যা' : 'Good Evening';
    return isBangla ? 'শুভ রাত্রি' : 'Good Night';
  }

  IconData _getTimeIcon() {
    if (currentHour < 5) return Icons.dark_mode_rounded;
    if (currentHour < 12) return Icons.wb_sunny_rounded;
    if (currentHour < 17) return Icons.wb_cloudy_rounded;
    if (currentHour < 20) return Icons.wb_twilight_rounded;
    return Icons.dark_mode_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? _DashTheme.greetingGradientDark
            : _DashTheme.greetingGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF1B3A4B) : _DashTheme.emerald)
                .withOpacity(0.35),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // ── Geometric pattern overlay ───────────────────────────────
            Positioned.fill(
              child: Opacity(
                opacity: 0.06,
                child: CustomPaint(painter: _IslamicPatternPainter()),
              ),
            ),

            // ── Decorative circles ─────────────────────────────────────
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: -30,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            // ── Content ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time icon badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getTimeIcon(),
                                  color: _DashTheme.goldLight, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                _getTimeLabel(),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Greeting text
                        Text(
                          _getGreeting(),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isBangla
                              ? 'আজকের তেলাওয়াত শুরু করুন'
                              : 'Start your recitation today',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.75),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // CTA button
                        _GlowButton(
                          label:
                              isBangla ? 'পড়া শুরু করুন' : 'Continue Reading',
                          onTap: () => Get.toNamed(AppRoutes.quran),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Decorative Quran icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _DashTheme.goldLight.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 32,
                      color: _DashTheme.goldLight,
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom gold accent line ────────────────────────────────
            Positioned(
              bottom: 0,
              left: 24,
              right: 24,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _DashTheme.gold.withOpacity(0),
                      _DashTheme.goldLight.withOpacity(0.6),
                      _DashTheme.gold.withOpacity(0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeLabel() {
    if (currentHour < 5) return isBangla ? 'রাত' : 'Night';
    if (currentHour < 12) return isBangla ? 'সকাল' : 'Morning';
    if (currentHour < 17) return isBangla ? 'দুপুর' : 'Afternoon';
    if (currentHour < 20) return isBangla ? 'সন্ধ্যা' : 'Evening';
    return isBangla ? 'রাত' : 'Night';
  }
}

// ── Glow Button ──────────────────────────────────────────────────────────────
class _GlowButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GlowButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_DashTheme.gold, _DashTheme.goldLight],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _DashTheme.gold.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Quick Action Card ────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final String route;
  final GlobalKey? showcaseKey;
  final String? showcaseTitle;
  final String? showcaseDesc;
  final String? badgeText;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.route,
    this.showcaseKey,
    this.showcaseTitle,
    this.showcaseDesc,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;

    Widget card = GestureDetector(
      onTap: () {
        if (route == AppRoutes.salahGuide || route == AppRoutes.salahGuide2) {
          settings.checkNamazGuideAccessAndNavigate(route);
        } else {
          Get.toNamed(route);
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? _DashTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? _DashTheme.darkBorder
                    : gradient.first.withOpacity(0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withOpacity(isDark ? 0.08 : 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container with gradient
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradient.first.withOpacity(isDark ? 0.25 : 0.15),
                        gradient.last.withOpacity(isDark ? 0.15 : 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: gradient.first.withOpacity(isDark ? 0.15 : 0.1),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: gradient.first, size: 24),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white.withOpacity(0.85)
                          : AppColors.textDark,
                      letterSpacing: 0.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (badgeText != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC9A84C), Color(0xFFE8C97A)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC9A84C).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badgeText!,
                  style: GoogleFonts.poppins(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (showcaseKey != null) {
      return Showcase(
        key: showcaseKey!,
        title: showcaseTitle ?? '',
        description: showcaseDesc ?? '',
        child: card,
      );
    }

    return card;
  }
}

// ── Daily Verse Data ─────────────────────────────────────────────────────────
class _DailyVerse {
  final String arabic;
  final String english;
  final String bangla;
  final String referenceEn;
  final String referenceBn;

  const _DailyVerse({
    required this.arabic,
    required this.english,
    required this.bangla,
    required this.referenceEn,
    required this.referenceBn,
  });
}

const List<_DailyVerse> _dailyVerses = [
  _DailyVerse(
    arabic: 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
    english: 'And whoever fears Allah — He will make for him a way out.',
    bangla: 'যে আল্লাহকে ভয় করে, তিনি তার জন্য পথ করে দেন।',
    referenceEn: '— Surah At-Talaq (65:2)',
    referenceBn: '— সূরা আত-তালাক (৬৫:২)',
  ),
  _DailyVerse(
    arabic: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ',
    english: 'And when My servants ask you concerning Me - indeed I am near.',
    bangla:
        'আর যখন আমার বান্দাগণ আমার সম্পর্কে জিজ্ঞাসা করে, নিশ্চয়ই আমি নিকটে আছি।',
    referenceEn: '— Surah Al-Baqarah (2:186)',
    referenceBn: '— সূরা আল-বাকারা (২:১৮৬)',
  ),
  _DailyVerse(
    arabic: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    english: 'Indeed, with hardship [will be] ease.',
    bangla: 'নিশ্চয়ই কষ্টের সাথে স্বস্তি রয়েছে।',
    referenceEn: '— Surah Ash-Sharh (94:6)',
    referenceBn: '— সূরা আশ-শারহ (৯৪:৬)',
  ),
  _DailyVerse(
    arabic:
        'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
    english:
        'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
    bangla:
        'তুমি ছাড়া কোন উপাস্য নেই, তুমি পবিত্র! নিশ্চয় আমি অপরাধীদের অন্তর্ভুক্ত ছিলাম।',
    referenceEn: '— Surah Al-Anbiya (21:87)',
    referenceBn: '— সূরা আল-আম্বিয়া (২১:৮৭)',
  ),
  _DailyVerse(
    arabic: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
    english: 'If you are grateful, I will surely increase you [in favor].',
    bangla:
        'যদি তোমরা কৃতজ্ঞতা প্রকাশ করো, তবে আমি অবশ্যই তোমাদেরকে বাড়িয়ে দেব।',
    referenceEn: '— Surah Ibrahim (14:7)',
    referenceBn: '— সূরা ইব্রাহিম (১৪:৭)',
  ),
  _DailyVerse(
    arabic: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي',
    english: 'So remember Me; I will remember you. And be grateful to Me.',
    bangla:
        'অতএব তোমরা আমাকে স্মরণ করো, আমিও তোমাদের স্মরণ করব। আর আমার প্রতি কৃতজ্ঞ হও।',
    referenceEn: '— Surah Al-Baqarah (2:152)',
    referenceBn: '— সূরা আল-বাকারা (২:১৫২)',
  ),
  _DailyVerse(
    arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي  وَيَسِّرْ لِي أَمْرِي',
    english:
        'My Lord, expand for me my breast [with assurance] and ease for me my task.',
    bangla: 'হে আমার রব, আমার বুক প্রশস্ত করে দিন এবং আমার কাজ সহজ করে দিন।',
    referenceEn: '— Surah Taha (20:25-26)',
    referenceBn: '— সূরা তহা (২০:২৫-২৬)',
  ),
];

// ── Daily Verse Card ─────────────────────────────────────────────────────────
class _DailyVerseCard extends StatelessWidget {
  final bool isBangla;

  const _DailyVerseCard({required this.isBangla});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;

    // Select daily verse based on day of year
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final verse = _dailyVerses[dayOfYear % _dailyVerses.length];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? _DashTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? _DashTheme.gold.withOpacity(0.15)
              : _DashTheme.gold.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.black : _DashTheme.emerald).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with gold accent ──────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [_DashTheme.gold.withOpacity(0.08), Colors.transparent]
                    : [_DashTheme.goldSoft, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_DashTheme.gold, _DashTheme.goldLight],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_stories_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  isBangla ? 'আজকের আয়াত' : 'Verse of the Day',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? _DashTheme.goldLight : _DashTheme.emerald,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                // Share button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      final text = isBangla
                          ? '${verse.arabic}\n\n${verse.bangla}\n\n${verse.referenceBn}\n\nShared from Quran App'
                          : '${verse.arabic}\n\n${verse.english}\n\n${verse.referenceEn}\n\nShared from Quran App';
                      Share.share(text);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : _DashTheme.emerald)
                            .withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.share_rounded,
                        size: 16,
                        color:
                            isDark ? _DashTheme.goldLight : _DashTheme.emerald,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Verse content ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Arabic text with gold accent
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? _DashTheme.gold.withOpacity(0.05)
                        : _DashTheme.goldSoft.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _DashTheme.gold.withOpacity(isDark ? 0.1 : 0.15),
                    ),
                  ),
                  child: Text(
                    verse.arabic,
                    style: GoogleFonts.amiri(
                      fontSize: 24,
                      color: isDark ? _DashTheme.goldLight : _DashTheme.gold,
                      height: 1.8,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ),

                const SizedBox(height: 16),

                // Ornamental divider
                _OrnamentalDivider(isDark: isDark),

                const SizedBox(height: 14),

                // Translation
                Text(
                  isBangla ? verse.bangla : verse.english,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : AppColors.textDark.withOpacity(0.85),
                    height: 1.7,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                // Reference
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 1.5,
                      decoration: BoxDecoration(
                        color: _DashTheme.gold.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isBangla ? verse.referenceBn : verse.referenceEn,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark
                            ? _DashTheme.goldLight.withOpacity(0.7)
                            : AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ornamental Divider ───────────────────────────────────────────────────────
class _OrnamentalDivider extends StatelessWidget {
  final bool isDark;
  const _OrnamentalDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = _DashTheme.gold.withOpacity(isDark ? 0.25 : 0.35);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, color],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.star_rounded,
            size: 10,
            color: _DashTheme.gold.withOpacity(isDark ? 0.4 : 0.5),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Custom Ad Banner ─────────────────────────────────────────────────────────
class _CustomAdBanner extends StatelessWidget {
  final bool isBangla;
  const _CustomAdBanner({required this.isBangla});

  @override
  Widget build(BuildContext context) {
    final bannerController = Get.find<BannerController>();
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;

    return Obx(() {
      if (bannerController.campaignAds.isEmpty) return const SizedBox.shrink();

      final ad =
          bannerController.campaignAds[bannerController.currentAdIndex.value];
      final String title = ad['title'] ?? '';
      final String imageUrl = ad['imageUrl'] ?? '';
      final String targetUrl = ad['targetUrl'] ?? '';

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Container(
          key: ValueKey(ad['id']),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Ad Image
                AspectRatio(
                  aspectRatio: 3.2,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const SizedBox(),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.15),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                // Content
                Positioned(
                  left: 16,
                  bottom: 12,
                  right: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    _DashTheme.gold,
                                    _DashTheme.goldLight
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isBangla ? 'বিজ্ঞাপন' : 'AD',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (targetUrl.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            isBangla ? 'ভিজিট করুন' : 'Visit',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Tappable Area
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (targetUrl.isNotEmpty) {
                          final uri = Uri.parse(targetUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ── Islamic Geometric Pattern Painter ────────────────────────────────────────
class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const step = 36.0;

    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar8(canvas, paint, Offset(x, y), 10);
      }
    }
  }

  void _drawStar8(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 16; i++) {
      final angle = (i * 22.5 - 90) * (math.pi / 180);
      final radius = i.isEven ? r : r * 0.4;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_IslamicPatternPainter old) => false;
}
