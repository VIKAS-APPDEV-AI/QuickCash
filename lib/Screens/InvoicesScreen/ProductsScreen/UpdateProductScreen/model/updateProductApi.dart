import 'package:dio/dio.dart';
import 'package:quickcash/Screens/InvoicesScreen/ProductsScreen/UpdateProductScreen/model/updateProductModel.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../../util/apiConstants.dart';

class UpdateProductApi {
  final Dio _dio = Dio();

  UpdateProductApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = 'Bearer ${AuthManager.getToken()}'; // Ensure token is prefixed with "Bearer"

    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
    ));

  }


  Future<UpdateProductResponse> updateProduct(UpdateProductRequest request, String? productID) async {
    try {
      final response = await _dio.patch(
        '/product/update/$productID',
        data: request.toJson(),
      );

      // Check for a successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UpdateProductResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to update product: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
