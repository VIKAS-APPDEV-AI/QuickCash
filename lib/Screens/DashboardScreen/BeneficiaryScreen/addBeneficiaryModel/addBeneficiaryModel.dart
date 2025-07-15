class AddBeneficiaryRequest {
  final String userId;
  final String name;
  final String email;
  final String address;
  final String mobile;
  final String iban;
  final String bicCode;
  final String country;
  final String rType;
  final String currency;
  final bool status;
  final String bankName;

  AddBeneficiaryRequest({
    required this.userId,
    required this.name,
    required this.email,
    required this.address,
    required this.mobile,
    required this.iban,
    required this.bicCode,
    required this.country,
    required this.rType,
    required this.currency,
    required this.status,
    required this.bankName,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'name': name,
      'email': email,
      'address': address,
      'mobile': mobile,
      'iban': iban,
      'bic_code': bicCode,
      'country': country,
      'rtype': country,
      'currency': currency,
      'status': status,
      'bankName': bankName,
    };
  }
}

class AddBeneficiaryResponse {
  final int status;
  final String message;

  AddBeneficiaryResponse({
    required this.status,
    required this.message,
  });

  factory AddBeneficiaryResponse.fromJson(Map<String, dynamic> json) {
    return AddBeneficiaryResponse(
      status: json['status'] as int,
      message: json['message'] as String,
    );
  }
}

