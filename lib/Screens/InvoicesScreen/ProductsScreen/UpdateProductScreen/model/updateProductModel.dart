class UpdateProductRequest {
  final String userId;
  final String name;
  final String categoryId;
  final String description;
  final String productCode;
  final int unitPrice;

  UpdateProductRequest({
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


class UpdateProductResponse {
  final String? message;

  UpdateProductResponse({
    this.message,

  });

  factory UpdateProductResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProductResponse(
      message: json['message'] as String?,
    );
  }
}
