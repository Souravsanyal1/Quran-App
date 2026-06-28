import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/cloudinary_service.dart';
import '../../data/models/support_chat_model.dart';
import '../../data/repositories/support_repository.dart';
import '../auth/auth_controller.dart';

class SupportController extends GetxController {
  final SupportRepository _repository;
  final CloudinaryService _cloudinaryService = Get.find<CloudinaryService>();
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger();

  SupportController(this._repository);

  // Lists
  final RxList<SupportTicket> myTickets = <SupportTicket>[].obs;
  final RxList<SupportMessage> currentMessages = <SupportMessage>[].obs;
  
  // States
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final Rxn<SupportTicket> activeTicket = Rxn<SupportTicket>();
  final Rxn<XFile> selectedImage = Rxn<XFile>();
  final Rxn<Uint8List> selectedImageBytes = Rxn<Uint8List>();
  final RxBool isAdminTyping = false.obs;
  
  // Controllers
  final messageController = TextEditingController();
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();

  StreamSubscription? _ticketSubscription;
  StreamSubscription? _messagesSubscription;
  Timer? _typingTimer;
  
  // Use a getter to ensure we always have a valid controller attached to the view
  ScrollController? _scrollController;
  ScrollController get scrollController {
    if (_scrollController == null || !_scrollController!.hasClients) {
      _scrollController?.dispose();
      _scrollController = ScrollController();
    }
    return _scrollController!;
  }
  
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    _listenToMyTickets();
    _listenToPersonalNotifications();

