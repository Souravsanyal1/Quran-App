import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/notification_model.dart';

class NotificationDetailsView extends StatelessWidget {
  final AppNotification notification;

  const NotificationDetailsView({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: Colors.white10),
                  const SizedBox(height: 24),
                  _buildContent(context),
                  const SizedBox(height: 40),
                  _buildActions(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: notification.imageUrl != null ? 300 : 0,
      pinned: true,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Get.back(),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black26,
          foregroundColor: Colors.white,
        ),
      ),
      flexibleSpace: notification.imageUrl != null
          ? FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () => _openFullscreenImage(context, notification.imageUrl!),
                child: Hero(
                  tag: 'notif_img_${notification.id}',
                  child: CachedNetworkImage(
                    imageUrl: notification.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildCategoryBadge(notification.category),
            const SizedBox(width: 12),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(notification.createdAt),
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          notification.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(NotificationCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category.name.toUpperCase(),
        style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Text(
      notification.body,
      style: TextStyle(
        fontSize: 16,
        color: Colors.white.withOpacity(0.7),
        height: 1.6,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          context,
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: () => Share.share('${notification.title}\n\n${notification.body}'),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          context,
          icon: Icons.copy_rounded,
          label: 'Copy',
          onTap: () {
            Clipboard.setData(ClipboardData(text: notification.body));
            Get.snackbar('Copied', 'Notification content copied to clipboard');
          },
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          context,
          icon: Icons.bookmark_border_rounded,
          label: 'Save',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: Colors.white70),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.white60)),
            ],
          ),
        ),
      ),
    );
  }

  void _openFullscreenImage(BuildContext context, String imageUrl) {
    Get.to(() => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white),
          body: PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            heroAttributes: PhotoViewHeroAttributes(tag: 'notif_img_${notification.id}'),
          ),
        ));
  }
}
