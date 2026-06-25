import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A standard back button using [Icons.arrow_back_ios_new_rounded].
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed, this.color});

  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: color ?? Colors.white,
        size: 20,
      ),
      onPressed: onPressed ?? () => Get.back(),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }
}
