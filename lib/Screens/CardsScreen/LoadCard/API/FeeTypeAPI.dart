import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quickcash/util/apiConstants.dart';
import 'package:quickcash/util/auth_manager.dart';

class FeeTypeApi {
  Future<double> getDepositFeePercent() async {
    try {
      final url = Uri.parse(
          '${ApiConstants.baseUrl}/admin/feetype/type?type=Deposit');
      final headers = {
        'Content-Type': 'application/json',
       // 'Authorization': 'Bearer ${AuthManager.getToken()}',
      };
      final response = await http.get(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {

        final data = jsonDecode(response.body);
        final feeList = data['data'] as List<dynamic>;

        if (feeList.isNotEmpty &&
            feeList[0]['feedetails'] != null &&
            feeList[0]['feedetails'].isNotEmpty) {
          final feeDetail = feeList[0]['feedetails'][0];
          final feeValue = feeDetail['value'] ?? 0.0;

          print('🎯 Deposit Fee from backend: $feeValue%');
          return double.tryParse(feeValue.toString()) ?? 0.0;
        } else {
          throw Exception('No fee details found');
        }
      } else {
        throw Exception('Failed to fetch deposit fee. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ FeeTypeApi Error: $e');
      throw Exception('Fee API error: $e');
    }
  }
}
