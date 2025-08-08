import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:quickcash/util/auth_manager.dart'; // Assuming this manages token

Future<void> uploadProfileImage(String filePath) async {
  final url = Uri.parse('https://quickcash.oyefin.com/api/v1/user/update-profile');
  final token = await AuthManager.getToken(); // Replace with your token method

  final request = http.MultipartRequest('PATCH', url)
    ..headers['Authorization'] = 'Bearer $token'
    ..headers['Accept'] = 'application/json';

  // Get file and its mime type
  File imageFile = File(filePath);
  final mimeType = lookupMimeType(imageFile.path)?.split('/');
  if (mimeType == null || mimeType.length != 2) {
    throw Exception("Invalid mime type");
  }

  // Attach the image file
  request.files.add(
    await http.MultipartFile.fromPath(
      'owner_profile', // 👈 Field name used by API for profile image
      imageFile.path,
      contentType: MediaType(mimeType[0], mimeType[1]),
      filename: basename(imageFile.path),
    ),
  );

  // Send the request
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    print("✅ Profile image uploaded successfully");
  } else {
    print("❌ Failed to upload image: ${response.statusCode}");
    print(response.body);
  }
}
