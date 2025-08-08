class CardListsData {
  final String? cardId;
  final String? user;
  final String? account;
  final String? cardHolderName;
  final String? cardNumber;
  final String? cardCVV;
  final String? cardValidity;
  final String? currency;
  final int? cardPin;
  final bool? status;
  final String? cardType;
  final double? balance; // Maps to 'amount' in API
  final String? paymentType;
  final String? iban;
  final String? createdAt;
  final String? updatedAt;
  final int? version; // Maps to '__v' in API
  final double? dailyLimit;
  final double? monthlyLimit;
  final bool? isFrozen;

  CardListsData({
    this.cardId,
    this.user,
    this.account,
    this.cardHolderName,
    this.cardNumber,
    this.cardCVV,
    this.cardValidity,
    this.currency,
    this.cardPin,
    this.status,
    this.cardType,
    this.balance,
    this.paymentType,
    this.iban,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.dailyLimit,
    this.monthlyLimit,
    this.isFrozen,
  });

  factory CardListsData.fromJson(Map<String, dynamic> json) {
    return CardListsData(
      cardId: json['_id'] as String?,
      user: json['user'] as String?,
      account: json['Account'] as String?,
      cardHolderName: json['name'] as String?,
      cardNumber: json['cardNumber'] as String?,
      cardCVV: json['cvv'] as String?,
      cardValidity: json['expiry'] as String?,
      currency: json['currency'] as String?,
      cardPin: json['pin'] as int?,
      status: json['status'] as bool?,
      cardType: json['cardType'] as String?,
      balance: (json['amount'] as num?)?.toDouble(),
      paymentType: json['paymentType'] as String?,
      iban: json['iban'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      version: json['__v'] as int?,
      dailyLimit: (json['dailyLimit'] as num?)?.toDouble(),
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble(),
      isFrozen: json['isFrozen'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': cardId,
        'user': user,
        'Account': account,
        'name': cardHolderName,
        'cardNumber': cardNumber,
        'cvv': cardCVV,
        'expiry': cardValidity,
        'currency': currency,
        'pin': cardPin,
        'status': status,
        'cardType': cardType,
        'amount': balance,
        'paymentType': paymentType,
        'iban': iban,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        '__v': version,
        'dailyLimit': dailyLimit,
        'monthlyLimit': monthlyLimit,
        'isFrozen': isFrozen,
      };
}

class CardListResponse {
  final int? status;
  final String? message;
  final List<CardListsData>? cardList;

  CardListResponse({
    this.status,
    this.message,
    this.cardList,
  });

  factory CardListResponse.fromJson(Map<String, dynamic> json) {
    return CardListResponse(
      status: json['status'] as int?,
      message: json['message'] as String?,
      cardList: (json['data'] as List<dynamic>?)
          ?.map((item) => CardListsData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': cardList?.map((item) => item.toJson()).toList(),
      };
}