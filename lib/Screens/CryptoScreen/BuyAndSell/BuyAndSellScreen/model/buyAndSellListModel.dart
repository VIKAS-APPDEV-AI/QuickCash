class CryptoListsData {
  final String? coinName;
  final String? date;
  final String? paymentType;
  final String? noOfCoin;
  final String? side;
  final double? amount;
  final String? status;
  final String? currencyType;

  CryptoListsData({
    this.coinName,
    this.date,
    this.paymentType,
    this.noOfCoin,
    this.side,
    this.amount,
    this.status,
    this.currencyType,
  });

  // Factory constructor to create an instance of CryptoListsData from JSON
  factory CryptoListsData.fromJson(Map<String, dynamic> json) {
    return CryptoListsData(
      coinName: json['coin']?.toString(),  // Ensure coinName is a String
      date: json['createdAt']?.toString(),  // Ensure date is a String
      paymentType: json['paymentType']?.toString(),  // Ensure paymentType is a String
      noOfCoin: json['noOfCoins']?.toString(),  // Ensure noOfCoin is a String (or maybe Double if needed)
      side: json['side']?.toString(),  // Ensure side is a String
      amount: json['amount'] is double
          ? json['amount'] as double  // Directly cast to double
          : json['amount'] is int
          ? (json['amount'] as int).toDouble()  // Convert int to double
          : null,  // Return null if amount is not provided
      status: json['status']?.toString(),  // Ensure status is a String
      currencyType: json['currencyType']?.toString(),  // Ensure status is a String
    );
  }
}


class CryptoListResponse {
  final List<CryptoListsData>? cryptoList;

  CryptoListResponse({
    this.cryptoList,
  });

  // Factory constructor to create an instance of CryptoListResponse from JSON
  factory CryptoListResponse.fromJson(Map<String, dynamic> json) {
    return CryptoListResponse(
      cryptoList: (json['data'] as List<dynamic>?)
          ?.map((item) => CryptoListsData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
