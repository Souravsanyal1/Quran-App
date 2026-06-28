import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationPriority { low, medium, high, urgent }

enum NotificationCategory { general, prayer, quran, announcement, event, donation, update, support }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime createdAt;
  bool isRead;
  final NotificationCategory category;
  final NotificationPriority priority;
  final String targetUserId;
  final String? deepLink;
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.createdAt,
    this.isRead = false,
    this.category = NotificationCategory.general,
    this.priority = NotificationPriority.medium,
    this.targetUserId = 'all',
    this.deepLink,
    this.metadata,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      createdAt: _parseDate(json['createdAt'] ?? json['sentAt']),
      isRead: json['isRead'] as bool? ?? false,
      category: _parseCategory(json['category'] as String? ?? json['type'] as String?),
      priority: _parsePriority(json['priority'] as String?),
      targetUserId: json['targetUserId'] as String? ?? 'all',
      deepLink: json['deepLink'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }

  static NotificationCategory _parseCategory(String? category) {
    if (category == 'support_reply' || category == 'support') return NotificationCategory.support;
    if (category == 'broadcast') return NotificationCategory.announcement;

    return NotificationCategory.values.firstWhere(
      (e) => e.name == category,
      orElse: () => NotificationCategory.general,
    );
  }

  static NotificationPriority _parsePriority(String? priority) {
    return NotificationPriority.values.firstWhere(
      (e) => e.name == priority,
      orElse: () => NotificationPriority.medium,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'category': category.name,
      'priority': priority.name,
      'targetUserId': targetUserId,
      'deepLink': deepLink,
      'metadata': metadata,
    };
  }
}
