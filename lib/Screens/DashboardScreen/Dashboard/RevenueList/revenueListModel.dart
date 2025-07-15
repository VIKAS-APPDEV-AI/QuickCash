class RevenueListResponse {
  final double? creditAmount;
  final double? debitAmount;
  final double? investingAmount;
  final double? earningAmount;



  RevenueListResponse({
    this.creditAmount,
    this.debitAmount,
    this.investingAmount,
    this.earningAmount,

  });

  factory RevenueListResponse.fromJson(Map<String, dynamic> json) {
    return RevenueListResponse(
      creditAmount: (json['data']?['depositTotal'] is int
          ? (json['data']?['depositTotal'] as int).toDouble()
          : json['data']?['depositTotal']) as double?,
      debitAmount: (json['data']?['debitTotal'] is int
          ? (json['data']?['debitTotal'] as int).toDouble()
          : json['data']?['debitTotal']) as double?,
      investingAmount: (json['data']?['investingTotal'] is int
          ? (json['data']?['investingTotal'] as int).toDouble()
          : json['data']?['investingTotal']) as double?,
      earningAmount: (json['data']?['earningTotal'] is int
          ? (json['data']?['earningTotal'] as int).toDouble()
          : json['data']?['earningTotal']) as double?,
    );
  }
}
