import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../modules/settings/settings_controller.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final bool bn = settings.isBangla;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting card
          _GreetingCard(isBangla: bn).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // Quick actions
          Text(
            bn ? 'দ্রুত অ্যাক্সেস' : 'Quick Access',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
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
                icon: Icons.menu_book_rounded,
                label: bn ? 'কুরআন' : 'Quran',
                color: AppColors.primary,
                route: AppRoutes.quran,
              ),
              _QuickActionCard(
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
                icon: Icons.self_improvement_rounded,
                label: bn ? 'নামাজ গাইড' : 'Salah',
                color: AppColors.emerald,
                route: AppRoutes.salahGuide,
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
                icon: Icons.school_rounded,
                label: bn ? 'নতুন মুসলিম' : 'New Muslim',
                color: AppColors.info,
                route: AppRoutes.newMuslimGuide,
              ),
              _QuickActionCard(
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

          // Daily Verse card
          _DailyVerseCard(isBangla: bn).animate(delay: 600.ms).fadeIn(),

          const SizedBox(height: 80), // FAB space
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final bool isBangla;

  const _GreetingCard({required this.isBangla});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return isBangla ? 'আস-সালামু আলাইকুম 🌙' : 'Assalamu Alaikum 🌙';
    if (hour < 12) return isBangla ? 'সুপ্রভাত ☀️' : 'Good Morning ☀️';
    if (hour < 17) return isBangla ? 'শুভ অপরাহ্ন 🌤' : 'Good Afternoon 🌤';
    if (hour < 20) return isBangla ? 'শুভ সন্ধ্যা 🌅' : 'Good Evening 🌅';
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
                    color: Colors.black.withValues(alpha: 0.7),
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

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyVerseCard extends StatelessWidget {
  final bool isBangla;

  const _DailyVerseCard({required this.isBangla});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.borderDark, width: 0.5),
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
                  color: AppColors.primary.withValues(alpha: 0.15),
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
              Icon(
                Icons.share_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'Uthmanic',
              color: AppColors.gold,
              height: 1.8,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 12),
          Text(
            isBangla
                ? 'যে আল্লাহকে ভয় করে, তিনি তার জন্য পথ করে দেন।'
                : 'And whoever fears Allah — He will make for him a way out.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isBangla ? '— সূরা আত-তালাক (৬৫:২)' : '— Surah At-Talaq (65:2)',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
