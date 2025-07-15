import 'package:flutter/material.dart';

class AddMoneyProvider with ChangeNotifier {
  String? _selectedSendCurrency;
  String? _selectedTransferType;
  double _depositFees = 0.0;
  String _amountCharge = '0.0';
  String _conversionAmount = '0.0';
  String? _toCurrencySymbol = '';
  bool _isLoading = false;

  String? get selectedSendCurrency => _selectedSendCurrency;
  String? get selectedTransferType => _selectedTransferType;
  double get depositFees => _depositFees;
  String get amountCharge => _amountCharge;
  String get conversionAmount => _conversionAmount;
  String? get toCurrencySymbol => _toCurrencySymbol;
  bool get isLoading => _isLoading;

  void setSelectedSendCurrency(String? value) {
    _selectedSendCurrency = value;
    notifyListeners();
  }

  void setSelectedTransferType(String? value) {
    _selectedTransferType = value;
    notifyListeners();
  }

  void setDepositFees(double value) {
    _depositFees = value;
    print('Set depositFees to: $_depositFees');
    notifyListeners();
  }

  void setAmountCharge(String value) {
    _amountCharge = value;
    print('Set amountCharge to: $_amountCharge');
    notifyListeners();
  }

  void setConversionAmount(String value) {
    _conversionAmount = value;
    print('Set conversionAmount to: $_conversionAmount');
    notifyListeners();
  }

  void setToCurrencySymbol(String? value) {
    _toCurrencySymbol = value;
    notifyListeners();
  }

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void resetAllFields() {
    _depositFees = 0.0;
    _amountCharge = '0.0';
    _conversionAmount = '0.0';
    _isLoading = false;
    print('Resetting all fields: depositFees=$_depositFees, '
        'amountCharge=$_amountCharge, conversionAmount=$_conversionAmount');
    notifyListeners();
  }
}