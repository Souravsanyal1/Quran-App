import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/audio_player_service.dart';
import '../../settings/settings_controller.dart';
import 'package:just_audio/just_audio.dart';

class NowPlayingView extends StatelessWidget {
  const NowPlayingView({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = Get.find<AudioPlayerService>();
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.isDark;
      final isPlaying = audioService.isPlaying.value;
      final isBuffering = audioService.isPlayerLoading.value;

      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF141420) : const Color(0xFFF8F4EF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: isDark ? Colors.white : Colors.black87, size: 32),
            onPressed: () => Get.back(),
          ),
          title: Text(
            settings.isBangla ? 'এখন বাজছে' : 'Now Playing',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon / Image
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B5E35).withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/icons/icon_android.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Info
              Text(
                settings.isBangla
                    ? 'পবিত্র কুরআন তেলাওয়াত'
                    : 'Holy Quran Recitation',
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                audioService.player.audioSource?.sequence.first.tag.album ?? '',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFC9A84C),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // Progress Bar (Simple representation since just_audio needs more setup for full seek bar)
              StreamBuilder<Duration?>(
                stream: audioService.player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration =
                      audioService.player.duration ?? Duration.zero;
                  return Column(
                    children: [
                      Slider(
                        value: position.inMilliseconds
                            .toDouble()
                            .clamp(0, duration.inMilliseconds.toDouble()),
                        max: duration.inMilliseconds.toDouble() > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1.0,
                        onChanged: (value) {
                          audioService.player
                              .seek(Duration(milliseconds: value.toInt()));
                        },
                        activeColor: const Color(0xFF1B5E35),
                        inactiveColor:
                            const Color(0xFF1B5E35).withValues(alpha: 0.2),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text(_formatDuration(duration),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded,
                        size: 48, color: Color(0xFF1B5E35)),
                    onPressed: () => audioService.player.seekToPrevious(),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () => audioService.togglePlayback(),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B5E35), Color(0xFF2E7D52)],
                        ),
                      ),
                      child: isBuffering
                          ? const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3),
                            )
                          : Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 50,
                              color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded,
                        size: 48, color: Color(0xFF1B5E35)),
                    onPressed: () => audioService.player.seekToNext(),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
