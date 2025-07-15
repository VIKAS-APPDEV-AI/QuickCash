class InvoiceDetails {
  final String? id;
  final String? invoiceNumber;
  final String? currency;
  final double? total;

  InvoiceDetails({
    this.id,
    this.invoiceNumber,
    this.currency,
    this.total,
  });

  factory InvoiceDetails.fromJson(Map<String, dynamic> json) {
    return InvoiceDetails(
      id: json['_id'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      currency: json['currency'] as String?,
      total: (json['total'] as num?)?.toDouble(),
    );
  }
}

class InvoiceTransactionData {
  final String? id;
  final String? user;
  final String? fromCurrency;
  final String? toCurrency;
  final double? amount;
  final double? convertAmount;
  final String? dateAdded;
  final String? info;
  final String? transType;
  final List<InvoiceDetails>? invoiceDetails;

  InvoiceTransactionData({
    this.id,
    this.user,
    this.fromCurrency,
    this.toCurrency,
    this.amount,
    this.convertAmount,
    this.dateAdded,
    this.info,
    this.transType,
    this.invoiceDetails,
  });

  factory InvoiceTransactionData.fromJson(Map<String, dynamic> json) {
    return InvoiceTransactionData(
      id: json['_id'] as String?,
      user: json['user'] as String?,
      fromCurrency: json['fromCurrency'] as String?,
      toCurrency: json['toCurrency'] as String?,

      amount: (json['amount'] is int
          ? (json['amount'] as int).toDouble()
          : json['amount']) as double?,


      convertAmount: (json['convertAmount'] is int
          ? (json['convertAmount'] as int).toDouble()
          : json['convertAmount']) as double?,

      dateAdded: json['dateadded'] as String?,
      info: json['info'] as String?,
      transType: json['trans_type'] as String?,
      invoiceDetails: (json['invoiceDetails'] as List<dynamic>?)
          ?.map((item) => InvoiceDetails.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class InvoicesTransactionResponse {
  final List<InvoiceTransactionData>? invoiceTransactionList;

  InvoicesTransactionResponse({
    this.invoiceTransactionList,
  });

  factory InvoicesTransactionResponse.fromJson(Map<String, dynamic> json) {
    return InvoicesTransactionResponse(
      invoiceTransactionList: (json['data'] as List<dynamic>?)
          ?.map((item) => InvoiceTransactionData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
