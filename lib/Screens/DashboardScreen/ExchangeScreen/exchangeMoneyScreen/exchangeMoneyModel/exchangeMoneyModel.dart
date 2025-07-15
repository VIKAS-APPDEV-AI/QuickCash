class ExchangeMoneyRequest {
  final String userId;
  final String amount;
  final String fromCurrency;
  final String toCurrency;

  ExchangeMoneyRequest({
    required this.userId,
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'amount': amount,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
    };
  }
}

class ExchangeMoneyResponse {
  final int status;
  final String message;
  final ExchangeMoneyData data;

  ExchangeMoneyResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ExchangeMoneyResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeMoneyResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: ExchangeMoneyData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ExchangeMoneyData {
  final double rate;
  final double totalFees;
  final double totalCharge;
  final double convertedAmount;
  final double sourceAccountBalance;
  final String sourceAccountCountryCode;
  final String sourceAccountNo;
  final String transferAccountCountryCode;
  final String transferAccountNo;

  ExchangeMoneyData({
    required this.rate,
    required this.totalFees,
    required this.totalCharge,
    required this.convertedAmount,
    required this.sourceAccountBalance,
    required this.sourceAccountCountryCode,
    required this.sourceAccountNo,
    required this.transferAccountCountryCode,
    required this.transferAccountNo,
  });

  factory ExchangeMoneyData.fromJson(Map<String, dynamic> json) {
    return ExchangeMoneyData(
      rate: _parseDouble(json['rate']),
      totalFees: _parseDouble(json['totalFees']),
      totalCharge: _parseDouble(json['totalCharge']),
      convertedAmount: _parseDouble(json['convertedAmount']),
      sourceAccountBalance: _parseDouble(json['sourceAccountBalance']),
      sourceAccountCountryCode: json['sourceAccountCountryCode'] as String? ?? 'Unknown',  // Handle null
      sourceAccountNo: json['sourceAccountNo'] as String? ?? 'Unknown',  // Handle null
      transferAccountCountryCode: json['transferAccountCountryCode'] as String? ?? 'Unknown',  // Handle null
      transferAccountNo: json['transferAccountNo'] as String? ?? 'Unknown',  // Handle null
    );
  }

  // Helper function to handle the type conversion for fees
  static double _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      throw Exception("Invalid type for double parsing");
    }
  }
}

