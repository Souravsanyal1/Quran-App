enum TicketStatus {
  open,
  pending,
  inProgress,
  resolved,
  closed
}

enum TicketPriority {
  low,
  medium,
  high
}

class SupportTicketDto {
  final String id;
  final String userName;
  final String email;
  final String subject;
  final String description;
  final String? screenshotUrl;
  final TicketStatus status;
  final TicketPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessage;
  final int unreadCount;
  final String? assignedTo;

  SupportTicketDto({
    required this.id,
    required this.userName,
    required this.email,
    required this.subject,
    required this.description,
    this.screenshotUrl,
    this.status = TicketStatus.open,
    this.priority = TicketPriority.medium,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.assignedTo,
  });

  SupportTicketDto copyWith({
    String? id,
    String? userName,
    String? email,
    String? subject,
    String? description,
    String? screenshotUrl,
    TicketStatus? status,
    TicketPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessage,
    int? unreadCount,
    String? assignedTo,
  }) {
    return SupportTicketDto(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      screenshotUrl: screenshotUrl ?? this.screenshotUrl,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  factory SupportTicketDto.fromJson(Map<String, dynamic> json) {
    return SupportTicketDto(
      id: json['id'] as String,
      userName: json['userName'] as String? ?? 'Guest User',
      email: json['email'] as String? ?? '',
      subject: json['subject'] as String? ?? 'No Subject',
      description: json['description'] as String? ?? '',
      screenshotUrl: json['screenshotUrl'] as String?,
      status: TicketStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TicketStatus.open,
      ),
      priority: TicketPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => TicketPriority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastMessage: json['lastMessage'] as String?,
      unreadCount: json['unreadCount'] as int? ?? 0,
      assignedTo: json['assignedTo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'subject': subject,
      'description': description,
      'screenshotUrl': screenshotUrl,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'assignedTo': assignedTo,
    };
  }
}
