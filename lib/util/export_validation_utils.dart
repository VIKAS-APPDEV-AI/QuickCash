import 'dart:io';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/TransactionList/transactionListModel.dart';
import 'package:quickcash/util/file_export_utils.dart';

/// Validation utilities for Excel and PDF exports
class ExportValidationUtils {
  
  /// Create sample transaction data for testing
  static List<TransactionListDetails> createSampleTransactions() {
    return [
      TransactionListDetails(
        transactionId: 'TXN001',
        transactionDate: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        transactionType: 'Add Money',
        extraType: 'credit',
        amount: 1000.50,
        balance: 5000.75,
        transactionStatus: 'succeeded',
        fromCurrency: 'USD',
        fees: 2.50,
      ),
      TransactionListDetails(
        transactionId: 'TXN002',
        transactionDate: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        transactionType: 'Exchange',
        extraType: 'credit',
        amount: 850.00,
        balance: 4000.25,
        transactionStatus: 'succeeded',
        fromCurrency: 'EUR',
        to_currency: 'USD',
        conversionAmount: '920.50',
        fees: 5.00,
      ),
      TransactionListDetails(
        transactionId: 'TXN003',
        transactionDate: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        transactionType: 'External Transfer',
        extraType: 'debit',
        amount: 500.00,
        balance: 3500.25,
        transactionStatus: 'pending',
        fromCurrency: 'GBP',
        fees: 10.00,
      ),
      TransactionListDetails(
        transactionId: 'TXN004',
        transactionDate: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        transactionType: 'Crypto',
        extraType: 'credit',
        amount: 0.05,
        balance: 0.15,
        transactionStatus: 'succeeded',
        fromCurrency: 'BTC',
        fees: 0.001,
      ),
      TransactionListDetails(
        transactionId: 'TXN005',
        transactionDate: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        transactionType: 'Add Money',
        extraType: 'credit',
        amount: 75000.00,
        balance: 125000.50,
        transactionStatus: 'succeeded',
        fromCurrency: 'INR',
        fees: 50.00,
      ),
      TransactionListDetails(
        transactionId: 'TXN006',
        transactionDate: DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
        transactionType: 'Exchange',
        extraType: 'debit',
        amount: 1200.00,
        balance: 8500.75,
        transactionStatus: 'failed',
        fromCurrency: 'JPY',
        fees: 25.00,
      ),
    ];
  }
  
  /// Test Excel export with various currencies
  static Future<String?> testExcelExport() async {
    try {
      final transactions = createSampleTransactions();
      final fileName = "test_excel_export_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      
      final filePath = await FileExportUtils.createEnhancedExcelFile(
        transactions: transactions,
        fileName: fileName,
        title: "Test Excel Export",
      );
      
      // Verify file exists
      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        print('✅ Excel export successful: $filePath (${fileSize} bytes)');
        return filePath;
      } else {
        print('❌ Excel file was not created');
        return null;
      }
    } catch (e) {
      print('❌ Excel export failed: $e');
      return null;
    }
  }
  
  /// Test PDF export with various currencies
  static Future<String?> testPDFExport() async {
    try {
      final transactions = createSampleTransactions();
      final fileName = "test_pdf_export_${DateTime.now().millisecondsSinceEpoch}.pdf";
      
      final filePath = await FileExportUtils.createEnhancedPDFFile(
        transactions: transactions,
        fileName: fileName,
        title: "Test PDF Export",
      );
      
      // Verify file exists
      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        print('✅ PDF export successful: $filePath (${fileSize} bytes)');
        return filePath;
      } else {
        print('❌ PDF file was not created');
        return null;
      }
    } catch (e) {
      print('❌ PDF export failed: $e');
      return null;
    }
  }
  
  /// Test currency symbol consistency
  static void testCurrencyConsistency() {
    print('\n=== Currency Consistency Test ===');
    
    final testCurrencies = ['USD', 'EUR', 'GBP', 'INR', 'JPY', 'BTC', 'ETH'];
    final transactions = createSampleTransactions();
    
    for (String currency in testCurrencies) {
      // Test direct symbol retrieval
      String directSymbol = FileExportUtils.getEnhancedCurrencySymbol(currency);
      
      // Test formatted amount
      String formattedAmount = FileExportUtils.formatCurrencyAmount(100.50, currency);
      
      // Test with sample transaction
      var testTransaction = TransactionListDetails(
        transactionId: 'TEST',
        transactionType: 'Add Money',
        amount: 100.50,
        fromCurrency: currency,
      );
      
      String transactionAmount = FileExportUtils.getEnhancedAmountDisplay(testTransaction);
      
      print('$currency:');
      print('  Direct Symbol: "$directSymbol"');
      print('  Formatted Amount: "$formattedAmount"');
      print('  Transaction Display: "$transactionAmount"');
      print('  Unicode Safe: ${directSymbol.runes.every((r) => r < 256)}');
      print('');
    }
  }
  
  /// Validate file content quality
  static Future<void> validateExportQuality(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      print('❌ File does not exist: $filePath');
      return;
    }
    
    final fileSize = await file.length();
    final extension = filePath.split('.').last.toLowerCase();
    
    print('\n=== Export Quality Validation ===');
    print('File: $filePath');
    print('Size: ${fileSize} bytes');
    print('Type: $extension');
    
    // Basic size validation
    if (fileSize < 1000) {
      print('⚠️  Warning: File size seems too small (${fileSize} bytes)');
    } else if (fileSize > 10000000) {
      print('⚠️  Warning: File size seems too large (${fileSize} bytes)');
    } else {
      print('✅ File size looks reasonable');
    }
    
    // Extension validation
    if (extension == 'xlsx' || extension == 'pdf') {
      print('✅ File extension is correct');
    } else {
      print('❌ Unexpected file extension: $extension');
    }
    
    // Try to read file header to validate format
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isNotEmpty) {
        if (extension == 'xlsx') {
          // Excel files start with PK (ZIP signature)
          if (bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B) {
            print('✅ Excel file format signature is valid');
          } else {
            print('❌ Excel file format signature is invalid');
          }
        } else if (extension == 'pdf') {
          // PDF files start with %PDF
          if (bytes.length >= 4 && 
              bytes[0] == 0x25 && bytes[1] == 0x50 && 
              bytes[2] == 0x44 && bytes[3] == 0x46) {
            print('✅ PDF file format signature is valid');
          } else {
            print('❌ PDF file format signature is invalid');
          }
        }
      }
    } catch (e) {
      print('⚠️  Could not validate file format: $e');
    }
    
    print('================================');
  }
  
  /// Run comprehensive export tests
  static Future<void> runComprehensiveTests() async {
    print('🚀 Starting Comprehensive Export Tests...\n');
    
    // Test currency consistency
    testCurrencyConsistency();
    
    // Test Excel export
    print('\n📊 Testing Excel Export...');
    final excelPath = await testExcelExport();
    if (excelPath != null) {
      await validateExportQuality(excelPath);
    }
    
    // Test PDF export
    print('\n📄 Testing PDF Export...');
    final pdfPath = await testPDFExport();
    if (pdfPath != null) {
      await validateExportQuality(pdfPath);
    }
    
    print('\n✨ Comprehensive tests completed!');
    
    if (excelPath != null && pdfPath != null) {
      print('\n📁 Generated test files:');
      print('Excel: $excelPath');
      print('PDF: $pdfPath');
      print('\nYou can open these files to verify the currency symbols display correctly.');
    }
  }
}