class TaxDetailsItem {
  final String? id;
  final String? user;
  final String? name;
  final double? taxValue;
  final String? isDefault;
  final String? createdAt;
  final String? updatedAt;
  bool isDefaultSwitch;

  TaxDetailsItem({
    this.id,
    this.user,
    this.name,
    this.taxValue,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
    this.isDefaultSwitch = false,
  });

  factory TaxDetailsItem.fromJson(Map<String, dynamic> json) {
    return TaxDetailsItem(
      id: json['_id'] as String?,
      user: json['user'] as String?,
      name: json['Name'] as String?,
      taxValue: (json['taxvalue'] is int
          ? (json['taxvalue'] as int).toDouble()
          : json['taxvalue']) as double?,
      isDefault: json['IsDefault'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      isDefaultSwitch: json['IsDefault'] == "yes", // Set switch state based on IsDefault
    );
  }
}


class TaxDetailsResponse {
  final List<TaxDetailsItem>? taxDetailsList;
  final int? status;
  final String? message;

  TaxDetailsResponse({
    this.taxDetailsList,
    this.status,
    this.message,
  });

  factory TaxDetailsResponse.fromJson(Map<String, dynamic> json) {
    return TaxDetailsResponse(
      status: json['status'] as int?,
      message: json['message'] as String?,
      taxDetailsList: (json['data'] as List<dynamic>?)
          ?.map((item) => TaxDetailsItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
