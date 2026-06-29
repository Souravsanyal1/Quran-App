import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_urls.dart';
import 'package:quran_app/widgets/shimmer_loading.dart';
import '../../widgets/app_back_button.dart';
import 'settings_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _SettingsTheme {
  _SettingsTheme._();
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

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final isDark = settings.isDark;
      final scaffoldBg = isDark ? _SettingsTheme.darkSurface : _SettingsTheme.lightSurface;

      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            leading: const AppBackButton(color: Colors.white),
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_SettingsTheme.emeraldDark, _SettingsTheme.emerald, _SettingsTheme.emeraldLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(bottom: BorderSide(color: _SettingsTheme.gold, width: 1.5)),
              ),
            ),
            title: Text(
              controller.isBangla ? 'সেটিংস' : 'Settings',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ShimmerLoading.rounded(height: 100, borderRadius: 20),
                const SizedBox(height: 24),
                ShimmerList(itemCount: 5, height: 60, padding: EdgeInsets.zero),
              ],
            ),
          ),
        );
      }

      final bn = controller.isBangla;

      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          leading: const AppBackButton(color: Colors.white),
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_SettingsTheme.emeraldDark, _SettingsTheme.emerald, _SettingsTheme.emeraldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(bottom: BorderSide(color: _SettingsTheme.gold, width: 1.5)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPatternPainter())),
              ],
            ),
          ),
          title: Text(
            bn ? 'সেটিংস' : 'Settings',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
          children: [
            // ── General ────────────────────────────────────────────
            _SectionHeader(title: bn ? 'সাধারণ' : 'General'),

            _SettingsCard(
              isDark: isDark,
              children: [
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.language_rounded,
                  title: bn ? 'ভাষা' : 'Language',
                  subtitle: controller.language.value == 'bn' ? 'বাংলা' : 'English',
                  trailing: _StyledSwitch(
                    value: controller.isBangla,
                    onChanged: (val) => controller.setLanguage(val ? 'bn' : 'en'),
                  ),
                ),
              ],
            ),

            // ── Appearance ─────────────────────────────────────────
            _SectionHeader(title: bn ? 'থিম' : 'Appearance'),

            _SettingsCard(
              isDark: isDark,
              children: [
                _SettingsTile(
                  isDark: isDark,
                  icon: controller.isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title: bn ? 'ডার্ক মোড' : 'Dark Mode',
                  trailing: _StyledSwitch(
                    value: controller.isDark,
                    onChanged: (_) => controller.toggleTheme(),
                  ),
                ),
              ],
            ),

            // ── Quran ──────────────────────────────────────────────
            _SectionHeader(title: bn ? 'কুরআন' : 'Quran'),

            _SettingsCard(
              isDark: isDark,
              children: [
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.format_size_rounded,
                  title: bn ? 'আরবি ফন্ট সাইজ' : 'Arabic Font Size',
                  subtitle: controller.arabicFontSize.value.toStringAsFixed(0),
                ),
                _FontSizeSlider(
                  isDark: isDark,
                  bn: bn,
                  controller: controller,
                ),
              ],
            ),

            // ── Audio ──────────────────────────────────────────────
            _SectionHeader(title: bn ? 'অডিও' : 'Audio'),

            _SettingsCard(
              isDark: isDark,
              children: [
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.record_voice_over_rounded,
                  title: bn ? 'কারী নির্বাচন করুন' : 'Select Qari',
                  subtitle: AppUrls.qariList.firstWhere(
                        (q) => q['id'] == controller.selectedQari.value,
                    orElse: () => {'name': 'Unknown'},
                  )['name']!,
                  onTap: () => _showQariSheet(context, controller, bn),
                ),
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.play_circle_fill_rounded,
                  title: bn ? 'ব্যাকগ্রাউন্ডে অডিও' : 'Background Audio',
                  subtitle: bn
                      ? 'স্ক্রিন লক থাকলেও চলবে'
                      : 'Play while screen is locked',
                  trailing: _StyledSwitch(
                    value: controller.backgroundPlayEnabled.value,
                    onChanged: controller.setBackgroundPlay,
                  ),
                ),
              ],
            ),

            // ── Notifications ──────────────────────────────────────
            _SectionHeader(title: bn ? 'নোটিফিকেশন' : 'Notifications'),

            _SettingsCard(
              isDark: isDark,
              children: [
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.notifications_active_rounded,
                  title: bn ? 'নোটিফিকেশন' : 'Notifications',
                  trailing: _StyledSwitch(
                    value: controller.notificationsEnabled.value,
                    onChanged: controller.setNotificationsEnabled,
                  ),
                ),
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.notifications_rounded,
                  title: bn ? 'আযান নোটিফিকেশন' : 'Azan Notification',
                  trailing: _StyledSwitch(
                    value: controller.azanEnabled.value,
                    onChanged: controller.setAzanEnabled,
                  ),
                ),
              ],
            ),

            // ── Daily Dua ──────────────────────────────────────────
            _SectionHeader(title: bn ? 'দৈনিক দোয়া' : 'Daily Dua'),

            _SettingsCard(
              isDark: isDark,
              children: [
                _SettingsTile(
                  isDark: isDark,
                  icon: Icons.auto_awesome_rounded,
                  title: bn ? 'দৈনিক দোয়ার রিমাইন্ডার' : 'Daily Dua Reminder',
                  subtitle: bn
                      ? 'প্রতিদিন নির্দিষ্ট সময়ে নোটিফিকেশন'
                      : 'Get a daily dua notification',
                  trailing: _StyledSwitch(
                    value: controller.duaReminderEnabled.value,
                    onChanged: controller.setDuaReminderEnabled,
                  ),
                ),
                if (controller.duaReminderEnabled.value)
                  _SettingsTile(
                    isDark: isDark,
                    icon: Icons.schedule_rounded,
                    title: bn ? 'রিমাইন্ডারের সময়' : 'Reminder Time',
                    subtitle: () {
                      final tod = TimeOfDay(
                        hour: controller.duaReminderHour.value,
                        minute: controller.duaReminderMinute.value,
                      );
                      return tod.format(context);
                    }(),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: controller.duaReminderHour.value,
                          minute: controller.duaReminderMinute.value,
                        ),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                              primary: _SettingsTheme.emerald,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        if (!context.mounted) return;
                        final formattedTime = picked.format(context);
                        await controller.setDuaReminderTime(picked);
                        Get.snackbar(
                          bn ? 'রিমাইন্ডার সেট' : 'Reminder Set',
                          bn
                              ? 'প্রতিদিন $formattedTime-এ দোয়ার নোটিফিকেশন আসবে'
                              : 'Daily dua reminder set for $formattedTime',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: _SettingsTheme.emerald.withOpacity(0.92),
                          colorText: Colors.white,
                          borderRadius: 16,
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          duration: const Duration(seconds: 3),
                        );
                      }
                    },
                  ),
              ],
            ),

            const SizedBox(height: 32),
            Text(
              'Quran App v1.0.0\nMade with ❤️ for the Ummah',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.textMuted,
                fontSize: 11,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }

  void _showQariSheet(BuildContext context, SettingsController controller, bool bn) {
    Get.bottomSheet(
      _QariBottomSheet(controller: controller, bn: bn),
      isScrollControlled: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Font Size Slider + Preview
// ─────────────────────────────────────────────────────────────────────────────

class _FontSizeSlider extends StatelessWidget {
  final bool isDark;
  final bool bn;
  final SettingsController controller;
  const _FontSizeSlider({
    required this.isDark,
    required this.bn,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: _SettingsTheme.emerald,
              inactiveTrackColor:
              isDark ? Colors.white10 : Colors.grey.shade200,
              thumbColor: _SettingsTheme.gold,
              overlayColor: _SettingsTheme.emerald.withOpacity(0.12),
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            child: Slider(
              value: controller.arabicFontSize.value,
              min: 16,
              max: 40,
              divisions: 12,
              onChanged: controller.setArabicFontSize,
            ),
          ),
        ),
        // Preview
        Container(
          margin: const EdgeInsets.fromLTRB(14, 2, 14, 18),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: isDark
                ? _SettingsTheme.darkSurface
                : _SettingsTheme.goldSoft.withOpacity(0.3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _SettingsTheme.emerald.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                bn ? 'ফন্ট প্রিভিউ' : 'Font size preview',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _SettingsTheme.emerald,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Uthmanic',
                  fontSize: controller.arabicFontSize.value,
                  color: isDark ? _SettingsTheme.goldLight : _SettingsTheme.emerald,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 20, 2, 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 13,
            decoration: BoxDecoration(
              color: _SettingsTheme.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _SettingsTheme.emerald,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings Card
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? _SettingsTheme.darkCard : _SettingsTheme.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? _SettingsTheme.emerald.withOpacity(0.15)
              : _SettingsTheme.emerald.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _SettingsTheme.emerald.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings Tile
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isDark;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: _SettingsTheme.emerald.withOpacity(0.06),
        highlightColor: _SettingsTheme.emerald.withOpacity(0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.03)
                    : Colors.grey.shade100,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _SettingsTheme.emerald.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: _SettingsTheme.emerald.withOpacity(0.18),
                    width: 0.5,
                  ),
                ),
                child: Icon(icon, color: _SettingsTheme.emerald, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white : AppColors.textDark,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.poppins(
                          color: AppColors.textGrey,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  (onTap != null
                      ? const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: _SettingsTheme.emerald,
                    size: 13,
                  )
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Styled Switch (replaces Switch.adaptive with consistent look)
// ─────────────────────────────────────────────────────────────────────────────

class _StyledSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _StyledSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: _SettingsTheme.emerald,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey.withOpacity(0.25),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Qari Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _QariBottomSheet extends StatelessWidget {
  final SettingsController controller;
  final bool bn;
  const _QariBottomSheet({required this.controller, required this.bn});

  @override
  Widget build(BuildContext context) {
    final isDark = controller.isDark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? _SettingsTheme.darkCard : _SettingsTheme.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark
              ? _SettingsTheme.emerald.withOpacity(0.15)
              : _SettingsTheme.emerald.withOpacity(0.06),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            bn ? 'কারী নির্বাচন করুন' : 'Select Qari',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: AppUrls.qariList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final qari = AppUrls.qariList[i];
                final isSelected = controller.selectedQari.value == qari['id'];
                return GestureDetector(
                  onTap: () {
                    controller.setQari(qari['id']!);
                    Get.back();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _SettingsTheme.emerald.withOpacity(0.09)
                          : (isDark ? _SettingsTheme.darkSurface : Colors.grey.shade50),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? _SettingsTheme.gold
                            : (isDark
                            ? _SettingsTheme.emerald.withOpacity(0.15)
                            : _SettingsTheme.emerald.withOpacity(0.06)),
                        width: isSelected ? 1 : 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _SettingsTheme.emerald.withOpacity(0.15)
                                : (isDark
                                ? _SettingsTheme.darkCard
                                : Colors.white),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.record_voice_over_rounded,
                            color: isSelected
                                ? _SettingsTheme.emerald
                                : AppColors.textGrey,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            qari['name']!,
                            style: GoogleFonts.poppins(
                              color: isSelected
                                  ? _SettingsTheme.emerald
                                  : (isDark
                                  ? Colors.white
                                  : AppColors.textDark),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: _SettingsTheme.gold,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              },
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
