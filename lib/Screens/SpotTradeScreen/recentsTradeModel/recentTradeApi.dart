import 'package:dio/dio.dart';
import 'package:quickcash/Screens/SpotTradeScreen/recentsTradeModel/recentTradeModel.dart';
import 'package:quickcash/util/auth_manager.dart';

import '../../../../../util/apiConstants.dart';

class RecentTradeApi {
  final Dio _dio = Dio();

  RecentTradeApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;

    /*_dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
    ));*/
  }

  Future<RecentTradeResponse> recentTradeApi() async {
    try {
      final response = await _dio.get(
        '/user/getRecentTrades',
        options: Options(headers: {
          'Authorization': 'Bearer ${AuthManager.getToken()}',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RecentTradeResponse.fromJson(response.data);
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
