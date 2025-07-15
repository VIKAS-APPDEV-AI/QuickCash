class RecipientExchangeMoneyRequest {
  final String userId;
  final String amount;
  final String fromCurrency;
  final String toCurrency;

  RecipientExchangeMoneyRequest({
    required this.userId,
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency, required String accountId,
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

class RecipientExchangeMoneyResponse {
  final int status;
  final String message;
  final RecipientExchangeMoneyData data;

  RecipientExchangeMoneyResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RecipientExchangeMoneyResponse.fromJson(Map<String, dynamic> json) {
    return RecipientExchangeMoneyResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: RecipientExchangeMoneyData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class RecipientExchangeMoneyData {
  final double rate;
  final double totalFees;
  final double totalCharge;
  final double convertedAmount;
  final double sourceAccountBalance;
  final String sourceAccountCountryCode;
  final String sourceAccountNo;
  final String sourceAccountId;

  RecipientExchangeMoneyData({
    required this.rate,
    required this.totalFees,
    required this.totalCharge,
    required this.convertedAmount,
    required this.sourceAccountBalance,
    required this.sourceAccountCountryCode,
    required this.sourceAccountNo,
    required this.sourceAccountId,
  });

  factory RecipientExchangeMoneyData.fromJson(Map<String, dynamic> json) {
    return RecipientExchangeMoneyData(
      rate: _parseDouble(json['rate']) ?? 0.0,
      totalFees: _parseDouble(json['totalFees']) ?? 0.0,
      totalCharge: _parseDouble(json['totalCharge']) ?? 0.0,  // Fixing type conversion
      convertedAmount: _parseDouble(json['convertedAmount']) ?? 0.0,
      sourceAccountBalance: _parseDouble(json['sourceAccountBalance']) ?? 0.0,
      sourceAccountCountryCode: json['sourceAccuntCountryCode'] as String,  // Fix typo
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
