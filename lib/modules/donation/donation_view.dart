import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _DonateTheme {
  _DonateTheme._();
  static const Color emerald      = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark  = Color(0xFF0D3B1E);
  static const Color gold         = Color(0xFFC9A84C);
  static const Color goldLight    = Color(0xFFE8C97A);
  static const Color goldSoft     = Color(0xFFFFF8E7);
  static const Color darkSurface  = Color(0xFF141420);
  static const Color darkCard     = Color(0xFF1E1E2E);
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard    = Color(0xFFFFFFFF);
}

class DonationView extends StatelessWidget {
  const DonationView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;
    final isBn = settings.isBangla;

    return Scaffold(
      backgroundColor: isDark ? _DonateTheme.darkSurface : _DonateTheme.lightSurface,
      appBar: AppBar(
        leading: const AppBackButton(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_DonateTheme.emeraldDark, _DonateTheme.emerald, _DonateTheme.emeraldLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(bottom: BorderSide(color: _DonateTheme.gold, width: 1.5)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPatternPainter())),
            ],
          ),
        ),
        title: Text(
          isBn ? 'অনুদান ও সদকা' : 'Donation & Sadakah',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Islamic Quote Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_DonateTheme.emeraldDark, _DonateTheme.emerald],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _DonateTheme.gold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _DonateTheme.emerald.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'مَّن ذَا الَّذِي يُقْرِضُ اللَّهَ قَرْضًا حَسَنًا فَيُضَاعِفَهُ لَهُ أَضْعَافًا كَثِيرَةً',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 20,
                      color: _DonateTheme.goldSoft,
                      height: 1.6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isBn
                        ? '“কে সেই যে আল্লাহকে করজে হাসানা (উত্তম ঋণ) দেবে? ফলে তিনি তার জন্য তা বহু গুণ বাড়িয়ে দেবেন।” (সূরা আল-বাকারাহ: ২৪৫)'
                        : '“Who is it that would loan Allah a goodly loan so He may multiply it for him many times over?” (Surah Al-Baqarah: 245)',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sadakah Jariyah Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: isDark ? _DonateTheme.darkCard : _DonateTheme.lightCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? _DonateTheme.emerald.withOpacity(0.15) : _DonateTheme.emerald.withOpacity(0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _DonateTheme.emerald.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn
                        ? 'সদকায়ে জারিয়া হিসেবে অংশ নিন'
                        : 'Sadakah Jariyah (Ongoing Charity)',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isBn
                        ? 'এই অ্যাপটি সম্পূর্ণ বিজ্ঞাপনমুক্ত এবং বিনামূল্যে কুরআন শিক্ষার উদ্দেশ্যে তৈরি। অ্যাপটির উন্নয়ন ও সার্ভার মেইনটেন্যান্স সচল রাখতে আপনার সদকা দিয়ে সাহায্য করতে পারেন।'
                        : 'This application is entirely ad-free and free for teaching Al-Quran. To keep updates, feature developments and server maintenance running, you can contribute your Sadakah.',
                    style: GoogleFonts.poppins(
                      color: AppColors.textGrey,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Methods Title
            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _DonateTheme.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isBn
                      ? 'মোবাইল ও ব্যাংক অ্যাকাউন্ট'
                      : 'Payment Accounts',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: _DonateTheme.emerald),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bkash/Nagad/Rocket
            _buildDonationMethod(
              context,
              settings,
              'bKash / Nagad (Personal)',
              '+880 13074 60389',
              Icons.phone_android_rounded,
            ),
            const SizedBox(height: 12),

            // Bank Account
            _buildDonationMethod(
              context,
              settings,
              'Islami Bank Bangladesh Ltd',
              'A/C No: 2050 356 67 00160203\nName: Quran App Project',
              Icons.account_balance_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationMethod(
    BuildContext context,
    SettingsController settings,
    String method,
    String details,
    IconData icon,
  ) {
    final isDark = settings.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? _DonateTheme.darkCard : _DonateTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? _DonateTheme.emerald.withOpacity(0.15) : _DonateTheme.emerald.withOpacity(0.06),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _DonateTheme.emerald.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _DonateTheme.emerald, size: 24),
        ),
        title: Text(
          method,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            details,
            style: GoogleFonts.poppins(
              color: AppColors.textGrey,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_all_rounded, color: _DonateTheme.gold),
          onPressed: () {
            // Remove text formatting to copy raw number
            final cleanNum = details.replaceAll(RegExp(r'[^0-9+]'), '');
            Clipboard.setData(
              ClipboardData(text: cleanNum.isNotEmpty ? cleanNum : details),
            );
            Get.snackbar(
              settings.isBangla ? 'অনুলিপি করা হয়েছে' : 'Copied',
              settings.isBangla
                  ? 'অ্যাকাউন্ট নম্বরটি কপি করা হয়েছে!'
                  : 'Account details copied to clipboard!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: _DonateTheme.emerald.withOpacity(0.92),
              colorText: Colors.white,
            );
          },
        ),
      ),
    );
  }
}

// ─── Islamic Star / Geometric Pattern Painter ──────────────────────────────────
class _StarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const step = 32.0;

    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar6(canvas, paint, Offset(x, y), 9);
      }
    }
  }

  void _drawStar6(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * (3.14159 / 180);
      final radius = i.isEven ? r : r * 0.45;
      final point = Offset(
        center.dx + radius * _cos(angle),
        center.dy + radius * _sin(angle),
      );
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double rad) => rad == 0
      ? 1
      : (rad - (rad * rad * rad) / 6 + (rad * rad * rad * rad * rad) / 120);
  double _sin(double rad) =>
      rad - (rad * rad * rad) / 6 + (rad * rad * rad * rad * rad) / 120;

  @override
  bool shouldRepaint(_StarPatternPainter old) => false;
}
