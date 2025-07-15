class UserProfileRequest {
  UserProfileRequest();
}

class SenderDetail {
  final String? senderName;
  final String? senderAccountNumber;
  final String? senderAddress;

  SenderDetail({
    this.senderName,
    this.senderAccountNumber,
    this.senderAddress,
  });

  factory SenderDetail.fromJson(Map<String, dynamic> json) {
    return SenderDetail(
      senderName: json['name'] as String?,
      senderAccountNumber: json['iban'] as String?,
      senderAddress: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': senderName,
      'iban': senderAccountNumber,
      'address': senderAddress,
    };
  }
}

class ReceiverDetail {
  final String? receiverName;
  final String? receiverAccountNumber;
  final String? receiverAddress;

  ReceiverDetail({
    this.receiverName,
    this.receiverAccountNumber,
    this.receiverAddress,
  });

  factory ReceiverDetail.fromJson(Map<String, dynamic> json) {
    return ReceiverDetail(
      receiverName: json['name'] as String?,
      receiverAccountNumber: json['iban'] as String?,
      receiverAddress: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': receiverName,
      'iban': receiverAccountNumber,
      'address': receiverAddress,
    };
  }
}

class TransactionDetailsListResponse {
  final String? trx;
  final String? toCurrency;
  final String? fromCurrency;
  final String? requestedDate;
  final double? conversionAmount;
  final String? amountText;
  final double? fee;
  final double? billAmount;
  final String? transactionType;
  final String? extraType;
  final String? status;
  final List<SenderDetail>? senderDetail;
  final List<ReceiverDetail>? receiverDetail;

  TransactionDetailsListResponse({
    this.trx,
    this.toCurrency,
    this.conversionAmount,
    this.fromCurrency,
    this.requestedDate,
    this.amountText,
    this.fee,
    this.billAmount,
    this.transactionType,
    this.extraType,
    this.status,
    this.senderDetail,
    this.receiverDetail,
  });

  factory TransactionDetailsListResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null || json['data'] is! List || (json['data'] as List).isEmpty) {
      return TransactionDetailsListResponse();
    }

    var data = json['data'][0] as Map<String, dynamic>;

    return TransactionDetailsListResponse(
      trx: data['trx'] as String?,
      fromCurrency: data['from_currency'] as String?,
      toCurrency: data['to_currency'] as String?,
      conversionAmount: (data['conversionAmount'] is int)
          ? (data['conversionAmount'] as int).toDouble()
          : data['conversionAmount'] as double?,
      requestedDate: data['createdAt'] as String?,
      fee: (data['fee'] is int) ? (data['fee'] as int).toDouble() : data['fee'] as double?,
      billAmount: (data['amount'] is int) ? (data['amount'] as int).toDouble() : data['amount'] as double?,
      amountText: data['amountText'] as String?,
      transactionType: data['trans_type'] as String?,
      extraType: data['extraType'] as String?,
      status: data['status'] as String?,
      senderDetail: (data['senderAccountDetails'] is List)
          ? (data['senderAccountDetails'] as List)
              .map((item) => SenderDetail.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      receiverDetail: (data['transferAccountDetails'] is List)
          ? (data['transferAccountDetails'] as List)
              .map((item) => ReceiverDetail.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trx': trx,
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'conversionAmount': conversionAmount,
      'createdAt': requestedDate,
      'fee': fee,
      'amount': billAmount,
      'amountText': amountText,
      'trans_type': transactionType,
      'extraType': extraType,
      'status': status,
      'senderAccountDetails': senderDetail?.map((e) => e.toJson()).toList(),
      'transferAccountDetails': receiverDetail?.map((e) => e.toJson()).toList(),
    };
  }
}
