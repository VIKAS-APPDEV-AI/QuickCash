// login_api.dart
import 'package:dio/dio.dart';
import '../../../util/apiConstants.dart';
import 'login_model.dart';

class LoginApi {
  final Dio _dio = Dio();

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/user/login',
        data: {
          'email': email,
          'password': password,
        },
        //options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("API Response Data: ${response.data}");

        if (response.data != null) {
          return LoginResponse.fromJson(response.data);
          
        } else {
          throw Exception('Unexpected error: Reponse Data is null');
        }
        //return LoginResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to login: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
