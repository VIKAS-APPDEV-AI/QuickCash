class ConvertCoinRequest {
  final String fromCoin;
  final String toCoin;
  final double amount;

  ConvertCoinRequest({
    required this.fromCoin,
    required this.toCoin,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'fromCoin': fromCoin,
        'toCoin': toCoin,
        'amount': amount,
      };
}

class ConvertCoinResponse {
  final String message;
  final double convertedAmount;

  ConvertCoinResponse({required this.message, required this.convertedAmount});

  factory ConvertCoinResponse.fromJson(Map<String, dynamic> json) {
    return ConvertCoinResponse(
      message: json['message'],
      convertedAmount: (json['convertedAmount'] as num).toDouble(),
    );
  }
}

