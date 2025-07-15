
class CurrencyListsData {
  final String? currencyCode;

  CurrencyListsData({
    this.currencyCode,
  });

  factory CurrencyListsData.fromJson(Map<String, dynamic> json) {
    return CurrencyListsData(
      currencyCode: json['base_code'] as String?,
    );
  }
}

class CurrencyResponse {
  final List<CurrencyListsData>? currencyList;

  CurrencyResponse({
    this.currencyList,
  });

  factory CurrencyResponse.fromJson(Map<String, dynamic> json) {
    return CurrencyResponse(
      currencyList: (json['data'] as List<dynamic>? )
          ?.map((item) => CurrencyListsData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
