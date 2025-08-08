import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/CryptoBuyAndSellScreen/CryptoSwap/CryptoSwapModel/ConvertCoinModel.dart';
import 'package:quickcash/util/apiConstants.dart';

Future<ConvertCoinResponse?> convertCoin(ConvertCoinRequest request) async {
  final url = Uri.parse("${ApiConstants.baseUrl}/crypto/convert-coin");
  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return ConvertCoinResponse.fromJson(jsonData);
    } else {
      print("API error: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Exception during conversion: $e");
    return null;
  }
}
