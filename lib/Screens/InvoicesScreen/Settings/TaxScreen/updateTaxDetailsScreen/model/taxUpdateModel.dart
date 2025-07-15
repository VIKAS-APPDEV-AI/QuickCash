class TaxUpdateRequest {
  final String userId;
  final String name;
  final String value;
  final String type;


  TaxUpdateRequest({
    required this.userId,
    required this.name,
    required this.value,
    required this.type,

  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'name': name,
      'value': value,
      'isDefault': type,
    };
  }
}


class TaxUpdateResponse {
  final String? message;

  TaxUpdateResponse({
    this.message,

  });

  factory TaxUpdateResponse.fromJson(Map<String, dynamic> json) {
    return TaxUpdateResponse(
      message: json['message'] as String?,
    );
  }
}
