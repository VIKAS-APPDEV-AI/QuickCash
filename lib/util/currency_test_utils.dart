import 'package:quickcash/util/file_export_utils.dart';

/// Test utility to verify currency symbol rendering
class CurrencyTestUtils {
  
  /// Test all supported currency symbols
  static void testAllCurrencySymbols() {
    final testCurrencies = [
      'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR', 'KRW', 'RUB',
      'CAD', 'AUD', 'CHF', 'SEK', 'NOK', 'DKK', 'PLN', 'CZK',
      'HUF', 'TRY', 'BRL', 'MXN', 'ZAR', 'SGD', 'HKD', 'NZD',
      'THB', 'MYR', 'PHP', 'IDR', 'VND', 'AWG',
      'BTC', 'ETH', 'LTC', 'ADA', 'SOL', 'DOGE', 'BNB', 'BCH', 'SHIB'
    ];
    
    print('=== Currency Symbol Test Results ===');
    for (String currency in testCurrencies) {
      String symbol = FileExportUtils.getEnhancedCurrencySymbol(currency);
      String formatted = FileExportUtils.formatCurrencyAmount(100.50, currency);
      print('$currency: Symbol="$symbol", Formatted="$formatted"');
    }
    print('=====================================');
  }
  
  /// Test specific currency formatting scenarios
  static void testCurrencyFormatting() {
    print('\n=== Currency Formatting Test ===');
    
    // Test positive amounts
    print('Positive amounts:');
    print('USD 100.50: ${FileExportUtils.formatCurrencyAmount(100.50, 'USD')}');
    print('EUR 100.50: ${FileExportUtils.formatCurrencyAmount(100.50, 'EUR')}');
    print('INR 100.50: ${FileExportUtils.formatCurrencyAmount(100.50, 'INR')}');
    
    // Test with sign
    print('\nWith positive sign:');
    print('USD +100.50: ${FileExportUtils.formatCurrencyAmount(100.50, 'USD', showSign: true)}');
    print('EUR +100.50: ${FileExportUtils.formatCurrencyAmount(100.50, 'EUR', showSign: true)}');
    
    // Test with prefix
    print('\nWith negative prefix:');
    print('USD -100.50: ${FileExportUtils.formatCurrencyAmount(100.50, 'USD', prefix: '-')}');
    print('GBP -100.50: ${FileExportUtils.formatCurrencyAmount(100.50, 'GBP', prefix: '-')}');
    
    // Test null/empty cases
    print('\nEdge cases:');
    print('Null amount: ${FileExportUtils.formatCurrencyAmount(null, 'USD')}');
    print('Empty currency: ${FileExportUtils.formatCurrencyAmount(100.50, '')}');
    print('Unknown currency: ${FileExportUtils.formatCurrencyAmount(100.50, 'XYZ')}');
    
    print('================================');
  }
  
  /// Test Unicode character support
  static void testUnicodeSupport() {
    print('\n=== Unicode Support Test ===');
    
    final unicodeCurrencies = {
      'EUR': '€',
      'GBP': '£', 
      'JPY': '¥',
      'INR': '₹',
      'KRW': '₩',
      'RUB': '₽',
      'THB': '฿',
      'PHP': '₱',
      'VND': '₫',
      'AWG': 'ƒ',
    };
    
    for (var entry in unicodeCurrencies.entries) {
      String currency = entry.key;
      String expectedSymbol = entry.value;
      String actualSymbol = FileExportUtils.getEnhancedCurrencySymbol(currency);
      bool matches = actualSymbol == expectedSymbol;
      
      print('$currency: Expected="$expectedSymbol", Actual="$actualSymbol", Match=$matches');
      
      // Test if the symbol contains only ASCII characters
      bool isAscii = actualSymbol.runes.every((r) => r < 128);
      print('  ASCII-only: $isAscii');
    }
    
    print('============================');
  }
}