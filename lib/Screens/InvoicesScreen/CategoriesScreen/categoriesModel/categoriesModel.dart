class CategoriesData {
  final String? id;
  final String? categoriesName;
  final String? date;
  final String? user;
  final bool? status;
  final List<ProductDetail>? productDetails;

  CategoriesData({
    this.id,
    this.categoriesName,
    this.date,
    this.user,
    this.status,
    this.productDetails,
  });

  factory CategoriesData.fromJson(Map<String, dynamic> json) {
    return CategoriesData(
      id: json['_id'] as String?,
      categoriesName: json['name'] as String?,
      date: json['createdAt'] as String?,
      user: json['user'] as String?,
      status: json['status'] as bool?,
      productDetails: (json['productDetails'] as List<dynamic>?)
          ?.map((item) => ProductDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProductDetail {
  final String? id;

  ProductDetail({this.id});

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['_id'] as String?,
    );
  }
}

class CategoriesResponse {
  final List<CategoriesData>? categoriesList;

  CategoriesResponse({
    this.categoriesList,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(
      categoriesList: (json['data'] as List<dynamic>?)
          ?.map((item) => CategoriesData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
