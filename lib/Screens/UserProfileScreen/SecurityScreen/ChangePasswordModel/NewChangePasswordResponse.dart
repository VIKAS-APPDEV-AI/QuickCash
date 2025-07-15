class NewChangePasswordRequest {
  final String token;
  final String password;

  NewChangePasswordRequest({required this.token, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'password': password,
    };
  }
}

class NewChangePasswordResponse {
  final String? token;

  NewChangePasswordResponse({this.token});

  factory NewChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return NewChangePasswordResponse(
      token: json['token'] as String?,
    );
  }
}
