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
            // Greeting card
            _GreetingCard(isBangla: bn, currentHour: currentHour).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // Quick actions
            Text(
              bn ? 'দ্রুত অ্যাক্সেস' : 'Quick Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
            ).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _QuickActionCard(
                  showcaseKey: homeController.quranKey,
                  showcaseTitle: bn ? 'কুরআন' : 'Quran',
                  showcaseDesc: bn ? 'এখান থেকে কুরআন পড়ুন' : 'Read the Holy Quran from here',
                  icon: Icons.menu_book_rounded,
                  label: bn ? 'কুরআন' : 'Quran',
                  color: AppColors.primary,
                  route: AppRoutes.quran,
                ),
                _QuickActionCard(
                  showcaseKey: homeController.prayerKey,
                  showcaseTitle: bn ? 'নামাজ' : 'Prayer',
                  showcaseDesc: bn ? 'আজকের নামাজের সময় দেখুন' : 'Check today\'s prayer times',
                  icon: Icons.access_time_rounded,
                  label: bn ? 'নামাজ' : 'Prayer',
                  color: AppColors.fajr,
                  route: AppRoutes.prayerTime,
                ),
                _QuickActionCard(
                  icon: Icons.explore_rounded,
                  label: bn ? 'কিবলা' : 'Qibla',
                  color: AppColors.islamic,
                  route: AppRoutes.qibla,
                ),
                _QuickActionCard(
                  showcaseKey: homeController.learnKey,
                  showcaseTitle: bn ? 'শিক্ষা' : 'Learn',
                  showcaseDesc: bn ? 'নতুন মুসলিমদের জন্য শিক্ষা' : 'Step-by-step education for new Muslims',
                  icon: Icons.school_rounded,
                  label: bn ? 'শিক্ষা ও গাইড' : 'Learning & Guide',
                  color: AppColors.info,
                  route: AppRoutes.newMuslimGuide,
                ),
                _QuickActionCard(
                  icon: Icons.volunteer_activism_rounded,
                  label: bn ? 'দোয়া' : "Du'a",
                  color: AppColors.dhuhr,
                  route: AppRoutes.duas,
                ),
                _QuickActionCard(
                  icon: Icons.radio_button_checked_rounded,
                  label: bn ? 'তাসবীহ' : 'Tasbih',
                  color: AppColors.goldDark,
                  route: AppRoutes.tasbih,
                ),
                _QuickActionCard(
                  icon: Icons.track_changes_rounded,
                  label: bn ? 'ট্র্যাকার' : 'Tracker',
                  color: AppColors.islamicLight,
                  route: AppRoutes.tracker,
                ),
                _QuickActionCard(
                  icon: Icons.menu_book_outlined,
                  label: bn ? 'নামাজ শিক্ষা' : 'Namaz Guide',
                  color: AppColors.primary,
                  route: AppRoutes.salahGuide,
                ),
                _QuickActionCard(
                  showcaseKey: homeController.settingsKey,
                  showcaseTitle: bn ? 'প্রোফাইল' : 'Profile',
                  showcaseDesc: bn ? 'সেটিংস ও প্রগ্রেস দেখুন' : 'View your settings and progress',
                  icon: Icons.settings_rounded,
                  label: bn ? 'সেটিংস' : 'Settings',
                  color: AppColors.textMuted,
                  route: AppRoutes.settings,
                ),
              ].asMap().entries.map((entry) {
                return entry.value
                    .animate(delay: (150 + entry.key * 60).ms)
                    .fadeIn()
                    .scale(begin: const Offset(0.8, 0.8));
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Custom Ad Banner
            _CustomAdBanner(isBangla: bn).animate(delay: 500.ms).fadeIn(),

            const SizedBox(height: 24),

            // Daily Verse card
            _DailyVerseCard(isBangla: bn).animate(delay: 600.ms).fadeIn(),

            const SizedBox(height: 80), // FAB space
          ],
        ),
      );
    });
  }
}

class _GreetingCard extends StatelessWidget {
  final bool isBangla;
  final int currentHour;

  const _GreetingCard({required this.isBangla, required this.currentHour});

