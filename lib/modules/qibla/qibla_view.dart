import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      backgroundColor: settings.isDark ? AppColors.bgDark : const Color(0xFFF9F5F0),
      appBar: AppBar(
        leading: const AppBackButton(color: Colors.white),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          settings.isBangla ? 'কিবলা কম্পাস' : 'Qibla Compass',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLinearLoader(settings.isBangla);
        }

        if (!controller.hasPermission.value) {
          return _buildPermissionRequest(settings);
        }

        return StreamBuilder<QiblahDirection>(
          stream: FlutterQiblah.qiblahStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLinearLoader(settings.isBangla);
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  settings.isBangla
                      ? 'ত্রুটি: কিবলা সেন্সর পাওয়া যায়নি।'
                      : 'Error: Compass sensor not found.',
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            final qiblahDirection = snapshot.data;
            if (qiblahDirection == null) return const SizedBox();

            // 1. Heading from North (0-359)
            final double deviceHeading = (qiblahDirection.direction % 360 + 360) % 360;
            
            // 2. Qibla Bearing (We use our manual calculation for guaranteed accuracy)
            final double qiblaAngle = controller.manualQiblaBearing.value > 0 
                ? controller.manualQiblaBearing.value 
                : (qiblahDirection.qiblah % 360 + 360) % 360;
            
            // 3. Offset calculation (Relative angle to Mecca)
            double offset = qiblaAngle - deviceHeading;
            if (offset > 180) offset -= 360;
            if (offset < -180) offset += 360;

            final bool isAligned = offset.abs() < 4;

            // Trigger vibration feedback
            controller.handleAlignmentVibration(isAligned);

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.7,
                  colors: [
                    (isAligned ? AppColors.emerald : AppColors.primary).withValues(alpha: settings.isDark ? 0.05 : 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    // Kaaba Info
                    _buildGlassCard(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Obx(() => Text(
                            '${settings.isBangla ? "কাবা থেকে দূরত্ব" : "Distance"}: ${controller.distanceToKaaba.value.toStringAsFixed(0)} km',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                        ],
                      ),
                      settings: settings,
                    ).animate().fadeIn().slideY(begin: -0.2),

                    const SizedBox(height: 40),
                    
                    // Top Static Target Indicator
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: isAligned ? AppColors.emerald : AppColors.primary,
                      size: 64,
                    ).animate(target: isAligned ? 1 : 0).tint(color: AppColors.emerald),

                    // Main Compass Visual
                    Center(
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isAligned ? AppColors.emerald : AppColors.primary).withValues(alpha: 0.1),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 1. Dial: Smoothly counter-rotates so N is always North
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(end: (deviceHeading * (math.pi / 180) * -1)),
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutQuad,
                              builder: (context, angle, child) {
                                return Transform.rotate(
                                  angle: angle,
                                  child: _buildCompassDial(settings),
                                );
                              },
                            ),

                            // 2. Kaaba Icon: Stays at the correct absolute bearing relative to dial North
                            // but since dial North is fixed to world North, this points to Mecca on Earth.
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(end: (offset * (math.pi / 180))),
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutQuad,
                              builder: (context, angle, child) {
                                return Transform.rotate(
                                  angle: angle,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                      ),
                                      child: const Icon(Icons.mosque, color: Colors.black, size: 24),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // 3. Needle: Rotates relative to phone top to find Mecca
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(end: (offset * (math.pi / 180))),
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutQuad,
                              builder: (context, angle, child) {
                                return Transform.rotate(
                                  angle: angle,
                                  child: _buildCompassNeedle(isAligned),
                                );
                              },
                            ),

                            // 3. Center Pivot
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isAligned ? AppColors.emerald : AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Degrees and Direction Name
                    Column(
                      children: [
                        Text(
                          '${qiblaAngle.round()}°',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: settings.isDark ? Colors.white : AppColors.textDark,
                            letterSpacing: -2,
                          ),
                        ),
                        Text(
                          _getCardinalDirection(qiblaAngle, settings.isBangla),
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ).animate(target: isAligned ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),

                    const SizedBox(height: 32),

                    // Accuracy Indicator
                    _buildAccuracyCard(settings),

                    const SizedBox(height: 40),

                    // Guidance Banner
                    _buildInstructionBanner(offset, settings, isAligned),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildGlassCard({required Widget child, required SettingsController settings}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: settings.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: settings.isDark ? 0.1 : 0.5)),
      ),
      child: child,
    );
  }

  Widget _buildCompassDial(SettingsController settings) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildDirectionLabel('N', 0),
          _buildDirectionLabel('E', 90),
          _buildDirectionLabel('S', 180),
          _buildDirectionLabel('W', 270),

          // Scale Ticks
          ...List.generate(36, (index) {
            final angle = (index * 10) * (math.pi / 180);
            return Transform.rotate(
              angle: angle,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: index % 9 == 0 ? 15 : 8,
                  width: index % 9 == 0 ? 2 : 1,
                  color: AppColors.textGrey.withValues(alpha: 0.5),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDirectionLabel(String label, double angleDegrees) {
    final settings = Get.find<SettingsController>();
    return Transform.rotate(
      angle: angleDegrees * (math.pi / 180),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Text(
            label,
            style: TextStyle(
              color: settings.isDark ? Colors.white70 : AppColors.textDark,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompassNeedle(bool isAligned) {
    return CustomPaint(
      size: const Size(220, 220),
      painter: QiblaNeedlePainter(isAligned),
    );
  }

  Widget _buildAccuracyCard(SettingsController settings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: settings.isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
        boxShadow: [
          if (!settings.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                settings.isBangla ? 'নির্ভুলতা:' : 'Accuracy:',
                style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: AppColors.emerald, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      settings.isBangla ? 'উচ্চ' : 'High',
                      style: const TextStyle(
                        color: AppColors.emerald,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.5),
          ),
          Text(
            settings.isBangla 
              ? 'নির্ভুলতার জন্য ফোনটিকে সমান্তরাল রাখুন এবং "8" শেপে ঘুরিয়ে ক্যালিব্রেট করুন।' 
              : 'Keep phone flat and calibrate by moving it in an "8" shape for best accuracy.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textGrey, height: 1.4),
          ),
        ],
      ),
    );
  }

  String _getCardinalDirection(double angle, bool isBn) {
    if (angle >= 337.5 || angle < 22.5) return isBn ? 'উত্তর' : 'NORTH';
    if (angle >= 22.5 && angle < 67.5) return isBn ? 'উত্তর-পূর্ব' : 'NORTH-EAST';
    if (angle >= 67.5 && angle < 112.5) return isBn ? 'পূর্ব' : 'EAST';
    if (angle >= 112.5 && angle < 157.5) return isBn ? 'দক্ষিণ-পূর্ব' : 'SOUTH-EAST';
    if (angle >= 157.5 && angle < 202.5) return isBn ? 'দক্ষিণ' : 'SOUTH';
    if (angle >= 202.5 && angle < 247.5) return isBn ? 'দক্ষিণ-পশ্চিম' : 'SOUTH-WEST';
    if (angle >= 247.5 && angle < 292.5) return isBn ? 'পশ্চিম' : 'WEST';
    return isBn ? 'উত্তর-পশ্চিম' : 'NORTH-WEST';
  }

  Widget _buildInstructionBanner(double offset, SettingsController settings, bool isAligned) {
    if (isAligned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.emerald.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.emerald, size: 22),
            const SizedBox(width: 10),
            Text(
              settings.isBangla ? 'আপনি কিবলার সঠিক দিকে আছেন' : "ALIGNED WITH QIBLA",
              style: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      );
    }

    int angle = offset.round();
    if (angle > 180) angle -= 360;
    if (angle < -180) angle += 360;
    String dir = angle > 0 ? (settings.isBangla ? 'ডানে' : 'RIGHT') : (settings.isBangla ? 'বামে' : 'LEFT');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        settings.isBangla ? 'ফোনটি ${angle.abs()}° $dir ঘুরান' : 'ROTATE ${angle.abs()}° $dir',
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15),
      ),
    );
  }

  Widget _buildLinearLoader(bool bn) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore_rounded, size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(bn ? 'কম্পাস লোড হচ্ছে...' : 'Loading Compass...', style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 60),
            child: LinearProgressIndicator(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequest(SettingsController settings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              controller.isLocationEnabled.value ? Icons.location_off_rounded : Icons.gps_off_rounded,
              size: 100,
              color: AppColors.error,
            ),
            const SizedBox(height: 32),
            Text(
              !controller.isLocationEnabled.value
                  ? (settings.isBangla ? 'জিপিএস (GPS) বন্ধ আছে' : 'GPS is Disabled')
                  : (settings.isBangla ? 'লোকেশন প্রয়োজন' : 'Location Required'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 16),
            Text(
              !controller.isLocationEnabled.value
                  ? (settings.isBangla
                      ? 'আপনার ফোনের লোকেশন বা জিপিএস সার্ভিসটি চালু করুন।'
                      : 'Please turn on your device location services (GPS).')
                  : (settings.isBangla
                      ? 'সঠিক কিবলা দিক পেতে আপনার লোকেশন পারমিশন প্রয়োজন।'
                      : 'Precise Qibla requires location access.'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => controller.requestPermission(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  !controller.isLocationEnabled.value
                      ? (settings.isBangla ? 'সেটিিংস ওপেন করুন' : 'OPEN SETTINGS')
                      : (settings.isBangla ? 'অনুমতি দিন' : 'GRANT ACCESS'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QiblaNeedlePainter extends CustomPainter {
  final bool isAligned;
  QiblaNeedlePainter(this.isAligned);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isAligned ? AppColors.emerald : AppColors.primary
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    path.moveTo(centerX, 20); // Tip
    path.lineTo(centerX - 10, centerY);
    path.lineTo(centerX, centerY - 4);
    path.lineTo(centerX + 10, centerY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
