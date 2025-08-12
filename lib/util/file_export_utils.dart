import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/TransactionList/transactionListModel.dart';


class FileExportUtils {
  // Enhanced currency symbol mapping with proper Unicode support
  static String getEnhancedCurrencySymbol(String? currencyCode) {
    if (currencyCode == null || currencyCode.isEmpty) return '\$';
    
    // Handle crypto currencies
    final cryptoCurrencies = {
      'BTC', 'BCH', 'BNB', 'ADA', 'SOL', 'DOGE', 'LTC', 'ETH', 'SHIB'
    };
    
    if (cryptoCurrencies.contains(currencyCode.toUpperCase())) {
      return currencyCode.toUpperCase();
    }
    
    // Enhanced currency symbol mapping
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
      case 'AED':
        return 'د.إ';
      case 'SAR':
        return 'ر.س';
      case 'QAR':
        return 'ر.ق';
      case 'KWD':
        return 'د.ك';
      case 'BHD':
        return 'د.ب';
      case 'OMR':
        return 'ر.ع';
      case 'JOD':
        return 'د.أ';
      case 'LBP':
        return 'ل.ل';
      case 'EGP':
        return 'ج.م';
      default:
        // Fallback to NumberFormat for other currencies
        try {
          return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
        } catch (e) {
          return currencyCode.toUpperCase();
        }
    }
  }

  // Get encoding-safe currency symbol for exports (fallback to text when Unicode fails)
  static String getExportSafeCurrencySymbol(String? currencyCode) {
    if (currencyCode == null || currencyCode.isEmpty) return 'USD';
    
    // For exports, use text-based representations for problematic Unicode symbols
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return 'USD \$';
      case 'EUR':
        return 'EUR €';
      case 'GBP':
        return 'GBP £';
      case 'JPY':
        return 'JPY ¥';
      case 'CNY':
        return 'CNY ¥';
      case 'INR':
        return 'INR ₹';
      case 'KRW':
        return 'KRW ₩';
      case 'RUB':
        return 'RUB ₽';
      case 'AED':
        return 'AED د.إ';
      case 'SAR':
        return 'SAR ر.س';
      case 'QAR':
        return 'QAR ر.ق';
      case 'KWD':
        return 'KWD د.ك';
      case 'BHD':
        return 'BHD د.ب';
      case 'OMR':
        return 'OMR ر.ع';
      case 'THB':
        return 'THB ฿';
      case 'PHP':
        return 'PHP ₱';
      case 'VND':
        return 'VND ₫';
      case 'TRY':
        return 'TRY ₺';
      case 'PLN':
        return 'PLN zł';
      case 'CZK':
        return 'CZK Kč';
      case 'HUF':
        return 'HUF Ft';
      case 'AWG':
        return 'AWG ƒ';
      default:
        return currencyCode.toUpperCase();
    }
  }

  // Format amount with encoding-safe currency display for exports
  static String formatExportSafeAmount(double? amount, String? currencyCode, {String prefix = '', bool showSign = false}) {
    if (amount == null) return '0.00';
    
    final formattedAmount = amount.toStringAsFixed(2);
    final currencyDisplay = getExportSafeCurrencySymbol(currencyCode);
    final sign = showSign && amount > 0 ? '+' : '';
    
    return '$prefix$sign$currencyDisplay $formattedAmount';
  }

  // Format amount with proper currency symbol and decimal places
  static String formatCurrencyAmount(double? amount, String? currencyCode, {bool showSign = false, String? prefix}) {
    if (amount == null) return '0.00';
    
    final symbol = getEnhancedCurrencySymbol(currencyCode);
    final formattedAmount = amount.toStringAsFixed(2);
    final sign = showSign && amount > 0 ? '+' : '';
    final prefixStr = prefix ?? '';
    
    return '$prefixStr$sign$symbol$formattedAmount';
  }

  // Enhanced amount display logic
  static String getEnhancedAmountDisplay(TransactionListDetails transaction) {
    String transType = transaction.transactionType?.toLowerCase() ?? '';
    String? extraType = transaction.extraType?.toLowerCase();
    String fullType = "$extraType-$transType";
    
    double displayAmount = transaction.amount ?? 0.0;
    double fees = transaction.fees ?? 0.0;
    double cryptobillAmount = fees + displayAmount;
    double? conversionAmount = transaction.conversionAmount != null
        ? double.tryParse(transaction.conversionAmount!) ?? 0.0
        : null;

    String currencyCode = fullType.contains('credit-exchange')
        ? transaction.to_currency ?? ''
        : transaction.fromCurrency ?? '';

    // Credit transactions (incoming money)
    if (fullType == 'credit-exchange' && conversionAmount != null) {
      return formatCurrencyAmount(conversionAmount, currencyCode, showSign: true);
    }
    if (fullType == 'credit-add money' && conversionAmount != null) {
      return formatCurrencyAmount(conversionAmount, currencyCode, showSign: true);
    }
    if (transType == 'add money') {
      return formatCurrencyAmount(displayAmount, currencyCode, showSign: true);
    }
    if (fullType == 'credit-crypto' && conversionAmount != null) {
      return formatCurrencyAmount(displayAmount, currencyCode, showSign: true);
    }

    // Debit transactions (outgoing money)
    if (fullType == 'debit-crypto' && conversionAmount != null) {
      return formatCurrencyAmount(cryptobillAmount, currencyCode, prefix: '-');
    }
    if (transType == 'external transfer' ||
        transType == 'beneficiary transfer money' ||
        transType == 'exchange') {
      return formatCurrencyAmount(fees + displayAmount, currencyCode, prefix: '-');
    }

    // Default case
    return formatCurrencyAmount(displayAmount, currencyCode);
  }

  // Enhanced balance display
  static String getEnhancedBalanceDisplay(TransactionListDetails transaction) {
    String transType = transaction.transactionType?.toLowerCase() ?? '';
    String? extraType = transaction.extraType?.toLowerCase();
    String fullType = "$extraType-$transType";
    
    String currencyCode = fullType.contains('credit-exchange')
        ? transaction.to_currency ?? ''
        : transaction.fromCurrency ?? '';
    
    return formatCurrencyAmount(transaction.balance, currencyCode);
  }

  // Export-safe amount display for transactions
  static String _getExportSafeAmountDisplay(TransactionListDetails transaction) {
    String transType = transaction.transactionType?.toLowerCase() ?? '';
    String? extraType = transaction.extraType?.toLowerCase();
    String fullType = "$extraType-$transType";
    
    double displayAmount = transaction.amount ?? 0.0;
    double fees = transaction.fees ?? 0.0;
    double cryptobillAmount = fees + displayAmount;
    double? conversionAmount = transaction.conversionAmount != null
        ? double.tryParse(transaction.conversionAmount!) ?? 0.0
        : null;

    String currencyCode = fullType.contains('credit-exchange')
        ? transaction.to_currency ?? transaction.fromCurrency ?? ''
        : transaction.fromCurrency ?? '';

    if (fullType == 'credit-exchange' && conversionAmount != null) {
      return formatExportSafeAmount(conversionAmount, currencyCode, prefix: '+');
    }
    if (fullType == 'credit-add money' && conversionAmount != null) {
      return formatExportSafeAmount(conversionAmount, currencyCode, prefix: '+');
    }
    if (transType == 'add money') {
      return formatExportSafeAmount(displayAmount, currencyCode, prefix: '+');
    }
    if (fullType == 'credit-crypto' && conversionAmount != null) {
      return formatExportSafeAmount(displayAmount, currencyCode, prefix: '+');
    }
    if (fullType == 'debit-crypto' && conversionAmount != null) {
      return formatExportSafeAmount(cryptobillAmount, currencyCode, prefix: '-');
    }
    if (transType == 'external transfer' ||
        transType == 'beneficiary transfer money' ||
        transType == 'exchange') {
      return formatExportSafeAmount(fees + displayAmount, currencyCode, prefix: '-');
    }
    return formatExportSafeAmount(displayAmount, currencyCode);
  }

  // Export-safe balance display for transactions
  static String _getExportSafeBalanceDisplay(TransactionListDetails transaction) {
    String transType = transaction.transactionType?.toLowerCase() ?? '';
    String? extraType = transaction.extraType?.toLowerCase();
    String fullType = "$extraType-$transType";
    
    String currencyCode = fullType.contains('credit-exchange')
        ? transaction.to_currency ?? ''
        : transaction.fromCurrency ?? '';
    
    return formatExportSafeAmount(transaction.balance, currencyCode);
  }

  // Create Excel file with enhanced formatting
  static Future<String> createEnhancedExcelFile({
    required List<TransactionListDetails> transactions,
    required String fileName,
    String title = "Transaction Report",
  }) async {
    var excelInstance = excel.Excel.createExcel();
    excel.Sheet sheet = excelInstance['Sheet1'];
    
    // Remove default sheet if it exists
    if (excelInstance.sheets.containsKey('Sheet1')) {
      excelInstance.delete('Sheet1');
    }
    
    // Create new sheet with custom name
    sheet = excelInstance[title];
    
    // Header styling
    final headerStyle = excel.CellStyle(
      bold: true,
      backgroundColorHex: excel.ExcelColor.blue,
      fontColorHex: excel.ExcelColor.white,
    );
    
    // Set headers with styling
    final headers = ['Date', 'Transaction ID', 'Type', 'Amount', 'Balance', 'Status'];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = excel.TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }
    
    // Add data rows
    for (int i = 0; i < transactions.length; i++) {
      var transaction = transactions[i];
      final rowIndex = i + 1;
      
      // Date
      sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value =
          excel.TextCellValue(transaction.transactionDate != null
              ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(transaction.transactionDate!))
              : 'N/A');
      
      // Transaction ID
      sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex)).value =
          excel.TextCellValue(transaction.transactionId ?? 'N/A');
      
      // Type
      sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex)).value =
          excel.TextCellValue(transaction.transactionType ?? 'N/A');
      
      // Amount with export-safe currency formatting
      String amountDisplay = _getExportSafeAmountDisplay(transaction);
      sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value =
          excel.TextCellValue(amountDisplay);
      
      // Balance with export-safe currency formatting
      String balanceDisplay = _getExportSafeBalanceDisplay(transaction);
      sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex)).value =
          excel.TextCellValue(balanceDisplay);
      
      // Status
      String status = transaction.transactionStatus?.isEmpty ?? true
          ? 'Unknown'
          : (transaction.transactionStatus!.toLowerCase() == 'succeeded'
              ? 'Success'
              : transaction.transactionStatus!.substring(0, 1).toUpperCase() +
                  transaction.transactionStatus!.substring(1).toLowerCase());
      
      final statusCell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex));
      statusCell.value = excel.TextCellValue(status);
      
      // Color code status
      if (status.toLowerCase() == 'success') {
        statusCell.cellStyle = excel.CellStyle(fontColorHex: excel.ExcelColor.green);
      } else if (status.toLowerCase() == 'pending') {
        statusCell.cellStyle = excel.CellStyle(fontColorHex: excel.ExcelColor.orange);
      } else if (status.toLowerCase() == 'denied' || status.toLowerCase() == 'failed') {
        statusCell.cellStyle = excel.CellStyle(fontColorHex: excel.ExcelColor.red);
      }
    }
    
    // Auto-fit columns (approximate)
    for (int i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 20.0);
    }
    
    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/$fileName";
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excelInstance.encode()!);
    
    return path;
  }

  // Create PDF file with enhanced formatting
  static Future<String> createEnhancedPDFFile({
    required List<TransactionListDetails> transactions,
    required String fileName,
    String title = "Transaction Report",
  }) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Title
            pw.Header(
              level: 0,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),
            ),
            
            // Table
            pw.Table.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.center,
              columnWidths: {
                0: const pw.FixedColumnWidth(80),  // Date
                1: const pw.FixedColumnWidth(100), // Transaction ID
                2: const pw.FixedColumnWidth(80),  // Type
                3: const pw.FixedColumnWidth(80),  // Amount
                4: const pw.FixedColumnWidth(80),  // Balance
                5: const pw.FixedColumnWidth(60),  // Status
              },
              headers: ['Date', 'Transaction ID', 'Type', 'Amount', 'Balance', 'Status'],
              data: transactions.map((transaction) {
                String status = transaction.transactionStatus?.isEmpty ?? true
                    ? 'Unknown'
                    : (transaction.transactionStatus!.toLowerCase() == 'succeeded'
                        ? 'Success'
                        : transaction.transactionStatus!.substring(0, 1).toUpperCase() +
                            transaction.transactionStatus!.substring(1).toLowerCase());
                
                return [
                  transaction.transactionDate != null
                      ? DateFormat('dd MMM yyyy').format(DateTime.parse(transaction.transactionDate!))
                      : 'N/A',
                  transaction.transactionId ?? 'N/A',
                  transaction.transactionType ?? 'N/A',
                  _getExportSafeAmountDisplay(transaction),
                  _getExportSafeBalanceDisplay(transaction),
                  status,
                ];
              }).toList(),
            ),
            
            // Footer
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.only(top: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
              ),
              child: pw.Text(
                'Total Transactions: ${transactions.length}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ];
        },
      ),
    );
    
    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/$fileName";
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    
    return path;
  }

  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message, String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () => OpenFile.open(filePath),
              child: const Text(
                'Open',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 6,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 6,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}