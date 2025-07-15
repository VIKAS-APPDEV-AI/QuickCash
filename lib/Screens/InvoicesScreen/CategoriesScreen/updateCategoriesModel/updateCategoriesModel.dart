class UpdateCategoriesRequest {
  final String categoryName;

  UpdateCategoriesRequest({
    required this.categoryName,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': categoryName,
    };
  }
}


class UpdateCategoriesResponse {
  final String? message;

  UpdateCategoriesResponse({
    this.message,

  });

  factory UpdateCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return UpdateCategoriesResponse(
      message: json['message'] as String?,
    );
  }
}
