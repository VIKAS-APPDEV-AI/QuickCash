class QRCodeDetailsItem {
  final String? id;
  final String? user;
  final String? title;  // Changed from 'name' to 'title'
  final String? image;  // Added 'image' field
  final String? isDefault;
  final String? createdAt;
  final String? updatedAt;
  bool isDefaultSwitch;

  QRCodeDetailsItem({
    this.id,
    this.user,
    this.title,  // Changed from 'name' to 'title'
    this.image,  // Added 'image' field
    this.isDefault,
    this.createdAt,
    this.updatedAt,
    this.isDefaultSwitch = false,
  });

  factory QRCodeDetailsItem.fromJson(Map<String, dynamic> json) {
    return QRCodeDetailsItem(
      id: json['_id'] as String?,
      user: json['user'] as String?,
      title: json['title'] as String?,  // Changed from 'name' to 'title'
      image: json['image'] as String?,  // Added mapping for 'image' field
      isDefault: json['IsDefault'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      isDefaultSwitch: json['IsDefault'] == "yes", // Set switch state based on IsDefault
    );
  }
}

class QRCodeDetailsResponse {
  final List<QRCodeDetailsItem>? qrCodeDetailsList;
  final int? status;
  final String? message;

  QRCodeDetailsResponse({
    this.qrCodeDetailsList,
    this.status,
    this.message,
  });

  factory QRCodeDetailsResponse.fromJson(Map<String, dynamic> json) {
    return QRCodeDetailsResponse(
      status: json['status'] as int?,
      message: json['message'] as String?,
      qrCodeDetailsList: (json['data'] as List<dynamic>?)
          ?.map((item) => QRCodeDetailsItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
