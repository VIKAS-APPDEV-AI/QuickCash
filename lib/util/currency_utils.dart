import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getCurrencySymbol(String? currencyCode, {TextStyle? style}) {
  if (currencyCode == null || currencyCode.isEmpty) {
    return '\$';
  }

  // Handle crypto currencies
  final cryptoCurrencies = {
    'BTC', 'BCH', 'BNB', 'ADA', 'SOL', 'DOGE', 'LTC', 'ETH', 'SHIB'
  };

  if (cryptoCurrencies.contains(currencyCode.toUpperCase())) {
    return currencyCode.toUpperCase();
  }

  // Enhanced currency symbol mapping with proper Unicode support
  switch (currencyCode.toUpperCase()) {
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'JPY':
      return '¥';
    case 'CNY':
      return '¥';
    case 'INR':
      return '₹';
    case 'KRW':
      return '₩';
    case 'RUB':
      return '₽';
    case 'CAD':
      return 'C\$';
    case 'AUD':
      return 'A\$';
    case 'CHF':
      return 'CHF';
    case 'SEK':
      return 'kr';
    case 'NOK':
      return 'kr';
    case 'DKK':
      return 'kr';
    case 'PLN':
      return 'zł';
    case 'CZK':
      return 'Kč';
    case 'HUF':
      return 'Ft';
    case 'TRY':
      return '₺';
    case 'BRL':
      return 'R\$';
    case 'MXN':
      return '\$';
    case 'ZAR':
      return 'R';
    case 'SGD':
      return 'S\$';
    case 'HKD':
      return 'HK\$';
    case 'NZD':
      return 'NZ\$';
    case 'THB':
      return '฿';
    case 'MYR':
      return 'RM';
    case 'PHP':
      return '₱';
    case 'IDR':
      return 'Rp';
    case 'VND':
      return '₫';
    case 'AWG':
      return 'ƒ';
    default:
      // Fallback to NumberFormat for other currencies
      try {
        return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
      } catch (e) {
        return currencyCode.toUpperCase();
      }
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