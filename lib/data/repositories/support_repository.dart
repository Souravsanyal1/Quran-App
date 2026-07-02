import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/support_api_provider.dart';
import '../../core/constants/app_keys.dart';
import '../../modules/settings/settings_controller.dart';
import '../models/support_chat_model.dart';


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

  Stream<List<SupportTicket>> streamMyTickets(String userId) {
    return _firestore.collection('support_tickets')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => _ticketFromDoc(doc)).toList();
          list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return list;
        });
  }

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

  Future<void> updateBotStatus(String ticketId, bool isActive) async {
    await _firestore.collection('support_tickets').doc(ticketId).update({
      'isBotActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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

  // --- n8n MCP Server / Webhook Chat ---

  Future<String?> sendToN8n(String message, String userId, {String? userName}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString('n8n_url') ?? 'https://islansourav.app.n8n.cloud/webhook/chat';
      final apiKey = prefs.getString('n8n_api_key') ?? AppKeys.n8nApiKey;
      final toolName = prefs.getString('n8n_tool_name') ?? AppKeys.n8nToolName;
      final useMcp = prefs.getBool('n8n_use_mcp') ?? (!url.contains('/webhook'));

      // Retrieve dynamic package version info
      String appVersion = '1.0.0';
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        appVersion = packageInfo.version;
      } catch (e) {
        debugPrint('Failed to get package info: $e');
      }

      // Retrieve language settings from SettingsController
      String appLanguage = 'bn';
      try {
        if (Get.isRegistered<SettingsController>()) {
          appLanguage = Get.find<SettingsController>().language.value;
        } else {
          appLanguage = Get.locale?.languageCode ?? 'bn';
        }
      } catch (e) {
        debugPrint('Failed to get language settings: $e');
      }

      final platformStr = kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown'));

      final Map<String, dynamic> requestData;
      if (useMcp) {
        requestData = {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': toolName,
            'arguments': {
              'message': message,
              'userId': userId,
              'userName': userName ?? 'User',
              'appLanguage': appLanguage,
              'appVersion': appVersion,
              'platform': platformStr,
              'timestamp': DateTime.now().toIso8601String(),
            },
          },
          'id': 1,
        };
      } else {
        requestData = {
          'message': message,
          'userId': userId,
          'userName': userName ?? 'User',
          'appLanguage': appLanguage,
          'appVersion': appVersion,
          'platform': platformStr,
          'timestamp': DateTime.now().toIso8601String(),
        };
      }

      final Map<String, dynamic> headers = {
        'Content-Type': 'application/json',
      };
      if (apiKey.isNotEmpty && apiKey != 'your_n8n_api_key_here') {
        headers['Authorization'] = 'Bearer $apiKey';
        headers['X-N8N-API-KEY'] = apiKey;
      }

      final response = await _apiProvider.dio.post(
        url,
        options: Options(headers: headers),
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          // 1. If response is a List (e.g. n8n workflow returning an array)
          if (data is List) {
            if (data.isEmpty) return null;
            final first = data.first;
            if (first is Map) {
              return first['response'] ?? first['output'] ?? first['text'] ?? first['message'] ?? first['reply'];
            } else {
              return first.toString();
            }
          }

          // 2. If response is a String (e.g. raw text from webhook)
          if (data is String) {
            return data;
          }

          // 3. If response is a Map
          if (data is Map) {
            // Try standard MCP JSON-RPC format first
            if (data['result'] != null && data['result']['content'] is List) {
              final contentList = data['result']['content'] as List;
              if (contentList.isNotEmpty) {
                final textItem = contentList.firstWhere(
                  (item) => item is Map && item['type'] == 'text',
                  orElse: () => null,
                );
                if (textItem != null && textItem['text'] != null) {
                  return textItem['text'].toString();
                }
              }
            }
            // Fallback to direct output keys
            return data['response'] ?? data['output'] ?? data['text'] ?? data['message'] ?? data['reply'];
          }
        }
      }
    } catch (e) {
      debugPrint('n8n MCP Error: $e');
    }
    return null;
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
      isBotActive: data['isBotActive'] ?? true,
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
      'isBotActive': t.isBotActive,
    };
  }
}
