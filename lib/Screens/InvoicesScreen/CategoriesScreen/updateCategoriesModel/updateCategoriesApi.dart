import 'package:dio/dio.dart';
import 'package:quickcash/Screens/InvoicesScreen/CategoriesScreen/updateCategoriesModel/updateCategoriesModel.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../../util/apiConstants.dart';

class UpdateCategoriesApi {
  final Dio _dio = Dio();

  UpdateCategoriesApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = 'Bearer ${AuthManager.getToken()}'; // Ensure token is prefixed with "Bearer"
  }


  Future<UpdateCategoriesResponse> updateCategory(UpdateCategoriesRequest request, String? categoryID) async {
    try {
      final response = await _dio.patch(
        '/category/update/$categoryID',
        data: request.toJson(),
      );

      // Check for a successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UpdateCategoriesResponse.fromJson(response.data);
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
