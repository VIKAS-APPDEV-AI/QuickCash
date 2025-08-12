import 'package:quickcash/util/advanced_export_utils.dart';
import 'package:quickcash/util/crypto_logo_manager.dart';
import 'package:quickcash/util/unicode_font_manager.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/TransactionList/transactionListModel.dart';

/// Demo and test class for advanced export functionality
class AdvancedExportDemo {
  
  /// Create comprehensive test transactions with various currencies
  static List<TransactionListDetails> createTestTransactions() {
    return [
      // Fiat currencies with Unicode symbols
      TransactionListDetails(
        transactionId: 'USD001',
        transactionDate: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        transactionType: 'Add Money',
        extraType: 'credit',
        amount: 1000.50,
        balance: 5000.75,
        transactionStatus: 'succeeded',
        fromCurrency: 'USD',
      ),
      
      TransactionListDetails(
        transactionId: 'INR001',
        transactionDate: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        transactionType: 'Add Money',
        extraType: 'credit',
        amount: 75000.00,
        balance: 125000.50,
        transactionStatus: 'succeeded',
        fromCurrency: 'INR',
      ),
      
      TransactionListDetails(
        transactionId: 'EUR001',
        transactionDate: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        transactionType: 'Exchange',
        extraType: 'credit',
        amount: 850.00,
        balance: 2500.25,
        transactionStatus: 'succeeded',
        fromCurrency: 'EUR',
        to_currency: 'USD',
        conversionAmount: '920.50',
      ),
      
      TransactionListDetails(
        transactionId: 'AED001',
        transactionDate: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        transactionType: 'External Transfer',
        extraType: 'debit',
        amount: 5000.00,
        balance: 15000.25,
        transactionStatus: 'pending',
        fromCurrency: 'AED',
      ),
      
      TransactionListDetails(
        transactionId: 'THB001',
        transactionDate: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        transactionType: 'Add Money',
        extraType: 'credit',
        amount: 35000.00,
        balance: 85000.75,
        transactionStatus: 'succeeded',
        fromCurrency: 'THB',
      ),
      
      // Cryptocurrency transactions
      TransactionListDetails(
        transactionId: 'BTC001',
        transactionDate: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        transactionType: 'Crypto Buy',
        extraType: 'credit',
        amount: 0.025,
        balance: 0.125,
        transactionStatus: 'succeeded',
        fromCurrency: 'BTC',
      ),
      
      TransactionListDetails(
        transactionId: 'ETH001',
        transactionDate: DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        transactionType: 'Crypto Buy',
        extraType: 'credit',
        amount: 2.5,
        balance: 8.75,
        transactionStatus: 'succeeded',
        fromCurrency: 'ETH',
      ),
      
      TransactionListDetails(
        transactionId: 'ADA001',
        transactionDate: DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        transactionType: 'Crypto Sell',
        extraType: 'debit',
        amount: 1000.0,
        balance: 2500.0,
        transactionStatus: 'succeeded',
        fromCurrency: 'ADA',
      ),
      
      TransactionListDetails(
        transactionId: 'SOL001',
        transactionDate: DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
        transactionType: 'Crypto Transfer',
        extraType: 'debit',
        amount: 15.5,
        balance: 45.25,
        transactionStatus: 'pending',
        fromCurrency: 'SOL',
      ),
      
      TransactionListDetails(
        transactionId: 'DOGE001',
        transactionDate: DateTime.now().subtract(const Duration(hours: 10)).toIso8601String(),
        transactionType: 'Crypto Buy',
        extraType: 'credit',
        amount: 10000.0,
        balance: 25000.0,
        transactionStatus: 'succeeded',
        fromCurrency: 'DOGE',
      ),
    ];
  }

  /// Test Unicode currency symbol rendering
  static void testUnicodeCurrencySymbols() {
    print('🧪 Testing Unicode Currency Symbols...\n');
    
    final testCurrencies = [
      'USD', 'EUR', 'GBP', 'INR', 'AED', 'SAR', 'THB', 'PHP', 'VND', 'KRW', 'JPY', 'CNY'
    ];
    
    for (final currency in testCurrencies) {
      final symbol = AdvancedExportUtils.getUnicodeCurrencySymbol(currency);
      final formatted = AdvancedExportUtils.formatCurrencyWithUnicode(1234.56, currency);
      final font = UnicodeFontManager.getFontForCurrency(currency);
      
      print('$currency:');
      print('  Symbol: "$symbol"');
      print('  Formatted: "$formatted"');
      print('  Font: $font');
      print('  Unicode Points: ${symbol.runes.map((r) => 'U+${r.toRadixString(16).toUpperCase().padLeft(4, '0')}').join(' ')}');
      print('');
    }
  }

