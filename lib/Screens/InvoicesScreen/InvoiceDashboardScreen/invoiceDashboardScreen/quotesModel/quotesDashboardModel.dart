class QuotesDashboardData {
  final int? totalQuote;
  final int? totalConverted;
  final int? totalAccept;
  final int? totalReject;

  QuotesDashboardData({
    this.totalQuote,
    this.totalConverted,
    this.totalAccept,
    this.totalReject,
  });

  factory QuotesDashboardData.fromJson(Map<String, dynamic> json) {
    return QuotesDashboardData(
      totalQuote: json['totalQuote'] as int?,
      totalConverted: json['totalConverted'] as int?,
      totalAccept: json['totalAccept'] as int?,
      totalReject: json['totalReject'] as int?,
    );
  }
}

class QuotesDashboardResponse {
  final int? status;
  final String? message;
  final QuotesDashboardData? data;

  QuotesDashboardResponse({
    this.status,
    this.message,
    this.data,
  });

  factory QuotesDashboardResponse.fromJson(Map<String, dynamic> json) {
    return QuotesDashboardResponse(
      status: json['status'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? QuotesDashboardData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
