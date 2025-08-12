import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;

import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;
import 'package:quickcash/Screens/DashboardScreen/Dashboard/TransactionList/transactionListModel.dart';


/// Advanced export utilities with full Unicode support and crypto logos
class AdvancedExportUtils {
  
  // Crypto logo URLs (you can host these locally or use CDN)
  static const Map<String, String> cryptoLogoUrls = {
    'BTC': 'https://cryptologos.cc/logos/bitcoin-btc-logo.png',
    'ETH': 'https://cryptologos.cc/logos/ethereum-eth-logo.png',
    'LTC': 'https://cryptologos.cc/logos/litecoin-ltc-logo.png',
    'ADA': 'https://cryptologos.cc/logos/cardano-ada-logo.png',
    'SOL': 'https://cryptologos.cc/logos/solana-sol-logo.png',
    'DOGE': 'https://cryptologos.cc/logos/dogecoin-doge-logo.png',
    'BNB': 'https://cryptologos.cc/logos/bnb-bnb-logo.png',
    'BCH': 'https://cryptologos.cc/logos/bitcoin-cash-bch-logo.png',
    'SHIB': 'https://cryptologos.cc/logos/shiba-inu-shib-logo.png',
  };

  // Local crypto logo assets (fallback)
  static const Map<String, String> cryptoLogoAssets = {
    'BTC': 'assets/crypto_logos/bitcoin.png',
    'ETH': 'assets/crypto_logos/ethereum.png',
    'LTC': 'assets/crypto_logos/litecoin.png',
    'ADA': 'assets/crypto_logos/cardano.png',
    'SOL': 'assets/crypto_logos/solana.png',
    'DOGE': 'assets/crypto_logos/dogecoin.png',
    'BNB': 'assets/crypto_logos/binance.png',
    'BCH': 'assets/crypto_logos/bitcoin-cash.png',
    'SHIB': 'assets/crypto_logos/shiba-inu.png',
  };

  /// Check if currency is a cryptocurrency
  static bool isCryptoCurrency(String? currencyCode) {
    if (currencyCode == null) return false;
    return cryptoLogoUrls.containsKey(currencyCode.toUpperCase());
  }

  /// Get currency symbol with full Unicode support
  static String getUnicodeCurrencySymbol(String? currencyCode) {
    if (currencyCode == null || currencyCode.isEmpty) return '\$';
    
    switch (currencyCode.toUpperCase()) {
      // Major fiat currencies
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'CNY': return '¥';
      case 'INR': return '₹';
      case 'KRW': return '₩';
      case 'RUB': return '₽';
      
      // Middle Eastern currencies
      case 'AED': return 'د.إ';
      case 'SAR': return 'ر.س';
      case 'QAR': return 'ر.ق';
      case 'KWD': return 'د.ك';
      case 'BHD': return 'د.ب';
      case 'OMR': return 'ر.ع';
      case 'JOD': return 'د.أ';
      case 'LBP': return 'ل.ل';
      case 'EGP': return 'ج.م';
      
      // Asian currencies
      case 'THB': return '฿';
      case 'PHP': return '₱';
      case 'VND': return '₫';
      case 'MYR': return 'RM';
      case 'IDR': return 'Rp';
      case 'SGD': return 'S\$';
      case 'HKD': return 'HK\$';
      
      // European currencies
      case 'CHF': return 'CHF';
      case 'SEK': return 'kr';
      case 'NOK': return 'kr';
      case 'DKK': return 'kr';
      case 'PLN': return 'zł';
      case 'CZK': return 'Kč';
      case 'HUF': return 'Ft';
      case 'TRY': return '₺';
      
      // Other currencies
      case 'CAD': return 'C\$';
      case 'AUD': return 'A\$';
      case 'NZD': return 'NZ\$';
      case 'BRL': return 'R\$';
      case 'MXN': return '\$';
      case 'ZAR': return 'R';
      case 'AWG': return 'ƒ';
      
      // Cryptocurrencies
      case 'BTC': return '₿';
      case 'ETH': return 'Ξ';
      case 'LTC': return 'Ł';
      default:
        return currencyCode.toUpperCase();
    }
  }

  /// Format currency amount with proper Unicode symbols
  static String formatCurrencyWithUnicode(double? amount, String? currencyCode, {String prefix = ''}) {
    if (amount == null) return '0.00';
    
    final symbol = getUnicodeCurrencySymbol(currencyCode);
    final formattedAmount = amount.toStringAsFixed(2);
    
    if (isCryptoCurrency(currencyCode)) {
      // For crypto, show symbol after amount
      return '$prefix$formattedAmount $symbol';
    } else {
      // For fiat, show symbol before amount
      return '$prefix$symbol$formattedAmount';
    }
  }

