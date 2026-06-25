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
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Section
            _buildSectionTitle('Add Slider Banner'),
            const SizedBox(height: 16),
            _buildTextField(bannerTitleController, 'Banner Title'),
            const SizedBox(height: 12),
            _buildTextField(imgController, 'Image URL'),
            const SizedBox(height: 12),
            _buildTextField(linkController, 'Target URL'),
            const SizedBox(height: 16),
            _buildActionButton('Add Slider Banner', () {
              if (imgController.text.isNotEmpty && linkController.text.isNotEmpty) {
                bannerController.addBanner(
                  imgController.text, 
                  linkController.text, 
                  bannerTitleController.text.isNotEmpty ? bannerTitleController.text : 'New Banner'
                );
                bannerTitleController.clear();
                imgController.clear();
                linkController.clear();
                Get.snackbar('Success', 'Banner added');
              }
            }),

            const SizedBox(height: 40),

            // Custom Ad Section
            _buildSectionTitle('Add Custom Ad Banner'),
            const SizedBox(height: 16),
            _buildTextField(adTitleController, 'Ad Title'),
            const SizedBox(height: 12),
            _buildTextField(adImgController, 'Ad Image URL'),
            const SizedBox(height: 12),
            _buildTextField(adLinkController, 'Ad Target URL'),
            const SizedBox(height: 16),
            _buildActionButton('Publish Custom Ad', () {
              if (adImgController.text.isNotEmpty && adLinkController.text.isNotEmpty) {
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

            const SizedBox(height: 40),

            // Static Top Banner Section
            _buildSectionTitle('Add Static Top Banner (728x90)'),
            const SizedBox(height: 16),
            _buildTextField(staticTitleController, 'Title'),
            const SizedBox(height: 12),
            _buildTextField(staticImgController, 'Image URL'),
            const SizedBox(height: 12),
            _buildTextField(staticLinkController, 'Target URL'),
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

            const SizedBox(height: 40),
            _buildSectionTitle('Manage Active Banners'),
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
                    child: Image.network(
                      banner.imageUrl, 
                      width: 60, 
                      height: 40, 
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                    ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
