// login_model.dart
class DocumentsRequest {

  DocumentsRequest();

}

class DocumentsDetail {
  final String? documentsType;
  final String? documentsNo;
  final String? documentPhotoFront;

  DocumentsDetail({
    this.documentsType,
    this.documentsNo,
    this.documentPhotoFront,

  });

  factory DocumentsDetail.fromJson(Map<String, dynamic> json) {
    return DocumentsDetail(
      documentsType: json['documentType'] as String?,
      documentsNo: json['documentNumber'] as String?,
      documentPhotoFront: json['documentPhotoFront'] as String?,
    );
  }
}

class DocumentsResponse {
  final List<DocumentsDetail>? documentsDetails; // List of AccountDetail

  DocumentsResponse({
    this.documentsDetails,
  });

  factory DocumentsResponse.fromJson(Map<String, dynamic> json) {
    return DocumentsResponse(
      documentsDetails: (json['data']?['kycDetails'] as List<dynamic>?)
          ?.map((item) => DocumentsDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
