class InvoiceNoResponse {
  final String? message;
  final String? invoiceNo;

  InvoiceNoResponse({
    this.message,
    this.invoiceNo,

  });

  factory InvoiceNoResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceNoResponse(
      message: json['message'] as String?,
      invoiceNo: json['invoiceid'] as String?,
    );
  }
}