// login_model.dart
class BeneficiaryAccountList {
  BeneficiaryAccountList();
}

class BeneficiaryAccountListDetails {
  final String? currency;
  final String? iban;
  final String? bic;
  final double? balance;

  BeneficiaryAccountListDetails({
    this.currency,
    this.iban,
    this.bic,
    this.balance,
  });

  factory BeneficiaryAccountListDetails.fromJson(Map<String, dynamic> json) {
    return BeneficiaryAccountListDetails(
      currency: json['currency'] as String?,
      iban: json['iban'] as String?,
      bic: json['bic_code'] as String?,
      balance: (json['amount'] as num?)?.toDouble(),
    );
  }
}

class BeneficiaryListResponse {
  final List<BeneficiaryAccountListDetails>? beneficiaryAccountList; // Change to List<BeneficiaryAccountListDetails>

  BeneficiaryListResponse({
    this.beneficiaryAccountList,
  });

  factory BeneficiaryListResponse.fromJson(Map<String, dynamic> json) {
    return BeneficiaryListResponse(
      beneficiaryAccountList: (json['data'] as List<dynamic>?)
          ?.map((item) => BeneficiaryAccountListDetails.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
