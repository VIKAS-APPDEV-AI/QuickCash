
class QrCodeUpdateRequest {
  final String userId;
  final String title;
  final String type;
 // final File qrCodeImage;


  QrCodeUpdateRequest({
    required this.userId,
    required this.title,
    required this.type,
  //  required this.qrCodeImage,

  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'title': title,
      'isDefault': type,
    //  'qrCodeImage': qrCodeImage,
    };
  }
}


class QrCodeUpdateResponse {
  final String? message;

  QrCodeUpdateResponse({
    this.message,

  });

  factory QrCodeUpdateResponse.fromJson(Map<String, dynamic> json) {
    return QrCodeUpdateResponse(
      message: json['message'] as String?,
    );
  }
}
