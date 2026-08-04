import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_urls.dart';
import '../../data/models/support_chat_model.dart';

class SupportApiProvider {
  final Dio _dio;
  final Logger _logger = Logger();

  Dio get dio => _dio;

  SupportApiProvider()
      : _dio = Dio(BaseOptions(
          baseUrl: AppUrls.backendBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': 'QuranApp/1.0.0 (Flutter Mobile)',
          },
        )) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => _logger.d(o.toString()),
    ));
  }

  /// Fetches a list of support tickets.
  Future<List<SupportTicket>> getTickets(
      {String? userId, String? status}) async {
    if (AppUrls.backendBaseUrl.contains('your-backend-api.com')) {
      _logger.w(
          '⚠️ API URL not configured! Please update backendBaseUrl in app_urls.dart');
      return [];
    }

    try {
      final response = await _dio.get(
        AppUrls.supportTickets,
        queryParameters: {
          if (userId != null) 'userId': userId,
          if (status != null) 'status': status,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => SupportTicket.fromJson(json)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    } catch (e) {
      return [];
    }
  }

  /// Submits a new support ticket.
  Future<SupportTicket> createTicket(SupportTicket ticket) async {
    try {
      final response = await _dio.post(
        AppUrls.supportTickets,
        data: ticket.toJson(),
      );
      if (response.statusCode == 201) {
        return SupportTicket.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to create support ticket: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error creating support ticket: $e');
      rethrow;
    }
  }

  /// Fetches messages for a specific support ticket.
  Future<List<SupportMessage>> getMessages(String ticketId) async {
    try {
      final url = AppUrls.supportMessages.replaceFirst('{ticketId}', ticketId);
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => SupportMessage.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch ticket messages: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error getting ticket messages: $e');
      rethrow;
    }
  }

  /// Sends a new message to a support ticket.
  Future<SupportMessage> sendMessage(
      String ticketId, SupportMessage message) async {
    try {
      final url = AppUrls.supportMessages.replaceFirst('{ticketId}', ticketId);
      final response = await _dio.post(
        url,
        data: message.toJson(),
      );
      if (response.statusCode == 201) {
        return SupportMessage.fromJson(response.data);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error sending ticket message: $e');
      rethrow;
    }
  }

  /// Updates the status of a support ticket.
  Future<void> updateTicketStatus(String ticketId, String status) async {
    try {
      final url =
          AppUrls.updateTicketStatus.replaceFirst('{ticketId}', ticketId);
      final response = await _dio.patch(
        url,
        data: {'status': status},
      );
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update ticket status: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error updating ticket status: $e');
      rethrow;
    }
  }

  /// Updates the priority of a support ticket.
  Future<void> updateTicketPriority(String ticketId, String priority) async {
    try {
      final url =
          '${AppUrls.supportTicketById.replaceFirst('{ticketId}', ticketId)}/priority';
      final response = await _dio.patch(
        url,
        data: {'priority': priority},
      );
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update ticket priority: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error updating ticket priority: $e');
      rethrow;
    }
  }

  /// Deletes a support ticket.
  Future<void> deleteTicket(String ticketId) async {
    try {
      final url =
          AppUrls.supportTicketById.replaceFirst('{ticketId}', ticketId);
      final response = await _dio.delete(url);
      if (response.statusCode != 204) {
        throw Exception(
            'Failed to delete support ticket: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error deleting support ticket: $e');
      rethrow;
    }
  }
}
