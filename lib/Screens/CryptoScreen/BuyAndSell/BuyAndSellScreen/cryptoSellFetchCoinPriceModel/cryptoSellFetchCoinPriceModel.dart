class CryptoSellFetchCoinPriceRequest {
  final String coinType;
  final String currencyType;
  final String noOfCoins;

  CryptoSellFetchCoinPriceRequest({
    required this.coinType,
    required this.currencyType,
    required this.noOfCoins,
  });

  Map<String, dynamic> toJson() {
    return {
      'coin': coinType,
      'currency': currencyType,
      'noOfCoins': noOfCoins,
    };
  }
}

class CryptoSellFetchCoinPriceResponse {
  final int status;
  final String message;
  final CryptoBuyData data;

  CryptoSellFetchCoinPriceResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CryptoSellFetchCoinPriceResponse.fromJson(Map<String, dynamic> json) {
    return CryptoSellFetchCoinPriceResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: CryptoBuyData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class CryptoBuyData {
  final String amount;
  final double? fees;  // Made nullable to handle potential null values
  final double? cryptoFees;  // Made nullable
  final double? exchangeFees;  // Made nullable

  CryptoBuyData({
    required this.amount,
    this.fees,
    this.cryptoFees,
    this.exchangeFees,
  });

  factory CryptoBuyData.fromJson(Map<String, dynamic> json) {
    return CryptoBuyData(
      amount: json['amount'] as String,
      fees: _parseDouble(json['fees']),
      cryptoFees: _parseDouble(json['cryptoFees']),
      exchangeFees: _parseDouble(json['exchangeFees']),
    );
  }

  // Helper function to handle the type conversion for fees
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    }
    return null;  // Return null if the value is neither int nor double
  }
}
