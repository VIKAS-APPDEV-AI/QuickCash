import 'package:dio/dio.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../../util/apiConstants.dart';
import 'addManualPaymentModel.dart';

class AddManualPaymentApi {
  final Dio _dio = Dio();

  AddManualPaymentApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = 'Bearer ${AuthManager.getToken()}'; // Ensure token is prefixed with "Bearer"

   /* _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
    ));*/

  }


  Future<AddManualPaymentResponse> addManualPayment(AddManualPaymentRequest request) async {
    try {
      final response = await _dio.post(
        '/manualPayment/add',
        data: request.toJson(),
      );

      // Check for a successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddManualPaymentResponse.fromJson(response.data);
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
