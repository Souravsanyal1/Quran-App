import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'qibla_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _QiblaTheme {
  _QiblaTheme._();
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

class QiblaView extends StatelessWidget {
  const QiblaView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final c = Get.find<QiblaController>();
    final isDark = settings.isDark;

    final Color dialBg = isDark ? _QiblaTheme.darkSurface : _QiblaTheme.goldSoft;
    final Color cardBg = isDark ? _QiblaTheme.darkCard : _QiblaTheme.lightCard;
    final Color primaryColor = _QiblaTheme.emerald;
    final Color scaffoldBg = isDark ? _QiblaTheme.darkSurface : _QiblaTheme.lightSurface;
    final Color textColor = isDark ? Colors.white : AppColors.textDark;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        leading: const AppBackButton(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_QiblaTheme.emeraldDark, _QiblaTheme.emerald, _QiblaTheme.emeraldLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(bottom: BorderSide(color: _QiblaTheme.gold, width: 1.5)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPatternPainter())),
            ],
          ),
        ),
        centerTitle: true,
        title: Text(
          settings.isBangla ? 'কিবলা কম্পাস' : 'Qibla Compass',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, 
            color: Colors.white, 
            fontSize: 16
          ),
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value) return _buildShimmerLoading(isDark);
        
        if (c.errorMessage.value != null) {
          return _buildErrorState(c.errorMessage.value!, c.requestPermission, settings);
        }

        final data = c.direction.value;
        if (data == null) return _buildShimmerLoading(isDark);

        final double deviceHeading = data.direction;
        final double qiblaBearing = data.qiblah;
        final double offset = qiblaBearing - deviceHeading;
        
        final bool isAligned = offset.abs() < 5 || offset.abs() > 355;
        c.handleAlignmentVibration(isAligned);

        return Container(
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // Location Info
                  _buildLocationCard(c, cardBg, primaryColor, settings, isDark, textColor),
                  
                  const SizedBox(height: 16),

                  // Stats Info
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        settings.isBangla ? 'কিবলার দিক' : 'Qibla Bearing',
                        '${qiblaBearing.round()}°',
                        settings.isBangla ? 'উত্তর থেকে' : 'From North',
                        Icons.explore_outlined, cardBg, primaryColor, textColor, isDark
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard(
                        settings.isBangla ? 'কাবা থেকে দূরত্ব' : 'Distance to Kaaba',
                        '${c.distanceToKaaba.value.toStringAsFixed(0)} km',
                        settings.isBangla ? 'প্রায়' : 'Approx',
                        Icons.location_on_outlined, cardBg, primaryColor, textColor, isDark
                      )),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // COMPASS UI
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Static outer ring
                        Container(
                          width: 310, height: 310,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _QiblaTheme.gold.withOpacity(0.2), width: 1.5),
                          ),
                        ),
                        
                        // 1. Rotating Compass Dial (Stays aligned with Earth's North)
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: (deviceHeading * (math.pi / 180) * -1)),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, angle, child) {
                            return Transform.rotate(
                              angle: angle,
                              child: Container(
                                width: 290, height: 290,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: dialBg,
                                  border: Border.all(color: isAligned ? _QiblaTheme.gold : _QiblaTheme.emerald, width: 3),
                                  boxShadow: [
                                    BoxShadow(color: isAligned ? _QiblaTheme.gold.withOpacity(0.3) : Colors.black12, blurRadius: 20, spreadRadius: 3),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    _buildCardinalLabel('N', 0, primaryColor, isDark, isN: true),
                                    _buildCardinalLabel('E', 90, primaryColor, isDark),
                                    _buildCardinalLabel('S', 180, primaryColor, isDark),
                                    _buildCardinalLabel('W', 270, primaryColor, isDark),
                                    
                                    // Ticks
                                    ...List.generate(72, (i) => Transform.rotate(
                                      angle: (i * 5) * (math.pi / 180),
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          height: i % 6 == 0 ? 12 : 5, width: 1.5,
                                          margin: const EdgeInsets.only(top: 8),
                                          color: i % 6 == 0 ? _QiblaTheme.gold : _QiblaTheme.emerald.withOpacity(0.3),
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // 2. Needle (Rotating relative to phone to point at Makkah)
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: (offset * (math.pi / 180))),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          builder: (context, angle, child) {
                            return Transform.rotate(
                              angle: angle,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Kaaba Icon at the tip
                                  Positioned(
                                    top: -5,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: isAligned ? _QiblaTheme.gold : (isDark ? Colors.black87 : Colors.white), 
                                        shape: BoxShape.circle, 
                                        border: Border.all(color: _QiblaTheme.gold, width: 1.5),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: 'https://img.icons8.com/color/48/kaaba.png',
                                        width: 24,
                                        height: 24,
                                        errorWidget: (context, url, error) => const Icon(Icons.mosque, color: _QiblaTheme.gold, size: 20),
                                      ),
                                    ),
                                  ),
                                  // Needle
                                  Container(
                                    width: 200, height: 200,
                                    child: CustomPaint(painter: LuxuryNeedlePainter(color: isAligned ? _QiblaTheme.gold : _QiblaTheme.emerald)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        
                        // Center Pin
                        Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(color: dialBg, shape: BoxShape.circle, border: Border.all(color: _QiblaTheme.gold, width: 3)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),
                  
                  // Instruction Card
                  _buildBottomInstruction(cardBg, primaryColor, settings, textColor, isDark),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLocationCard(QiblaController c, Color bg, Color emerald, SettingsController s, bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? _QiblaTheme.emerald.withOpacity(0.15) : _QiblaTheme.emerald.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: emerald.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.location_on_rounded, color: emerald, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.isBangla ? 'আপনার অবস্থান' : 'Your Location', style: TextStyle(color: isDark ? Colors.white.withOpacity(0.5) : textColor.withOpacity(0.6), fontSize: 12)),
                Text(c.currentAddress.value, style: TextStyle(color: isDark ? Colors.white : textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(c.latLong.value, style: TextStyle(color: isDark ? Colors.white.withOpacity(0.4) : textColor.withOpacity(0.4), fontSize: 11)),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: 'https://img.icons8.com/color/96/kaaba.png',
              width: 48,
              height: 48,
              errorWidget: (context, url, error) => const Icon(Icons.mosque, color: _QiblaTheme.gold, size: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String sub, IconData icon, Color bg, Color emerald, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? _QiblaTheme.emerald.withOpacity(0.15) : _QiblaTheme.emerald.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _QiblaTheme.gold, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(color: isDark ? Colors.white.withOpacity(0.5) : textColor.withOpacity(0.6), fontSize: 11), maxLines: 1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: isDark ? Colors.white : textColor, fontSize: 20, fontWeight: FontWeight.w900)),
          Text(sub, style: TextStyle(color: isDark ? Colors.white.withOpacity(0.3) : textColor.withOpacity(0.4), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildCardinalLabel(String label, double angle, Color color, bool isDark, {bool isN = false}) {
    return Transform.rotate(
      angle: angle * (math.pi / 180),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isN) const Icon(Icons.arrow_drop_up, color: Colors.red, size: 14),
              Text(
                label, 
                style: TextStyle(
                  color: isN ? Colors.red : (isDark ? Colors.white : _QiblaTheme.emerald), 
                  fontWeight: FontWeight.w900, 
                  fontSize: 18
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInstruction(Color bg, Color emerald, SettingsController s, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? _QiblaTheme.emerald.withOpacity(0.15) : _QiblaTheme.emerald.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: _QiblaTheme.gold, size: 30),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.isBangla ? 'কিবলার দিকে মুখ করুন' : 'Face towards the Kaaba', style: TextStyle(color: isDark ? Colors.white : textColor, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(s.isBangla ? 'তীরচিহ্নটি কাবার সাথে মিলিয়ে নিন' : 'Align the arrow with the Kaaba icon', style: TextStyle(color: isDark ? Colors.white.withOpacity(0.5) : textColor.withOpacity(0.5), fontSize: 11)),
            ],
          )),
          Icon(Icons.accessibility_new_rounded, color: isDark ? Colors.white24 : textColor.withOpacity(0.1), size: 40),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.grey[300]!,
      highlightColor: isDark ? Colors.white24 : Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [const SizedBox(height: 60), Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))), const SizedBox(height: 60), Container(width: 290, height: 290, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))]),
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry, SettingsController s) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_rounded, size: 64, color: Colors.redAccent),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: _QiblaTheme.emerald, foregroundColor: Colors.white),
              child: Text(s.isBangla ? 'আবার চেষ্টা করুন' : 'Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class LuxuryNeedlePainter extends CustomPainter {
  final Color color;
  LuxuryNeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;

    path.moveTo(cx, 10);
    path.lineTo(cx - 15, cy);
    path.lineTo(cx + 15, cy);
    path.close();
    canvas.drawPath(path, paint);
    
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.3);
    final shadowPath = Path();
    shadowPath.moveTo(cx, 10);
    shadowPath.lineTo(cx, cy);
    shadowPath.lineTo(cx + 15, cy);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
