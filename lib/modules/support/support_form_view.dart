import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_back_button.dart';
import '../settings/settings_controller.dart';
import 'support_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _FormTheme {
  _FormTheme._();
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

class SupportFormView extends GetView<SupportController> {
  const SupportFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isBn = settings.isBangla;
    final isDark = settings.isDark;

    return Scaffold(
      backgroundColor: isDark ? _FormTheme.darkSurface : _FormTheme.lightSurface,
      appBar: AppBar(
        elevation: 0,
        leading: const AppBackButton(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_FormTheme.emeraldDark, _FormTheme.emerald, _FormTheme.emeraldLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(bottom: BorderSide(color: _FormTheme.gold, width: 1.5)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPatternPainter())),
            ],
          ),
        ),
        title: Text(
          isBn ? 'নতুন চ্যাট' : 'New Chat',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _FormTheme.emerald.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: _FormTheme.gold.withOpacity(0.3), width: 1),
                    ),
                    child: const Icon(Icons.forum_rounded, size: 48, color: _FormTheme.emerald),
                  ).animate().scale(),
                  const SizedBox(height: 24),
                  Text(
                    isBn ? 'কিভাবে সাহায্য করতে পারি?' : 'Start a conversation',
                    style: GoogleFonts.poppins(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isBn 
                      ? 'নিচে আপনার সমস্যাটি লিখুন এবং আমাদের টিম দ্রুত আপনার সাথে যোগাযোগ করবে।' 
                      : 'Please describe your issue below and our team will get back to you shortly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textDark.withOpacity(0.7), 
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 36),
                  
                  // Message Starter Bubble
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? _FormTheme.darkCard : _FormTheme.lightCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? _FormTheme.emerald.withOpacity(0.15) : _FormTheme.emerald.withOpacity(0.06),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _FormTheme.emerald.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'বিষয় (ঐচ্ছিক)' : 'Subject (Optional)',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: _FormTheme.emerald),
                        ),
                        TextField(
                          controller: controller.subjectController,
                          style: TextStyle(fontSize: 16, color: isDark ? Colors.white : AppColors.textDark),
                          decoration: InputDecoration(
                            hintText: isBn ? 'যেমন: লগইন সমস্যা' : 'e.g., Recitation error',
                            hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
                            border: InputBorder.none,
                          ),
                        ),
                        Divider(color: isDark ? Colors.white10 : Colors.grey.shade200),
                        const SizedBox(height: 8),
                        Text(
                          isBn ? 'আপনার বার্তা' : 'Your Message',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: _FormTheme.emerald),
                        ),
                        TextField(
                          controller: controller.descriptionController,
                          maxLines: 5,
                          style: TextStyle(fontSize: 16, color: isDark ? Colors.white : AppColors.textDark),
                          decoration: InputDecoration(
                            hintText: isBn ? 'এখানে লিখুন...' : 'Type details here...',
                            hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
          
          // Submit Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? _FormTheme.darkCard : _FormTheme.lightCard,
              border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : controller.createTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _FormTheme.emerald,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: _FormTheme.gold, width: 1),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isSubmitting.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isBn ? 'মেসেজ পাঠান' : 'Send Message', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                )),
              ),
            ),
          ),
        ],
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
