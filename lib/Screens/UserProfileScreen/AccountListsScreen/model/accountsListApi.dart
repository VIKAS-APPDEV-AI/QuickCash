import 'package:dio/dio.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../util/apiConstants.dart';
import 'accountsListModel.dart';

class AccountsListApi {
  final Dio _dio = Dio();

  AccountsListApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = AuthManager.getToken();
  }

  Future<AccountsListResponse> fetchAccounts() async {
   final userID = await AuthManager.getUserId();
    try {
      final response = await _dio.get(
        '/account/list/$userID',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AccountsListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch account list: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
