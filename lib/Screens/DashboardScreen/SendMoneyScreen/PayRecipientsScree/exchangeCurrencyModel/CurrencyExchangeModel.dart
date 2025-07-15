/// Request model to encapsulate the parameters for currency conversion.
class ExchangeCurrencyRequestnew {
  final String fromCurrency;
  final String toCurrency; // Dynamic currency selected by the user.
  final double amount;

  ExchangeCurrencyRequestnew( {
    required this.fromCurrency,
    required this.amount,
    required this.toCurrency
  });

  /// Convert request data to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'from': fromCurrency,
      'to': toCurrency, // Fixed target currency.
      'amount': amount,
    };
  }
}

/// Model representing the conversion result.
class ExchangeResult {
  final String from;
  final String to;
  final double amountToConvert;
  final double convertedAmount;

  ExchangeResult({
    required this.from,
    required this.to,
    required this.amountToConvert,
    required this.convertedAmount,
  });

  factory ExchangeResult.fromJson(Map<String, dynamic>? json) {
    // If json is null, return a default/fallback instance
    if (json == null) {
      return ExchangeResult(
        from: '',
        to: '',
        amountToConvert: 0.0,
        convertedAmount: 0.0,
      );
    }

    return ExchangeResult(
      from: json['from'] as String? ?? '', // Default to empty string if null
      to: json['to'] as String? ?? '',
      amountToConvert: (json['amountToConvert'] as num?)?.toDouble() ?? 0.0,
      convertedAmount: (json['convertedAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
/// Response model for the currency conversion.
class ExchangeResponse {
  final bool success;
  final List<dynamic> validationMessage;
  final ExchangeResult? result; // Make result nullable

  ExchangeResponse({
    required this.success,
    required this.validationMessage,
    this.result, // Allow result to be null
  });

  factory ExchangeResponse.fromJson(Map<String, dynamic>? json) {
    // Handle null or invalid JSON
    if (json == null) {
      return ExchangeResponse(
        success: false,
        validationMessage: [],
        result: null,
      );
    }

    return ExchangeResponse(
      success: json['success'] as bool? ?? false, // Default to false if null
      validationMessage: json['validationMessage'] as List<dynamic>? ?? [],
      result: json['result'] != null
          ? ExchangeResult.fromJson(json['result'] as Map<String, dynamic>?)
          : null, // Pass null if result is absent
    );
  }
}