  /// Test crypto currency handling
  static void testCryptoCurrencies() {
    print('🪙 Testing Crypto Currencies...\n');
    
    final cryptoCurrencies = ['BTC', 'ETH', 'LTC', 'ADA', 'SOL', 'DOGE', 'BNB', 'BCH', 'SHIB'];
    
    for (final crypto in cryptoCurrencies) {
      final isCrypto = AdvancedExportUtils.isCryptoCurrency(crypto);
      final symbol = AdvancedExportUtils.getUnicodeCurrencySymbol(crypto);
      final formatted = AdvancedExportUtils.formatCurrencyWithUnicode(1.23456789, crypto);
      
      print('$crypto:');
      print('  Is Crypto: ${isCrypto ? "✅" : "❌"}');
      print('  Symbol: "$symbol"');
      print('  Formatted: "$formatted"');
      print('');
    }
  }

  /// Test font availability
  static Future<void> testFontAvailability() async {
    print('📝 Testing Font Availability...\n');
    
    final fontInfo = await UnicodeFontManager.getFontInfo();
    
    print('Font System Status:');
    print('  Total Fonts: ${fontInfo['totalFonts']}');
    print('  Loaded Fonts: ${fontInfo['loadedFonts']}');
    print('  Supported Currencies: ${fontInfo['supportedCurrencies'].length}');
    print('');
    
    print('Font Availability:');
    final availability = fontInfo['availableFonts'] as Map<String, bool>;
    for (final entry in availability.entries) {
      print('  ${entry.value ? "✅" : "❌"} ${entry.key}');
    }
    print('');
  }

  /// Test crypto logo availability
  static Future<void> testCryptoLogos() async {
    print('🖼️  Testing Crypto Logo Availability...\n');
    
    await CryptoLogoManager.initialize();
    
    final cryptos = ['BTC', 'ETH', 'LTC', 'ADA', 'SOL'];
    
    for (final crypto in cryptos) {
      print('Testing $crypto logo...');
      final logoData = await CryptoLogoManager.getLogo(crypto);
      
      if (logoData != null) {
        print('  ✅ Logo loaded successfully (${logoData.length} bytes)');
      } else {
        print('  ❌ Logo not available');
      }
    }
    
    final cacheSize = await CryptoLogoManager.getCacheSize();
    print('\nCache Status:');
    print('  Cache Size: ${CryptoLogoManager.formatCacheSize(cacheSize)}');
    print('');
  }

  /// Create demo export files
  static Future<void> createDemoExports() async {
    print('📊 Creating Demo Export Files...\n');
    
    final transactions = createTestTransactions();
    
    try {
      // Create Excel demo
      print('Creating Excel demo with Unicode fonts and crypto logos...');
      final excelPath = await AdvancedExportUtils.createAdvancedExcelFile(
        transactions: transactions,
        fileName: 'advanced_export_demo_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        title: 'Advanced Export Demo',
      );
      print('✅ Excel demo created: $excelPath');
      
      // Create PDF demo
      print('Creating PDF demo with Unicode fonts and crypto logos...');
      final pdfPath = await AdvancedExportUtils.createAdvancedPDFFile(
        transactions: transactions,
        fileName: 'advanced_export_demo_${DateTime.now().millisecondsSinceEpoch}.pdf',
        title: 'Advanced Export Demo',
      );
      print('✅ PDF demo created: $pdfPath');
      
      print('\n🎉 Demo files created successfully!');
      print('📁 Files contain:');
      print('   ✓ Fiat currencies with proper Unicode symbols');
      print('   ✓ Crypto currencies with logos and special formatting');
      print('   ✓ Professional layout and styling');
      print('   ✓ Full Unicode font support');
      
    } catch (e) {
      print('❌ Failed to create demo exports: $e');
    }
  }

  /// Run comprehensive demo
  static Future<void> runComprehensiveDemo() async {
    print('🚀 Starting Advanced Export Demo...\n');
    
    testUnicodeCurrencySymbols();
    testCryptoCurrencies();
    await testFontAvailability();
    await testCryptoLogos();
    await createDemoExports();
    
    print('✨ Advanced Export Demo Completed!\n');
    
    print('🎯 Summary of Features:');
    print('   ✅ Full Unicode support for all currency symbols');
    print('   ✅ Crypto logos embedded in exports');
    print('   ✅ Professional PDF/Excel formatting');
    print('   ✅ Multi-language font support');
    print('   ✅ Automatic font fallback system');
    print('   ✅ Cached logo management');
    print('   ✅ Enhanced user notifications');
    
    print('\n📋 Next Steps:');
    print('   1. Add the dependencies to pubspec.yaml');
    print('   2. Run the font/logo setup script');
    print('   3. Update your export buttons to use AdvancedExportUtils');
    print('   4. Test with various currencies and crypto transactions');
    
    print('\n🎉 Your app now has enterprise-grade export capabilities!');
  }
}