import 'package:dio/dio.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../util/apiConstants.dart';
import 'accountsListModel.dart';

class AccountsListApi {
  final Dio _dio = Dio();

  AccountsListApi() {
    // Setting base options for Dio
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = AuthManager.getToken();
  }

  Future<AccountsListResponse> accountListApi() async {
    try {
      final response = await _dio.post(
        '/user/auth',
      );

      // Check for a successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AccountsListResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to authenticate user: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
