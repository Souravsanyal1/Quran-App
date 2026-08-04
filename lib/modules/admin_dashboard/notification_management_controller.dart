import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/notification_config_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationManagementController extends GetxController {
  final NotificationRepository _repository;

  NotificationManagementController(this._repository);

  final RxMap<String, NotificationCategoryConfig> globalConfigs =
      <String, NotificationCategoryConfig>{}.obs;
  final RxList<CustomNotificationConfig> customNotifications =
      <CustomNotificationConfig>[].obs;
  final RxBool isLoading = true.obs;

  // Controllers for editing
  final Map<String, TextEditingController> titleControllers = {};
  final Map<String, TextEditingController> messageControllers = {};
  final Map<String, TextEditingController> timeControllers = {};
  final Map<String, RxBool> enabledStates = {};

  @override
  void onInit() {
    super.onInit();
    _listenToConfigs();
  }

  void _listenToConfigs() {
    _repository.streamGlobalConfigs().listen((configs) {
      globalConfigs.assignAll(configs);
      _initializeCategoryControllers(configs);
      isLoading.value = false;
    });

    _repository.streamCustomNotifications().listen((list) {
      customNotifications.assignAll(list);
    });
  }

  void _initializeCategoryControllers(
      Map<String, NotificationCategoryConfig> configs) {
    configs.forEach((key, config) {
      if (!titleControllers.containsKey(key)) {
        titleControllers[key] = TextEditingController(text: config.title);
        messageControllers[key] = TextEditingController(text: config.message);
        if (config.time != null) {
          timeControllers[key] = TextEditingController(text: config.time);
        }
        enabledStates[key] = config.enabled.obs;
      } else {
        // Only update if not currently focused to avoid jumpy cursor
        // but for now simple sync
        titleControllers[key]!.text = config.title;
        messageControllers[key]!.text = config.message;
        if (config.time != null) {
          timeControllers[key]!.text = config.time!;
        }
        enabledStates[key]!.value = config.enabled;
      }
    });
  }

  Future<void> saveGlobalConfig(String category) async {
    try {
      final updatedConfigs =
          Map<String, NotificationCategoryConfig>.from(globalConfigs);
      updatedConfigs[category] = NotificationCategoryConfig(
        enabled: enabledStates[category]?.value ?? true,
        title: titleControllers[category]?.text ?? '',
        message: messageControllers[category]?.text ?? '',
        time: timeControllers[category]?.text,
      );

      await _repository.updateGlobalConfigs(updatedConfigs);
      Get.snackbar('Success', '$category configuration updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update $category: $e');
    }
  }

  Future<void> addCustomNotification({
    required String type,
    required String title,
    required String message,
    required String scheduleTime,
    required DateTime startDate,
    DateTime? endDate,
    required String repeat,
    required String priority,
  }) async {
    try {
      final config = CustomNotificationConfig(
        id: '',
        type: type,
        title: title,
        message: message,
        scheduleTime: scheduleTime,
        startDate: startDate,
        endDate: endDate,
        repeat: repeat,
        priority: priority,
        isActive: true,
      );
      await _repository.addCustomNotification(config);
      Get.snackbar('Success', 'Custom notification added');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add custom notification: $e');
    }
  }

  Future<void> deleteCustomNotification(String id) async {
    try {
      await _repository.deleteCustomNotification(id);
      Get.snackbar('Success', 'Notification deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }

  Future<void> toggleCustomStatus(CustomNotificationConfig config) async {
    try {
      final updated = CustomNotificationConfig(
        id: config.id,
        type: config.type,
        title: config.title,
        message: config.message,
        scheduleTime: config.scheduleTime,
        startDate: config.startDate,
        endDate: config.endDate,
        repeat: config.repeat,
        priority: config.priority,
        isActive: !config.isActive,
      );
      await _repository.updateCustomNotification(updated);
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle status: $e');
    }
  }

  @override
  void onClose() {
    for (var c in titleControllers.values) {
      c.dispose();
    }
    for (var c in messageControllers.values) {
      c.dispose();
    }
    for (var c in timeControllers.values) {
      c.dispose();
    }
    super.onClose();
  }
}
