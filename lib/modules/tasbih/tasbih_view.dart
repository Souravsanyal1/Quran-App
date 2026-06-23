import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/settings/settings_controller.dart';
import 'tasbih_controller.dart';

class TasbihView extends GetView<TasbihController> {
  const TasbihView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(settings.isBangla ? 'ডিজিটাল তসবীহ' : 'Tasbih Counter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Target Selection Row
            Column(
              children: [
                Text(
                  settings.isBangla ? 'লক্ষ্য নির্ধারণ করুন' : 'Select Target',
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTargetTab(33, '33'),
                        const SizedBox(width: 10),
                        _buildTargetTab(99, '99'),
                        const SizedBox(width: 10),
                        _buildTargetTab(100, '100'),
                        const SizedBox(width: 10),
                        _buildTargetTab(9999, '∞'),
                      ],
                    )),
              ],
            ),

            // Large Center Counter Tap Target
            GestureDetector(
              onTap: () => controller.increment(),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      settings.isBangla ? 'জিকির করুন' : 'TAP',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => Text(
                          controller.count.value.toString(),
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: settings.isDark ? AppColors.textWhite : AppColors.textDark,
                          ),
                        )),
                    const SizedBox(height: 8),
                    Obx(() {
                      final tar = controller.target.value;
                      final displayTar = tar == 9999 ? '∞' : tar.toString();
                      return Text(
                        '${settings.isBangla ? "লক্ষ্য" : "Target"}: $displayTar',
                        style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Actions & Session Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Reset Button
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.refresh, color: AppColors.error),
                  onPressed: () => controller.reset(),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                
                // Completed rounds
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: settings.isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: settings.isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Obx(() => Text(
                            '${settings.isBangla ? "মোট চক্র" : "Rounds"}: ${controller.totalSaves.value}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetTab(int value, String label) {
    final isSelected = controller.target.value == value;
    return GestureDetector(
      onTap: () => controller.setTarget(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
