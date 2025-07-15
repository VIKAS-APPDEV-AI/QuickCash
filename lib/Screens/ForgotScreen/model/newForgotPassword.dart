// login_model.dart
class newForgotPasswordRequest {
  final String email;

  newForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

// Response Model
class NewForgotPasswordResponse {
  final String? message;

  NewForgotPasswordResponse({this.message});

  factory NewForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return NewForgotPasswordResponse(
      message: json['message'] as String,
    );
  }

  // @override
  // String toString() {
  //   return 'NewForgotPasswordResponse(message: $message)';
  // }
}

