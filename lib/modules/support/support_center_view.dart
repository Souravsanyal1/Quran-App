import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/support_chat_model.dart';
import '../../widgets/app_back_button.dart';
import '../settings/settings_controller.dart';
import 'support_controller.dart';
import 'support_view.dart';
import 'support_form_view.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _SupportTheme {
  _SupportTheme._();
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

class SupportCenterView extends GetView<SupportController> {
  const SupportCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final isBn = settings.isBangla;
    final isDark = settings.isDark;

    return Obx(() {
      final title = isBn ? 'সাপোর্ট সেন্টার' : 'Live Support';

      // 1. Loading State
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor:
              isDark ? _SupportTheme.darkSurface : _SupportTheme.lightSurface,
          appBar: AppBar(
            elevation: 0,
            leading: const AppBackButton(color: Colors.white),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _SupportTheme.emeraldDark,
                    _SupportTheme.emerald,
                    _SupportTheme.emeraldLight
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(
                    bottom: BorderSide(color: _SupportTheme.gold, width: 1.5)),
              ),
            ),
            title: Text(title,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            centerTitle: true,
          ),
          body: const Center(
              child: CircularProgressIndicator(color: _SupportTheme.emerald)),
        );
      }

      // 2. Chat View (If an active chat exists)
      if (controller.activeTicket.value != null) {
        return const SupportChatView();
      }

      // 3. Welcome/Onboarding View (If no active ticket)
      return Scaffold(
        backgroundColor:
            isDark ? _SupportTheme.darkSurface : _SupportTheme.lightSurface,
        appBar: AppBar(
          elevation: 0,
          leading: const AppBackButton(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _SupportTheme.emeraldDark,
                  _SupportTheme.emerald,
                  _SupportTheme.emeraldLight
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                  bottom: BorderSide(color: _SupportTheme.gold, width: 1.5)),
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
          title: Text(title,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                _buildModernHeader(isBn, isDark),
                const SizedBox(height: 48),
                _buildActionButtons(isBn, isDark),
                if (controller.myTickets.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildHistoryButton(isBn, isDark),
                ],
                const SizedBox(height: 60),
                _buildContactInfo(isBn, isDark),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildModernHeader(bool isBn, bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _SupportTheme.emerald.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: const Duration(seconds: 2)),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_SupportTheme.emerald, _SupportTheme.emeraldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.forum_rounded,
                  size: 48, color: _SupportTheme.goldLight),
            ),
          ],
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 32),
        Text(
          isBn ? 'আপনার ব্যক্তিগত সহকারী' : 'Your Personal Assistant',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textDark),
        ),
        const SizedBox(height: 12),
        Text(
          isBn
              ? 'আমাদের বিশেষজ্ঞ দল আপনার দ্বীনি এবং অ্যাপ সংক্রান্ত যে কোনো সমস্যায় সাহায্য করতে প্রস্তুত।'
              : 'Our expert team is ready to help you with any Deen or App related issues in real-time.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: isDark
                  ? Colors.white70
                  : AppColors.textDark.withValues(alpha: 0.7),
              height: 1.5,
              fontSize: 14),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildActionButtons(bool isBn, bool isDark) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _SupportTheme.emerald.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Obx(() => ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : controller.startInstantChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _SupportTheme.emerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: _SupportTheme.gold, width: 1),
                  ),
                  elevation: 0,
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_rounded),
                          const SizedBox(width: 12),
                          Text(
                            isBn
                                ? 'সরাসরি চ্যাট শুরু করুন'
                                : 'Start Live Chat Now',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
              )),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () => Get.to(() => const SupportFormView()),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              isBn
                  ? 'বিস্তারিত সমস্যা জানাতে টিকেট ওপেন করুন'
                  : 'or open a ticket for detailed issues',
              style: GoogleFonts.poppins(
                color: _SupportTheme.gold,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: _SupportTheme.gold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryButton(bool isBn, bool isDark) {
    return InkWell(
      onTap: () => _showTicketHistory(Get.context!),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? _SupportTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: _SupportTheme.emerald.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded,
                size: 20, color: _SupportTheme.emerald.withValues(alpha: 0.8)),
            const SizedBox(width: 8),
            Text(
              isBn ? 'পূর্ববর্তী কথোপকথন' : 'Previous Conversations',
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white70 : AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _SupportTheme.emerald.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                controller.myTickets.length.toString(),
                style: const TextStyle(
                    color: _SupportTheme.emerald,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketHistory(BuildContext context) {
    final isBn = Get.find<SettingsController>().isBangla;
    final isDark = Get.find<SettingsController>().isDark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isDark ? _SupportTheme.darkCard : _SupportTheme.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
              top: BorderSide(
                  color: _SupportTheme.emerald.withValues(alpha: 0.2))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBn ? 'আপনার টিকেটসমূহ' : 'Your Tickets',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textDark),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded,
                        color: _SupportTheme.emerald),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.myTickets.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final ticket = controller.myTickets[index];
                      return Card(
                        color: isDark
                            ? _SupportTheme.darkSurface
                            : _SupportTheme.goldSoft.withValues(alpha: 0.3),
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              color:
                                  _SupportTheme.emerald.withValues(alpha: 0.1)),
                        ),
                        child: ListTile(
                          onTap: () {
                            Get.back();
                            controller.openTicketChat(ticket);
                          },
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getStatusColor(ticket.status)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.chat_outlined,
                                color: _getStatusColor(ticket.status),
                                size: 20),
                          ),
                          title: Text(ticket.subject,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textDark)),
                          subtitle: Text(
                            '${ticket.status.name.capitalizeFirst} • ${DateFormat('MMM dd, yyyy').format(ticket.createdAt)}',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppColors.textGrey),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 14, color: _SupportTheme.emerald),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return Colors.green;
      case TicketStatus.pending:
        return _SupportTheme.gold;
      case TicketStatus.resolved:
        return _SupportTheme.emerald;
      case TicketStatus.closed:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildContactInfo(bool isBn, bool isDark) {
    return Column(
      children: [
        Text(
          isBn ? 'অথবা সরাসরি যোগাযোগ করুন' : 'Or Contact Us Directly',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textGrey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildContactCard(
              icon: Icons.chat_bubble_rounded,
              color: const Color(0xFF25D366),
              label: 'WhatsApp',
              onTap: controller.launchWhatsApp,
              isDark: isDark,
            ),
            const SizedBox(width: 20),
            _buildContactCard(
              icon: Icons.facebook_rounded,
              color: const Color(0xFF1877F2),
              label: 'Facebook',
              onTap: controller.launchFacebook,
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          '+8801340989509',
          style: TextStyle(
            color: isDark ? Colors.white24 : AppColors.textGrey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(
      {required IconData icon,
      required Color color,
      required String label,
      required VoidCallback onTap,
      required bool isDark}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? _SupportTheme.darkCard : _SupportTheme.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                  color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
