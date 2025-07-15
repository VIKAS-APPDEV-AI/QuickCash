class CryptoBuyAddRequest {
  final String userId;
  final int amount;
  final String coinType;
  final String currencyType;
  final int fees;
  final String noOfCoins;
  final String paymentType;
  final String side;
  final String status;
  final String walletAddress;

  CryptoBuyAddRequest({
    required this.userId,
    required this.amount,
    required this.coinType,
    required this.currencyType,
    required this.fees,
    required this.noOfCoins,
    required this.paymentType,
    required this.side,
    required this.status,
    required this.walletAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'amount': amount,
      'coin': coinType,
      'currencyType': currencyType,
      'fee': fees,
      'noOfCoins': noOfCoins,
      'paymentType': paymentType,
      'side': side,
      'status': status,
      'walletAddress': walletAddress,
    };
  }
}

class CryptoBuyAddResponse {
  final int status;
  final String message;
  final CryptoBuyAddData data;

  CryptoBuyAddResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CryptoBuyAddResponse.fromJson(Map<String, dynamic> json) {
    return CryptoBuyAddResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: CryptoBuyAddData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class CryptoBuyAddData {
  final String id;

  CryptoBuyAddData({
    required this.id,
  });

  factory CryptoBuyAddData.fromJson(Map<String, dynamic> json) {
    return CryptoBuyAddData(
      id: json['_id'] as String,
    );
  }
}

