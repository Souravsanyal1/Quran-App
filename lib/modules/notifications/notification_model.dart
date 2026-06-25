/// Model for storing in-app notifications locally
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime receivedAt;
  final String type; // 'fcm', 'prayer'
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.receivedAt,
    this.type = 'fcm',
    this.isRead = false,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      imageUrl: map['imageUrl'] as String?,
      receivedAt: DateTime.fromMillisecondsSinceEpoch(map['receivedAt'] as int),
      type: (map['type'] as String?) ?? 'fcm',
      isRead: (map['isRead'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'receivedAt': receivedAt.millisecondsSinceEpoch,
      'type': type,
      'isRead': isRead,
    };
  }
}
