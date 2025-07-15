class QuoteDetailData {
  final String? id;
  final String? user;
  final String? userId;
  final String? url;
  final String? quoteNumber;
  final String? invoiceDate;
  final String? dueDate;
  final String? status;
  final String? invoiceCountry;
  final String? currency;
  final List<ProductInfo>? productsInfo;
  final double? discount;
  final String? discountType;
  final List<String>? tax;
  final double? subTotal;
  final double? subDiscount;
  final double? subTax;
  final double? total;
  final String? note;
  final String? terms;
  final String? currencyText;
  final String? createdAt;
  final List<UserDetails>? userDetails;

  QuoteDetailData({
    this.id,
    this.user,
    this.userId,
    this.url,
    this.quoteNumber,
    this.invoiceDate,
    this.dueDate,
    this.status,
    this.invoiceCountry,
    this.currency,
    this.productsInfo,
    this.discount,
    this.discountType,
    this.tax,
    this.subTotal,
    this.subDiscount,
    this.subTax,
    this.total,
    this.note,
    this.terms,
    this.currencyText,
    this.createdAt,
    this.userDetails,
  });

  factory QuoteDetailData.fromJson(Map<String, dynamic> json) {
    return QuoteDetailData(
      id: json['_id'] as String?,
      user: json['user'] as String?,
      userId: json['userid'] as String?,
      url: json['url'] as String?,
      quoteNumber: _parseString(json['quote_number']),
      invoiceDate: json['invoice_date'] as String?,
      dueDate: json['due_date'] as String?,
      status: json['status'] as String?,
      invoiceCountry: json['invoice_country'] as String?,
      currency: json['currency'] as String?,
      productsInfo: (json['productsInfo'] as List<dynamic>?)
          ?.map((item) => ProductInfo.fromJson(item as Map<String, dynamic>))
          .toList(),
      discount: _parseDouble(json['discount']),
      discountType: json['discount_type'] as String?,
      tax: (json['tax'] as List<dynamic>?)?.map((item) => item as String).toList(),
      subTotal: _parseDouble(json['subTotal']),
      subDiscount: _parseDouble(json['sub_discount']),
      subTax: _parseDouble(json['sub_tax']),
      total: _parseDouble(json['total']),
      note: json['note'] as String?,
      terms: json['terms'] as String?,
      currencyText: json['currency_text'] as String?,
      createdAt: json['createdAt'] as String?,
      userDetails: (json['userDetails'] as List<dynamic>?)
          ?.map((item) => UserDetails.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return value.toString(); // Convert int to String if needed
    } else if (value is String) {
      return value;
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return double.tryParse(value);
    } else if (value is int) {
      return value.toDouble(); // Handle case where value is int
    } else if (value is double) {
      return value;
    }
    return null;
  }
}

class ProductInfo {
  final String? productName;
  final String? productId;
  final String? quantity;
  final double? price;
  final double? tax;
  final double? taxValue;
  final double? amount;

  ProductInfo({
    this.productName,
    this.productId,
    this.quantity,
    this.price,
    this.tax,
    this.taxValue,
    this.amount,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      productName: json['productName'] as String?,
      productId: json['productId'] as String?,
      quantity: json['quantity'] as String?,
      price: _parseDouble(json['price']),
      tax: _parseDouble(json['tax']),
      taxValue: _parseDouble(json['taxValue']),
      amount: _parseDouble(json['amount']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return double.tryParse(value);
    } else if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    }
    return null;
  }
}

class UserDetails {
  final String? id;
  final String? name;
  final String? email;
  final int? mobile;
  final String? address;
  final String? city;
  final String? country;
  final String? defaultCurrency;
  final bool? status;

  UserDetails({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.address,
    this.city,
    this.country,
    this.defaultCurrency,
    this.status,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as int?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      defaultCurrency: json['defaultCurrency'] as String?,
      status: json['status'] as bool?,
    );
  }
}

class QuoteDetailsResponse {
  final int status;
  final String message;
  final List<QuoteDetailData>? quoteList;

  QuoteDetailsResponse({
    required this.status,
    required this.message,
    this.quoteList,
  });

  factory QuoteDetailsResponse.fromJson(Map<String, dynamic> json) {
    return QuoteDetailsResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      quoteList: (json['data'] as List<dynamic>?)
          ?.map((item) => QuoteDetailData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
