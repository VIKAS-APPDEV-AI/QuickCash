class CryptoBuyRequest {
  final int amount;
  final String coinType;
  final String currencyType;
  final String sideType;

  CryptoBuyRequest({
    required this.amount,
    required this.coinType,
    required this.currencyType,
    required this.sideType,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'coin': coinType,
      'currency': currencyType,
      'side': sideType,
    };
  }
}

class CryptoBuyResponse {
  final int status;
  final String message;
  final CryptoBuyData data;

  CryptoBuyResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CryptoBuyResponse.fromJson(Map<String, dynamic> json) {
    return CryptoBuyResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: CryptoBuyData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class CryptoBuyData {
  final double rate;
  final double numberofCoins;
  final double? fees;  // Made nullable to handle potential null values
  final double? cryptoFees;  // Made nullable
  final double? exchangeFees;  // Made nullable

  CryptoBuyData({
    required this.rate,
    required this.numberofCoins,
    this.fees,
    this.cryptoFees,
    this.exchangeFees,
  });

  factory CryptoBuyData.fromJson(Map<String, dynamic> json) {
    return CryptoBuyData(
      rate: json['rate'] as double,
      numberofCoins: json['numberofCoins'] as double,
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
