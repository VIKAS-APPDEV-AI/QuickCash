class GetManualPaymentData {
  final String? id;
  final String? invoiceNumber;
  final String? status;
  final double? paidAmount;
  final double? dueAmount;
  final String? currencyText;

  GetManualPaymentData({
    this.id,
    this.invoiceNumber,
    this.status,
    this.paidAmount,
    this.dueAmount,
    this.currencyText,
  });

  factory GetManualPaymentData.fromJson(Map<String, dynamic> json) {
    return GetManualPaymentData(
      id: json['_id'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      status: json['status'] as String?,
      paidAmount: json['paidAmount'] != null ? (json['paidAmount'] as num).toDouble() : null,
      dueAmount: json['dueAmount'] != null ? (json['dueAmount'] as num).toDouble() : null,
      currencyText: json['currency_text'] as String?,
    );
  }
}

class GetManualPaymentResponse {
  final List<GetManualPaymentData>? getManualPaymentList;

  GetManualPaymentResponse({
    this.getManualPaymentList,
  });

  factory GetManualPaymentResponse.fromJson(Map<String, dynamic> json) {
    return GetManualPaymentResponse(
      getManualPaymentList: (json['data'] as List<dynamic>?)
          ?.map((item) => GetManualPaymentData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
