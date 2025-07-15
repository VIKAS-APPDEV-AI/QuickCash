import 'package:dio/dio.dart';
import 'package:quickcash/Screens/TransactionScreen/TransactionDetailsScreen/model/transactionDetailsModel.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../util/apiConstants.dart';

class TransactionDetailsListApi {
  final Dio _dio = Dio();

  TransactionDetailsListApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  Future<TransactionDetailsListResponse> transactionDetailsListApi(String trxID) async {
    try {
      final response = await _dio.get(
        '/transaction/tapi/$trxID',
        options: Options(headers: {
          'Authorization': 'Bearer ${AuthManager.getToken()}',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Ensure response is a Map<String, dynamic>
        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;

          // Check if 'data' exists and is a non-empty list
          if (responseData.containsKey('data') &&
              responseData['data'] is List &&
              (responseData['data'] as List).isNotEmpty) {
            return TransactionDetailsListResponse.fromJson(responseData);
          }
        }
        // Return empty response if no valid data
        return TransactionDetailsListResponse();
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
