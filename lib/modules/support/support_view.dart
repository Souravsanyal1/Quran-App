import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter/foundation.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/support_chat_model.dart';
import 'support_controller.dart';

class SupportChatView extends GetView<SupportController> {
  const SupportChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.currentMessages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.currentMessages.isEmpty) {
                return _buildEmptyChat();
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: controller.currentMessages.length + (controller.isAdminTyping.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.currentMessages.length) {
                    return _buildTypingIndicator();
                  }

                  final message = controller.currentMessages[index];
                  final isMe = message.senderType == 'user';
                  final showDate = index == 0 || 
                      !_isSameDay(message.timestamp, controller.currentMessages[index - 1].timestamp);

                  return Column(
                    children: [
                      if (showDate) _buildDateSeparator(message.timestamp),
                      _MessageBubble(message: message, isMe: isMe),
                    ],
                  );
                },
              );
            }),
          ),
          _buildMessageComposer(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        final ticket = controller.activeTicket.value;
        return Column(
          children: [
            Text(ticket?.subject ?? 'Support Chat', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: _getStatusColor(ticket?.status), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(ticket?.status.name.capitalizeFirst ?? '...', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
              ],
            ),
          ],
        );
      }),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) {
            if (value == 'whatsapp') controller.launchWhatsApp();
            if (value == 'facebook') controller.launchFacebook();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'whatsapp',
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, color: Colors.green, size: 20),
                  SizedBox(width: 12),
                  Text('WhatsApp Support'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'facebook',
              child: Row(
                children: [
                  Icon(Icons.facebook_rounded, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Text('Facebook Page'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          const Text('No messages yet. Say hi!', style: TextStyle(color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Text(
            _formatDate(date),
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 2, right: 64),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Admin is typing", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            const SizedBox(width: 8),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer(BuildContext context) {
    return Obx(() {
      final isClosed = controller.activeTicket.value?.status == TicketStatus.closed;
      
      if (isClosed) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: context.theme.cardColor, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
          child: Column(
            children: [
              const Text('This support ticket has been closed.', style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 12),
              TextButton(onPressed: () => Get.back(), child: const Text('Create New Ticket', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuickReplies(),
              if (controller.selectedImage.value != null)
                _buildImagePreview(),
              Row(
                children: [
                  IconButton(
                    onPressed: controller.pickImage, 
                    icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28)
                  ),
                  IconButton(
                    onPressed: () {}, 
                    icon: const Icon(Icons.camera_alt_rounded, color: Colors.white30)
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: context.theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: controller.messageController,
                        maxLines: 4,
                        minLines: 1,
                        style: TextStyle(color: context.theme.brightness == Brightness.dark ? Colors.white : Colors.black87, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Message...', 
                          border: InputBorder.none, 
                          hintStyle: TextStyle(color: Colors.white24, fontSize: 15)
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => IconButton(
                    onPressed: controller.isSubmitting.value ? null : controller.sendMessage,
                    icon: controller.isSubmitting.value 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                      : const Icon(Icons.send_rounded, color: AppColors.primary, size: 28),
                  )),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuickReplies() {
    final suggestions = [
      "How to download?",
      "Prayer times error",
      "Feature request",
      "Assalamu Alaikum",
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: suggestions.map((text) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ActionChip(
            label: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            backgroundColor: Colors.white.withOpacity(0.05),
            onPressed: () {
              controller.messageController.text = text;
              controller.sendMessage();
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(controller.selectedImageBytes.value!, width: 80, height: 80, fit: BoxFit.cover),
          ),
          Positioned(right: -4, top: -4, child: IconButton(onPressed: () {
            controller.selectedImage.value = null;
            controller.selectedImageBytes.value = null;
          }, icon: const Icon(Icons.cancel, color: Colors.red, size: 20))),
        ],
      ),
    );
  }

  Color _getStatusColor(TicketStatus? status) {
    switch (status) {
      case TicketStatus.open: return Colors.green;
      case TicketStatus.pending: return Colors.orange;
      case TicketStatus.resolved: return Colors.blue;
      case TicketStatus.closed: return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'TODAY';
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) return 'YESTERDAY';
    return DateFormat('MMM dd, yyyy').format(date).toUpperCase();
  }

  bool _isSameDay(DateTime d1, DateTime d2) => d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

class _MessageBubble extends StatelessWidget {
  final SupportMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 4, 
              bottom: 2, 
              left: isMe ? 64 : 0, 
              right: isMe ? 0 : 64
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe 
                  ? AppColors.primary 
                  : (theme.brightness == Brightness.dark ? const Color(0xff26262d) : Colors.grey[200]),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.imageUrl != null)
                  _buildImage(context, message.imageUrl!),
                if (message.message.isNotEmpty)
                  Text(
                    message.message, 
                    style: TextStyle(
                      color: isMe ? Colors.black : (theme.brightness == Brightness.dark ? Colors.white : Colors.black87), 
                      fontSize: 15, 
                      height: 1.3
                    )
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('hh:mm a').format(message.timestamp), 
                  style: TextStyle(
                    fontSize: 10, 
                    color: theme.brightness == Brightness.dark ? Colors.white30 : Colors.black38,
                  )
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all_rounded : Icons.done_rounded, 
                    size: 14, 
                    color: message.isRead ? Colors.blue : Colors.white24
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ).animate().fadeIn(duration: 200.ms).slideX(begin: isMe ? 0.1 : -0.1, curve: Curves.easeOutQuad),
    );
  }

  Widget _buildImage(BuildContext context, String url) {
    return GestureDetector(
      onTap: () => Get.to(() => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white),
            body: PhotoView(imageProvider: CachedNetworkImageProvider(url)),
          )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: const BoxConstraints(maxHeight: 200, maxWidth: 250),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: url,
            placeholder: (context, url) => Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.black12,
              height: 100,
              width: 150,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey),
                  SizedBox(height: 4),
                  Text('Invalid Image', style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
