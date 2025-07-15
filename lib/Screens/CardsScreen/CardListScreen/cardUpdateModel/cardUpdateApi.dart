import 'package:dio/dio.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../util/apiConstants.dart';
import 'cardUpdateModel.dart';

class CardUpdateApi {
  final Dio _dio = Dio();

  CardUpdateApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = 'Bearer ${AuthManager.getToken()}';


    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
    ));
  }


  Future<CardUpdateResponse> cardUpdate(CardUpdateRequest request, cardId) async {
    try {
      final response = await _dio.patch(
        '/card/updateapp/$cardId',
        data: request.toJson(),
      );

      // Check for a successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CardUpdateResponse.fromJson(response.data);
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
