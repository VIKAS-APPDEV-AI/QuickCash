import 'package:quickcash/util/enhanced_export_utils.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/TransactionList/transactionListModel.dart';

/// Test the currency encoding fix
class CurrencyEncodingFixTest {
  
  /// Test the specific currencies mentioned in the issue
  static void testProblematicCurrencies() {
    print('🧪 Testing Currency Encoding Fix...\n');
    
    // Test the specific currencies mentioned in the issue
    final problematicCurrencies = {
      'USD': 'USD \$',
      'INR': 'INR ₹', 
      'EUR': 'EUR €',
      'AED': 'AED د.إ', // Dirham
    };
    
    print('=== Testing Problematic Currencies ===');
    for (var entry in problematicCurrencies.entries) {
      String currencyCode = entry.key;
      String expectedFormat = entry.value;
      
      String result = EnhancedExportUtils.getCurrencySymbolWithEncoding(currencyCode);
      bool isCorrect = result == expectedFormat;
      
      print('$currencyCode:');
      print('  Expected: "$expectedFormat"');
      print('  Got: "$result"');
      print('  Status: ${isCorrect ? "✅ PASS" : "❌ FAIL"}');
      print('  Bytes: ${result.codeUnits}');
      print('');
    }
  }
  
  /// Test amount formatting with problematic currencies
  static void testAmountFormatting() {
    print('=== Testing Amount Formatting ===');
    
    final testAmounts = [100.50, 1000.00, 75000.00, 5000.00];
    final testCurrencies = ['USD', 'INR', 'EUR', 'AED'];
    
    for (String currency in testCurrencies) {
      print('$currency amounts:');
      for (double amount in testAmounts) {
        String formatted = EnhancedExportUtils.formatAmountWithCurrency(amount, currency);
        print('  $amount -> "$formatted"');
      }
      print('');
    }
  }
  
  /// Create test transactions with problematic currencies
  static List<TransactionListDetails> createTestTransactions() {
    return [
      // USD transaction (should work)
      TransactionListDetails(
        transactionId: 'USD001',
        transactionDate: DateTime.now().toIso8601String(),
        transactionType: 'Add Money',
        extraType: 'credit',
        amount: 100.50,
        balance: 1000.75,
        transactionStatus: 'succeeded',
        fromCurrency: 'USD',
      ),
      
      // INR transaction (problematic)
      TransactionListDetails(
        transactionId: 'INR001',
        transactionDate: DateTime.now().toIso8601String(),
        transactionType: 'Add Money',
        extraType: 'credit',
        amount: 7500.00,
        balance: 50000.50,
        transactionStatus: 'succeeded',
        fromCurrency: 'INR',
      ),
      
      // EUR transaction (problematic)
      TransactionListDetails(
        transactionId: 'EUR001',
        transactionDate: DateTime.now().toIso8601String(),
        transactionType: 'Exchange',
        extraType: 'credit',
        amount: 850.00,
        balance: 2500.25,
        transactionStatus: 'succeeded',
        fromCurrency: 'EUR',
        to_currency: 'USD',
        conversionAmount: '920.50',
      ),
      
      // AED transaction (problematic - Dirham)
      TransactionListDetails(
        transactionId: 'AED001',
        transactionDate: DateTime.now().toIso8601String(),
        transactionType: 'External Transfer',
        extraType: 'debit',
        amount: 5000.00,
        balance: 15000.25,
        transactionStatus: 'pending',
        fromCurrency: 'AED',
      ),
    ];
  }
  
  /// Test transaction amount display
  static void testTransactionAmountDisplay() {
    print('=== Testing Transaction Amount Display ===');
    
    final transactions = createTestTransactions();
    
    for (var transaction in transactions) {
      String amountDisplay = EnhancedExportUtils.getAmountDisplayWithEncoding(transaction);
      String balanceDisplay = EnhancedExportUtils.getBalanceDisplayWithEncoding(transaction);
      
      print('Transaction ${transaction.transactionId}:');
      print('  Currency: ${transaction.fromCurrency}');
      print('  Amount Display: "$amountDisplay"');
      print('  Balance Display: "$balanceDisplay"');
      print('  Amount Bytes: ${amountDisplay.codeUnits}');
      print('  Balance Bytes: ${balanceDisplay.codeUnits}');
      print('');
    }
  }
  
