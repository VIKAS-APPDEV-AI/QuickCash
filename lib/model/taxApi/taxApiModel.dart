class TaxData {
  final String? id;
  final String? user;
  final String? name;
  final int? taxValue;
  final String? isDefault;
  final String? createdAt;
  final String? updatedAt;

  TaxData({
    this.id,
    this.user,
    this.name,
    this.taxValue,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory TaxData.fromJson(Map<String, dynamic> json) {
    return TaxData(
      id: json['_id'] as String?,
      user: json['user'] as String?,
      name: json['Name'] as String?,
      taxValue: json['taxvalue'] as int?,
      isDefault: json['IsDefault'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class TaxResponse {
  final List<TaxData>? taxesList;
  final int? status;
  final String? message;

  TaxResponse({
    this.taxesList,
    this.status,
    this.message,
  });

  factory TaxResponse.fromJson(Map<String, dynamic> json) {
    return TaxResponse(
      status: json['status'] as int?,
      message: json['message'] as String?,
      taxesList: (json['data'] as List<dynamic>?)
          ?.map((item) => TaxData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
