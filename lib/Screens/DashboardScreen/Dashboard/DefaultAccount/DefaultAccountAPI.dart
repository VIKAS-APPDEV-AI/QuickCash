// services/account_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quickcash/Screens/DashboardScreen/Dashboard/DefaultAccount/DefaultAccountModel.dart';

class AccountService {
  static const String baseUrl =
      "https://quickcash.oyefin.com/api/v1/account/default";

  /// Fetch default account(s) for a given user id.
  static Future<List<Account>> fetchDefaultAccounts(String userId) async {
    final url = Uri.parse("$baseUrl/$userId");
    final response = await http.get(url);

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      List<dynamic> accountListJson = data['data'];
      return accountListJson.map((json) => Account.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load accounts");
    }
  }
}
