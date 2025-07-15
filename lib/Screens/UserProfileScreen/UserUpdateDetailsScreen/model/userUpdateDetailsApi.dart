import 'package:dio/dio.dart';
import 'package:quickcash/Screens/UserProfileScreen/UserUpdateDetailsScreen/model/userUpdateDetailsModel.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../util/apiConstants.dart';

class UserProfileUpdateApi {
  final Dio _dio = Dio();

  UserProfileUpdateApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = 'Bearer ${AuthManager.getToken()}'; // Ensure token is prefixed with "Bearer"
  }


  Future<UserProfileUpdateResponse> userProfileUpdate(UserProfileUpdateRequest request) async {
    try {
      final response = await _dio.patch(
        '/user/update-profile',
        data: request.toJson(),
      );

      // Check for a successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserProfileUpdateResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to update profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
