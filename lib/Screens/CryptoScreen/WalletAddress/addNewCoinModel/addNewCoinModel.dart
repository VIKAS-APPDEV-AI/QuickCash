class AddNewCoinRequest {
  final String coinName;
  final String userEmail;
  final String status;
  final String userId;

  AddNewCoinRequest({
    required this.coinName,
    required this.userEmail,
    required this.status,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'coin': coinName,
      'email': userEmail,
      'status': status,
      'user': userId,
    };
  }
}


class AddNewCoinResponse {
  final String? message;

  AddNewCoinResponse({
    this.message,

  });

  factory AddNewCoinResponse.fromJson(Map<String, dynamic> json) {
    return AddNewCoinResponse(
      message: json['message'] as String?,
    );
  }
}
