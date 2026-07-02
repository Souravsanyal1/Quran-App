import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationCategoryConfig {
  final bool enabled;
  final String title;
  final String message;
  final String? time; // HH:mm format

  NotificationCategoryConfig({
    required this.enabled,
    required this.title,
    required this.message,
    this.time,
  });

  factory NotificationCategoryConfig.fromJson(Map<String, dynamic> json) {
    return NotificationCategoryConfig(
      enabled: json['enabled'] ?? true,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'title': title,
      'message': message,
      if (time != null) 'time': time,
    };
  }
}

class CustomNotificationConfig {
  final String id;
  final String type;
  final String title;
  final String message;
  final String scheduleTime; // HH:mm format
  final DateTime startDate;
  final DateTime? endDate;
  final String repeat; // 'once', 'daily', 'weekly', 'monthly'
  final String priority; // 'low', 'medium', 'high'
  final bool isActive;

  CustomNotificationConfig({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.scheduleTime,
    required this.startDate,
    this.endDate,
    required this.repeat,
    required this.priority,
    required this.isActive,
  });

  factory CustomNotificationConfig.fromJson(Map<String, dynamic> json, String docId) {
    return CustomNotificationConfig(
      id: docId,
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      scheduleTime: json['scheduleTime'] ?? '08:00',
      startDate: (json['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (json['endDate'] as Timestamp?)?.toDate(),
      repeat: json['repeat'] ?? 'once',
      priority: json['priority'] ?? 'medium',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'message': message,
      'scheduleTime': scheduleTime,
      'startDate': Timestamp.fromDate(startDate),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      'repeat': repeat,
      'priority': priority,
      'isActive': isActive,
    };
  }
}
