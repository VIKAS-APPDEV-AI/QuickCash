import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img; // Image processing package
import 'package:quickcash/Screens/InvoicesScreen/ClientsScreen/EditClientsFormScreen/model/updateClientsModel.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../../../util/apiConstants.dart';

class ClientUpdateApi {
  final Dio _dio = Dio();

  ClientUpdateApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = 'Bearer ${AuthManager.getToken()}';

    /*_dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
    ));*/
  }

  /// Compresses an image to reduce its size before upload
  Future<File> compressImage(File imageFile) async {
    final image = img.decodeImage(imageFile.readAsBytesSync());
    final resizedImage = img.copyResize(image!, width: 800); // Adjust dimensions
    final compressedImage = File(imageFile.path)..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 80));
    return compressedImage;
  }

  Future<ClientUpdateResponse> clientUpdate(ClientUpdateRequest request, clientsID) async {
    try {
      // Compress the image if it exists
      File? compressedImage;
      if (request.profilePhoto != null) {
        compressedImage = await compressImage(request.profilePhoto!);
      }

      // Create FormData for the multipart request
      final formData = FormData.fromMap({
        ...request.toJson(),
        if (compressedImage != null)
          'profilePhoto': await MultipartFile.fromFile(
            compressedImage.path,
            filename: compressedImage.path.split('/').last,
          ),
      });

      /*// Log payload size
      final payloadSize = formData.toString().length / 1024; // Size in KB
      print("Payload size: ${payloadSize.toStringAsFixed(2)} KB");
*/
      final response = await _dio.patch(
        '/client/update/$clientsID',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ClientUpdateResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to Update Clients: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 413) {
        throw Exception(
            'Request entity too large. Try reducing the image size or data.');
      }
      throw Exception('Dio error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}




/*
import 'package:dio/dio.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../../util/apiConstants.dart';
import 'updateClientsModel.dart';

class ClientUpdateApi {
  final Dio _dio = Dio();

  ClientUpdateApi() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.headers['Authorization'] = 'Bearer ${AuthManager.getToken()}'; // Ensure token is prefixed with "Bearer"
  }


  Future<ClientUpdateResponse> clientUpdate(ClientUpdateRequest request, String? clientsID) async {
    try {
      final response = await _dio.patch(
        '/client/update/$clientsID',
        data: request.toJson(),
      );

      // Check for a successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ClientUpdateResponse.fromJson(response.data);
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
*/
