// login_model.dart
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponse {
  final String userId;
  final String token;
  final String name;
  final String email;
  final String? ownerProfile; // Nullable because it can be null in the response
  final bool kycStatus;

  LoginResponse({
    required this.userId,
    required this.token,
    required this.name,
    required this.email,
    this.ownerProfile, // Nullable field
    required this.kycStatus,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json['user_id'] ?? '',
      token: json['token'] ?? '',
      name: json['data']?['name'] ?? '', // Defaults to an empty string if null
      email: json['data']?['email'] ?? '', // Defaults to an empty string if null
      ownerProfile: json['data']?['ownerProfile'], // Nullable, no default
      kycStatus: json['data']?['kycstatus'] ?? false, // Defaults to false if null
    );
  }
}

