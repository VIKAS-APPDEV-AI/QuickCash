// models/account_models.dart

class AccountDetails {
  final String id;
  final String name;
  final String bankName;
  final String iban;
  final String ibanText;
  final int bicCode;
  final String country;
  final String currency;
  final double amount;
  final String address;
  final bool defaultAccount;
  final bool status;

  AccountDetails({
    required this.id,
    required this.name,
    required this.bankName,
    required this.iban,
    required this.ibanText,
    required this.bicCode,
    required this.country,
    required this.currency,
    required this.amount,
    required this.address,
    required this.defaultAccount,
    required this.status,
  });

  factory AccountDetails.fromJson(Map<String, dynamic> json) {
    return AccountDetails(
      id: json['_id'],
      name: json['name'] ?? '',
      bankName: json['bankName'] ?? '',
      iban: json['iban'] ?? '',
      ibanText: json['ibanText'] ?? '',
      bicCode: json['bic_code'] ?? 0,
      country: json['country'] ?? '',
      currency: json['currency'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      defaultAccount: json['defaultAccount'] ?? false,
      status: json['status'] ?? false,
    );
  }
}

class Account {
  final String id;
  final String name;
  final String email;
  final String country;
  final String defaultCurrency;
  final bool status;
  final AccountDetails accountDetails;

  Account({
    required this.id,
    required this.name,
    required this.email,
    required this.country,
    required this.defaultCurrency,
    required this.status,
    required this.accountDetails,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      country: json['country'] ?? '',
      defaultCurrency: json['defaultCurrency'] ?? '',
      status: json['status'] ?? false,
      accountDetails: AccountDetails.fromJson(json['accountDetails']),
    );
  }
}
