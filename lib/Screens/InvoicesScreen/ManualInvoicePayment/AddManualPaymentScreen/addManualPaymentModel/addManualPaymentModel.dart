class AddManualPaymentRequest {
  final String userId;
  final String invoiceNumber;
  final String currency;
  final String invoiceId;
  final String notes;
  final double amount;
  final String paymentDate;
  final String mode;
  final double dueAmount;
  final double paidAmount;

  AddManualPaymentRequest({
    required this.userId,
    required this.invoiceNumber,
    required this.currency,
    required this.invoiceId,
    required this.notes,
    required this.amount,
    required this.paymentDate,
    required this.mode,
    required this.dueAmount,
    required this.paidAmount,

  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'invoice_number': invoiceNumber,
      'amountCurrencyText': currency,
      'invoice': invoiceId,
      'notes': notes,
      'amount': amount,
      'payment_date': paymentDate,
      'mode': mode,
      'dueAmount': dueAmount,
      'paidAmount': paidAmount,
    };
  }
}


class AddManualPaymentResponse {
  final String? message;

  AddManualPaymentResponse({
    this.message,

  });

  factory AddManualPaymentResponse.fromJson(Map<String, dynamic> json) {
    return AddManualPaymentResponse(
      message: json['message'] as String?,
    );
  }
}
