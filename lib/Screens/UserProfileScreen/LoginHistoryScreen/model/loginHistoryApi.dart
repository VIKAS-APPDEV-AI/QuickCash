import 'package:dio/dio.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../util/apiConstants.dart';
import 'loginHistoryModel.dart';


class LoginHistoryApi {
  final Dio _dio = Dio();

  LoginHistoryApi() {
    // Setting base options for Dio
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = AuthManager.getToken();
  }

  // Function to get the beneficiary list by ID
  Future<LoginHistoryResponse> loginHistoryListApi() async {
    try {
      // Construct the endpoint URL by appending the recipient ID to the base URL
      final response = await _dio.get(
        '/session/getusersession/${AuthManager.getUserId()}', // This dynamically inserts the recipient ID into the URL
      );

      // Check if the response status is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginHistoryResponse.fromJson(response.data); // Parse the response data
      } else {
        throw Exception('Failed to fetch data: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // Catch Dio-specific errors
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      // Catch any other unexpected errors
      throw Exception('Unexpected error: $e');
    }
  }
}
