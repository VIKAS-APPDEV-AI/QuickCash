
class ChangePasswordRequest {
  final String password;
  final String confirmPassword;

  ChangePasswordRequest({required this.password, required this.confirmPassword});

  Map<String, dynamic> toJson() {
    return {
      'new_passsword': password,
      'confirm_password': confirmPassword,
    };
  }
}

class ChangePasswordResponse {
  final String? message;


  ChangePasswordResponse({this.message});

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      message: json['message'] as String?,
    );
  }
}


