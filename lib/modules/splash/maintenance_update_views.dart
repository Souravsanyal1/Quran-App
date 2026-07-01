import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../settings/settings_controller.dart';

class MaintenanceView extends StatelessWidget {
  const MaintenanceView({super.key});

  Future<void> _launchSupport() async {
    final Uri url = Uri.parse('https://wa.me/8801307460389'); 
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Scaffold(
      backgroundColor: const Color(0xFF141420),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D3B1E), Color(0xFF141420)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Lottie.network(
                  'https://assets9.lottiefiles.com/packages/lf20_m6cu96ze.json',
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.build_circle_rounded,
                    size: 100,
                    color: Color(0xFFC9A84C),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Under Maintenance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'We are upgrading our servers to give you a better experience. We will be back online shortly!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Obx(() {
                final endTime = settings.maintenanceEndTime.value;
                
                if (endTime == null) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A84C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded, color: Color(0xFFC9A84C), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Expected back soon',
                          style: TextStyle(
                            color: Color(0xFFC9A84C), 
                            fontWeight: FontWeight.bold, 
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Use a StreamBuilder for local ticking to ensure UI updates every second
                return StreamBuilder<DateTime>(
                  stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                  initialData: DateTime.now(),
                  builder: (context, snapshot) {
                    final now = snapshot.data ?? DateTime.now();
                    final remaining = endTime.difference(now);
                    
                    if (remaining.inSeconds <= 0) {
                      return Column(
                        children: [
                          const Text(
                            'Reconnecting...',
                            style: TextStyle(
                              color: Colors.greenAccent, 
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent.withOpacity(0.5)),
                            ),
                          ),
                        ],
                      );
                    }

                    String timeText;
                    if (remaining.inHours > 0) {
                      timeText = '${remaining.inHours}h ${remaining.inMinutes % 60}m ${remaining.inSeconds % 60}s';
                    } else if (remaining.inMinutes > 0) {
                      timeText = '${remaining.inMinutes}m ${remaining.inSeconds % 60}s';
                    } else {
                      timeText = '${remaining.inSeconds}s';
                    }

                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.orangeAccent.withOpacity(0.3), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orangeAccent.withOpacity(0.05),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, color: Colors.orangeAccent, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                timeText,
                                style: const TextStyle(
                                  color: Colors.orangeAccent, 
                                  fontWeight: FontWeight.w900, 
                                  fontSize: 18,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Expected completion: ${DateFormat('hh:mm:ss a').format(endTime)}',
                          style: const TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    );
                  },
                );
              }),
              const SizedBox(height: 40),
              TextButton.icon(
                onPressed: _launchSupport,
                icon: const Icon(Icons.support_agent_rounded, color: Colors.white70),
                label: const Text(
                  'Contact Support',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForceUpdateView extends StatelessWidget {
  const ForceUpdateView({super.key});

  Future<void> _launchSupport() async {
    final Uri url = Uri.parse('https://wa.me/8801307460389');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141420),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D3B1E), Color(0xFF141420)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Lottie.network(
                'https://assets2.lottiefiles.com/packages/lf20_y9m8vtbc.json',
                height: 240,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.system_update_rounded,
                  size: 100,
                  color: Color(0xFFC9A84C),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'New Version Available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please update your app to the latest version to enjoy new features and improved stability.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.nexora.quran_app'));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A84C),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Update Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _launchSupport,
                icon: const Icon(Icons.help_outline_rounded, color: Colors.white38, size: 20),
                label: const Text(
                  'Need help? Contact Support',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
