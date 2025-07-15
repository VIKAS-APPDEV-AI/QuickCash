import 'package:dio/dio.dart';

import 'CurrencyExchangeModel.dart';
class ExchangeCurrencyApiNew {
  final Dio _dio = Dio();

  ExchangeCurrencyApiNew() {
    _dio.options.baseUrl =
        'https://currency-converter18.p.rapidapi.com/api/v1';
    _dio.options.headers = {
      'X-RapidAPI-Key': '311afaeddamshd77a2f8d6e0aac1p1cdfc8jsnafcf611ee45f', // Replace with your actual API key
      'X-RapidAPI-Host': 'currency-converter18.p.rapidapi.com',
      'Content-Type': 'application/json',
    };
  }

  Future<ExchangeResponse> exchangeCurrencyApiNew(
      ExchangeCurrencyRequestnew request) async {
    try {
      final response = await _dio.get(
        '/convert',
        queryParameters: request.toJson(),
      );

      if (response.statusCode == 200) {
        return ExchangeResponse.fromJson(response.data);
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