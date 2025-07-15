class ExchangeCurrencyRequest {
  final String userId;
  final String amount;
  final String fromCurrency;
  final String toCurrency;

  ExchangeCurrencyRequest({
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

class ExchangeCurrencyResponse {
  final int status;
  final String message;
  final ExchangeCurrencyData data;

  ExchangeCurrencyResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ExchangeCurrencyResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeCurrencyResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: ExchangeCurrencyData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ExchangeCurrencyData {
  final double rate;
  final double totalFees;
  final String totalCharge;
  final double convertedAmount;
  final double sourceAccountBalance;
  final String sourceAccountCountryCode;
  final String sourceAccountNo;
  final String sourceAccountId;

  ExchangeCurrencyData({
    required this.rate,
    required this.totalFees,
    required this.totalCharge,
    required this.convertedAmount,
    required this.sourceAccountBalance,
    required this.sourceAccountCountryCode,
    required this.sourceAccountNo,
    required this.sourceAccountId,
  });

  factory ExchangeCurrencyData.fromJson(Map<String, dynamic> json) {
    return ExchangeCurrencyData(
      rate: _parseDouble(json['rate']) ?? 0.0,
      totalFees: _parseDouble(json['totalFees']) ?? 0.0,
      totalCharge: json['totalCharge'].toString(),  // Fixing the totalCharge casting
      convertedAmount: _parseDouble(json['convertedAmount']) ?? 0.0,
      sourceAccountBalance: _parseDouble(json['sourceAccountBalance']) ?? 0.0,
      sourceAccountCountryCode: json['sourceAccuntCountryCode'] as String,  // Fix typo here
      sourceAccountNo: json['sourceAccountNo'] as String,
      sourceAccountId: json['sourceAccountId'] as String,
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
