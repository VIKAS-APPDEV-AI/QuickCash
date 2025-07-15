class CardData {
  final String? cardId;
  final String? cardNumber;
  final String? cardHolderName;
  final String? cardValidity;
  final String? cardCVV;
  final bool? status;
  final int? cardPin;
  final String? date;
  final String? currency;

  CardData({
    this.cardId,
    this.cardNumber,
    this.cardHolderName,
    this.cardValidity,
    this.cardCVV,
    this.status,
    this.cardPin,
    this.date,
    this.currency,
  });

  factory CardData.fromJson(Map<String, dynamic> json) {
    return CardData(
      cardId: json['_id'] as String?,
      cardNumber: json['cardNumber'] as String?,
      cardHolderName: json['name'] as String?,
      cardValidity: json['expiry'] as String?,
      cardCVV: json['cvv'] as String?,
      status: json['status'] as bool?,
      cardPin: json['pin'] as int?,
      date: json['createdAt'] as String?,
      currency: json['currency'] as String?,
    );
  }
}

class CardResponse {
  final CardData? card; // Change this to hold a single CardData object, not a list

  CardResponse({
    this.card,
  });

  factory CardResponse.fromJson(Map<String, dynamic> json) {
    return CardResponse(
      card: json['data'] != null ? CardData.fromJson(json['data']) : null, // Parse the 'data' object as a single CardData
    );
  }
}
