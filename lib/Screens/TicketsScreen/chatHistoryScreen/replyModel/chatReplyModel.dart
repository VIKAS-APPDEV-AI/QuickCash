class ChatReplyResponse {
  final String? message;

  ChatReplyResponse({
    this.message,

  });

  factory ChatReplyResponse.fromJson(Map<String, dynamic> json) {
    return ChatReplyResponse(
      message: json['message'] as String?,
    );
  }
}