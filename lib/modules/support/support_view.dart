import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/support_chat_model.dart';
import '../settings/settings_controller.dart';
import '../auth/auth_controller.dart';
import 'support_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _ChatTheme {
  _ChatTheme._();
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

class SupportChatView extends GetView<SupportController> {
  const SupportChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final authController = Get.find<AuthController>();
    final isBn = settings.isBangla;
    final isDark = settings.isDark;
    final userId = authController.user.value?.uid;

    return Scaffold(
      backgroundColor: isDark ? _ChatTheme.darkSurface : _ChatTheme.lightSurface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
          onPressed: () {
            controller.activeTicket.value = null;
            Get.back();
          },
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_ChatTheme.emeraldDark, _ChatTheme.emerald, _ChatTheme.emeraldLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(bottom: BorderSide(color: _ChatTheme.gold, width: 1.5)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPatternPainter())),
            ],
          ),
        ),
        title: Obx(() {
          final ticket = controller.activeTicket.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ticket?.subject ?? (isBn ? 'সাপোর্ট চ্যাট' : 'Support Chat'),
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                isBn ? 'সরাসরি কথোপকথন' : 'Live Chat Agent',
                style: GoogleFonts.poppins(color: _ChatTheme.goldSoft, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          );
        }),
        actions: [
          Obx(() {
            final ticket = controller.activeTicket.value;
            final isClosed = ticket?.status == TicketStatus.closed;

            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              color: isDark ? _ChatTheme.darkCard : Colors.white,
              onSelected: (val) {
                if (val == 'close') {
                  Get.dialog(
                    AlertDialog(
                      backgroundColor: isDark ? _ChatTheme.darkCard : Colors.white,
                      title: Text(isBn ? 'চ্যাট বন্ধ করুন' : 'Close Chat', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                      content: Text(isBn ? 'আপনি কি নিশ্চিত যে আপনি এই চ্যাটটি বন্ধ করতে চান?' : 'Are you sure you want to close this chat?', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                      actions: [
                        TextButton(onPressed: () => Get.back(), child: Text(isBn ? 'না' : 'No')),
                        ElevatedButton(
                          onPressed: () {
                            controller.closeActiveTicket();
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          child: Text(isBn ? 'হ্যাঁ, বন্ধ করুন' : 'Yes, Close'),
                        ),
                      ],
                    ),
                  );
                } else if (val == 'new') {
                  controller.startNewChat();
                }
              },
              itemBuilder: (ctx) => [
                if (!isClosed)
                  PopupMenuItem(
                    value: 'close',
                    child: Row(
                      children: [
                        const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 12),
                        Text(isBn ? 'চ্যাট বন্ধ করুন' : 'Close Chat', style: const TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'new',
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle_outline_rounded, color: _ChatTheme.emerald, size: 20),
                      const SizedBox(width: 12),
                      Text(isBn ? 'নতুন চ্যাট শুরু করুন' : 'Start New Chat'),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // 1. Messages Area
          Expanded(
            child: Obx(() {
              final messages = controller.currentMessages;
              if (messages.isEmpty) {
                return _buildEmptyState(isBn, isDark);
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: messages.length + (controller.isAdminTyping.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                    return _buildTypingIndicator(isDark);
                  }
                  final msg = messages[index];
                  final isMe = msg.senderId == controller.effectiveUserId;
                  return _MessageBubble(msg: msg, isMe: isMe, isDark: isDark);
                },
              );
            }),
          ),

          // 2. Typing Image Preview Row
          Obx(() {
            if (controller.selectedImage.value == null) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? _ChatTheme.darkCard : _ChatTheme.goldSoft.withOpacity(0.5),
              child: Row(
                children: [
                  if (controller.selectedImageBytes.value != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        controller.selectedImageBytes.value!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isBn ? 'ছবি সংযুক্ত করা হয়েছে' : 'Image attached',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _ChatTheme.emerald),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_rounded, color: AppColors.error),
                    onPressed: () {
                      controller.selectedImage.value = null;
                      controller.selectedImageBytes.value = null;
                    },
                  ),
                ],
              ),
            );
          }),

          // 3. Chat Input Field Panel
          _buildInputPanel(context, isBn, isDark),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 2, right: 64),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Admin is typing", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
            const SizedBox(width: 8),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: _ChatTheme.emerald),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isBn, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _ChatTheme.emerald.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: _ChatTheme.emerald),
            ),
            const SizedBox(height: 16),
            Text(
              isBn ? 'কথোপকথন শুরু করুন' : 'No messages yet',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                isBn 
                  ? 'আপনার বার্তাটি লিখুন। আমাদের সাপোর্ট প্রতিনিধি শীঘ্রই উত্তর দেবেন।' 
                  : 'Send your query. A support agent will respond to you shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isBn ? 'সরাসরি প্রশ্ন করুন:' : 'Ask a quick question:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? _ChatTheme.goldLight : _ChatTheme.emerald,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: (isBn 
                  ? [
                      'আসসালামু আলাইকুম',
                      'নামাজের সময়',
                      'সূরা বুকমার্ক করার নিয়ম',
                      'অডিও ডাউনলোড কিভাবে করব?',
                    ]
                  : [
                      'Assalamu Alaikum',
                      'Prayer times today',
                      'How to bookmark a Surah?',
                      'How to download audio?',
                    ]).map((text) {
                  return ActionChip(
                    label: Text(
                      text,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    backgroundColor: isDark ? _ChatTheme.darkCard : Colors.white,
                    side: BorderSide(
                      color: isDark ? Colors.white10 : Colors.grey.shade300,
                    ),
                    onPressed: () => controller.sendDirectMessage(text),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputPanel(BuildContext context, bool isBn, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? _ChatTheme.darkCard : _ChatTheme.lightCard,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Image Picker Button
            IconButton(
              icon: const Icon(Icons.image_rounded, color: _ChatTheme.emerald),
              onPressed: () => controller.pickImage(),
            ),
            const SizedBox(width: 8),
            
            // Text Input Form
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? _ChatTheme.darkSurface : _ChatTheme.lightSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? _ChatTheme.emerald.withOpacity(0.15) : _ChatTheme.emerald.withOpacity(0.06),
                  ),
                ),
                child: TextField(
                  controller: controller.messageController,
                  maxLines: null,
                  style: TextStyle(fontSize: 15, color: isDark ? Colors.white : AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: isBn ? 'বার্তা লিখুন...' : 'Type message...',
                    hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send Button
            Obx(() => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_ChatTheme.emerald, _ChatTheme.emeraldLight],
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: controller.isSubmitting.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: controller.isSubmitting.value ? null : () => controller.sendMessage(),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final SupportMessage msg;
  final bool isMe;
  final bool isDark;

  const _MessageBubble({
    required this.msg,
    required this.isMe,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(msg.timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: Get.width * 0.75),
            decoration: BoxDecoration(
              gradient: isMe
                  ? const LinearGradient(
                      colors: [_ChatTheme.emerald, _ChatTheme.emeraldLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isMe ? null : (isDark ? _ChatTheme.darkCard : _ChatTheme.goldSoft),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              border: Border.all(
                color: isMe 
                    ? _ChatTheme.gold.withOpacity(0.3)
                    : _ChatTheme.emerald.withOpacity(0.12),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // If message has image
                if (msg.imageUrl != null) ...[
                  GestureDetector(
                    onTap: () => Get.to(() => Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white),
                      body: PhotoView(imageProvider: CachedNetworkImageProvider(msg.imageUrl!)),
                    )),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: msg.imageUrl!,
                        placeholder: (context, url) => Container(
                          height: 150,
                          color: Colors.grey.withOpacity(0.1),
                          child: const Center(child: CircularProgressIndicator(color: _ChatTheme.emerald)),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 40),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (msg.message.isNotEmpty) const SizedBox(height: 8),
                ],
                // Message text
                if (msg.message.isNotEmpty)
                  Text(
                    msg.message,
                    style: GoogleFonts.poppins(
                      color: isMe ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark),
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
          // Time details label
          Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 6.0, bottom: 12.0),
            child: Text(
              timeStr,
              style: TextStyle(color: AppColors.textGrey, fontSize: 10),
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
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarPatternPainter old) => false;
}