  /// Download crypto logo from URL
  static Future<Uint8List?> downloadCryptoLogo(String currencyCode) async {
    try {
      final url = cryptoLogoUrls[currencyCode.toUpperCase()];
      if (url == null) return null;
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print('Failed to download crypto logo for $currencyCode: $e');
    }
    return null;
  }

  /// Load crypto logo from assets
  static Future<Uint8List?> loadCryptoLogoFromAssets(String currencyCode) async {
    try {
      final assetPath = cryptoLogoAssets[currencyCode.toUpperCase()];
      if (assetPath == null) return null;
      
      final ByteData data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      print('Failed to load crypto logo from assets for $currencyCode: $e');
    }
    return null;
  }

  /// Get crypto logo (try download first, fallback to assets)
  static Future<Uint8List?> getCryptoLogo(String currencyCode) async {
    // Try downloading first
    Uint8List? logoData = await downloadCryptoLogo(currencyCode);
    
    // Fallback to assets
    if (logoData == null) {
      logoData = await loadCryptoLogoFromAssets(currencyCode);
    }
    
    return logoData;
  }

  /// Create advanced Excel file with Unicode fonts and crypto logos
  static Future<String> createAdvancedExcelFile({
    required List<TransactionListDetails> transactions,
    required String fileName,
    String title = "Transaction Report",
  }) async {
    // Create Excel workbook
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet worksheet = workbook.worksheets[0];
    worksheet.name = title;

    // Set up Unicode font
    final xlsio.Style headerStyle = workbook.styles.add('HeaderStyle');
    headerStyle.fontName = 'Noto Sans';
    headerStyle.fontSize = 12;
    headerStyle.bold = true;
    headerStyle.fontColor = '#FFFFFF';
    headerStyle.backColor = '#6f35a5';
    headerStyle.hAlign = xlsio.HAlignType.center;
    headerStyle.vAlign = xlsio.VAlignType.center;

    final xlsio.Style dataStyle = workbook.styles.add('DataStyle');
    dataStyle.fontName = 'Noto Sans';
    dataStyle.fontSize = 10;
    dataStyle.vAlign = xlsio.VAlignType.center;

    final xlsio.Style cryptoStyle = workbook.styles.add('CryptoStyle');
    cryptoStyle.fontName = 'Noto Sans';
    cryptoStyle.fontSize = 10;
    cryptoStyle.fontColor = '#FF6600';
    cryptoStyle.bold = true;

    // Set headers
    final headers = ['Date', 'ID', 'Type', 'Currency', 'Amount', 'Balance', 'Status'];
    for (int i = 0; i < headers.length; i++) {
      final cell = worksheet.getRangeByIndex(1, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Add data rows
    for (int i = 0; i < transactions.length; i++) {
      final transaction = transactions[i];
      final rowIndex = i + 2;

      // Date
      worksheet.getRangeByIndex(rowIndex, 1).setText(
        transaction.transactionDate != null
            ? DateTime.parse(transaction.transactionDate!).toString().substring(0, 19)
            : 'N/A'
      );

      // Transaction ID
      worksheet.getRangeByIndex(rowIndex, 2).setText(transaction.transactionId ?? 'N/A');

      // Type
      worksheet.getRangeByIndex(rowIndex, 3).setText(transaction.transactionType ?? 'N/A');

      // Currency with logo indicator
      final currencyCode = transaction.fromCurrency ?? 'USD';
      final currencyCell = worksheet.getRangeByIndex(rowIndex, 4);
      
      if (isCryptoCurrency(currencyCode)) {
        currencyCell.setText('🪙 $currencyCode'); // Crypto indicator
        currencyCell.cellStyle = cryptoStyle;
      } else {
        currencyCell.setText(currencyCode);
      }

      // Amount with Unicode symbols
      final amountCell = worksheet.getRangeByIndex(rowIndex, 5);
      final amountDisplay = formatCurrencyWithUnicode(transaction.amount, currencyCode);
      amountCell.setText(amountDisplay);
      
      if (isCryptoCurrency(currencyCode)) {
        amountCell.cellStyle = cryptoStyle;
      }

      // Balance with Unicode symbols
      final balanceCell = worksheet.getRangeByIndex(rowIndex, 6);
      final balanceDisplay = formatCurrencyWithUnicode(transaction.balance, currencyCode);
      balanceCell.setText(balanceDisplay);

      // Status
      final status = transaction.transactionStatus?.toLowerCase() == 'succeeded' ? 'Success' : 
                    (transaction.transactionStatus ?? 'Unknown');
      worksheet.getRangeByIndex(rowIndex, 7).setText(status);

      // Apply data style to all cells in row
      for (int col = 1; col <= 7; col++) {
        if (col != 4 && col != 5) { // Skip currency and amount cells (already styled)
          worksheet.getRangeByIndex(rowIndex, col).cellStyle = dataStyle;
        }
      }
    }

    // Auto-fit columns
    for (int i = 1; i <= 7; i++) {
      worksheet.autoFitColumn(i);
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/$fileName";
    final List<int> bytes = workbook.saveAsStream();
    final File file = File(path);
    await file.writeAsBytes(bytes);
    
    workbook.dispose();
    return path;
  }

  /// Create advanced PDF file with Unicode fonts and crypto logos
  static Future<String> createAdvancedPDFFile({
    required List<TransactionListDetails> transactions,
    required String fileName,
    String title = "Transaction Report",
  }) async {
    // Create PDF document
    final sf_pdf.PdfDocument document = sf_pdf.PdfDocument();
    final sf_pdf.PdfPage page = document.pages.add();
    final sf_pdf.PdfGraphics graphics = page.graphics;

    // Load Unicode fonts
    final sf_pdf.PdfFont headerFont = await _loadUnicodeFont(size: 14, isBold: true);
    final sf_pdf.PdfFont dataFont = await _loadUnicodeFont(size: 10);
    final sf_pdf.PdfFont cryptoFont = await _loadUnicodeFont(size: 10, isBold: true);

    // Colors
    final sf_pdf.PdfColor headerColor = sf_pdf.PdfColor(0, 102, 204);
    final sf_pdf.PdfColor cryptoColor = sf_pdf.PdfColor(255, 102, 0);
    final sf_pdf.PdfColor textColor = sf_pdf.PdfColor(0, 0, 0);

    // Draw title
    graphics.drawString(
      title,
      headerFont,
      brush: sf_pdf.PdfSolidBrush(headerColor),
      bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 30),
    );

    // Draw generation date
    graphics.drawString(
      'Generated: ${DateTime.now().toString().substring(0, 19)}',
      dataFont,
      brush: sf_pdf.PdfSolidBrush(textColor),
      bounds: Rect.fromLTWH(0, 35, page.getClientSize().width, 20),
    );

    // Create table
    final sf_pdf.PdfGrid grid = sf_pdf.PdfGrid();
    grid.columns.add(count: 7);

    // Set headers
    final sf_pdf.PdfGridRow headerRow = grid.headers.add(1)[0];
    final headers = ['Date', 'ID', 'Type', 'Currency', 'Amount', 'Balance', 'Status'];
    
    for (int i = 0; i < headers.length; i++) {
      headerRow.cells[i].value = headers[i];
      headerRow.cells[i].style.font = headerFont;
      headerRow.cells[i].style.backgroundBrush = sf_pdf.PdfSolidBrush(headerColor);
      headerRow.cells[i].style.textBrush = sf_pdf.PdfSolidBrush(sf_pdf.PdfColor(255, 255, 255));
      headerRow.cells[i].style.stringFormat = sf_pdf.PdfStringFormat(
        alignment: sf_pdf.PdfTextAlignment.center,
        lineAlignment: sf_pdf.PdfVerticalAlignment.middle,
      );
    }

    // Add data rows
    for (final transaction in transactions) {
      final sf_pdf.PdfGridRow row = grid.rows.add();
      
      // Date
      row.cells[0].value = transaction.transactionDate != null
          ? DateTime.parse(transaction.transactionDate!).toString().substring(0, 19)
          : 'N/A';

      // Transaction ID
      row.cells[1].value = transaction.transactionId ?? 'N/A';

      // Type
      row.cells[2].value = transaction.transactionType ?? 'N/A';

      // Currency with crypto indicator
      final currencyCode = transaction.fromCurrency ?? 'USD';
      if (isCryptoCurrency(currencyCode)) {
        row.cells[3].value = '🪙 $currencyCode';
        row.cells[3].style.font = cryptoFont;
        row.cells[3].style.textBrush = sf_pdf.PdfSolidBrush(cryptoColor);
      } else {
        row.cells[3].value = currencyCode;
      }

      // Amount with Unicode symbols
      final amountDisplay = formatCurrencyWithUnicode(transaction.amount, currencyCode);
      row.cells[4].value = amountDisplay;
      if (isCryptoCurrency(currencyCode)) {
        row.cells[4].style.font = cryptoFont;
        row.cells[4].style.textBrush = sf_pdf.PdfSolidBrush(cryptoColor);
      }

      // Balance with Unicode symbols
      final balanceDisplay = formatCurrencyWithUnicode(transaction.balance, currencyCode);
      row.cells[5].value = balanceDisplay;

      // Status
      row.cells[6].value = transaction.transactionStatus?.toLowerCase() == 'succeeded' 
          ? 'Success' 
          : (transaction.transactionStatus ?? 'Unknown');

      // Apply default font to cells without specific styling
      for (int i = 0; i < 7; i++) {
        if (i != 3 && i != 4) { // Skip currency and amount cells
          row.cells[i].style.font = dataFont;
        }
      }
    }

    // Draw grid
    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(0, 70, page.getClientSize().width, page.getClientSize().height - 100),
    );

    // Add crypto logos if any crypto transactions exist
    await _addCryptoLogosToPage(page, transactions);

    // Save document
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/$fileName";
    final File file = File(path);
    await file.writeAsBytes(await document.save());
    
    document.dispose();
    return path;
  }

  /// Load Unicode font for PDF
  static Future<sf_pdf.PdfFont> _loadUnicodeFont({double size = 12, bool isBold = false}) async {
    try {
      // Try to load Noto Sans font for Unicode support
      final String fontPath = isBold 
          ? 'assets/fonts/NotoSans-Bold.ttf'
          : 'assets/fonts/NotoSans-Regular.ttf';
      
      final ByteData fontData = await rootBundle.load(fontPath);
      return sf_pdf.PdfTrueTypeFont(fontData.buffer.asUint8List(), size);
    } catch (e) {
      // Fallback to standard font
      return sf_pdf.PdfStandardFont(
        sf_pdf.PdfFontFamily.helvetica,
        size,
        style: isBold ? sf_pdf.PdfFontStyle.bold : sf_pdf.PdfFontStyle.regular,
      );
    }
  }

  /// Add crypto logos to PDF page
  static Future<void> _addCryptoLogosToPage(sf_pdf.PdfPage page, List<TransactionListDetails> transactions) async {
    final Set<String> cryptoCurrencies = {};
    
    // Collect unique crypto currencies
    for (final transaction in transactions) {
      final currency = transaction.fromCurrency;
      if (currency != null && isCryptoCurrency(currency)) {
        cryptoCurrencies.add(currency.toUpperCase());
      }
    }

    // Add legend with crypto logos
    if (cryptoCurrencies.isNotEmpty) {
      final sf_pdf.PdfGraphics graphics = page.graphics;
      double yPosition = page.getClientSize().height - 50;
      
      graphics.drawString(
        'Crypto Currencies:',
        await _loadUnicodeFont(size: 10, isBold: true),
        brush: sf_pdf.PdfSolidBrush(sf_pdf.PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(0, yPosition, 200, 20),
      );

      double xPosition = 0;
      for (final currency in cryptoCurrencies) {
        final logoData = await getCryptoLogo(currency);
        if (logoData != null) {
          try {
            final sf_pdf.PdfBitmap logo = sf_pdf.PdfBitmap(logoData);
            graphics.drawImage(
              logo,
              Rect.fromLTWH(xPosition, yPosition + 20, 20, 20),
            );
            
            graphics.drawString(
              currency,
              await _loadUnicodeFont(size: 8),
              brush: sf_pdf.PdfSolidBrush(sf_pdf.PdfColor(0, 0, 0)),
              bounds: Rect.fromLTWH(xPosition, yPosition + 42, 30, 15),
            );
            
            xPosition += 40;
          } catch (e) {
            print('Failed to add logo for $currency: $e');
          }
        }
      }
    }
  }

  /// Show success notification with enhanced styling
  static void showAdvancedSuccessSnackBar(BuildContext context, String message, String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'With Unicode fonts & crypto logos',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton.icon(
                  onPressed: () => OpenFile.open(filePath),
                  icon: const Icon(Icons.open_in_new, color: Colors.white, size: 16),
                  label: const Text(
                    'Open',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 8,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Show error notification
  static void showAdvancedErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }
}