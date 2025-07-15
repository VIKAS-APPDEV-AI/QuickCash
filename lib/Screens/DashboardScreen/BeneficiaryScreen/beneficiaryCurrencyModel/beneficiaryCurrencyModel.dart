class BeneficiaryCurrencyResponse {
  final int status;
  final String message;
  final List<BeneficiaryCurrencyData> data; // New field for the list of currencies

  BeneficiaryCurrencyResponse({
    required this.status,
    required this.message,
    required this.data, // Include the data list in the constructor
  });

  factory BeneficiaryCurrencyResponse.fromJson(Map<String, dynamic> json) {
    // Parsing the 'data' field as a list of Currency objects
    var dataList = (json['data'] as List)
        .map((currencyJson) => BeneficiaryCurrencyData.fromJson(currencyJson))
        .toList();

    return BeneficiaryCurrencyResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: dataList, // Populate the data field
    );
  }
}

class BeneficiaryCurrencyData {
  final String id;
  final String currencyCode;
  final String currencyName;

  BeneficiaryCurrencyData({
    required this.id,
    required this.currencyCode,
    required this.currencyName,
  });

  factory BeneficiaryCurrencyData.fromJson(Map<String, dynamic> json) {
    return BeneficiaryCurrencyData(
      id: json['_id'] as String,
      currencyCode: json['CurrencyCode'] as String,
      currencyName: json['CurrencyName'] as String,
    );
  }
}
