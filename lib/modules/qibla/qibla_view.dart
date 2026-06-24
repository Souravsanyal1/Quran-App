import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import '../../widgets/app_back_button.dart';
import 'qibla_controller.dart';

class QiblaView extends GetView<QiblaController> {
  const QiblaView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(settings.isBangla ? 'কিবলা কম্পাস' : 'Qibla Finder'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (!controller.hasPermission.value) {
          return _buildPermissionRequest(settings);
        }

        return StreamBuilder<QiblahDirection>(
          stream: FlutterQiblah.qiblahStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  settings.isBangla
                      ? 'ত্রুটি: কিবলা সেন্সর পাওয়া যায়নি।'
                      : 'Error: Qibla sensor not found on this device.',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            final qiblahDirection = snapshot.data;
            if (qiblahDirection == null) {
              return Center(
                child: Text(
                  settings.isBangla
                      ? 'কম্পাস লোড করা যাচ্ছে না।'
                      : 'Unable to read compass data.',
                  style: const TextStyle(color: AppColors.textGrey),
                ),
              );
            }

            // offset represents the angle difference between device heading and Kaaba direction
            // direction represents device heading relative to North
            final direction = qiblahDirection.direction;
            final offset = qiblahDirection.offset;
            final isAligned = offset.abs() < 5; // aligned within 5 degrees

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      settings.isBangla ? 'ডিভাইসটি সোজা সমান্তরালে রাখুন' : 'Keep your device flat',
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                    ),
                    const SizedBox(height: 32),
                    
                    // The Compass Visual Stack
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect when aligned
                          if (isAligned)
                            Container(
                              width: 260,
                              height: 260,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.emerald.withValues(alpha: 0.08),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.emerald.withValues(alpha: 0.2),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                            
                          // Outer Compass Dial (rotates with device direction)
                          Transform.rotate(
                            angle: -(direction * (math.pi / 180)),
                            child: _buildCompassDial(settings),
                          ),
                          
                          // Qibla Pointer/Needle (pointing to Kaaba, rotates relative to device)
                          Transform.rotate(
                            angle: -(offset * (math.pi / 180)),
                            child: _buildCompassNeedle(isAligned),
                          ),

                          // Kaaba Icon in the center
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isAligned ? AppColors.emerald : AppColors.cardDark,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 2),
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: isAligned ? Colors.white : AppColors.primary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Aligned status message
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: isAligned
                            ? AppColors.emerald.withValues(alpha: 0.1)
                            : (settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAligned ? AppColors.emerald : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAligned ? Icons.check_circle : Icons.compass_calibration,
                            color: isAligned ? AppColors.emerald : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAligned
                                ? (settings.isBangla ? 'কিবলা সঠিক দিকে আলকাআবা' : 'Qibla Aligned!')
                                : '${offset.round().abs()}° ${settings.isBangla ? "অফসেট" : "offset"}',
                            style: TextStyle(
                              color: isAligned ? AppColors.emerald : AppColors.textGrey,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildPermissionRequest(SettingsController settings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_outlined, size: 80, color: AppColors.error),
            const SizedBox(height: 24),
            Text(
              settings.isBangla ? 'লোকেশন অ্যাক্সেস প্রয়োজন' : 'Location Permission Required',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              settings.isBangla
                  ? 'আপনার সঠিক কিবলা দিক নির্ধারণ করতে লোকেশন পারমিশন চালু করুন।'
                  : 'We need location permission to calculate the precise Qibla direction for your current position.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => controller.requestPermission(),
              child: Text(settings.isBangla ? 'পারমিশন দিন' : 'Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassDial(SettingsController settings) {
    final isDark = settings.isDark;
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cardinal points
          Positioned(
            top: 10,
            child: Text(
              'N',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Text(
              'S',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            left: 10,
            child: Text(
              'W',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            right: 10,
            child: Text(
              'E',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          
          // Little ticks on the compass
          ...List.generate(12, (index) {
            final angle = (index * 30) * (math.pi / 180);
            return Transform.rotate(
              angle: angle,
              child: const Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: 12,
                  child: VerticalDivider(
                    color: Colors.white24,
                    thickness: 1.5,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompassNeedle(bool isAligned) {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: CompassNeedlePainter(isAligned),
      ),
    );
  }
}

class CompassNeedlePainter extends CustomPainter {
  final bool isAligned;

  CompassNeedlePainter(this.isAligned);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isAligned ? AppColors.emerald : AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw the pointer arrow towards top
    path.moveTo(centerX, 20); // Tip
    path.lineTo(centerX - 12, centerY - 10);
    path.lineTo(centerX, centerY - 5);
    path.lineTo(centerX + 12, centerY - 10);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
