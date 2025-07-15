import 'package:dio/dio.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/PaymentQRCodeScreen/updateQrCodeScreen/model/updateQrCodeModel.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../../../util/apiConstants.dart';


class QrCodeUpdateApi {
  final Dio _dio = Dio();

  QrCodeUpdateApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = 'Bearer ${AuthManager.getToken()}'; // Ensure token is prefixed with "Bearer"

   /* _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
    ));*/

  }


  Future<QrCodeUpdateResponse> qrCodeUpdate(QrCodeUpdateRequest request, String? qrCodeID) async {
    try {
      final response = await _dio.patch(
        '/qrcode/update/$qrCodeID',
        data: request.toJson(),
      );

      // Check for a successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return QrCodeUpdateResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to update tax: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