  String _getGreeting() {
    if (currentHour < 5) return isBangla ? 'আস-সালামু আলাইকুম 🌙' : 'Assalamu Alaikum 🌙';
    if (currentHour < 12) return isBangla ? 'সুপ্রভাত ☀️' : 'Good Morning ☀️';
    if (currentHour < 17) return isBangla ? 'শুভ অপরাহ্ন 🌤' : 'Good Afternoon 🌤';
    if (currentHour < 20) return isBangla ? 'শুভ সন্ধ্যা 🌅' : 'Good Evening 🌅';
    return isBangla ? 'শুভ রাত্রি 🌙' : 'Good Night 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isBangla
                      ? 'আজকের তেলাওয়াত শুরু করুন'
                      : 'Start your recitation today',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.quran),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(isBangla ? 'পড়া শুরু করুন' : 'Continue Reading'),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.menu_book_rounded,
            size: 60,
            color: Colors.black38,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  final GlobalKey? showcaseKey;
  final String? showcaseTitle;
  final String? showcaseDesc;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
    this.showcaseKey,
    this.showcaseTitle,
    this.showcaseDesc,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;

    Widget card = GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textGrey : AppColors.textDark.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
    arabic: 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ মَخْرَجًا',
    english: 'And whoever fears Allah — He will make for him a way out.',
    bangla: 'যে আল্লাহকে ভয় করে, তিনি তার জন্য পথ করে দেন।',
    referenceEn: '— Surah At-Talaq (65:2)',
    referenceBn: '— সূরা আত-তালাক (৬৫:২)',
  ),
  _DailyVerse(
    arabic: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ',
    english: 'And when My servants ask you concerning Me - indeed I am near.',
    bangla: 'আর যখন আমার বান্দাগণ আমার সম্পর্কে জিজ্ঞাসা করে, নিশ্চয়ই আমি নিকটে আছি।',
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
    arabic: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
    english: 'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
    bangla: 'তুমি ছাড়া কোন উপাস্য নেই, তুমি পবিত্র! নিশ্চয় আমি অপরাধীদের অন্তর্ভুক্ত ছিলাম।',
    referenceEn: '— Surah Al-Anbiya (21:87)',
    referenceBn: '— সূরা আল-আম্বিয়া (২১:৮৭)',
  ),
  _DailyVerse(
    arabic: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
    english: 'If you are grateful, I will surely increase you [in favor].',
    bangla: 'যদি তোমরা কৃতজ্ঞতা প্রকাশ করো, তবে আমি অবশ্যই তোমাদেরকে বাড়িয়ে দেব।',
    referenceEn: '— Surah Ibrahim (14:7)',
    referenceBn: '— সূরা ইব্রাহিম (১৪:৭)',
  ),
  _DailyVerse(
    arabic: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي',
    english: 'So remember Me; I will remember you. And be grateful to Me.',
    bangla: 'অতএব তোমরা আমাকে স্মরণ করো, আমিও তোমাদের স্মরণ করব। আর আমার প্রতি কৃতজ্ঞ হও।',
    referenceEn: '— Surah Al-Baqarah (2:152)',
    referenceBn: '— সূরা আল-বাকারা (২:১৫২)',
  ),
  _DailyVerse(
    arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي  وَيَسِّরْ لِي أَمْرِي',
    english: 'My Lord, expand for me my breast [with assurance] and ease for me my task.',
    bangla: 'হে আমার রব, আমার বুক প্রশস্ত করে দিন এবং আমার কাজ সহজ করে দিন।',
    referenceEn: '— Surah Taha (20:25-26)',
    referenceBn: '— সূরা তহা (২০:২৫-২৬)',
  ),
];

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.fromBorderSide(
          BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isBangla ? 'আজকের আয়াত' : 'Verse of the Day',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 18),
                color: isDark ? AppColors.textMuted : AppColors.textDark.withOpacity(0.5),
                onPressed: () {
                  final text = isBangla
                      ? '${verse.arabic}\n\n${verse.bangla}\n\n${verse.referenceBn}\n\nShared from Quran App'
                      : '${verse.arabic}\n\n${verse.english}\n\n${verse.referenceEn}\n\nShared from Quran App';
                  Share.share(text);
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            verse.arabic,
            style: GoogleFonts.amiri(
              fontSize: 22,
              color: AppColors.gold,
              height: 1.8,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 12),
          Text(
            isBangla ? verse.bangla : verse.english,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textGrey : AppColors.textDark.withOpacity(0.8),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isBangla ? verse.referenceBn : verse.referenceEn,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textMuted : AppColors.textDark.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

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

      final ad = bannerController.campaignAds[bannerController.currentAdIndex.value];
      final String title = ad['title'] ?? '';
      final String imageUrl = ad['imageUrl'] ?? '';
      final String targetUrl = ad['targetUrl'] ?? '';

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Container(
          key: ValueKey(ad['id']),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
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
                          Colors.black.withOpacity(0.2),
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
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isBangla ? 'বিজ্ঞাপন' : 'AD',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isBangla ? 'ভিজিট করুন' : 'Visit',
                            style: const TextStyle(
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
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
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
