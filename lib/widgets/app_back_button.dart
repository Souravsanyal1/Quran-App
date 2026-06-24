import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A standard back button using [Icons.arrow_back_ios_new_rounded].
/// Always white — designed for use inside AppBars with the primary orange background.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Colors.white,
        size: 20,
      ),
      onPressed: onPressed ?? () => Get.back(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }
}
