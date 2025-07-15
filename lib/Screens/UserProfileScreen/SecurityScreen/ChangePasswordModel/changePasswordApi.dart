import 'package:dio/dio.dart';
import '../../../../util/apiConstants.dart';
import '../../../../util/auth_manager.dart';
import 'changePasswordModel.dart';


class ChangePasswordApi {
  final Dio _dio = Dio();

  ChangePasswordApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = AuthManager.getToken();
  }

  Future<ChangePasswordResponse> changePassword(String password, String confirmPassword) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.baseUrl}/user/change-password',
        data: {
          'new_passsword': password,
          'confirm_password': confirmPassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChangePasswordResponse.fromJson(response.data);
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
