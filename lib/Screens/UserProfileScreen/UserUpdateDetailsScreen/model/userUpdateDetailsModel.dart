class UserProfileUpdateRequest {
  final String userId;
  final String name;
  final String email;
  final int mobile;
  final String address;
  final String country;
  final String state;
  final String city;
  final int postalCode;
  final String title;

  UserProfileUpdateRequest({
    required this.userId,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
    required this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'mobile': mobile,
      'address': address,
      'country': country,
      'state': state,
      'city': city,
      'postalcode': postalCode,
      'ownerTitle': title,
    };
  }
}


class UserProfileUpdateResponse {
  final String? message;

  UserProfileUpdateResponse({
    this.message,

  });

  factory UserProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileUpdateResponse(
      message: json['message'] as String?,
    );
  }
}
