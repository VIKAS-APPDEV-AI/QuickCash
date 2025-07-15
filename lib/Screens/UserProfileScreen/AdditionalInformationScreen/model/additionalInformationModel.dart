// login_model.dart
class AdditionalInformationRequest {
  AdditionalInformationRequest();
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

class ReferralDetail {
  final String? referralCode;


  ReferralDetail({
    this.referralCode,
  });

  factory ReferralDetail.fromJson(Map<String, dynamic> json) {
    return ReferralDetail(
      referralCode: json['referral_code'] as String?,
    );
  }
}

class AdditionalInformationResponse {
  final String? state;
  final String? city;
  final String? postalCode;
  final String? documentSubmitted;
  final String? documentNo;
  final List<ReferralDetail>? referralDetails; // List of AccountDetail

  AdditionalInformationResponse({
    this.state,
    this.city,
    this.postalCode,
    this.documentSubmitted,
    this.documentNo,
    this.referralDetails,
  });

  factory AdditionalInformationResponse.fromJson(Map<String, dynamic> json) {
    return AdditionalInformationResponse(
      state: json['data']?['state'] as String?,
      city: json['data']?['city'] as String?,
      postalCode: json['data']?['postalcode'] as String?,
      documentSubmitted: json['data']?['owneridofindividual'] as String?,
      documentNo: json['data']?['ownertaxid'] as String?,

      referralDetails: (json['data']?['referalDetails'] as List<dynamic>?)
          ?.map((item) => ReferralDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
