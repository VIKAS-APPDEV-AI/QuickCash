// LoadCardApi
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quickcash/util/apiConstants.dart';
import 'package:quickcash/util/auth_manager.dart';

class LoadCardApi {
  Future<Map<String, dynamic>> loadCardApi({
    required String sourceAccountId,
    required String cardId,
    required double amount,
    required double fee,
    required double conversionAmount, // new param
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/card/load-balance');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthManager.getToken()}', // Include token
      };
      final body = jsonEncode({
        'sourceAccountId': sourceAccountId,
        'cardId': cardId,
        'amount': amount,
        'fee': fee, // Assuming 1% fee, adjust as per backend
        'conversionAmount':
            conversionAmount, // Mock conversion, adjust as per backend
        'fromCurrency': fromCurrency,
        'toCurrency': toCurrency,
        'info': 'Wallet to Card Balance Load',
      });

      print('Request URL: $url');
      print('Request headers: $headers'); // Debug headers
      print('Request body: $body'); // Debug body

      final response = await http.post(url, headers: headers, body: body);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Debug response

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic>) {
          return responseData;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
            'Failed to load card: ${response.statusCode}. Details: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error loading card: $error');
    }
  }
}
