import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../util/apiConstants.dart';
import '../../../../util/auth_manager.dart';
import 'changePasswordModel.dart';

class NewChangePasswordApi {
  final Dio _dio = Dio();

  NewChangePasswordApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    // _setAuthorizationHeader();
    //_dio.options.headers['Authorization'] = AuthManager.getToken();
  }

  // Method to asynchronously set the Authorization header
  // Future<void> _setAuthorizationHeader() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('authToken'); // Replace 'authToken' with your actual key
  //   if (token != null) {
  //     _dio.options.headers['Authorization'] = 'Bearer $token';
  //   } else {
  //     // Handle the case where token is not found (e.g., log out the user, throw an error)
  //     print("Token not found");
  //   }
  
  Future<ChangePasswordResponse> changePassword(
      String token, String password) async {
    try {

       print("Token being sent to the API: $token");
       
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/user/reset-password',
        data: {
          'token': token,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        
        print(response);
        print(token);
        return ChangePasswordResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to authenticate user: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
