import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img; // Image processing package
import 'package:quickcash/util/auth_manager.dart';
import '../../../../../../util/apiConstants.dart';
import 'kycUpdateModel.dart';

class KycUpdateApi {
  final Dio _dio = Dio();

  KycUpdateApi() {
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

  Future<KycUpdateResponse> kycUpdateApi(KycUpdateRequest request, kycId) async {
    try {
      // Compress the image if it exists
      File? documentPhotoFront;
      if (request.documentPhotoFront != null) {
        documentPhotoFront = await compressImage(request.documentPhotoFront!);
      }

      File? documentPhotoBack;
      if (request.documentPhotoBack != null) {
        documentPhotoBack = await compressImage(request.documentPhotoBack!);
      }

      File? addressProofPhoto;
      if (request.addressProofPhoto != null) {
        addressProofPhoto = await compressImage(request.addressProofPhoto!);
      }

      // Create FormData for the multipart request
      final formData = FormData.fromMap({
        ...request.toJson(), // Include other fields from the request
        if (documentPhotoFront != null)
          'documentPhotoFront': await MultipartFile.fromFile(
            documentPhotoFront.path,
            filename: documentPhotoFront.path.split('/').last,
          ),
        if (documentPhotoBack != null)
          'documentPhotoBack': await MultipartFile.fromFile(
            documentPhotoBack.path,
            filename: documentPhotoBack.path.split('/').last,
          ),
        if (addressProofPhoto != null)
          'addressProofPhoto': await MultipartFile.fromFile(
            addressProofPhoto.path,
            filename: addressProofPhoto.path.split('/').last,
          ),
      });

      // Send a single PATCH request with all images and form data
      final response = await _dio.patch(
        '/kyc/update/$kycId',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return KycUpdateResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to Update Settings: ${response.statusMessage}');
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
