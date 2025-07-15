import 'package:dio/dio.dart';
import '../../../util/apiConstants.dart';
import '../../../util/auth_manager.dart';
import 'addCardModel.dart';

class AddCardApi {
  final Dio _dio = Dio();

  AddCardApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = AuthManager.getToken();

    /*_dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
    ));*/
  }

  Future<AddCardResponse> addCardApi(String userId, String name, String currency) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/card/add-app',
        data: {
          'user': userId,
          'name': name,
          'currency': currency,
        },
      );

      // Check for both 200 and 201 statuses
      if (response.statusCode == 200 || response.statusCode == 201) {
        //print("Response data: ${response.data}"); // Debugging line
        return AddCardResponse.fromJson(response.data);
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
