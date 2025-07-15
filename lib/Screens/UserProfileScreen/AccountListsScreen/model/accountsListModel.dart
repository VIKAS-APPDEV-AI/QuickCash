// login_model.dart
class AccountDetailsRequest {

  AccountDetailsRequest();
}

class AccountDetail {
  final String? id;
  final String? name;
  final String? iban;
  final int? bicCode;
  final String? country;
  final String? currency;
  final double? amount;
  final bool? status;

  AccountDetail({
    this.id,
    this.name,
    this.iban,
    this.bicCode,
    this.country,
    this.currency,
    this.amount,
    this.status,
  });

  factory AccountDetail.fromJson(Map<String, dynamic> json) {
    return AccountDetail(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      iban: json['iban'] as String?,
      bicCode: json['bic_code'] as int?,
      country: json['country'] as String?,
      currency: json['currency'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status'] as bool?,
    );
  }
}

class AccountsListResponse {

  final List<AccountDetail>? accountDetails; // List of AccountDetail

  AccountsListResponse({
    this.accountDetails,
  });

  factory AccountsListResponse.fromJson(Map<String, dynamic> json) {
    return AccountsListResponse(
      accountDetails: (json['data']?['accountDetails'] as List<dynamic>?)
          ?.map((item) => AccountDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
