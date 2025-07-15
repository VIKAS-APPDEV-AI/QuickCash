import 'package:dio/dio.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../util/apiConstants.dart';
import 'beneficiaryAccountModel.dart';

class BeneficiaryListApi {
  final Dio _dio = Dio();

  BeneficiaryListApi() {
    // Setting base options for Dio
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = AuthManager.getToken();
  }

  // Function to get the beneficiary list by ID
  Future<BeneficiaryListResponse> beneficiaryAccountListApi() async {
    try {
      // Construct the endpoint URL by appending the recipient ID to the base URL
      final response = await _dio.get(
        '/receipient/list/${AuthManager.getUserId()}', // This dynamically inserts the recipient ID into the URL
      );

      // Check if the response status is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return BeneficiaryListResponse.fromJson(response.data); // Parse the response data
      } else {
        throw Exception('Failed to fetch data: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // Catch Dio-specific errors
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      // Catch any other unexpected errors
      throw Exception('Unexpected error: $e');
    }
  }
}
