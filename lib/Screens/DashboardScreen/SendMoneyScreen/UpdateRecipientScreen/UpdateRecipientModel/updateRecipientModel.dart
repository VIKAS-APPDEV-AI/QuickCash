class RecipientUpdateRequest {
  final String userId;
  final String fee;
  final String toCurrency;
  final String recipientId;
  final String amount;
  final String amountText;

  final String conversionAmount;
  final String conversionAmountText;

  RecipientUpdateRequest({
    required this.userId,
    required this.fee,
    required this.toCurrency,
    required this.recipientId,
    required this.amount,
    required this.amountText,
    required this.conversionAmount,
    required this.conversionAmountText,

  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'fee': fee,
      'currency': toCurrency,
      'receipient': recipientId,
      'amount': amount,
      'amountText': amountText,
      'conversionAmount': conversionAmount,
      'conversionAmountText': conversionAmountText,
    };
  }
}

class RecipientUpdateResponse {
  final int status;
  final String message;

  RecipientUpdateResponse({
    required this.status,
    required this.message,
  });

  factory RecipientUpdateResponse.fromJson(Map<String, dynamic> json) {
    return RecipientUpdateResponse(
      status: json['status'] as int,
      message: json['message'] as String,
    );
  }
}

