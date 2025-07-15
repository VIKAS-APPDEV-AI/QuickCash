class CryptoSellResponse {
  final int status;
  final String message;
  final String data;

  // Constructor
  CryptoSellResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  // Factory method to create a CryptoResponse from JSON
  factory CryptoSellResponse.fromJson(Map<String, dynamic> json) {
    return CryptoSellResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'].toString(),
    );
  }

  // Method to convert CryptoResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}
