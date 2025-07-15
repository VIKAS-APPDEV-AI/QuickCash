
class CardListsData {
  final String? cardId;
  final String? cardNumber;
  final String? cardHolderName;
  final String? cardValidity;
  final String? cardCVV;
  final bool? status;
  final int? cardPin;
  final String? date;
  final String? currency;

  CardListsData({
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

  factory CardListsData.fromJson(Map<String, dynamic> json) {
    return CardListsData(
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

class CardListResponse {
  final List<CardListsData>? cardList;

  CardListResponse({
    this.cardList,
  });

  factory CardListResponse.fromJson(Map<String, dynamic> json) {
    return CardListResponse(
      cardList: (json['data'] as List<dynamic>? )
          ?.map((item) => CardListsData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
