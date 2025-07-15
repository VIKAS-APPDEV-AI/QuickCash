class RequestWalletAddressRequest {
  final String userId;
  final String coinType;

  RequestWalletAddressRequest({
    required this.userId,
    required this.coinType,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'coin': coinType,
    };
  }
}

class RequestWalletAddressResponse {
  final int status;
  final String message;
  final String data;  // Now the 'data' is a string (the wallet address)

  RequestWalletAddressResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RequestWalletAddressResponse.fromJson(Map<String, dynamic> json) {
    return RequestWalletAddressResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: json['data'] as String,  // The wallet address is directly assigned
    );
  }
}
