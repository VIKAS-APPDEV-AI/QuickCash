import 'package:dio/dio.dart';
import 'package:quickcash/util/apiConstants.dart';
import 'package:quickcash/util/auth_manager.dart';

import 'buyAndSellListModel.dart';


class CryptoListApi {
  final Dio _dio = Dio();

  CryptoListApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;


   /* _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
    ));*/
  }

  Future<CryptoListResponse> cryptoListApi() async {
    try {
      final response = await _dio.get(
        '/crypto/list/${AuthManager.getUserId()}',
        options: Options(headers: {
          'Authorization': 'Bearer ${AuthManager.getToken()}',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CryptoListResponse.fromJson(response.data);
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
