import 'package:quickcash/util/file_export_utils.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/TransactionList/transactionListModel.dart';

/// Test currency symbol encoding in exports
class CurrencyEncodingTest {
  
  /// Test problematic currency symbols
  static void testProblematicCurrencies() {
    print('=== Testing Problematic Currency Symbols ===');
    
    final testCurrencies = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'INR': '₹',
      'AED': 'د.إ',
      'SAR': 'ر.س',
      'JPY': '¥',
      'KRW': '₩',
      'RUB': '₽',
      'THB': '฿',
      'PHP': '₱',
      'VND': '₫',
      'TRY': '₺',
    };
    
    for (var entry in testCurrencies.entries) {
      String currency = entry.key;
      String expectedSymbol = entry.value;
      
      // Test regular symbol
      String regularSymbol = FileExportUtils.getEnhancedCurrencySymbol(currency);
      
      // Test export-safe symbol
      String exportSafeSymbol = FileExportUtils.getExportSafeCurrencySymbol(currency);
      
      // Test formatted amount
      String formattedAmount = FileExportUtils.formatExportSafeAmount(100.50, currency);
      
      print('$currency:');
      print('  Expected: "$expectedSymbol"');
      print('  Regular: "$regularSymbol"');
      print('  Export Safe: "$exportSafeSymbol"');
      print('  Formatted: "$formattedAmount"');
      print('  Bytes: ${formattedAmount.codeUnits}');
      print('');
    }
  }
  
  /// Create sample transactions for testing
  static List<TransactionListDetails> createTestTransactions() {
    return [
      TransactionListDetails(
        transactionId: 'TXN001',
        transactionDate: DateTime.now().toIso8601String(),
        transactionType: 'Add Money',
        extraType: 'credit',
        amount: 1000.50,
        balance: 5000.75,
        transactionStatus: 'succeeded',
        fromCurrency: 'USD',
      ),
      TransactionListDetails(
        transactionId: 'TXN002',
        transactionDate: DateTime.now().toIso8601String(),
        transactionType: 'Exchange',
        extraType: 'credit',
        amount: 850.00,
        balance: 4000.25,
        transactionStatus: 'succeeded',
        fromCurrency: 'EUR',
        to_currency: 'USD',
        conversionAmount: '920.50',
      ),
      TransactionListDetails(
        transactionId: 'TXN003',
        transactionDate: DateTime.now().toIso8601String(),
        transactionType: 'Add Money',
        extraType: 'credit',
        amount: 75000.00,
        balance: 125000.50,
        transactionStatus: 'succeeded',
        fromCurrency: 'INR',
      ),
      TransactionListDetails(
        transactionId: 'TXN004',
        transactionDate: DateTime.now().toIso8601String(),
        transactionType: 'External Transfer',
        extraType: 'debit',
        amount: 5000.00,
        balance: 15000.25,
        transactionStatus: 'pending',
        fromCurrency: 'AED',
      ),
      TransactionListDetails(
        transactionId: 'TXN005',
        transactionDate: DateTime.now().toIso8601String(),
        transactionType: 'Add Money',
        extraType: 'credit',
        amount: 25000.00,
        balance: 50000.75,
        transactionStatus: 'succeeded',
        fromCurrency: 'SAR',
      ),
    ];
  }
  
  /// Test export with various currencies
  static Future<void> testCurrencyExports() async {
    print('=== Testing Currency Exports ===');
    
    final transactions = createTestTransactions();
    
    try {
      // Test Excel export
      print('Testing Excel export...');
      final excelPath = await FileExportUtils.createEnhancedExcelFile(
        transactions: transactions,
        fileName: 'currency_test_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        title: 'Currency Symbol Test',
      );
      print('Excel file created: $excelPath');
      
      // Test PDF export
      print('Testing PDF export...');
      final pdfPath = await FileExportUtils.createEnhancedPDFFile(
        transactions: transactions,
        fileName: 'currency_test_${DateTime.now().millisecondsSinceEpoch}.pdf',
        title: 'Currency Symbol Test',
      );
      print('PDF file created: $pdfPath');
      
      print('✅ Export tests completed successfully!');
      print('Please open the files to verify currency symbols display correctly.');
      
    } catch (e) {
      print('❌ Export test failed: $e');
    }
  }
  
  /// Test specific currency encoding issues
  static void testEncodingIssues() {
    print('=== Testing Encoding Issues ===');
    
    final problematicCurrencies = ['INR', 'EUR', 'AED', 'SAR', 'THB', 'PHP', 'VND'];
    
    for (String currency in problematicCurrencies) {
      String symbol = FileExportUtils.getEnhancedCurrencySymbol(currency);
      String exportSafe = FileExportUtils.getExportSafeCurrencySymbol(currency);
      
      // Check if symbol contains non-ASCII characters
      bool hasUnicode = symbol.runes.any((r) => r > 127);
      
      // Check byte representation
      List<int> symbolBytes = symbol.codeUnits;
      List<int> exportSafeBytes = exportSafe.codeUnits;
      
      print('$currency:');
      print('  Symbol: "$symbol" (Unicode: $hasUnicode)');
      print('  Symbol Bytes: $symbolBytes');
      print('  Export Safe: "$exportSafe"');
      print('  Export Safe Bytes: $exportSafeBytes');
      print('');
    }
  }
  
  /// Run all currency encoding tests
  static Future<void> runAllTests() async {
    print('🧪 Starting Currency Encoding Tests...\n');
    
    testProblematicCurrencies();
    testEncodingIssues();
    await testCurrencyExports();
    
    print('\n✨ All currency encoding tests completed!');
  }
}