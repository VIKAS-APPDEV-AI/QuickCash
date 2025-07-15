import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getCurrencySymbol(String? currencyCode, {TextStyle? style}) {
  if (currencyCode == "AWG") return 'ƒ'; 
  if (currencyCode == null || currencyCode.isEmpty) {
    return NumberFormat.simpleCurrency(name: 'USD').currencySymbol;
  }

  final cryptoCurrencies = {
    'BTC',
    'BCH',
    'BNB',
    'ADA',
    'SOL',
    'DOGE',
    'LTC',
    'ETH',
    'SHIB'
  };

  if (cryptoCurrencies.contains(currencyCode.toUpperCase())) {
    return currencyCode.toUpperCase();
  }

  switch (currencyCode.toUpperCase()) {
    case 'EUR':
      return '€'; // Return the Euro symbol (€) instead of "EUR"
    case 'USD':
      return '\$'; // Use escaped dollar symbol to treat it as a literal character
    case 'GBP':
      return '£'; // Pound symbol
    default:
      return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
  }
}

Widget getEuFlagWidget() {
  // Return the EU flag as a reusable widget
  return ClipOval(
    child: Image.asset(
      'assets/images/EuroFlag.png', // Ensure this path matches your file
      width: 35,
      height: 35,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error, color: Colors.red);
      }, // Fallback if image fails to load
    ),
  );
}