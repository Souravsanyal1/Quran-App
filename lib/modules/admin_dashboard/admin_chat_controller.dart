import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/cloudinary_service.dart';
import '../../data/models/support_chat_model.dart';
import '../../data/repositories/support_repository.dart';

class AdminChatController extends GetxController {
  final SupportRepository _repository;
  final CloudinaryService _cloudinaryService = Get.find<CloudinaryService>();
  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger();

  AdminChatController(this._repository);

  final messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<SupportMessage> messages = <SupportMessage>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<File> selectedImage = Rxn<File>();
  final RxBool isUserTyping = false.obs;

  late final String currentTicketId;
  late final String currentUserName;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _ticketSubscription;
  Timer? _typingTimer;

  void setupChat(String ticketId, String userName) {
    currentTicketId = ticketId;
    currentUserName = userName;
    _listenToMessages();
    _listenToTicketMetadata();
    _repository.markMessagesAsRead(ticketId, isAdmin: true);
    
    messageController.addListener(_onMessageChanged);
  }

  void _onMessageChanged() {
    if (_typingTimer?.isActive ?? false) _typingTimer!.cancel();

    _repository.updateTypingStatus(currentTicketId, true, isAdmin: true);

    _typingTimer = Timer(const Duration(seconds: 2), () {
      _repository.updateTypingStatus(currentTicketId, false, isAdmin: true);
    });
  }

  void _listenToTicketMetadata() {
    _ticketSubscription?.cancel();
    _ticketSubscription = _repository.streamTicket(currentTicketId).listen((ticket) {
      if (ticket != null) {
        isUserTyping.value = ticket.isUserTyping;
      }
    });
  }

  void _listenToMessages() {
    _messagesSubscription?.cancel();
    _messagesSubscription = _repository.streamMessages(currentTicketId).listen((fetchedMessages) {
      // If new messages from user, mark as read
      if (fetchedMessages.length > messages.length) {
        final last = fetchedMessages.last;
        if (last.senderType == 'user') {
          _repository.markMessagesAsRead(currentTicketId, isAdmin: true);
        }
      }
      messages.assignAll(fetchedMessages);
      _scrollToBottom();
    }, onError: (e) {
      _logger.e("Error streaming admin chat messages: $e");
    });
    isLoading.value = false;
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty && selectedImage.value == null) return;

    try {
      isSubmitting.value = true;
      String? imageUrl;
      if (selectedImage.value != null) {
        imageUrl = await _cloudinaryService.uploadImage(selectedImage.value!, folder: 'support_admin');
      }

      final newMessage = SupportMessage(
        id: const Uuid().v4(),
        ticketId: currentTicketId,
        senderId: 'admin',
        senderType: 'admin',
        message: text,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
      );

      await _repository.sendFirestoreMessage(currentTicketId, newMessage);
      
      // Notify the user (Specific User Notification)
      await _notifyUserOfReply(text);

      messageController.clear();
      selectedImage.value = null;
      _scrollToBottom();
    } catch (e) {
      _logger.e('Failed to send admin message: $e');
      Get.snackbar('Error', 'Failed to send message');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _notifyUserOfReply(String messageText) async {
    try {
      // 1. Get ticket info to find user ID
      final ticketDoc = await FirebaseFirestore.instance.collection('support_tickets').doc(currentTicketId).get();
      final userId = ticketDoc.data()?['userId'];
      if (userId == null) return;

      // 2. Add to user's notifications collection (so it shows in their app)
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('notifications').add({
        'title': 'New Support Reply',
        'body': messageText.length > 50 ? '${messageText.substring(0, 47)}...' : messageText,
        'type': 'support_reply',
        'ticketId': currentTicketId,
        'sentAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // 3. For real FCM, you'd usually trigger a Cloud Function here.
      // Since we don't have that, we rely on the app listening to its own notifications collection
      // or using the broadcast system if you want everyone to see it (not recommended).
    } catch (e) {
      _logger.w('Failed to notify user: $e');
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    _ticketSubscription?.cancel();
    _typingTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
