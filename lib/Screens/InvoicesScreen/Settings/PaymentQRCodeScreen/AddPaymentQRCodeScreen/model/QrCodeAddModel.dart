import 'dart:io';

class QrCodeAddRequest {
  final String userId;
  final String title;
  final String type;
  final File? qrCodeImage; // Add this

  QrCodeAddRequest({
    required this.userId,
    required this.title,
    required this.type,
    this.qrCodeImage, // Optional for now
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'title': title,
      'isDefault': type,
    };
  }
}



class QrCodeAddResponse {
  final String? message;

  QrCodeAddResponse({
    this.message,

  });

  factory QrCodeAddResponse.fromJson(Map<String, dynamic> json) {
    return QrCodeAddResponse(
      message: json['message'] as String?,
    );
  }
}
