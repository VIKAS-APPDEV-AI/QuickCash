class AddCardResponse {
  final String? message;
  final int? status;

  AddCardResponse({this.message,this.status});

  factory AddCardResponse.fromJson(Map<String, dynamic> json) {
    return AddCardResponse(
      message: json['message'] as String?,
      status: json['status'] as int?,
    );
  }
}