import 'dart:io';

import 'package:dio/dio.dart';
import 'package:quickcash/Screens/TicketsScreen/chatHistoryScreen/replyModel/chatReplyModel.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../util/apiConstants.dart';

class ChatReplyApi {
  final Dio _dio = Dio();

  ChatReplyApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = 'Bearer ${AuthManager.getToken()}'; // Ensure token is prefixed with "Bearer"
  }

  Future<ChatReplyResponse> replyTicket({
    required String support,
    required String user,
    required String message,
    required String from,
    required String to,
    File? attachment, // Optional attachment file
  }) async {
    try {
      // Create FormData to hold the request data
      FormData formData = FormData.fromMap({
        'support': support,
        'user': user,
        'message': message,
        'from': from,
        'to': to,
        // If there's an attachment, add it as a MultipartFile
       // if (attachment != null) 'attachment': await MultipartFile.fromFile(attachment.path),
      });

      // Make the request
      final response = await _dio.post(
        '/support/replyticket',
        data: formData,
      );

      // Check for successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChatReplyResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to send ticket reply: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
