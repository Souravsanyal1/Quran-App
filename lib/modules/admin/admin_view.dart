import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../home/banner_controller.dart';
import '../../widgets/app_back_button.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerController = Get.find<BannerController>();
    final imgController = TextEditingController();
    final linkController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Banner',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: imgController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'Paste image link here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(
                labelText: 'Target URL',
                hintText: 'https://...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (imgController.text.isNotEmpty && linkController.text.isNotEmpty) {
                    bannerController.addBanner(imgController.text, linkController.text);
                    imgController.clear();
                    linkController.clear();
                    Get.snackbar('Success', 'Banner added successfully');
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Add Banner', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Manage Banners',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Obx(() => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bannerController.banners.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final banner = bannerController.banners[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(banner.imageUrl, width: 60, height: 40, fit: BoxFit.cover),
                  ),
                  title: Text(banner.linkUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => bannerController.deleteBanner(banner.id),
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
