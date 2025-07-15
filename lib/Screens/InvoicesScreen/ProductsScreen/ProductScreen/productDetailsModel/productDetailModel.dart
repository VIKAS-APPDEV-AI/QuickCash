
class ProductDetailsResponse {
  final String? productName;
  final String? productCode;
  final String? category;
  final int? unitPrice;
  final String? description;
  final String? date;

  ProductDetailsResponse({
    this.productName,
    this.productCode,
    this.category,
    this.unitPrice,
    this.description,
    this.date,
  });

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailsResponse(
      productName: json['data']?['name'] as String?,
      productCode: json['data']?['productCode'] as String?,
      category: json['data']?['category'] as String?,
      unitPrice: json['data']?['unitPrice'] as int?,
      description: json['data']?['description'] as String?,
      date: json['data']?['updatedAt'] as String?,

    );
  }
}
