import 'package:dio/dio.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/TaxScreen/updateTaxDetailsScreen/model/taxUpdateModel.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../../../util/apiConstants.dart';


class TaxUpdateApi {
  final Dio _dio = Dio();

  TaxUpdateApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = 'Bearer ${AuthManager.getToken()}'; // Ensure token is prefixed with "Bearer"
  }


  Future<TaxUpdateResponse> taxUpdate(TaxUpdateRequest request, String? taxID) async {
    try {
      final response = await _dio.patch(
        '/tax/update/$taxID',
        data: request.toJson(),
      );

      // Check for a successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaxUpdateResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to update tax: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
