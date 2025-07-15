import 'package:dio/dio.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../../util/apiConstants.dart';
import 'cryptoSellFetchCoinPriceModel.dart';

class CryptoSellFetchCoinPriceApi {
  final Dio _dio = Dio();

  CryptoSellFetchCoinPriceApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = 'Bearer ${AuthManager.getToken()}';


     /*_dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
    ));*/
  }


  Future<CryptoSellFetchCoinPriceResponse> cryptoSellFetchCoinPriceApi(CryptoSellFetchCoinPriceRequest request) async {
    try {
      final response = await _dio.post(
        '/crypto/fetch-symbolprice',
        data: request.toJson(),
      );

      // Check for a successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CryptoSellFetchCoinPriceResponse.fromJson(response.data);
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
