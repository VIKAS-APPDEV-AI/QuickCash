import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img; // Image processing package
import 'package:quickcash/util/auth_manager.dart';
import '../../../../../../util/apiConstants.dart';
import 'documentsUpdateModel.dart';

class DocumentUpdateApi {
  final Dio _dio = Dio();

  DocumentUpdateApi() {
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

  Future<UpdateDocumentResponse> updateDocumentApi(UpdateDocumentRequest request) async {
    try {
      // Compress the image if it exists
      File? compressedImage;
      if (request.docImage != null) {
        compressedImage = await compressImage(request.docImage!);
      }

      // Create FormData for the multipart request
      final formData = FormData.fromMap({
        ...request.toJson(),
        if (compressedImage != null)
          'ownerbrd': await MultipartFile.fromFile(
            compressedImage.path,
            filename: compressedImage.path.split('/').last,
          ),
      });

      /*// Log payload size
      final payloadSize = formData.toString().length / 1024; // Size in KB
      print("Payload size: ${payloadSize.toStringAsFixed(2)} KB");
*/
      final response = await _dio.patch(
        '/user/update-profile',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UpdateDocumentResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to Update Document: ${response.statusMessage}');
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
