
class SendOTPRequest {
  final String email;
  final String name;

  SendOTPRequest({required this.email, required this.name});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
    };
  }
}

class SendOTPResponse {
  final String? message;
  final int? otp;


  SendOTPResponse({this.message, this.otp});

  factory SendOTPResponse.fromJson(Map<String, dynamic> json) {
    return SendOTPResponse(
      message: json['message'] as String?,
      otp: json['data'] as int?,
    );
  }
}


