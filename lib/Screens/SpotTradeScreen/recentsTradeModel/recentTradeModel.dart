class TradeDetail {
  final int? id;
  final String? price;
  final String? qty;
  final String? quoteQty;
  final int? time;
  final bool? isBuyerMaker;
  final bool? isBestMatch;

  TradeDetail({
    this.id,
    this.price,
    this.qty,
    this.quoteQty,
    this.time,
    this.isBuyerMaker,
    this.isBestMatch,
  });

  factory TradeDetail.fromJson(Map<String, dynamic> json) {
    return TradeDetail(
      id: json['id'] as int?,
      price: json['price'] as String?,
      qty: json['qty'] as String?,
      quoteQty: json['quoteQty'] as String?,
      time: json['time'] as int?,
      isBuyerMaker: json['isBuyerMaker'] as bool?,
      isBestMatch: json['isBestMatch'] as bool?,
    );
  }
}

class RecentTradeResponse {
  final List<TradeDetail>? tradeDetails;

  RecentTradeResponse({
    this.tradeDetails,
  });

  factory RecentTradeResponse.fromJson(Map<String, dynamic> json) {
    return RecentTradeResponse(
      tradeDetails: (json['data'] as List<dynamic>?)
          ?.map((item) => TradeDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
