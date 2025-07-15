class AddQuoteRequest {
  final String userId;
  final String currency;
  final String currencyText;
  final String discount;
  final String discountType;
  final String dueDate;
  final String invoiceCountry;
  final String invoiceDate;
  final String note;
  final String quoteNumber;
  final String subTotal;
  final String subDiscount;
  final String subTax;
  final List<String> tax;
  final String terms;
  final String total;
  final String clientId;
  final List<Map<String, String>> othersInfo;
  final List<Map<String, dynamic>> productsInfo;

  AddQuoteRequest({
    required this.userId,
    required this.currency,
    required this.currencyText,
    required this.discount,
    required this.discountType,
    required this.dueDate,
    required this.invoiceCountry,
    required this.invoiceDate,
    required this.note,
    required this.quoteNumber,
    required this.subTotal,
    required this.subDiscount,
    required this.subTax,
    required this.tax,
    required this.terms,
    required this.total,
    required this.clientId,
    required this.othersInfo,
    required this.productsInfo,
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
      'quote_number': quoteNumber,
      'subTotal': subTotal,
      'sub_discount': subDiscount,
      'sub_tax': subTax,
      'tax': tax,
      'terms': terms,
      'total': total,
      'userid': clientId,
      'othersInfo': othersInfo,
      'productsInfo': productsInfo,
    };
  }
}


class AddQuoteResponse {
  final int status;
  final String message;

  AddQuoteResponse({
    required this.status,
    required this.message,
  });

  factory AddQuoteResponse.fromJson(Map<String, dynamic> json) {
    return AddQuoteResponse(
      status: json['status'] as int,
      message: json['message'] as String,
    );
  }
}

