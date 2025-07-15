
class AccountsListsData {
  final String? accountId;
  final String? country;
  final String? Accountname;
  final String? currency;
  final String? iban;
  final bool? status;
  final double? amount;

  AccountsListsData({
    this.accountId,
    this.Accountname,
    this.country,
    this.currency,
    this.iban,
    this.status,
    this.amount,
  });

  factory AccountsListsData.fromJson(Map<String, dynamic> json) {
    return AccountsListsData(
      accountId: json['_id'] as String?,
      Accountname: json['name'] as String?,
      country: json['country'] as String?,
      currency: json['currency'] as String?,
      iban: json['iban'] as String?,
      status: json['defaultAccount'] as bool?,
      amount: (json['amount'] is int
          ? (json['amount'] as int).toDouble()
          : json['amount']) as double?,
    );
  }
}

class AccountListResponse {
  final List<AccountsListsData>? accountsList;

  AccountListResponse({
    this.accountsList,
  });

  factory AccountListResponse.fromJson(Map<String, dynamic> json) {
    return AccountListResponse(
      accountsList: (json['data'] as List<dynamic>? )
          ?.map((item) => AccountsListsData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
