class AddInvoiceRequest {
  final String userId;
  final String currency;
  final String currencyText;
  final String discount;
  final String discountType;
  final String dueDate;
  final String invoiceCountry;
  final String invoiceDate;
  final String note;
  final String invoiceNumber;
  final String subTotal;
  final String subDiscount;
  final String subTax;
  final List<String> tax;
  final String terms;
  final String total;
  final String clientId;
  final List<Map<String, String>> othersInfo;
  final List<Map<String, dynamic>> productsInfo;

  final String paymentQrCode;
  final String recurring;
  final String recurringCycle;
  final String type;
  final String status;

  AddInvoiceRequest({
    required this.userId,
    required this.currency,
    required this.currencyText,
    required this.discount,
    required this.discountType,
    required this.dueDate,
    required this.invoiceCountry,
    required this.invoiceDate,
    required this.note,
    required this.invoiceNumber,
    required this.subTotal,
    required this.subDiscount,
    required this.subTax,
    required this.tax,
    required this.terms,
    required this.total,
    required this.clientId,
    required this.othersInfo,
    required this.productsInfo,
    required this.paymentQrCode,
    required this.recurring,
    required this.recurringCycle,
    required this.type,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'currency': currency,
      'currency_text': currencyText,
      'discount': discount,
      'discount_type': discountType,
      'due_date': dueDate,
      'invoice_country': invoiceCountry,
      'invoice_date': invoiceDate,
      'note': note,
      'invoice_number': invoiceNumber,
      'subTotal': subTotal,
      'sub_discount': subDiscount,
      'sub_tax': subTax,
      'tax': tax,
      'terms': terms,
      'total': total,
      'userid': clientId,
      'othersInfo': othersInfo,
      'productsInfo': productsInfo,
      'payment_qr_code': paymentQrCode,
      'recurring': recurring,
      'recurring_cycle': recurringCycle,
      'type': type,
      'status': status,
    };
  }
}


class AddInvoiceResponse {
  final int status;
  final String message;

  AddInvoiceResponse({
    required this.status,
    required this.message,
  });

  factory AddInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return AddInvoiceResponse(
      status: json['status'] as int,
      message: json['message'] as String,
    );
  }
}

