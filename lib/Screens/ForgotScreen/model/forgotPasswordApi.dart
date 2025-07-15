import 'package:dio/dio.dart';
import 'package:quickcash/Screens/ForgotScreen/model/newForgotPassword.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../util/apiConstants.dart';
import 'forgot_password_model.dart';

class ForgotPasswordApi {
  final Dio _dio = Dio();

  Future<NewForgotPasswordResponse> forgotPassword(
    String email,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/user/forget-password-mobile',
        data: {
          'email': email,
        },
      );

      // Check for both 200 and 201 statuses
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Response data: ${response.data}"); // Debugging line

        final forgotPasswordResponse = NewForgotPasswordResponse.fromJson(response.data);

        // Debug the parsed response message
        print("Parsed Response Message: ${forgotPasswordResponse.message}");

        final token = response.data['token'];

        final message = response.data['message'];

        final prefs2 = await SharedPreferences.getInstance();
        await prefs2.setString('message', message);
        print("Message saved: $message");

        // Save the token in SharedPreferences
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
          print("Token saved: $token"); // Debugging line
        } else {
          print("Token not found in response");
        }
        return NewForgotPasswordResponse();
      } else {
        throw Exception('Failed to register: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
