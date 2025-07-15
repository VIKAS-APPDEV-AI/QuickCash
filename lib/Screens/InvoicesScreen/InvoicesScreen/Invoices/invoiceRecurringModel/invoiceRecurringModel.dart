class InvoiceRecurringRequest {
  final String userId;
  final String recurring;
  final String recurringCycle;

  InvoiceRecurringRequest({
    required this.userId,
    required this.recurring,
    required this.recurringCycle,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'recurring': recurring,
      'recurring_cycle': recurringCycle,
    };
  }
}


class InvoiceRecurringResponse {
  final String? message;

  InvoiceRecurringResponse({
    this.message,

  });

  factory InvoiceRecurringResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceRecurringResponse(
      message: json['message'] as String?,
    );
  }
}
