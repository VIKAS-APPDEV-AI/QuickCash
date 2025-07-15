import 'package:dio/dio.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../../util/apiConstants.dart';
import 'cryptoSellFetchCoinModel.dart';

class CryptoSellFetchCoinDataApi {
  final Dio _dio = Dio();

  CryptoSellFetchCoinDataApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;

    /*_dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
    ));*/
  }

  Future<CryptoSellResponse> cryptoSellFetchCoinDataApi(String coinType) async {
    try {
      final response = await _dio.get(
        '/crypto/fetch-coins/$coinType',
        options: Options(headers: {
          'Authorization': 'Bearer ${AuthManager.getToken()}',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CryptoSellResponse.fromJson(response.data);
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
