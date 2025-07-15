import 'package:dio/dio.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/TransactionList/transactionListModel.dart';

import '../../../../util/apiConstants.dart';
import '../../../../util/auth_manager.dart';


class AccountListTransactionApi {
  final Dio _dio = Dio();

  Future<TransactionListResponse> accountListTransaction(String accountId,String currency, String useId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/transaction/account',
        options: Options(headers: {
          'Authorization': 'Bearer ${AuthManager.getToken()}',
        }),
        data: {
          'account': accountId,
          'currency': currency,
          'user_id': useId,
        },
      );

      // Check for both 200 and 201 statuses
      if (response.statusCode == 200 || response.statusCode == 201) {
        //print("Response data: ${response.data}"); // Debugging line
        return TransactionListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to register: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
