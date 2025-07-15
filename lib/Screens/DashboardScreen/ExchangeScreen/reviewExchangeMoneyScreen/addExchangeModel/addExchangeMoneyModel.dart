
class AddExchangeRequest {
  final String userId;
  final String sourceAccount;
  final String transferAccount;
  final String transType;
  final double fee;
  final String info;
  final String country;
  final double fromAmount;
  final String amount;
  final String amountText;
  final String fromAmountText;
  final String fromCurrency;
  final String toCurrency;
  final String status;


  AddExchangeRequest({
    required this.userId,
    required this.sourceAccount,
    required this.transferAccount,
    required this.transType,
    required this.fee,
    required this.info,
    required this.country,
    required this.fromAmount,
    required this.amount,
    required this.amountText,
    required this.fromAmountText,
    required this.fromCurrency,
    required this.toCurrency,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'source_account': sourceAccount,
      'transfer_account': transferAccount,
      'trans_type': transType,
      'fee': fee,
      'info': info,
      'country': country,
      'fromAmount': fromAmount,
      'amount': amount,
      'amountText': amountText,
      'fromamountText': fromAmountText,
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'status': status,
    };
  }
}

class AddExchangeResponse {
  final int status;
  final String message;

  AddExchangeResponse({
    required this.status,
    required this.message,
  });

  factory AddExchangeResponse.fromJson(Map<String, dynamic> json) {
    return AddExchangeResponse(
      status: json['status'] as int,
      message: json['message'] as String,
    );
  }
}

