class CreateTicketRequest {
  final String cardStatus;
  final String subject;
  final String userId;
  final String message;


  CreateTicketRequest({
    required this.cardStatus,
    required this.subject,
    required this.userId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': cardStatus,
      'subject': subject,
      'user': userId,
      'message': message,

    };
  }
}


class CreateTicketResponse {
  final String? message;

  CreateTicketResponse({
    this.message,

  });

  factory CreateTicketResponse.fromJson(Map<String, dynamic> json) {
    return CreateTicketResponse(
      message: json['message'] as String?,
    );
  }
}
