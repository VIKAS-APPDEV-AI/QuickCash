import 'dart:io';

class ClientUpdateRequest {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final int mobile;
  final int postalCode;
  final String country;
  final String state;
  final String city;
  final String address;
  final String notes;
  final File? profilePhoto;

  ClientUpdateRequest({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.postalCode,
    required this.country,
    required this.state,
    required this.city,
    required this.address,
    required this.notes,
    this.profilePhoto,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobile': mobile,
      'postalCode': postalCode,
      'country': country,
      'state': state,
      'city': city,
      'address': address,
      'notes': notes,
    };
  }
}


class ClientUpdateResponse {
  final String? message;

  ClientUpdateResponse({
    this.message,

  });

  factory ClientUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ClientUpdateResponse(
      message: json['message'] as String?,
    );
  }
}
