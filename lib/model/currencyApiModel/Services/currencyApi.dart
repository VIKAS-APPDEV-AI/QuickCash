import 'package:dio/dio.dart';
import 'package:quickcash/model/currencyApiModel/Model/currencyModel.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../util/apiConstants.dart';

class CurrencyApi {
  final Dio _dio = Dio();

  CurrencyApi() {
    // Setting base options for Dio
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = AuthManager.getToken();
  }

  Future<CurrencyResponse> currencyApi() async {
    try {
      final response = await _dio.get(
        '/currency/list',
      );

      // Check for a successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CurrencyResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to authenticate user: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
