class AccountDetailsResponse {
  final String? name;
  final double? amount;
  final String? accountNo;
  final int? ifscCode;
  final String? currency;

  AccountDetailsResponse({
    this.name,
    this.amount,
    this.accountNo,
    this.ifscCode,
    this.currency,
  });

  factory AccountDetailsResponse.fromJson(Map<String, dynamic> json) {
    var amount = json['data']?['amount'];
    var fee = json['data']?['fee'];

    return AccountDetailsResponse(
      name: json['data']?['name'] as String?,
      amount: (amount is int) ? amount.toDouble() : amount as double?, // Convert amount to double
      accountNo: json['data']?['iban']?.toString(),
      ifscCode: json['data']?['bic_code'] as int?,
      currency: json['data']?['currency'] as String?,
    );
  }
}
