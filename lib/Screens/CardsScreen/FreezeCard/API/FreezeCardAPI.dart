  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:quickcash/util/apiConstants.dart';
  import 'package:quickcash/util/auth_manager.dart';

  
  class ToggleFreezeCardApi {
  Future<Map<String, dynamic>> toggleFreezeCardApi({
    required String cardId,
  }) async {
    try {
      final url =
          Uri.parse('${ApiConstants.baseUrl}/card/toggle-freeze-card/$cardId');
      final token = AuthManager.getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print('Request Time: ${DateTime.now()}');
      print('Request URL: $url');
      print('Request cardId: $cardId');
      print('Request Token: $token');

      final response = await http.patch(url, headers: headers);

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.trim().startsWith('<!doctype html>') ||
            response.body.contains('<html')) {
          print(
              'Warning: Received HTML response at ${DateTime.now()}. Full response: ${response.body}');
          throw Exception(
              'Received HTML response instead of JSON. Please verify the API endpoint (${url}) and contact the backend team.');
        }

        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic>) {
          return responseData;
        } else {
          throw Exception(
              'Invalid response format: Expected JSON object, got ${response.body}');
        }
      } else {
        throw Exception(
            'Failed to toggle card freeze status: ${response.statusCode}. Details: ${response.body}');
      }
    } catch (error) {
      print('Error details at ${DateTime.now()}: $error');
      throw Exception('Error toggling card freeze status: $error');
    }
  }
}
