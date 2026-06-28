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

    return Scaffold(
      backgroundColor: settings.isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        leading: const AppBackButton(color: Colors.white),
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          settings.isBangla ? 'কিবলা কম্পাস' : 'Qibla Finder',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value) return _buildShimmerLoading(settings.isDark);
        
        if (!c.isLocationEnabled.value) {
          return _buildErrorState(
            settings.isBangla ? 'লোকেশন বন্ধ আছে' : 'Location Service Disabled',
            settings.isBangla ? 'সঠিক দিক পেতে আপনার ফোনের লোকেশন চালু করুন।' : 'Enable location to find the Qibla direction.',
            Icons.location_off_rounded,
            c.requestPermission,
            settings.isBangla ? 'লোকেশন চালু করুন' : 'Enable Location',
          );
        }

        if (!c.hasPermission.value) {
          return _buildErrorState(
            settings.isBangla ? 'পারমিশন প্রয়োজন' : 'Permission Required',
            settings.isBangla ? 'অ্যাপটি ব্যবহারের জন্য লোকেশন পারমিশন দিন।' : 'Location permission is required to find Qibla.',
            Icons.security_rounded,
            c.requestPermission,
            settings.isBangla ? 'পারমিশন দিন' : 'Grant Permission',
          );
        }

        final data = c.direction.value;
        if (data == null) return _buildShimmerLoading(settings.isDark);

        final qiblaBearing = data.qiblah;
        final compassDirection = data.direction;
        
        // Check if user is aligned within 5 degrees
        final bool isAligned = (qiblaBearing - compassDirection).abs() < 5;
        c.handleAlignmentVibration(isAligned);

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Distance & Angle Info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: settings.isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoColumn(
                      settings.isBangla ? 'দূরত্ব' : 'Distance',
                      '${c.distanceToKaaba.value.toStringAsFixed(0)} km',
                      Icons.straighten_rounded,
                    ),
                    Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                    _buildInfoColumn(
                      settings.isBangla ? 'কোণ' : 'Bearing',
                      '${qiblaBearing.round()}°',
                      Icons.explore_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Kaaba Compass UI
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass Plate (Static Background)
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: settings.isDark ? AppColors.surfaceDark : Colors.white,
                        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 8),
                        boxShadow: [
                          BoxShadow(
                            color: isAligned 
                              ? AppColors.primary.withOpacity(0.3) 
                              : Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: List.generate(360, (index) {
                          if (index % 30 != 0) return const SizedBox.shrink();
                          return Transform.rotate(
                            angle: index * (math.pi / 180),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: const EdgeInsets.only(top: 10),
                                height: index % 90 == 0 ? 15 : 8,
                                width: 2,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Rotating Kaaba & Needle
                    Transform.rotate(
                      angle: (qiblaBearing - compassDirection) * (math.pi / 180),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Direction Needle
                          Container(
                            width: 220,
                            height: 220,
                            child: CustomPaint(
                              painter: CompassNeedlePainter(
                                color: isAligned ? AppColors.emerald : AppColors.primary,
                              ),
                            ),
                          ),
                          
                          // Kaaba Icon at the Qibla position
                          Positioned(
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isAligned ? AppColors.emerald : AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Image.network(
                                'https://img.icons8.com/color/96/kaaba.png',
                                width: 40,
                                height: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Center Pin
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),
              
              // Alignment Status
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isAligned ? AppColors.emerald.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isAligned ? AppColors.emerald : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAligned ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                      color: isAligned ? AppColors.emerald : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isAligned 
                        ? (settings.isBangla ? 'কিবলা সঠিক আছে' : 'Aligned with Qibla')
                        : (settings.isBangla ? 'ফোনটি ঘুরিয়ে কিবলা খুঁজুন' : 'Rotate phone to find Qibla'),
                      style: TextStyle(
                        color: isAligned ? AppColors.emerald : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.grey[300]!,
      highlightColor: isDark ? Colors.white24 : Colors.grey[100]!,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 100,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          ),
          const SizedBox(height: 60),
          Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
          const SizedBox(height: 60),
          Container(
            width: 200,
            height: 44,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String title, String desc, IconData icon, VoidCallback onAction, String btnText) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(btnText),
            ),
          ],
        ),
      ),
    );
  }
}

class CompassNeedlePainter extends CustomPainter {
  final Color color;
  CompassNeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw a sharp needle pointing Up (towards Kaaba)
    path.moveTo(centerX, 0); // Top tip
    path.lineTo(centerX - 10, centerY); // Left middle
    path.lineTo(centerX, centerY + 20); // Bottom tip
    path.lineTo(centerX + 10, centerY); // Right middle
    path.close();

    canvas.drawPath(path, paint);
    
    // Draw shadow/depth
    final darkPaint = Paint()..color = Colors.black.withOpacity(0.1);
    final darkPath = Path();
    darkPath.moveTo(centerX, 0);
    darkPath.lineTo(centerX, centerY + 20);
    darkPath.lineTo(centerX + 10, centerY);
    darkPath.close();
    canvas.drawPath(darkPath, darkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

