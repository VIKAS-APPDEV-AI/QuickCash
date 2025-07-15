class CardDeleteResponse {
  final String? message;

  CardDeleteResponse({
    this.message,

  });

  factory CardDeleteResponse.fromJson(Map<String, dynamic> json) {
    return CardDeleteResponse(
      message: json['message'] as String?,
    );
  }
}