import 'package:dio/dio.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../../util/apiConstants.dart';
import 'invoiceTransactionModel.dart';

class InvoicesTransactionApi {
  final Dio _dio = Dio();

  InvoicesTransactionApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;


   /* _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
    ));*/
  }

  Future<InvoicesTransactionResponse> invoiceTransactionApi() async {
    try {
      final response = await _dio.get(
        '/manualPayment/transaction-list',
        options: Options(headers: {
          'Authorization': 'Bearer ${AuthManager.getToken()}',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return InvoicesTransactionResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch data: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
