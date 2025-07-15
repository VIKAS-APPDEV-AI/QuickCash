class CryptoTransactionGetDetailsResponse {
  final int status;
  final String message;
  final List<TransactionData> data;

  // Constructor
  CryptoTransactionGetDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CryptoTransactionGetDetailsResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<TransactionData> data = dataList.map((i) => TransactionData.fromJson(i)).toList();

    return CryptoTransactionGetDetailsResponse(
      status: json['status'],
      message: json['message'],
      data: data,
    );
  }

  // Method to convert CryptoResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class TransactionData {
  final String id;
  final String user;
  final int fee;
  final String coin;
  final String currencyType;
  final double amount;
  final String noOfCoins;
  final String side;
  final String status;
  final String createdAt;


  // Constructor
  TransactionData({
    required this.id,
    required this.user,
    required this.fee,
    required this.coin,
    required this.currencyType,
    required this.amount,
    required this.noOfCoins,
    required this.side,
    required this.status,
    required this.createdAt,
  });

  // Factory method to create a TransactionData from JSON
  factory TransactionData.fromJson(Map<String, dynamic> json) {

    return TransactionData(
      id: json['_id'],
      user: json['user'],
      fee: json['fee'],
      coin: json['coin'],
      currencyType: json['currencyType'],
      amount: json['amount'].toDouble(),
      noOfCoins: json['noOfCoins'],
      side: json['side'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }

  // Method to convert TransactionData to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'fee': fee,
      'coin': coin,
      'currencyType': currencyType,
      'amount': amount,
      'noOfCoins': noOfCoins,
      'side': side,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

