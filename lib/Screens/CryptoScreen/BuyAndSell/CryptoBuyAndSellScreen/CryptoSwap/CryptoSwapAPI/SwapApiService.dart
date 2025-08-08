// API Service Class
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickcash/util/apiConstants.dart';
import 'package:quickcash/util/auth_manager.dart';

class CryptoApiService {
  Future<List<Map<String, String>>> fetchSwapCoins() async {
    try {
      final token = await AuthManager.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/crypto/fetchswapcoins'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('fetchSwapCoins response status: ${response.statusCode}');
      print('fetchSwapCoins response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data is Map && data['success'] == true && data['data'] is List) {
          return List<Map<String, String>>.from(
            data['data'].map((item) => {
                  'coin': item['coin'].toString(),
                  'logoName': item['logoName'].toString(),
                }),
          );
        }
        throw Exception('Invalid response format');
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests: Please try again later');
      }
      throw Exception('Failed to fetch swap coins: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching swap coins: $e');
    }
  }

  Future<Map<String, dynamic>> convertCoin({
    required String fromCoin,
    required String toCoin,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/crypto/convert-coin'),
        headers: {
          'Authorization': 'Bearer ${AuthManager.getToken()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fromCoin': fromCoin,
          'toCoin': toCoin,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map &&
            data['success'] == true &&
            data['conversion'] != null) {
          return {
            'rate': data['conversion']['rate']?.toString() ?? '0',
            'coinsDeducted':
                data['conversion']['coinsDeducted']?.toString() ?? '0',
            'coinsAdded': data['conversion']['coinsAdded']?.toString() ?? '0',
          };
        }
        throw Exception('Invalid conversion response format');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied: Invalid or expired token');
      }
      throw Exception('Failed to convert coin: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error converting coin: $e');
    }
  }

  Future<Map<String, dynamic>>updateSwap({
    required String userId,
    required String fromCoin,
    required String toCoin,
    required String coinsDeducted,
    required String coinsAdded,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/crypto/updateswap'),
      headers: {
        'Authorization': 'Bearer ${AuthManager.getToken()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'fromCoin': fromCoin,
        'toCoin': toCoin,
        'coinsDeducted': coinsDeducted,
        'coinsAdded': coinsAdded,
      }),
    );

    print('updateSwap status: ${response.statusCode}');
    print('updateSwap body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    }
    throw Exception('Failed to update swap: ${response.statusCode} -${response.body}');
  }
}

class CustomSnackBar {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}
