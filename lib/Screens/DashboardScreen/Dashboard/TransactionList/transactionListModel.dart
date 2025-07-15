class TransactionListDetails {
  final String? transactionDate;
  final String? transactionId;
  final String? transactionType;
  final String? transactionAmount;
  final String? trxId;
  final String? to_currency;
  final String? info;
  final String? conversionAmount;
  final String? conversionAmounttext;
  final double? balance;
  final String? transactionStatus;
  final double? amount;
  final double? fees;
  final String? fromCurrency;
  final String? extraType; // Added extraType as nullable

  TransactionListDetails({
    this.info,
    this.to_currency,
    this.transactionDate,
    this.conversionAmount,
    this.conversionAmounttext,
    this.transactionId,
    this.transactionType,
    this.transactionAmount,
    this.trxId,
    this.balance,
    this.transactionStatus,
    this.amount,
    this.fees,
    this.fromCurrency,
    this.extraType, // Added this
  });

  factory TransactionListDetails.fromJson(Map<String, dynamic> json) {
    return TransactionListDetails(
      transactionDate: json['createdAt'] as String?,
      to_currency: json['to_currency'] as String?,
      conversionAmount: json['conversionAmount']?.toString(),
      conversionAmounttext: json['conversionAmountText'] as String?,
      transactionId: json['trx'] as String?,
      transactionType: json['trans_type'] as String?,
      info: json['info'] as String?,
      transactionAmount: json['amountText'] as String?,
      trxId: json['_id'] as String?,
      balance: (json['postBalance'] is int
          ? (json['postBalance'] as int).toDouble()
          : json['postBalance']) as double?,
      transactionStatus: json['status'] as String?,
      amount: (json['amount'] is int
          ? (json['amount'] as int).toDouble()
          : json['amount']) as double?,
      fees: (json['fee'] is int ? (json['fee'] as int).toDouble() : json['fee'])
          as double?,
      fromCurrency: json['from_currency'] as String?,
      extraType: json['extraType'] as String?, // Added this
    );
  }

  // Added toJson method
  Map<String, dynamic> toJson() {
    return {
      'createdAt': transactionDate,
      'to_currency': to_currency,
      'conversionAmount': conversionAmount,
      'info': info,
      'conversionAmountText': conversionAmounttext,
      'trx': transactionId,
      'trans_type': transactionType,
      'amountText': transactionAmount,
      '_id': trxId,
      'postBalance': balance,
      'status': transactionStatus,
      'amount': amount,
      'fee': fees,
      'from_currency': fromCurrency,
      'extraType': extraType, // Added this
    };
  }
}

class TransactionListResponse {
  final List<TransactionListDetails>? transactionList;

  TransactionListResponse({
    this.transactionList,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    return TransactionListResponse(
      transactionList: (json['data'] as List<dynamic>?)
          ?.map((item) =>
              TransactionListDetails.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  // Added toJson method
  Map<String, dynamic> toJson() {
    return {
      'data': transactionList?.map((t) => t.toJson()).toList() ?? [],
    };
  }
}
