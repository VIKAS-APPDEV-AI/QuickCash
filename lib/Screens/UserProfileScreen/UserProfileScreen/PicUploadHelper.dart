import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:quickcash/util/auth_manager.dart';

Future<File?> cropImage(File imageFile) async {
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressFormat: ImageCompressFormat.jpg,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.deepPurple,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      IOSUiSettings(title: 'Crop Image')
    ],
  );

  if (croppedFile != null) {
    return File(croppedFile.path);
  }

  return null;
}

Future<void> uploadProfileImage(File imageFile) async {
  final token = await AuthManager.getToken(); // Replace with your method
  final url = Uri.parse('https://quickcash.oyefin.com/api/v1/user/update-profile');

  final request = http.MultipartRequest('PATCH', url)
    ..headers['Authorization'] = 'Bearer $token'
    ..headers['Accept'] = 'application/json';

  final mimeTypeData = lookupMimeType(imageFile.path)?.split('/');
  if (mimeTypeData == null || mimeTypeData.length != 2) return;

  request.files.add(
    await http.MultipartFile.fromPath(
      'owner_profile',
      imageFile.path,
      contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      filename: basename(imageFile.path),
    ),
  );

  final response = await request.send();
  if (response.statusCode == 200) {
    print('✅ Image uploaded successfully');
  } else {
    print('❌ Upload failed: ${response.statusCode}');
  }
}
