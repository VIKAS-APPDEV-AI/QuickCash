class InvoiceDashboardData {
  final String? totalPaid;
  final double? totalUnpaid;
  final String? totalOverdue;
  final int? totalProducts;
  final int? totalClients;
  final int? totalCategory;
  final double? totalInvoice;

  InvoiceDashboardData({
    this.totalPaid,
    this.totalUnpaid,
    this.totalOverdue,
    this.totalProducts,
    this.totalClients,
    this.totalCategory,
    this.totalInvoice,
  });

  factory InvoiceDashboardData.fromJson(Map<String, dynamic> json) {
    return InvoiceDashboardData(
      totalPaid: json['totalPaid'] as String?,
      totalUnpaid: json['totalUnpaid'] is int
          ? (json['totalUnpaid'] as int).toDouble()
          : json['totalUnpaid'] as double?,
      totalOverdue: json['totalOverdue'] as String?,
      totalProducts: json['totalProducts'] as int?,
      totalClients: json['totalClients'] as int?,
      totalCategory: json['totalCategory'] as int?,
      totalInvoice: json['totalInvoice'] is int
          ? (json['totalInvoice'] as int).toDouble()
          : json['totalInvoice'] as double?,
    );
  }
}

class InvoiceDashboardResponse {
  final int? status;
  final String? message;
  final InvoiceDashboardData? data;

  InvoiceDashboardResponse({
    this.status,
    this.message,
    this.data,
  });

  factory InvoiceDashboardResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceDashboardResponse(
      status: json['status'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? InvoiceDashboardData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
