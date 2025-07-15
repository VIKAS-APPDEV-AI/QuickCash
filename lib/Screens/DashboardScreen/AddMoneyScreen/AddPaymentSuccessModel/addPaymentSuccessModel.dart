class AddPaymentSuccessRequest {
  final String userId;
  final String status;
  final String paymentId;
  final String paymentGateway;
  final String amount;
  final String fee;
  final String amountText;
  final String fromCurrency;
  final String toCurrency;
  final String conversionAmount;
  final String conversionAmountText;

  AddPaymentSuccessRequest({
    required this.userId,
    required this.status,
    required this.paymentId,
    required this.paymentGateway,
    required this.amount,
    required this.fee,
    required this.amountText,
    required this.fromCurrency,
    required this.toCurrency,
    required this.conversionAmount,
    required this.conversionAmountText,

  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'status': status,
      'paymentId': paymentId,
      'paymentGateway': paymentGateway,
      'amount': amount,
      'fee': fee,
      'amountText': amountText,
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'convertedAmount': conversionAmount,
      'conversionAmountText': conversionAmountText,
    };
  }
}

class AddPaymentSuccessResponse {
  final int status;
  final String orderStatus;
  final String message;

  AddPaymentSuccessResponse({
    required this.status,
    required this.orderStatus,
    required this.message,
  });

  factory AddPaymentSuccessResponse.fromJson(Map<String, dynamic> json) {
    return AddPaymentSuccessResponse(
      status: json['status'] as int,
      orderStatus: json['orderStatus'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'orderStatus': orderStatus,
      'message': message,
    };
  }
}



