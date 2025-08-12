import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/TransactionList/transactionListModel.dart';
import 'package:quickcash/constants.dart';

/// Enhanced export utilities with proper currency symbol encoding
class EnhancedExportUtils {
  
  /// Get currency symbol with proper encoding handling
  static String getCurrencySymbolWithEncoding(String? currencyCode) {
    if (currencyCode == null || currencyCode.isEmpty) return 'USD';
    
    // Use currency code + symbol format for better compatibility
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
      case 'JOD':
        return 'JOD د.أ';
      case 'LBP':
        return 'LBP ل.ل';
      case 'EGP':
        return 'EGP ج.م';
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
      case 'CAD':
        return 'CAD C\$';
      case 'AUD':
        return 'AUD A\$';
      case 'CHF':
        return 'CHF';
      case 'SEK':
        return 'SEK kr';
      case 'NOK':
        return 'NOK kr';
      case 'DKK':
        return 'DKK kr';
      case 'BRL':
        return 'BRL R\$';
      case 'MXN':
        return 'MXN \$';
      case 'ZAR':
        return 'ZAR R';
      case 'SGD':
        return 'SGD S\$';
      case 'HKD':
        return 'HKD HK\$';
      case 'NZD':
        return 'NZD NZ\$';
      case 'MYR':
        return 'MYR RM';
      case 'IDR':
        return 'IDR Rp';
      case 'AWG':
        return 'AWG ƒ';
      default:
        // For crypto and unknown currencies
        return currencyCode.toUpperCase();
    }
  }
  
  /// Format amount with proper currency encoding
  static String formatAmountWithCurrency(double? amount, String? currencyCode, {String prefix = ''}) {
    if (amount == null) return '0.00';
    
    final formattedAmount = amount.toStringAsFixed(2);
    final currencyDisplay = getCurrencySymbolWithEncoding(currencyCode);
    
    return '$prefix$currencyDisplay $formattedAmount';
  }
  
  /// Get amount display for transaction with proper encoding
  static String getAmountDisplayWithEncoding(TransactionListDetails transaction) {
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
      return formatAmountWithCurrency(conversionAmount, currencyCode, prefix: '+');
    }
    if (fullType == 'credit-add money' && conversionAmount != null) {
      return formatAmountWithCurrency(conversionAmount, currencyCode, prefix: '+');
    }
    if (transType == 'add money') {
      return formatAmountWithCurrency(displayAmount, currencyCode, prefix: '+');
    }
    if (fullType == 'credit-crypto' && conversionAmount != null) {
      return formatAmountWithCurrency(displayAmount, currencyCode, prefix: '+');
    }
    if (fullType == 'debit-crypto' && conversionAmount != null) {
      return formatAmountWithCurrency(cryptobillAmount, currencyCode, prefix: '-');
    }
    if (transType == 'external transfer' ||
        transType == 'beneficiary transfer money' ||
        transType == 'exchange') {
      return formatAmountWithCurrency(fees + displayAmount, currencyCode, prefix: '-');
    }
    return formatAmountWithCurrency(displayAmount, currencyCode);
  }
  
  /// Get balance display for transaction with proper encoding
  static String getBalanceDisplayWithEncoding(TransactionListDetails transaction) {
    String transType = transaction.transactionType?.toLowerCase() ?? '';
    String? extraType = transaction.extraType?.toLowerCase();
    String fullType = "$extraType-$transType";
    
    String currencyCode = fullType.contains('credit-exchange')
        ? transaction.to_currency ?? ''
        : transaction.fromCurrency ?? '';
    
    return formatAmountWithCurrency(transaction.balance, currencyCode);
  }
  
  /// Create Excel file with proper encoding
  static Future<String> createExcelWithProperEncoding({
    required List<TransactionListDetails> transactions,
    required String fileName,
    String title = "Transaction Report",
  }) async {
    var excelInstance = excel.Excel.createExcel();
    
    // Remove default sheet
    if (excelInstance.sheets.containsKey('Sheet1')) {
      excelInstance.delete('Sheet1');
    }
    
    // Create new sheet
    excel.Sheet sheet = excelInstance[title];
    
    // Header styling
    final headerStyle = excel.CellStyle(
      bold: true,
      backgroundColorHex: excel.ExcelColor.blue,
      fontColorHex: excel.ExcelColor.white,
    );
    
    // Set headers
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
      
      // Amount with proper encoding
      String amountDisplay = getAmountDisplayWithEncoding(transaction);
      sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex)).value =
          excel.TextCellValue(amountDisplay);
      
      // Balance with proper encoding
      String balanceDisplay = getBalanceDisplayWithEncoding(transaction);
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
      
      // Color-code status
      if (status.toLowerCase() == 'success') {
        statusCell.cellStyle = excel.CellStyle(fontColorHex: excel.ExcelColor.green);
      } else if (status.toLowerCase() == 'pending') {
        statusCell.cellStyle = excel.CellStyle(fontColorHex: excel.ExcelColor.orange);
      } else if (status.toLowerCase() == 'failed' || status.toLowerCase() == 'denied') {
        statusCell.cellStyle = excel.CellStyle(fontColorHex: excel.ExcelColor.red);
      }
    }
    
    // Auto-size columns
    for (int i = 0; i < 6; i++) {
      sheet.setColumnAutoFit(i);
    }
    
    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/$fileName";
    final bytes = excelInstance.encode();
    final file = File(path);
    await file.writeAsBytes(bytes!);
    
    return path;
  }
  
  /// Create PDF file with proper encoding
  static Future<String> createPDFWithProperEncoding({
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
                3: const pw.FixedColumnWidth(120), // Amount (wider for currency)
                4: const pw.FixedColumnWidth(120), // Balance (wider for currency)
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
                  getAmountDisplayWithEncoding(transaction),
                  getBalanceDisplayWithEncoding(transaction),
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
  
  /// Show success snackbar with proper styling
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
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 6,
      ),
    );
  }
  
  /// Show error snackbar
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
      ),
    );
  }
}