    // Debounce message input for typing indicator
    messageController.addListener(_onMessageChanged);
  }

  void _onMessageChanged() {
    if (activeTicket.value == null) return;
    
    if (_typingTimer?.isActive ?? false) _typingTimer!.cancel();

    _repository.updateTypingStatus(activeTicket.value!.id, true);

    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (activeTicket.value != null) {
        _repository.updateTypingStatus(activeTicket.value!.id, false);
      }
    });
  }

  void _listenToMyTickets() {
    final user = _authController.user.value;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    _repository.streamAllTickets().listen((tickets) {
      final myOnly = tickets.where((t) => t.userId == user.uid).toList();
      myTickets.assignAll(myOnly);
      
      // Auto-select active chat
      if (myTickets.isNotEmpty && activeTicket.value == null) {
        final active = myTickets.firstWhere(
          (t) => t.status != TicketStatus.closed,
          orElse: () => myTickets.first,
        );
        activeTicket.value = active;
        _listenToCurrentMessages(active.id);
      }
      isLoading.value = false;
    });
  }

  void _listenToPersonalNotifications() {
    final user = _authController.user.value;
    if (user == null) return;

    FirebaseFirestore.instance.collection('users').doc(user.uid).collection('notifications')
        .where('sentAt', isGreaterThan: DateTime.now().subtract(const Duration(minutes: 1)))
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
             Get.snackbar(data['title'] ?? 'Notification', data['body'] ?? '');
          }
        }
      }
    });
  }

  Future<void> createTicket() async {
    final user = _authController.user.value;
    if (user == null) return;

    if (subjectController.text.isEmpty || descriptionController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    try {
      isSubmitting.value = true;
      String? screenshotUrl;
      if (selectedImage.value != null) {
        screenshotUrl = await _cloudinaryService.uploadImage(selectedImage.value!, folder: 'support_tickets');
      }

      final ticket = SupportTicket(
        id: '', 
        userId: user.uid,
        userName: user.displayName ?? user.email?.split('@').first ?? 'User',
        email: user.email ?? '',
        subject: subjectController.text,
        description: descriptionController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdTicket = await _repository.createFirestoreTicket(ticket);
      openTicketChat(createdTicket);
      
      // Clear form
      subjectController.clear();
      descriptionController.clear();
      selectedImage.value = null;
      selectedImageBytes.value = null;
    } catch (e) {
      _logger.e('Error creating ticket: $e');
      Get.snackbar('Error', 'Failed to create ticket');
    } finally {
      isSubmitting.value = false;
    }
  }

  void openTicketChat(SupportTicket ticket) {
    activeTicket.value = ticket;
    currentMessages.clear();
    _listenToCurrentMessages(ticket.id);
    _listenToTicketMetadata(ticket.id);
    _repository.markMessagesAsRead(ticket.id);
  }

  void _listenToTicketMetadata(String ticketId) {
    _ticketSubscription?.cancel();
    _ticketSubscription = _repository.streamTicket(ticketId).listen((ticket) {
      if (ticket != null) {
        isAdminTyping.value = ticket.isAdminTyping;
        // Update active ticket with fresh data (status, etc)
        activeTicket.value = ticket;
      }
    });
  }

  void _listenToCurrentMessages(String ticketId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _repository.streamMessages(ticketId).listen((messages) {
      // Check if new message arrived
      if (messages.length > currentMessages.length) {
        final last = messages.last;
        if (last.senderType == 'admin') {
          _playReceiveSound();
          _repository.markMessagesAsRead(ticketId);
        }
      }
      currentMessages.assignAll(messages);
      _scrollToBottom();
    });
  }

  void _playReceiveSound() {
    // Implement if needed
  }

  Future<void> sendMessage() async {
    final ticket = activeTicket.value;
    final user = _authController.user.value;
    if (ticket == null || user == null) return;
    
    if (ticket.status == TicketStatus.closed) {
      Get.snackbar('Ticket Closed', 'This ticket is closed and cannot receive new messages.');
      return;
    }

    final text = messageController.text.trim();
    if (text.isEmpty && selectedImage.value == null) return;

    try {
      isSubmitting.value = true;
      String? imageUrl;
      
      if (selectedImage.value != null) {
        imageUrl = await _cloudinaryService.uploadImage(selectedImage.value!, folder: 'support_messages');
      }

      final message = SupportMessage(
        id: const Uuid().v4(),
        ticketId: ticket.id,
        senderId: user.uid,
        senderType: 'user',
        message: text,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _repository.sendFirestoreMessage(ticket.id, message);

      messageController.clear();
      selectedImage.value = null;
      selectedImageBytes.value = null;
      _scrollToBottom();
    } catch (e) {
      _logger.e('Error sending message: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      selectedImage.value = image;
      selectedImageBytes.value = await image.readAsBytes();
    }
  }

  Future<void> startInstantChat() async {
    final user = _authController.user.value;
    if (user == null) {
      Get.snackbar('Login Required', 'Please login to start a live chat.');
      return;
    }

    try {
      isSubmitting.value = true;
      _logger.i('Starting chat for Firebase UID: ${user.uid}');
      
      final ticket = SupportTicket(
        id: '', 
        userId: user.uid,
        userName: user.displayName ?? user.email?.split('@').first ?? 'User',
        email: user.email ?? '',
        subject: 'Live Chat Support',
        description: 'Direct message session',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdTicket = await _repository.createFirestoreTicket(ticket);
      openTicketChat(createdTicket);

      // Initial system message
      await _repository.sendFirestoreMessage(createdTicket.id, SupportMessage(
        id: 'welcome',
        ticketId: createdTicket.id,
        senderId: 'admin',
        senderType: 'admin',
        message: 'আসসালামু আলাইকুম! আমরা আপনাকে কিভাবে সাহায্য করতে পারি?',
        timestamp: DateTime.now(),
      ));
      
    } catch (e) {
      _logger.e('Error starting instant chat: $e');
      Get.snackbar('Error', 'Failed to start chat.');
    } finally {
      isSubmitting.value = false;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (_scrollController != null && _scrollController!.hasClients) {
          _scrollController!.animateTo(
            _scrollController!.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } catch (e) {
        _logger.w('Scroll error: $e');
      }
    });
  }

  Future<void> launchWhatsApp() async {
    const phone = "8801340989509";
    final url = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Support', 'WhatsApp not found. Opening web support...', snackPosition: SnackPosition.BOTTOM);
      final webUrl = Uri.parse('https://api.whatsapp.com/send?phone=$phone');
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> launchFacebook() async {
    final url = Uri.parse('https://www.facebook.com/groups/quranappsupport'); // Replace with your actual group/page
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Support', 'Could not open Facebook.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    _ticketSubscription?.cancel();
    _messagesSubscription?.cancel();
    _typingTimer?.cancel();
    messageController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
    _scrollController?.dispose();
    super.onClose();
  }
}
