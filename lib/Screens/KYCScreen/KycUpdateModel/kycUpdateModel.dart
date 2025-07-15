import 'dart:io';

class KycUpdateRequest {
  final String userId;
  final String emailId;
  final String primaryPhoneNo;
  final String additionalPhoneNo;
  final String documentType;
  final String documentNumber;
  final String addressDocumentType;
  final String status;
  final bool emailVerified;
  final bool primaryPhoneVerified;
  final bool additionalPhoneVerified;
  final File? documentPhotoFront;
  final File? documentPhotoBack;
  final File? addressProofPhoto;

  KycUpdateRequest({
    required this.userId,
    required this.emailId,
    required this.primaryPhoneNo,
    required this.additionalPhoneNo,
    required this.documentType,
    required this.documentNumber,
    required this.addressDocumentType,
    required this.status,
    required this.emailVerified,
    required this.primaryPhoneVerified,
    required this.additionalPhoneVerified,
    this.documentPhotoFront, // Optional for now
    this.documentPhotoBack, // Optional for now
    this.addressProofPhoto, // Optional for now
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'email': emailId,
      'primaryPhoneNumber': primaryPhoneNo,
      'secondaryPhoneNumber': additionalPhoneNo,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'addressDocumentType': addressDocumentType,
      'status': status,
      'emailVerified': emailVerified,
      'phonePVerified': primaryPhoneVerified,
      'phoneSVerified': additionalPhoneVerified,
    };
  }
}



class KycUpdateResponse {
  final String? message;

  KycUpdateResponse({
    this.message,

  });

  factory KycUpdateResponse.fromJson(Map<String, dynamic> json) {
    return KycUpdateResponse(
      message: json['message'] as String?,
    );
  }
}
