class QrCodeData {
  final String? id;
  final String? title;
  final String? image;
  final String? isDefault;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  QrCodeData({
    this.id,
    this.title,
    this.image,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory QrCodeData.fromJson(Map<String, dynamic> json) {
    return QrCodeData(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      image: json['image'] as String?,
      isDefault: json['IsDefault'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
    );
  }
}

class QrCodeListResponse {
  final List<QrCodeData>? qrCodeList;
  final int? status;
  final String? message;

  QrCodeListResponse({
    this.qrCodeList,
    this.status,
    this.message,
  });

  factory QrCodeListResponse.fromJson(Map<String, dynamic> json) {
    return QrCodeListResponse(
      status: json['status'] as int?,
      message: json['message'] as String?,
      qrCodeList: (json['data'] as List<dynamic>?)
          ?.map((item) => QrCodeData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
