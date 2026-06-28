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

    // Custom Luxury Colors - Dark Mode is now Zinc/Black, not green
    final Color dialBg = isDark ? const Color(0xFF18181B) : const Color(0xFFFFFBF0);
    final Color cardBg = isDark ? const Color(0xFF27272A) : const Color(0xFFFFF4E0);
    final Color orangeColor = AppColors.primary;
    final Color scaffoldBg = isDark ? const Color(0xFF09090B) : const Color(0xFFFFF9E6);
    final Color textColor = isDark ? Colors.white : const Color(0xFF4A3428);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        leading: const AppBackButton(color: Colors.white),
        backgroundColor: isDark ? const Color(0xFF09090B) : AppColors.primary,
        elevation: 0,
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

        final double qiblaOffset = data.qiblah;
        final double deviceHeading = data.direction;
        
        final bool isAligned = qiblaOffset.abs() < 5 || qiblaOffset.abs() > 355;
        c.handleAlignmentVibration(isAligned);

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isDark ? const LinearGradient(
              colors: [Color(0xFF09090B), Color(0xFF020202)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ) : null,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  
                  _buildLocationCard(c, cardBg, orangeColor, settings, isDark, textColor),
                  
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        settings.isBangla ? 'কিবলার দিক' : 'Qibla Direction',
                        '${(qiblaOffset + deviceHeading) % 360 >= 0 ? ((qiblaOffset + deviceHeading) % 360).round() : ((qiblaOffset + deviceHeading) % 360 + 360).round()}°',
                        settings.isBangla ? 'উত্তর থেকে' : 'From North',
                        Icons.explore_outlined, cardBg, orangeColor, textColor, isDark
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard(
                        settings.isBangla ? 'কাবা থেকে দূরত্ব' : 'Distance to Kaaba',
                        '${c.distanceToKaaba.value.toStringAsFixed(0)} km',
                        settings.isBangla ? 'প্রায়' : 'Approx',
                        Icons.location_on_outlined, cardBg, orangeColor, textColor, isDark
                      )),
                    ],
                  ),

                  const SizedBox(height: 40),

                  _buildCompassUI(data, isAligned, dialBg, orangeColor, isDark),

                  const SizedBox(height: 40),
                  
                  _buildBottomInstruction(cardBg, orangeColor, settings, textColor, isDark),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLocationCard(QiblaController c, Color bg, Color orange, SettingsController s, bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: orange.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.location_on, color: orange, size: 24),
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

  Widget _buildStatCard(String title, String value, String sub, IconData icon, Color bg, Color orange, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : orange.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: orange, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(color: isDark ? Colors.white.withOpacity(0.5) : textColor.withOpacity(0.6), fontSize: 11), maxLines: 1)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: isDark ? Colors.white : textColor, fontSize: 22, fontWeight: FontWeight.w900)),
          Text(sub, style: TextStyle(color: isDark ? Colors.white.withOpacity(0.3) : textColor.withOpacity(0.4), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildCompassUI(QiblahDirection data, bool isAligned, Color dialBg, Color orange, bool isDark) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 310, height: 310,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: orange.withOpacity(0.2), width: 1),
            ),
          ),
          
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
                    border: Border.all(color: orange.withOpacity(0.8), width: 3),
                    boxShadow: [
                      BoxShadow(color: isAligned ? orange.withOpacity(0.3) : Colors.black26, blurRadius: 30, spreadRadius: 5),
                    ],
                  ),
                  child: Stack(
                    children: [
                      _buildCardinalLabel('N', 0, orange, isDark, isN: true),
                      _buildCardinalLabel('E', 90, orange, isDark),
                      _buildCardinalLabel('S', 180, orange, isDark),
                      _buildCardinalLabel('W', 270, orange, isDark),
                      
                      ...List.generate(72, (i) => Transform.rotate(
                        angle: (i * 5) * (math.pi / 180),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: i % 6 == 0 ? 12 : 5, width: 1.5,
                            margin: const EdgeInsets.only(top: 8),
                            color: orange.withOpacity(i % 6 == 0 ? 0.8 : 0.3),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              );
            },
          ),

          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: (data.qiblah * (math.pi / 180))),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (context, angle, child) {
              return Transform.rotate(
                angle: angle,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: isAligned ? orange : Colors.black87, shape: BoxShape.circle, border: Border.all(color: orange)),
                        child: Image.network('https://img.icons8.com/color/48/kaaba.png', width: 24, height: 24),
                      ),
                    ),
                    Container(
                      width: 200, height: 200,
                      child: CustomPaint(painter: LuxuryNeedlePainter(color: orange)),
                    ),
                  ],
                ),
              );
            },
          ),
          
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(color: dialBg, shape: BoxShape.circle, border: Border.all(color: orange, width: 3)),
          ),
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
                  color: isN ? Colors.red : (isDark ? Colors.white : const Color(0xFF4A3428)), 
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

  Widget _buildBottomInstruction(Color bg, Color orange, SettingsController s, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: orange, size: 30),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.isBangla ? 'কিবলার দিকে মুখ করুন' : 'Face towards the Kaaba', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(s.isBangla ? 'তীরচিহ্নটি কাবার সাথে মিলিয়ে নিন' : 'Align the arrow with the Kaaba icon', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
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
