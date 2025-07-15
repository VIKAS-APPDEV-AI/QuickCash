class CardUpdateRequest {
  final bool cardStatus;
  final String cardName;
  final String cardCVV;


  CardUpdateRequest({
    required this.cardStatus,
    required this.cardName,
    required this.cardCVV,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': cardStatus,
      'name': cardName,
      'cvv': cardCVV,

    };
  }
}


class CardUpdateResponse {
  final String? message;

  CardUpdateResponse({
    this.message,

  });

  factory CardUpdateResponse.fromJson(Map<String, dynamic> json) {
    return CardUpdateResponse(
      message: json['message'] as String?,
    );
  }
}
