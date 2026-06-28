import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/support_chat_model.dart';
import '../../core/api/support_api_provider.dart';

class SupportRepository {
  final SupportApiProvider _apiProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SupportRepository(this._apiProvider);

  // --- API Methods ---
  Future<List<SupportTicket>> getMyTickets(String userId) {
    return _apiProvider.getTickets(userId: userId);
  }

  Future<List<SupportTicket>> getAllTickets() {
    return _apiProvider.getTickets();
  }

  // --- Firestore Real-time Methods ---

  Stream<List<SupportTicket>> streamAllTickets() {
    return _firestore.collection('support_tickets')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _ticketFromDoc(doc)).toList());
  }

  Stream<List<SupportMessage>> streamMessages(String ticketId) {
    return _firestore.collection('support_tickets').doc(ticketId).collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _messageFromDoc(doc)).toList());
  }

  Stream<SupportTicket?> streamTicket(String ticketId) {
    return _firestore.collection('support_tickets').doc(ticketId)
        .snapshots()
        .map((doc) => doc.exists ? _ticketFromDoc(doc) : null);
  }

  Future<void> updateTypingStatus(String ticketId, bool isTyping, {bool isAdmin = false}) async {
    await _firestore.collection('support_tickets').doc(ticketId).update({
      isAdmin ? 'isAdminTyping' : 'isUserTyping': isTyping,
    });
  }

  Future<void> markMessagesAsRead(String ticketId, {bool isAdmin = false}) async {
    final senderToMark = isAdmin ? 'user' : 'admin';
    final messages = await _firestore.collection('support_tickets')
        .doc(ticketId)
        .collection('messages')
        .where('senderType', isEqualTo: senderToMark)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    
    // Also reset unread count on ticket if admin is reading
    if (isAdmin) {
      batch.update(_firestore.collection('support_tickets').doc(ticketId), {'unreadCount': 0});
    }

    await batch.commit();
  }

  Future<SupportTicket> createFirestoreTicket(SupportTicket ticket) async {
    final docRef = _firestore.collection('support_tickets').doc();
    final newTicket = SupportTicket(
      id: docRef.id,
      userId: ticket.userId,
      userName: ticket.userName,
      email: ticket.email,
      subject: ticket.subject,
      description: ticket.description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isUserTyping: false,
      isAdminTyping: false,
    );
    await docRef.set(_ticketToMap(newTicket));
    return newTicket;
  }

  Future<void> sendFirestoreMessage(String ticketId, SupportMessage message) async {
    final ticketRef = _firestore.collection('support_tickets').doc(ticketId);
    
    // Add message
    await ticketRef.collection('messages').add({
      ...message.toJson(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update ticket last message and timestamp
    String lastMsg = message.message;
    if (lastMsg.isEmpty && message.imageUrl != null) {
      lastMsg = "📷 Image";
    }

    await ticketRef.update({
      'lastMessage': lastMsg,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(String ticketId, TicketStatus status) {
    return updateFirestoreTicketStatus(ticketId, status.name);
  }

  Future<void> updatePriority(String ticketId, TicketPriority priority) async {
    await _firestore.collection('support_tickets').doc(ticketId).update({
      'priority': priority.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFirestoreTicketStatus(String ticketId, String status) async {
    await _firestore.collection('support_tickets').doc(ticketId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Helpers ---

  SupportTicket _ticketFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportTicket(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'User',
      email: data['email'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'],
      status: TicketStatus.values.firstWhere((e) => e.name == data['status'], orElse: () => TicketStatus.open),
      priority: TicketPriority.values.firstWhere((e) => e.name == data['priority'], orElse: () => TicketPriority.medium),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: data['lastMessage'],
      isUserTyping: data['isUserTyping'] ?? false,
      isAdminTyping: data['isAdminTyping'] ?? false,
    );
  }

  SupportMessage _messageFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportMessage(
      id: doc.id,
      ticketId: data['ticketId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderType: data['senderType'] ?? 'user',
      message: data['message'] ?? '',
      imageUrl: data['imageUrl'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> _ticketToMap(SupportTicket t) {
    return {
      'userId': t.userId,
      'userName': t.userName,
      'email': t.email,
      'subject': t.subject,
      'description': t.description,
      'status': t.status.name,
      'priority': t.priority.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': t.lastMessage,
      'isUserTyping': t.isUserTyping,
      'isAdminTyping': t.isAdminTyping,
    };
  }
}
