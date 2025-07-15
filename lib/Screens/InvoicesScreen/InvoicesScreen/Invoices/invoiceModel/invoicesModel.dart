class InvoicesData {
  final String? id;
  final String? user;
  final String? account;
  final String? userid;
  final String? reference;
  final String? url;
  final List<OtherInfo>? othersInfo;
  final String? invoiceNumber;
  final String? invoiceDate;
  final String? dueDate;
  final String? status;
  final String? transactionStatus;
  final String? invoiceCountry;
  final String? paymentQrCode;
  final String? currency;
  final String? recurringDate;
  final String recurring;
  final int? recurringCycle;
  final List<ProductInfo>? productsInfo;
  final double? subTotal;
  final double? subDiscount;
  final double? subTax;
  final double? total;
  final double? usdTotal;
  final double? paidAmount;
  final double? dueAmount;
  final String? note;
  final String? terms;
  final String? currencyText;
  final String? createdAt;
  final String? updatedAt;

  InvoicesData({
    this.id,
    this.user,
    this.account,
    this.userid,
    this.reference,
    this.url,
    this.othersInfo,
    this.invoiceNumber,
    this.invoiceDate,
    this.dueDate,
    this.status,
    this.transactionStatus,
    this.invoiceCountry,
    this.paymentQrCode,
    this.currency,
    this.recurringDate,
    required this.recurring,
    this.recurringCycle,
    this.productsInfo,
    this.subTotal,
    this.subDiscount,
    this.subTax,
    this.total,
    this.usdTotal,
    this.paidAmount,
    this.dueAmount,
    this.note,
    this.terms,
    this.currencyText,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoicesData.fromJson(Map<String, dynamic> json) {
    return InvoicesData(
      id: json['_id'] as String?,
      user: json['user'] as String?,
      account: json['account'] as String?,
      userid: json['userid'] as String?,
      reference: json['reference'] as String?,
      url: json['url'] as String?,
      othersInfo: (json['othersInfo'] as List<dynamic>?)
          ?.map((item) => OtherInfo.fromJson(item as Map<String, dynamic>))
          .toList(),
      invoiceNumber: json['invoice_number'] as String?,
      invoiceDate: json['invoice_date'] as String?,
      dueDate: json['due_date'] as String?,
      status: json['status'] as String?,
      transactionStatus: json['transactionStatus'] as String?,
      invoiceCountry: json['invoice_country'] as String?,
      paymentQrCode: json['payment_qr_code'] as String?,
      currency: json['currency'] as String?,
      recurringDate: json['recurringDate'] as String?,
      recurring: json['recurring'] as String,
      recurringCycle: json['recurring_cycle'] as int?,
      productsInfo: (json['productsInfo'] as List<dynamic>?)
          ?.map((item) => ProductInfo.fromJson(item as Map<String, dynamic>))
          .toList(),
      subTotal: (json['subTotal'] is int
          ? (json['subTotal'] as int).toDouble()
          : json['subTotal']) as double?,
      subDiscount: (json['sub_discount'] is int
          ? (json['sub_discount'] as int).toDouble()
          : json['sub_discount']) as double?,
      subTax: (json['sub_tax'] is int
          ? (json['sub_tax'] as int).toDouble()
          : json['sub_tax']) as double?,
      total: (json['total'] is int
          ? (json['total'] as int).toDouble()
          : json['total']) as double?,
      usdTotal: (json['usdtotal'] is int
          ? (json['usdtotal'] as int).toDouble()
          : json['usdtotal']) as double?,
      paidAmount: (json['paidAmount'] is int
          ? (json['paidAmount'] as int).toDouble()
          : json['paidAmount']) as double?,
      dueAmount: (json['dueAmount'] is int
          ? (json['dueAmount'] as int).toDouble()
          : json['dueAmount']) as double?,
      note: json['note'] as String?,
      terms: json['terms'] as String?,
      currencyText: json['currency_text'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class ProductInfo {
  final String? productName;
  final String? productId;
  final String? qty;
  final int? price;
  final int? tax;
  final int? taxValue;
  final int? amount;

  ProductInfo({
    this.productName,
    this.productId,
    this.qty,
    this.price,
    this.tax,
    this.taxValue,
    this.amount,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      productName: json['productName'] as String?,
      productId: json['productId'] as String?,
      qty: json['qty'] as String?,
      price: (json['price'] is String ? int.tryParse(json['price']) : json['price']) as int?,
      tax: json['tax'] as int?,
      taxValue: json['taxValue'] as int?,
      amount: (json['amount'] is String ? double.tryParse(json['amount'])?.toInt() : json['amount']) as int?,
    );
  }
}

class OtherInfo {
  final String? email;
  final String? name;
  final String? address;

  OtherInfo({
    this.email,
    this.name,
    this.address,
  });

  factory OtherInfo.fromJson(Map<String, dynamic> json) {
    return OtherInfo(
      email: json['email'] as String?,
      name: json['name'] as String?,
      address: json['address'] as String?,
    );
  }
}

class InvoicesResponse {
  final List<InvoicesData>? invoicesList;

  InvoicesResponse({
    this.invoicesList,
  });

  factory InvoicesResponse.fromJson(Map<String, dynamic> json) {
    return InvoicesResponse(
      invoicesList: (json['data'] as List<dynamic>?)
          ?.map((item) => InvoicesData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
