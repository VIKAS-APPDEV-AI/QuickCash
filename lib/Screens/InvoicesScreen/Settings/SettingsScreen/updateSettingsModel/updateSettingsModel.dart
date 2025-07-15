import 'dart:io';

class UpdateSettingsRequest {
  final String userId;
  final String country;
  final String companyName;
  final String mobileNo;
  final String state;
  final String city;
  final String zipCode;
  final String address;
  final String prefix;
  final String regardsText;
  final File? logo; // Add this

  UpdateSettingsRequest({
    required this.userId,
    required this.country,
    required this.companyName,
    required this.mobileNo,
    required this.state,
    required this.city,
    required this.zipCode,
    required this.address,
    required this.prefix,
    required this.regardsText,
    this.logo, // Optional for now
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'invoice_country': country,
      'company_name': companyName,
      'mobile': mobileNo,
      'state': state,
      'city': city,
      'zipcode': zipCode,
      'address': address,
      'prefix': prefix,
      'regardstext': regardsText,
    };
  }
}



class UpdateSettingsResponse {
  final String? message;

  UpdateSettingsResponse({
    this.message,

  });

  factory UpdateSettingsResponse.fromJson(Map<String, dynamic> json) {
    return UpdateSettingsResponse(
      message: json['message'] as String?,
    );
  }
}
