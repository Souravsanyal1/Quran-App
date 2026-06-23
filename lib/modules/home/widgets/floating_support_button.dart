import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../modules/settings/settings_controller.dart';

/// Floating support/chat button that persists across the home shell
class FloatingSupportButton extends StatelessWidget {
  const FloatingSupportButton({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return FloatingActionButton.extended(
      onPressed: () => Get.toNamed(AppRoutes.support),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.black,
      elevation: 4,
      icon: const Icon(Icons.support_agent_rounded, size: 20),
      label: Obx(() => Text(
            settings.isBangla ? 'সাহায্য' : 'Help',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          )),
    );
  }
}
