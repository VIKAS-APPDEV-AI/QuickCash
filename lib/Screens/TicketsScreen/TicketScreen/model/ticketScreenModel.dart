
class TicketListsData {
  final String? id;
  final String? ticketId;
  final String? subject;
  final String? message;
  final String? status;
  final String? date;

  TicketListsData({
    this.id,
    this.ticketId,
    this.subject,
    this.message,
    this.status,
    this.date,
  });

  factory TicketListsData.fromJson(Map<String, dynamic> json) {
    return TicketListsData(
      id: json['_id'] as String?,
      ticketId: json['ticketId'] as String?,
      subject: json['subject'] as String?,
      message: json['message'] as String?,
      status: json['status'] as String?,
      date: json['createdAt'] as String?,
    );
  }
}

class TicketListResponse {
  final List<TicketListsData>? ticketList;

  TicketListResponse({
    this.ticketList,
  });

  factory TicketListResponse.fromJson(Map<String, dynamic> json) {
    return TicketListResponse(
      ticketList: (json['data'] as List<dynamic>? )
          ?.map((item) => TicketListsData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
