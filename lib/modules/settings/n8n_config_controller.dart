import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_keys.dart';

class N8nConfigController extends GetxController {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController toolNameController = TextEditingController();
  final TextEditingController testMessageController = TextEditingController();

  final RxBool useMcp = false.obs;
  final RxBool isLoading = true.obs;
  
  // Test Connection States
  final RxBool isTesting = false.obs;
  final RxnInt testResultStatus = RxnInt();
  final RxString testResultText = ''.obs;
  final RxString testResultDetails = ''.obs;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  @override
  void onInit() {
    super.onInit();
    loadConfig();
    
    // Auto-toggle MCP option based on URL path when user types
    urlController.addListener(_onUrlChanged);
  }

  @override
  void onClose() {
    urlController.removeListener(_onUrlChanged);
    urlController.dispose();
    apiKeyController.dispose();
    toolNameController.dispose();
    testMessageController.dispose();
    super.onClose();
  }

  void _onUrlChanged() {
    final text = urlController.text;
    if (text.isNotEmpty) {
      final isWebhook = text.contains('/webhook/') || text.contains('/webhook-test/');
      useMcp.value = !isWebhook;
    }
  }

  Future<void> loadConfig() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      
      final url = prefs.getString('n8n_url') ?? 'https://islansourav.app.n8n.cloud/webhook/chat';
      final apiKey = prefs.getString('n8n_api_key') ?? AppKeys.n8nApiKey;
      final toolName = prefs.getString('n8n_tool_name') ?? AppKeys.n8nToolName;
      final savedUseMcp = prefs.getBool('n8n_use_mcp');

      urlController.text = url;
      apiKeyController.text = apiKey == 'your_n8n_api_key_here' ? '' : apiKey;
      toolNameController.text = toolName;
      
      if (savedUseMcp != null) {
        useMcp.value = savedUseMcp;
      } else {
        useMcp.value = !url.contains('/webhook');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load configuration: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('n8n_url', urlController.text.trim());
      
      final apiKeyValue = apiKeyController.text.trim();
      await prefs.setString('n8n_api_key', apiKeyValue.isEmpty ? 'your_n8n_api_key_here' : apiKeyValue);
      await prefs.setString('n8n_tool_name', toolNameController.text.trim());
      await prefs.setBool('n8n_use_mcp', useMcp.value);
      
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to save configuration: $e');
      return false;
    }
  }

  Future<void> testConnection() async {
    final testMsg = testMessageController.text.trim();
    if (testMsg.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter a test message to send',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final url = urlController.text.trim();
    if (url.isEmpty || !Uri.parse(url).isAbsolute) {
      Get.snackbar(
        'Invalid URL',
        'Please enter a valid HTTP/HTTPS URL',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isTesting.value = true;
      testResultStatus.value = null;
      testResultText.value = 'Connecting...';
      testResultDetails.value = '';

      final apiKey = apiKeyController.text.trim();
      final toolName = toolNameController.text.trim();

      final Map<String, dynamic> requestData;
      if (useMcp.value) {
        requestData = {
          'jsonrpc': '2.0',
          'method': 'tools/call',
          'params': {
            'name': toolName,
            'arguments': {
              'message': testMsg,
              'userId': 'test_user_id',
              'userName': 'Test Developer',
              'platform': 'flutter_dev',
              'timestamp': DateTime.now().toIso8601String(),
            },
          },
          'id': 1,
        };
      } else {
        requestData = {
          'message': testMsg,
          'userId': 'test_user_id',
          'userName': 'Test Developer',
          'platform': 'flutter_dev',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }

      final Map<String, dynamic> headers = {
        'Content-Type': 'application/json',
      };
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
        headers['X-N8N-API-KEY'] = apiKey;
      }

      // Capture request info for details
      final reqJson = const JsonEncoder.withIndent('  ').convert({
        'url': url,
        'headers': {
          ...headers,
          if (apiKey.isNotEmpty) 'Authorization': 'Bearer ****${apiKey.substring(apiKey.length > 4 ? apiKey.length - 4 : 0)}',
          if (apiKey.isNotEmpty) 'X-N8N-API-KEY': '****${apiKey.substring(apiKey.length > 4 ? apiKey.length - 4 : 0)}',
        },
        'body': requestData,
      });

      testResultDetails.value = '>>> SENT REQUEST\n$reqJson\n\n';

      final response = await _dio.post(
        url,
        options: Options(headers: headers, validateStatus: (status) => true),
        data: requestData,
      );

      testResultStatus.value = response.statusCode;
      
      final resJson = const JsonEncoder.withIndent('  ').convert(response.data);
      testResultDetails.value += '<<< RECEIVED RESPONSE (HTTP ${response.statusCode})\n$resJson';

      if (response.statusCode == 200) {
        final data = response.data;
        String? parsedMsg;

        if (data != null) {
          if (data is List) {
            if (data.isNotEmpty) {
              final first = data.first;
              if (first is Map) {
                parsedMsg = first['response'] ?? first['output'] ?? first['text'] ?? first['message'] ?? first['reply'];
              } else {
                parsedMsg = first.toString();
              }
            }
          } else if (data is String) {
            parsedMsg = data;
          } else if (data is Map) {
            if (data['result'] != null && data['result']['content'] is List) {
              final contentList = data['result']['content'] as List;
              if (contentList.isNotEmpty) {
                final textItem = contentList.firstWhere(
                  (item) => item is Map && item['type'] == 'text',
                  orElse: () => null,
                );
                if (textItem != null && textItem['text'] != null) {
                  parsedMsg = textItem['text'].toString();
                }
              }
            }
            parsedMsg ??= data['response'] ?? data['output'] ?? data['text'] ?? data['message'] ?? data['reply'];
          }
        }

        if (parsedMsg != null) {
          testResultText.value = parsedMsg;
        } else {
          testResultText.value = 'Connected successfully, but could not parse response text from keys (response/output/text/message/reply). See raw response details.';
        }
      } else {
        testResultText.value = 'Server returned error status code: ${response.statusCode}';
      }
    } catch (e) {
      testResultStatus.value = 500;
      testResultText.value = 'Network Error: $e';
      testResultDetails.value += '<<< ERROR OCCURRED\n$e';
    } finally {
      isTesting.value = false;
    }
  }
}
