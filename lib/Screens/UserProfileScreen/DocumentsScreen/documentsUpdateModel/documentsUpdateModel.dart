import 'dart:io';

class UpdateDocumentRequest {
  final String userId;
  final String documentsType;
  final String documentNo;

  final File? docImage; // Add this

  UpdateDocumentRequest({
    required this.userId,
    required this.documentsType,
    required this.documentNo,
    this.docImage, // Optional for now
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'owneridofindividual': documentsType,
      'ownertaxid': documentNo,
    };
  }
}



class UpdateDocumentResponse {
  final String? message;

  UpdateDocumentResponse({
    this.message,

  });

  factory UpdateDocumentResponse.fromJson(Map<String, dynamic> json) {
    return UpdateDocumentResponse(
      message: json['message'] as String?,
    );
  }
}
