class DeleteClientResponse {
  final String? message;

  DeleteClientResponse({
    this.message,

  });

  factory DeleteClientResponse.fromJson(Map<String, dynamic> json) {
    return DeleteClientResponse(
      message: json['message'] as String?,
    );
  }
}