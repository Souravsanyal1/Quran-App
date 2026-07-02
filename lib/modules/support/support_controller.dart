import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/cloudinary_service.dart';
import '../../data/models/support_chat_model.dart';
import '../../data/repositories/support_repository.dart';
import '../auth/auth_controller.dart';
import '../settings/settings_controller.dart';

class SupportController extends GetxController {
  final SupportRepository _repository;
  final CloudinaryService _cloudinaryService = Get.find<CloudinaryService>();
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger();

  String? _anonymousUserId;
  String? _anonymousUserName;
  String? _anonymousUserEmail;

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
    _initAnonymousUser().then((_) {
      _listenToMyTickets();
      _listenToPersonalNotifications();
    });

    // Debounce message input for typing indicator
    messageController.addListener(_onMessageChanged);
  }

  Future<void> _initAnonymousUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? storedId = prefs.getString('anonymous_user_id');
      if (storedId == null) {
        storedId = 'anon_${const Uuid().v4().substring(0, 8)}';
        await prefs.setString('anonymous_user_id', storedId);
      }
      _anonymousUserId = storedId;
      
      _anonymousUserName = prefs.getString('anonymous_user_name') ?? 'Guest User';
      _anonymousUserEmail = prefs.getString('anonymous_user_email') ?? 'guest@anonymous.com';
    } catch (e) {
      _logger.e('Error initializing anonymous user: $e');
      _anonymousUserId ??= 'anon_fallback';
      _anonymousUserName ??= 'Guest User';
      _anonymousUserEmail ??= 'guest@anonymous.com';
    }
  }

  String get effectiveUserId => _authController.user.value?.uid ?? _anonymousUserId ?? 'anonymous';
  String get effectiveUserName => _authController.user.value?.displayName ?? _authController.user.value?.email?.split('@').first ?? _anonymousUserName ?? 'Guest';
  String get effectiveUserEmail => _authController.user.value?.email ?? _anonymousUserEmail ?? 'guest@anonymous.com';

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
    final uid = effectiveUserId;
    _repository.streamMyTickets(uid).listen((tickets) {
      myTickets.assignAll(tickets);
      
      // Auto-select active chat
      if (myTickets.isNotEmpty && activeTicket.value == null) {
        final active = myTickets.firstWhereOrNull(
          (t) => t.status != TicketStatus.closed,
        );
        
        if (active != null) {
          activeTicket.value = active;
          _listenToCurrentMessages(active.id);
        }
      }
      isLoading.value = false;
    });
  }

  void _listenToPersonalNotifications() {
    final uid = effectiveUserId;
    if (uid == 'anonymous') return;

    FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications')
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
        userId: effectiveUserId,
        userName: effectiveUserName,
        email: effectiveUserEmail,
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
    if (ticket == null) return;
    
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
        senderId: effectiveUserId,
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

      // Trigger AI Auto-reply
      if (text.isNotEmpty) {
        _handleAiAutoReply(ticket.id, text);
      }
    } catch (e) {
      _logger.e('Error sending message: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> sendDirectMessage(String text) async {
    final ticket = activeTicket.value;
    if (ticket == null) return;

    if (ticket.status == TicketStatus.closed) {
      Get.snackbar('Ticket Closed', 'This chat is closed and cannot receive new messages.');
      return;
    }

    try {
      isSubmitting.value = true;
      final message = SupportMessage(
        id: const Uuid().v4(),
        ticketId: ticket.id,
        senderId: effectiveUserId,
        senderType: 'user',
        message: text,
        imageUrl: null,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _repository.sendFirestoreMessage(ticket.id, message);
      _scrollToBottom();

      // Trigger AI Auto-reply
      _handleAiAutoReply(ticket.id, text);
    } catch (e) {
      _logger.e('Error sending message: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  void _handleAiAutoReply(String ticketId, String userMessage) async {
    final ticket = activeTicket.value;
    if (ticket == null) return;

    // Check if bot is disabled for this specific ticket or globally
    final settings = Get.find<SettingsController>();
    if (!settings.isLiveSupportBotEnabled.value || !ticket.isBotActive) {
      _logger.i('AI Auto-reply skipped: Global Bot=${settings.isLiveSupportBotEnabled.value}, Ticket Bot=${ticket.isBotActive}');
      return;
    }

    final msg = userMessage.toLowerCase();
    String? aiResponse;

    // 1. Try n8n Live Chat Webhook first
    final user = _authController.user.value;
    aiResponse = await _repository.sendToN8n(
      userMessage, 
      user?.uid ?? 'anonymous', 
      userName: user?.displayName
    );

    // 2. Fallback to local logic if n8n fails or returns empty
    if (aiResponse == null || aiResponse.isEmpty) {
      if (msg.contains('hello') || msg.contains('hi') || msg.contains('hey')) {
        aiResponse = 'আসসালামু আলাইকুম! আমি আপনার এআই (AI) অ্যাসিস্ট্যান্ট। আপনাকে কিভাবে সাহায্য করতে পারি?';
      } else if (msg.contains('help') || msg.contains('সাহায্য')) {
        aiResponse = 'অবশ্যই! আপনি কুরআন পড়া, নামাজের সময় দেখা বা কিবলা কম্পাস ব্যবহারের বিষয়ে সাহায্য চাইলে আমাকে বলতে পারেন।';
      } else if (msg.contains('prayer') || msg.contains('নামাজ')) {
        aiResponse = 'নামাজের সময়সূচী দেখতে হোম স্ক্রিন থেকে "নামাজ" বাটনে ক্লিক করুন। আপনার লোকেশন অনুযায়ী সময় দেখানো হবে।';
      } else if (msg.contains('quran') || msg.contains('কুরআন')) {
        aiResponse = 'আপনি অ্যাপের মূল পাতা থেকে "কুরআন" সেকশনে গিয়ে সব সূরা এবং পারা পড়তে পারবেন।';
      } else if (msg.contains('developer') || msg.contains('admin')) {
        aiResponse = 'আমাদের অ্যাডমিন শীঘ্রই আপনার সাথে যোগাযোগ করবেন। অনুগ্রহ করে আপনার সমস্যাটি বিস্তারিত লিখে রাখুন।';
      }
    }

    if (aiResponse != null && aiResponse.isNotEmpty) {
      // Simulate typing
      _repository.updateTypingStatus(ticketId, true, isAdmin: true);
      await Future.delayed(const Duration(seconds: 2));
      
      final aiMsg = SupportMessage(
        id: const Uuid().v4(),
        ticketId: ticketId,
        senderId: 'ai_assistant',
        senderType: 'admin',
        message: aiResponse,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _repository.sendFirestoreMessage(ticketId, aiMsg);
      _repository.updateTypingStatus(ticketId, false, isAdmin: true);
      _scrollToBottom();
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
    try {
      isSubmitting.value = true;
      _logger.i('Starting chat for UID: $effectiveUserId');
      
      final ticket = SupportTicket(
        id: '', 
        userId: effectiveUserId,
        userName: effectiveUserName,
        email: effectiveUserEmail,
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

  Future<void> closeActiveTicket() async {
    final ticket = activeTicket.value;
    if (ticket == null) return;

    try {
      isSubmitting.value = true;
      await _repository.updateStatus(ticket.id, TicketStatus.closed);
      
      // Send a system message that the chat is closed
      await _repository.sendFirestoreMessage(ticket.id, SupportMessage(
        id: const Uuid().v4(),
        ticketId: ticket.id,
        senderId: 'system',
        senderType: 'admin',
        message: 'এই চ্যাটটি বন্ধ করা হয়েছে। আপনার অন্য কোনো প্রশ্ন থাকলে নতুন চ্যাট শুরু করতে পারেন।',
        timestamp: DateTime.now(),
      ));
      
      Get.snackbar('Success', 'Chat closed successfully.');
    } catch (e) {
      _logger.e('Error closing ticket: $e');
      Get.snackbar('Error', 'Failed to close chat.');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> startNewChat() async {
    activeTicket.value = null;
    currentMessages.clear();
    await startInstantChat();
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
