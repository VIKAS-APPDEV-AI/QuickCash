class RecipientMakePaymentRequest {
  final String userId;
  final String iban;
  final String bicCode;
  final String fee;
  final String amount;
  final String conversionAmount;
  final String conversionAmountText;
  final String amountText;
  final String fromCurrency;
  final String toCurrency;
  final String status;
  final String name;
  final String email;
  final String address;
  final String mobile;
  final String bankName;

  RecipientMakePaymentRequest({
    required this.userId,
    required this.iban,
    required this.bicCode,
    required this.fee,
    required this.amount,
    required this.conversionAmount,
    required this.conversionAmountText,
    required this.amountText,
    required this.fromCurrency,
    required this.toCurrency,
    required this.status,
    required this.name,
    required this.email,
    required this.address,
    required this.mobile,
    required this.bankName,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'iban': iban,
      'bic_code': bicCode,
      'fee': fee,
      'amount': amount,
      'conversionAmount': conversionAmount,
      'conversionAmountText': conversionAmountText,
      'amountText': amountText,
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'status': status,
      'name': name,
      'email': email,
      'address': address,
      'mobile': mobile,
      'bankName': bankName,
    };
  }
}

class RecipientMakePaymentResponse {
  final int status;
  final String message;

  RecipientMakePaymentResponse({
    required this.status,
    required this.message,
  });

  factory RecipientMakePaymentResponse.fromJson(Map<String, dynamic> json) {
    return RecipientMakePaymentResponse(
      status: json['status'] as int,
      message: json['message'] as String,
    );
  }
}

