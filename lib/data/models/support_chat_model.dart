enum TicketStatus { open, pending, inProgress, resolved, closed }
enum TicketPriority { low, medium, high, urgent }

class SupportTicket {
  final String id;
  final String userId;
  final String userName;
  final String email;
  final String subject;
  final String? description;
  final TicketStatus status;
  final TicketPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessage;
  final int unreadCount;
  final String? assignedAdminId;
  final bool isUserTyping;
  final bool isAdminTyping;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.email,
    required this.subject,
    this.description,
    this.status = TicketStatus.open,
    this.priority = TicketPriority.medium,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.assignedAdminId,
    this.isUserTyping = false,
    this.isAdminTyping = false,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? 'User',
      email: json['email'] as String? ?? '',
      subject: json['subject'] as String? ?? 'Support Request',
      description: json['description'] as String?,
      status: _parseStatus(json['status'] as String?),
      priority: _parsePriority(json['priority'] as String?),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
      lastMessage: json['lastMessage'] as String?,
      unreadCount: json['unreadCount'] as int? ?? 0,
      assignedAdminId: json['assignedAdminId'] as String?,
      isUserTyping: json['isUserTyping'] as bool? ?? false,
      isAdminTyping: json['isAdminTyping'] as bool? ?? false,
    );
  }

  static TicketStatus _parseStatus(String? status) {
    return TicketStatus.values.firstWhere((e) => e.name == status, orElse: () => TicketStatus.open);
  }

  static TicketPriority _parsePriority(String? priority) {
    return TicketPriority.values.firstWhere((e) => e.name == priority, orElse: () => TicketPriority.medium);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'email': email,
      'subject': subject,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'assignedAdminId': assignedAdminId,
      'isUserTyping': isUserTyping,
      'isAdminTyping': isAdminTyping,
    };
  }
}

class SupportMessage {
  final String id;
  final String ticketId;
  final String senderId;
  final String senderType; // 'user' or 'admin'
  final String message;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;

  SupportMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderType,
    required this.message,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'] as String,
      ticketId: json['ticketId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderType: json['senderType'] as String? ?? 'user',
      message: json['message'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp'] as String) : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'senderId': senderId,
      'senderType': senderType,
      'message': message,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}
