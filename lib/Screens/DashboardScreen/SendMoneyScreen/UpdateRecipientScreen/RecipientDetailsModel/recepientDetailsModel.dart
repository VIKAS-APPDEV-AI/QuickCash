class RecipientDetails {
  final String? id;
  final String? user;
  final String? name;
  final String? email;
  final String? rtype;
  final String? mobile;
  final String? address;
  final String? iban;
  final String? bicCode;
  final String? country;
  final String? currency;
  final double? amount;
  final String? bankName;
  final bool? status;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  RecipientDetails({
    this.id,
    this.user,
    this.name,
    this.email,
    this.rtype,
    this.mobile,
    this.address,
    this.iban,
    this.bicCode,
    this.country,
    this.currency,
    this.amount,
    this.bankName,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory RecipientDetails.fromJson(Map<String, dynamic> json) {
    return RecipientDetails(
      id: json['_id'] as String?,
      user: json['user'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      rtype: json['rtype'] as String?,
      mobile: json['mobile'] as String?,
      address: json['address'] as String?,
      iban: json['iban'] as String?,
      bicCode: json['bic_code'] as String?,
      country: json['country'] as String?,
      currency: json['currency'] as String?,
      amount: (json['amount'] is int
          ? (json['amount'] as int).toDouble()
          : json['amount']) as double?,
      bankName: json['bankName'] as String?,
      status: json['status'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      v: json['__v'] as int?,
    );
  }
}

class RecipientsDetailsResponse {
  final int? status;
  final String? message;
  final List<RecipientDetails>? recipientDetails;

  RecipientsDetailsResponse({
    this.status,
    this.message,
    this.recipientDetails,
  });

  factory RecipientsDetailsResponse.fromJson(Map<String, dynamic> json) {
    return RecipientsDetailsResponse(
      status: json['status'] as int?,
      message: json['message'] as String?,
      recipientDetails: json['data'] != null
          ? [RecipientDetails.fromJson(json['data'] as Map<String, dynamic>)]
          : [], // Convert data into a list of RecipientDetails
    );
  }
}
