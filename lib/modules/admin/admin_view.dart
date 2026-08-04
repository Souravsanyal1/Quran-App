import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../home/banner_controller.dart';
import '../../widgets/app_back_button.dart';
import '../settings/settings_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _AdminTheme {
  _AdminTheme._();
  static const Color emerald = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark = Color(0xFF0D3B1E);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C97A);
  static const Color goldSoft = Color(0xFFFFF8E7);
  static const Color darkSurface = Color(0xFF141420);
  static const Color darkCard = Color(0xFF1E1E2E);
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard = Color(0xFFFFFFFF);
}

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerController = Get.find<BannerController>();
    final settings = Get.find<SettingsController>();
    final isDark = settings.isDark;

    // Banner controllers
    final bannerTitleController = TextEditingController();
    final imgController = TextEditingController();
    final linkController = TextEditingController();

    // Ad controllers
    final adTitleController = TextEditingController();
    final adImgController = TextEditingController();
    final adLinkController = TextEditingController();

    // Static Top Banner controllers
    final staticTitleController = TextEditingController();
    final staticImgController = TextEditingController();
    final staticLinkController = TextEditingController();

    return Scaffold(
      backgroundColor:
          isDark ? _AdminTheme.darkSurface : _AdminTheme.lightSurface,
      appBar: AppBar(
        leading: const AppBackButton(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _AdminTheme.emeraldDark,
                _AdminTheme.emerald,
                _AdminTheme.emeraldLight
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border:
                Border(bottom: BorderSide(color: _AdminTheme.gold, width: 1.5)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                  opacity: 0.05,
                  child: CustomPaint(painter: _StarPatternPainter())),
            ],
          ),
        ),
        title: Text(
          'Admin Panel',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Section
            _buildSectionTitle('Add Slider Banner'),
            const SizedBox(height: 16),
            _buildTextField(bannerTitleController, 'Banner Title', isDark),
            const SizedBox(height: 12),
            _buildTextField(imgController, 'Image URL', isDark),
            const SizedBox(height: 12),
            _buildTextField(linkController, 'Target URL', isDark),
            const SizedBox(height: 16),
            _buildActionButton('Add Slider Banner', () {
              if (imgController.text.isNotEmpty &&
                  linkController.text.isNotEmpty) {
                bannerController.addBanner(
                    imgController.text,
                    linkController.text,
                    bannerTitleController.text.isNotEmpty
                        ? bannerTitleController.text
                        : 'New Banner');
                bannerTitleController.clear();
                imgController.clear();
                linkController.clear();
                Get.snackbar('Success', 'Banner added');
              }
            }),

            const SizedBox(height: 36),

            // Custom Ad Section
            _buildSectionTitle('Add Custom Ad Banner'),
            const SizedBox(height: 16),
            _buildTextField(adTitleController, 'Ad Title', isDark),
            const SizedBox(height: 12),
            _buildTextField(adImgController, 'Ad Image URL', isDark),
            const SizedBox(height: 12),
            _buildTextField(adLinkController, 'Ad Target URL', isDark),
            const SizedBox(height: 16),
            _buildActionButton('Publish Custom Ad', () {
              if (adImgController.text.isNotEmpty &&
                  adLinkController.text.isNotEmpty) {
                bannerController.addCustomAd(
                  adTitleController.text,
                  adImgController.text,
                  adLinkController.text,
                );
                adTitleController.clear();
                adImgController.clear();
                adLinkController.clear();
                Get.snackbar('Success', 'Ad published');
              }
            }),

            const SizedBox(height: 36),

            // Static Top Banner Section
            _buildSectionTitle('Add Static Top Banner (Header)'),
            const SizedBox(height: 16),
            _buildTextField(staticTitleController, 'Title', isDark),
            const SizedBox(height: 12),
            _buildTextField(staticImgController, 'Image URL', isDark),
            const SizedBox(height: 12),
            _buildTextField(staticLinkController, 'Target URL', isDark),
            const SizedBox(height: 16),
            _buildActionButton('Publish Top Banner', () {
              if (staticImgController.text.isNotEmpty) {
                bannerController.addStaticTopBanner(
                  staticImgController.text,
                  staticLinkController.text,
                  staticTitleController.text,
                );
                staticTitleController.clear();
                staticImgController.clear();
                staticLinkController.clear();
                Get.snackbar('Success', 'Top banner published');
              }
            }),

            const SizedBox(height: 36),
            _buildSectionTitle('Manage Active Banners'),
            const SizedBox(height: 16),
            Obx(() => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bannerController.banners.length,
                  separatorBuilder: (context, index) => Divider(
                      color: isDark ? Colors.white10 : Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final banner = bannerController.banners[index];
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? _AdminTheme.darkCard
                            : _AdminTheme.lightCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isDark
                                ? _AdminTheme.emerald.withValues(alpha: 0.15)
                                : _AdminTheme.emerald.withValues(alpha: 0.06)),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            banner.imageUrl,
                            width: 60,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(
                                Icons.broken_image,
                                color: _AdminTheme.emerald),
                          ),
                        ),
                        title: Text(
                          banner.linkUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () =>
                              bannerController.deleteBanner(banner.id),
                        ),
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: _AdminTheme.gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _AdminTheme.emerald),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Divider(color: _AdminTheme.gold, thickness: 0.5),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isDark) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: isDark
                  ? _AdminTheme.emerald.withValues(alpha: 0.15)
                  : _AdminTheme.emerald.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _AdminTheme.emerald, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _AdminTheme.emerald,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _AdminTheme.gold, width: 0.5),
          ),
          elevation: 0,
        ),
        child: Text(label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
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
