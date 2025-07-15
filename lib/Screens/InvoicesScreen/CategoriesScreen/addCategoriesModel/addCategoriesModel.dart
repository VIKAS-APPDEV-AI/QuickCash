class AddCategoriesRequest {
  final String userId;
  final String categoryName;

  AddCategoriesRequest({
    required this.userId,
    required this.categoryName,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'name': categoryName,
    };
  }
}


class AddCategoriesResponse {
  final String? message;

  AddCategoriesResponse({
    this.message,

  });

  factory AddCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return AddCategoriesResponse(
      message: json['message'] as String?,
    );
  }
}