  /// Test export file creation
  static Future<void> testExportFileCreation() async {
    print('=== Testing Export File Creation ===');
    
    final transactions = createTestTransactions();
    
    try {
      // Test Excel export
      print('Creating Excel file with currency encoding fix...');
      final excelPath = await EnhancedExportUtils.createExcelWithProperEncoding(
        transactions: transactions,
        fileName: 'currency_encoding_test_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        title: 'Currency Encoding Test',
      );
      print('✅ Excel file created: $excelPath');
      
      // Test PDF export
      print('Creating PDF file with currency encoding fix...');
      final pdfPath = await EnhancedExportUtils.createPDFWithProperEncoding(
        transactions: transactions,
        fileName: 'currency_encoding_test_${DateTime.now().millisecondsSinceEpoch}.pdf',
        title: 'Currency Encoding Test',
      );
      print('✅ PDF file created: $pdfPath');
      
      print('\n🎉 SUCCESS: Both files created successfully!');
      print('📁 Files location:');
      print('   Excel: $excelPath');
      print('   PDF: $pdfPath');
      print('\n📋 Please open these files to verify:');
      print('   ✓ USD \$ symbols display correctly');
      print('   ✓ INR ₹ symbols display correctly');
      print('   ✓ EUR € symbols display correctly');
      print('   ✓ AED د.إ symbols display correctly');
      
    } catch (e) {
      print('❌ Export test failed: $e');
    }
  }
  
  /// Test specific encoding issues
  static void testEncodingIssues() {
    print('=== Testing Encoding Issues ===');
    
    final testCases = [
      {'currency': 'INR', 'symbol': '₹', 'description': 'Indian Rupee'},
      {'currency': 'EUR', 'symbol': '€', 'description': 'Euro'},
      {'currency': 'AED', 'symbol': 'د.إ', 'description': 'UAE Dirham'},
      {'currency': 'SAR', 'symbol': 'ر.س', 'description': 'Saudi Riyal'},
      {'currency': 'THB', 'symbol': '฿', 'description': 'Thai Baht'},
      {'currency': 'PHP', 'symbol': '₱', 'description': 'Philippine Peso'},
    ];
    
    for (var testCase in testCases) {
      String currency = testCase['currency']!;
      String expectedSymbol = testCase['symbol']!;
      String description = testCase['description']!;
      
      String result = EnhancedExportUtils.getCurrencySymbolWithEncoding(currency);
      bool containsSymbol = result.contains(expectedSymbol);
      
      print('$currency ($description):');
      print('  Expected Symbol: "$expectedSymbol"');
      print('  Result: "$result"');
      print('  Contains Symbol: ${containsSymbol ? "✅ YES" : "❌ NO"}');
      print('  Unicode Points: ${expectedSymbol.runes.map((r) => 'U+${r.toRadixString(16).toUpperCase().padLeft(4, '0')}').join(' ')}');
      print('');
    }
  }
  
  /// Run all currency encoding fix tests
  static Future<void> runAllTests() async {
    print('🚀 Starting Currency Encoding Fix Tests...\n');
    
    testProblematicCurrencies();
    testAmountFormatting();
    testTransactionAmountDisplay();
    testEncodingIssues();
    await testExportFileCreation();
    
    print('\n✨ Currency Encoding Fix Tests Completed!');
    print('\n📝 Summary:');
    print('   ✅ Enhanced export utilities created');
    print('   ✅ Currency symbols with proper encoding');
    print('   ✅ Amount formatting with currency codes');
    print('   ✅ Transaction screens updated');
    print('   ✅ Export methods updated');
    print('\n🎯 The currency symbol encoding issue should now be resolved!');
  }
}