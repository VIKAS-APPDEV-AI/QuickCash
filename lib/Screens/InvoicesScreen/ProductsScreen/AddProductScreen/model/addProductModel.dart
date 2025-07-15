class AddProductRequest {
  final String userId;
  final String name;
  final String categoryId;
  final String description;
  final String productCode;
  final int unitPrice;

  AddProductRequest({
    required this.userId,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.productCode,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'name': name,
      'category': categoryId,
      'description': description,
      'productCode': productCode,
      'unitPrice': unitPrice,
    };
  }
}


class AddProductResponse {
  final String? message;

  AddProductResponse({
    this.message,

  });

  factory AddProductResponse.fromJson(Map<String, dynamic> json) {
    return AddProductResponse(
      message: json['message'] as String?,
    );
  }
}
