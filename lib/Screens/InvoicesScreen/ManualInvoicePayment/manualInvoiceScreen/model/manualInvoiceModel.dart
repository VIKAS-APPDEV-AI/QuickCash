class ManualInvoiceData {
  final String? id;
  final List<UserDetail>? userDetails;
  final List<ClientInfo>? clientInfo;
  final double? amount;
  final String? amountCurrencyText;
  final String? paymentDate;
  final String? paymentMode;
  final String? notes;
  final List<InvoiceDetail>? invoiceDetails;

  ManualInvoiceData({
    this.id,
    this.userDetails,
    this.clientInfo,
    this.amount,
    this.amountCurrencyText,
    this.paymentDate,
    this.paymentMode,
    this.notes,
    this.invoiceDetails,
  });

  factory ManualInvoiceData.fromJson(Map<String, dynamic> json) {
    return ManualInvoiceData(
      id: json['_id'] as String?,
      userDetails: (json['userDetails'] as List<dynamic>?)
          ?.map((item) => UserDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
      clientInfo: (json['clientInfo'] as List<dynamic>?)
          ?.map((item) => ClientInfo.fromJson(item as Map<String, dynamic>))
          .toList(),

      amount: (json['amount'] is int
          ? (json['amount'] as int).toDouble()
          : json['amount']) as double?,



      amountCurrencyText: json['amountCurrencyText'] as String?,
      paymentDate: json['paymentDate'] as String?,
      paymentMode: json['paymentMode'] as String?,
      notes: json['notes'] as String?,
      invoiceDetails: (json['invoiceDetails'] as List<dynamic>?)
          ?.map((item) => InvoiceDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UserDetail {
  final String? firstName;
  final String? lastName;
  final String? email;

  UserDetail({
    this.firstName,
    this.lastName,
    this.email,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
    );
  }
}

class ClientInfo {
  final String? name;
  final String? email;

  ClientInfo({
    this.name,
    this.email,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      name: json['name'] as String?,
      email: json['email'] as String?,
    );
  }
}

class InvoiceDetail {
  final String? userId;
  final List<OtherInfo>? othersInfo;
  final String? invoiceNumber;

  InvoiceDetail({
    this.userId,
    this.othersInfo,
    this.invoiceNumber,
  });

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) {
    return InvoiceDetail(
      userId: json['userid'] as String?,
      othersInfo: (json['othersInfo'] as List<dynamic>?)
          ?.map((item) => OtherInfo.fromJson(item as Map<String, dynamic>))
          .toList(),
      invoiceNumber: json['invoice_number'] as String?,
    );
  }
}

class OtherInfo {
  final String? name;
  final String? email;
  final String? address;

  OtherInfo({
    this.name,
    this.email,
    this.address,
  });

  factory OtherInfo.fromJson(Map<String, dynamic> json) {
    return OtherInfo(
      name: json['name'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
    );
  }
}

class ManualInvoicesResponse {
  final List<ManualInvoiceData>? manualInvoiceList;

  ManualInvoicesResponse({
    this.manualInvoiceList,
  });

  factory ManualInvoicesResponse.fromJson(Map<String, dynamic> json) {
    return ManualInvoicesResponse(
      manualInvoiceList: (json['data'] as List<dynamic>?)
          ?.map((item) => ManualInvoiceData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
