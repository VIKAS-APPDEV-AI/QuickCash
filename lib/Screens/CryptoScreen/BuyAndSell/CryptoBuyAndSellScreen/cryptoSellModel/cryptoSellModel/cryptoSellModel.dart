class CryptoSellRequest {
  final String userId;
  final String amount;
  final String coinType;
  final String currencyType;
  final int fees;
  final String noOfCoins;
  final String side;
  final String status;

  CryptoSellRequest({
    required this.userId,
    required this.amount,
    required this.coinType,
    required this.currencyType,
    required this.fees,
    required this.noOfCoins,
    required this.side,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'amount': amount,
      'coin': coinType,
      'currencyType': currencyType,
      'fee': fees,
      'noOfCoins': noOfCoins,
      'side': side,
      'status': status,
    };
  }
}

class CryptoSellAddResponse {
  final int status;
  final String message;
  final CryptoSellData data;

  CryptoSellAddResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CryptoSellAddResponse.fromJson(Map<String, dynamic> json) {
    return CryptoSellAddResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: CryptoSellData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class CryptoSellData {
  final String id;

  CryptoSellData({
    required this.id,
  });

  factory CryptoSellData.fromJson(Map<String, dynamic> json) {
    return CryptoSellData(
      id: json['_id'] as String,
    );
  }
}

