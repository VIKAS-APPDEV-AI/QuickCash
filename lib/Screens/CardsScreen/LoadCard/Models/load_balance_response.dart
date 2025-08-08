// load_balance_response.dart
class LoadBalanceResponse {
  final String sourceAccountId;
  final String cardId;
  final double amount;
  final double fee;
  final double conversionAmount;
  final String fromCurrency;
  final String toCurrency;
  final String info;

  LoadBalanceResponse({
    required this.sourceAccountId,
    required this.cardId,
    required this.amount,
    required this.fee,
    required this.conversionAmount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.info,
  });

  factory LoadBalanceResponse.fromJson(Map<String, dynamic> json) {
    return LoadBalanceResponse(
      sourceAccountId: json['sourceAccountId'] as String,
      cardId: json['cardId'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      conversionAmount: (json['conversionAmount'] as num).toDouble(),
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      info: json['info'] as String,
    );
  }
}