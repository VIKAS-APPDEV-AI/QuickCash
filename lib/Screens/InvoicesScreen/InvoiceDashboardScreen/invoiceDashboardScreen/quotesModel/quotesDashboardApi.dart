import 'package:dio/dio.dart';
import 'package:quickcash/Screens/InvoicesScreen/InvoiceDashboardScreen/invoiceDashboardScreen/quotesModel/quotesDashboardModel.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../../util/apiConstants.dart';

class QuotesDashboardApi {
  final Dio _dio = Dio();

  QuotesDashboardApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;


    /*_dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
    ));*/
  }

  Future<QuotesDashboardResponse> quotesDashboardApi() async {
    try {
      final response = await _dio.get(
        '/invoice/dashboard/quote',
        options: Options(headers: {
          'Authorization': 'Bearer ${AuthManager.getToken()}',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return QuotesDashboardResponse.fromJson(response.data);
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
