import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'qibla_controller.dart';

class QiblaView extends StatelessWidget {
  const QiblaView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final c = Get.find<QiblaController>();
    final isDark = settings.isDark;

    // Custom Luxury Colors based on the image and user request
    final Color dialBg = isDark ? const Color(0xFF0D1B13) : const Color(0xFFFFFBF0);
    final Color cardBg = isDark ? const Color(0xFF14241B) : const Color(0xFFFFF4E0);
    final Color goldColor = const Color(0xFFFFD700);
    final Color scaffoldBg = isDark ? const Color(0xFF08120D) : const Color(0xFFFFF9E6);
    final Color textColor = isDark ? Colors.white : const Color(0xFF4A3428);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        leading: AppBackButton(color: isDark ? Colors.white : Colors.black87),
        backgroundColor: isDark ? const Color(0xFF0D1B13) : AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          settings.isBangla ? 'কিবলা কম্পাস' : 'Qibla Compass',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, 
            color: isDark ? Colors.white : Colors.white, 
            fontSize: 16
          ),
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value) return _buildShimmerLoading(isDark);
        
        final data = c.direction.value;
        if (data == null) return _buildShimmerLoading(isDark);

        final double qiblaOffset = data.qiblah;
        final bool isAligned = qiblaOffset.abs() < 5 || qiblaOffset.abs() > 355;
        c.handleAlignmentVibration(isAligned);

        return Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // 1. Top Location Card
                _buildLocationCard(c, cardBg, goldColor, settings, isDark, textColor),
                
                const SizedBox(height: 20),

                // 2. Middle Stats Row (Bearing & Distance)
                Row(
                  children: [
                    Expanded(child: _buildStatCard(
                      settings.isBangla ? 'কিবলার দিক' : 'Qibla Direction',
                      '${data.qiblah.round()}°',
                      settings.isBangla ? 'উত্তর থেকে' : 'From North',
                      Icons.explore_outlined, cardBg, goldColor, textColor
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(
                      settings.isBangla ? 'কাবা থেকে দূরত্ব' : 'Distance to Kaaba',
                      '${c.distanceToKaaba.value.toStringAsFixed(0)} km',
                      settings.isBangla ? 'প্রায়' : 'Approx',
                      Icons.location_on_outlined, cardBg, goldColor, textColor
                    )),
                  ],
                ),

                const SizedBox(height: 40),

                // 3. Main Compass
                _buildCompassUI(data, isAligned, dialBg, goldColor, isDark),

                const SizedBox(height: 40),
                
                // 4. Bottom Instruction Card
                _buildBottomInstruction(cardBg, goldColor, settings, textColor),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLocationCard(QiblaController c, Color bg, Color gold, SettingsController s, bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : AppColors.primary.withOpacity(0.1)),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: gold.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.location_on, color: gold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.isBangla ? 'আপনার অবস্থান' : 'Your Location', style: TextStyle(color: isDark ? Colors.white.withOpacity(0.5) : textColor.withOpacity(0.6), fontSize: 12)),
                Text(c.currentAddress.value, style: TextStyle(color: isDark ? Colors.white : textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(c.latLong.value, style: TextStyle(color: isDark ? Colors.white.withOpacity(0.4) : textColor.withOpacity(0.4), fontSize: 11)),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network('https://img.icons8.com/color/96/kaaba.png', width: 50, height: 50),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String sub, IconData icon, Color bg, Color gold, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: gold, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11), maxLines: 1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildCompassUI(QiblahDirection data, bool isAligned, Color dialBg, Color gold, bool isDark) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Decorative Ring
          Container(
            width: 310, height: 310,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold.withOpacity(0.2), width: 1),
            ),
          ),
          
          // Rotating Compass Plate
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: (data.direction * (math.pi / 180) * -1)),
            duration: const Duration(milliseconds: 300),
            builder: (context, angle, child) {
              return Transform.rotate(
                angle: angle,
                child: Container(
                  width: 290, height: 290,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dialBg,
                    border: Border.all(color: gold.withOpacity(0.6), width: 3),
                    boxShadow: [
                      BoxShadow(color: isAligned ? gold.withOpacity(0.2) : Colors.black26, blurRadius: 30, spreadRadius: 5),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Cardinal Directions
                      _buildCardinalLabel('N', 0, gold, isN: true),
                      _buildCardinalLabel('E', 90, gold),
                      _buildCardinalLabel('S', 180, gold),
                      _buildCardinalLabel('W', 270, gold),
                      
                      // Ticks
                      ...List.generate(72, (i) => Transform.rotate(
                        angle: (i * 5) * (math.pi / 180),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: i % 6 == 0 ? 12 : 5, width: 1.5,
                            margin: const EdgeInsets.only(top: 8),
                            color: gold.withOpacity(i % 6 == 0 ? 0.8 : 0.3),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              );
            },
          ),

          // Qibla Pointer & Needle
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: (data.qiblah * (math.pi / 180) * -1)),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, angle, child) {
              return Transform.rotate(
                angle: angle,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Kaaba Indicator on circle
                    Positioned(
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: isAligned ? gold : Colors.black87, shape: BoxShape.circle, border: Border.all(color: gold)),
                        child: Image.network('https://img.icons8.com/color/48/kaaba.png', width: 24, height: 24),
                      ),
                    ),
                    // 3D Golden Needle
                    Container(
                      width: 200, height: 200,
                      child: CustomPaint(painter: LuxuryNeedlePainter(color: gold)),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Center Pin
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(color: dialBg, shape: BoxShape.circle, border: Border.all(color: gold, width: 3)),
          ),
        ],
      ),
    );
  }

  Widget _buildCardinalLabel(String label, double angle, Color color, {bool isN = false}) {
    return Transform.rotate(
      angle: angle * (math.pi / 180),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isN) Icon(Icons.arrow_drop_up, color: Colors.red, size: 14),
              Text(label, style: TextStyle(color: isN ? Colors.red : (label == 'S' || label == 'E' || label == 'W' ? Colors.white70 : Colors.white), fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInstruction(Color bg, Color gold, SettingsController s, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: gold, size: 30),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.isBangla ? 'কিবলার দিকে মুখ করুন' : 'Face towards the Kaaba', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(s.isBangla ? 'তীরচিহ্নটি কাবার সাথে মিলিয়ে নিন' : 'Align the arrow with the Kaaba icon', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ],
          )),
          const Icon(Icons.accessibility_new_rounded, color: Colors.white24, size: 40),
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

    // Modern Sharp Triangle Needle (3D style)
    path.moveTo(cx, 10);
    path.lineTo(cx - 15, cy);
    path.lineTo(cx + 15, cy);
    path.close();
    canvas.drawPath(path, paint);
    
    // Shadow for 3D effect
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
