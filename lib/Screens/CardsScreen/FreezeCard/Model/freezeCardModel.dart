
class FreezeCardResponse {
  final int status;
  final String message;
  final FreezeCardData? data;

  FreezeCardResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory FreezeCardResponse.fromJson(Map<String, dynamic> json) {
    return FreezeCardResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? FreezeCardData.fromJson(json['data']) : null,
    );
  }
}

class FreezeCardData {
  final String? cardId;
  final String? name;
  final String? user;
  final String? cardNumber;
  final String? cvv;
  final String? expiry;
  final String? account;
  final String? currency;
  final String? cardType;
  final double? amount;
  final String? paymentType;
  final String? iban;
  final bool? isFrozen;

  FreezeCardData({
    this.cardId,
    this.name,
    this.user,
    this.cardNumber,
    this.cvv,
    this.expiry,
    this.account,
    this.currency,
    this.cardType,
    this.amount,
    this.paymentType,
    this.iban,
    this.isFrozen,
  });

  factory FreezeCardData.fromJson(Map<String, dynamic> json) {
    return FreezeCardData(
      cardId: json['cardId'],
      name: json['name'],
      user: json['user'],
      cardNumber: json['cardNumber'],
      cvv: json['cvv'],
      expiry: json['expiry'],
      account: json['Account'],
      currency: json['currency'],
      cardType: json['cardType'],
      amount: json['amount'] != null ? json['amount'].toDouble() : null,
      paymentType: json['paymentType'],
      iban: json['iban'],
      isFrozen: json['isFrozen'],
    );
  }
}
