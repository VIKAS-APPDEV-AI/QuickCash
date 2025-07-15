import 'package:dio/dio.dart';
import 'package:quickcash/Screens/SignupScreen/model/signup_model.dart';
import '../../../util/apiConstants.dart';

class SignUpApi {
  final Dio _dio = Dio();

  Future<SignUpResponse> signup(String name, String email, String password, String country, String referralCode) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/user/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'country': country,
          'referalCode': referralCode,
        },
      );

      // Check for both 200 and 201 statuses
      if (response.statusCode == 200 || response.statusCode == 201) {
        //print("Response data: ${response.data}"); // Debugging line
        return SignUpResponse.fromJson(response.data);
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
