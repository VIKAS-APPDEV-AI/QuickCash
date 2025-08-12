# Excel and PDF Export Usage Guide

## Overview
This guide explains how to use the enhanced Excel and PDF export functionality with proper currency symbol support.

## Quick Start

### 1. Using the Enhanced Export Functions

The new export functionality is automatically integrated into all transaction screens. Users can:

- **Transaction Screen**: Tap the Excel/PDF export buttons
- **Statement Screen**: Use the export options in the menu
- **Dashboard**: Quick export from the transaction summary
- **All Transactions View**: Bulk export with filtering

### 2. Supported Currency Symbols

The system now supports proper Unicode rendering for:

#### Major Currencies
- **USD**: $ (Dollar)
- **EUR**: € (Euro)
- **GBP**: £ (Pound Sterling)
- **JPY**: ¥ (Yen)
- **CNY**: ¥ (Yuan)
- **INR**: ₹ (Rupee)
- **KRW**: ₩ (Won)
- **RUB**: ₽ (Ruble)

#### Regional Currencies
- **CAD**: C$ (Canadian Dollar)
- **AUD**: A$ (Australian Dollar)
- **SGD**: S$ (Singapore Dollar)
- **HKD**: HK$ (Hong Kong Dollar)
- **NZD**: NZ$ (New Zealand Dollar)
- **THB**: ฿ (Thai Baht)
- **MYR**: RM (Malaysian Ringgit)
- **PHP**: ₱ (Philippine Peso)
- **IDR**: Rp (Indonesian Rupiah)
- **VND**: ₫ (Vietnamese Dong)

#### Crypto Currencies
- **BTC**, **ETH**, **LTC**, **ADA**, **SOL**, **DOGE**, **BNB**, **BCH**, **SHIB**

## Testing the Implementation

### Manual Testing

1. **Navigate to any transaction screen**
2. **Tap the Excel or PDF export button**
3. **Open the generated file**
4. **Verify currency symbols display correctly**

### Automated Testing

Use the provided test utilities:

```dart
import 'package:quickcash/util/export_validation_utils.dart';
import 'package:quickcash/util/currency_test_utils.dart';

// Test all currency symbols
CurrencyTestUtils.testAllCurrencySymbols();

// Test currency formatting
CurrencyTestUtils.testCurrencyFormatting();

// Test Unicode support
CurrencyTestUtils.testUnicodeSupport();

// Run comprehensive export tests
await ExportValidationUtils.runComprehensiveTests();
```

## File Format Details

### Excel Files (.xlsx)
- **Professional Headers**: Blue background with white text
- **Auto-sized Columns**: Optimal width for readability
- **Status Color Coding**: Green (success), Orange (pending), Red (failed)
- **Enhanced Date Format**: "dd MMM yyyy, hh:mm a"
- **Proper Currency Symbols**: Unicode symbols in amount and balance columns

### PDF Files (.pdf)
- **Professional Layout**: Clean headers with generation timestamp
- **Table Styling**: Proper alignment and spacing
- **Color-coded Headers**: Blue background for headers
- **Footer Information**: Total transaction count
- **Proper Margins**: 20px margins for printing
- **Unicode Support**: Proper rendering of international currency symbols

## Troubleshooting

### Currency Symbols Not Displaying
1. **Check Currency Code**: Ensure the currency code is valid (e.g., "USD", "EUR")
2. **Update App**: Make sure you're using the latest version with the enhanced utilities
3. **File Viewer**: Some older Excel/PDF viewers may not support all Unicode symbols

### File Generation Errors
1. **Storage Permission**: Ensure the app has permission to write files
2. **Available Space**: Check device storage space
3. **File Path**: Verify the documents directory is accessible

### Performance Issues
1. **Large Datasets**: For exports with >1000 transactions, consider filtering
2. **Background Processing**: Large exports run in background to avoid UI blocking
3. **Memory Usage**: The system optimizes memory usage for large datasets

## Advanced Usage

### Custom Export Titles
```dart
await FileExportUtils.createEnhancedExcelFile(
  transactions: transactions,
  fileName: "custom_report.xlsx",
  title: "Monthly Financial Report",
);
```

### Filtered Exports
```dart
// Filter transactions by date range
final filteredTransactions = transactions.where((t) => 
  DateTime.parse(t.transactionDate!).isAfter(startDate) &&
  DateTime.parse(t.transactionDate!).isBefore(endDate)
).toList();

await FileExportUtils.createEnhancedPDFFile(
  transactions: filteredTransactions,
  fileName: "filtered_report.pdf",
  title: "Filtered Transaction Report",
);
```

## Best Practices

### For Developers
1. **Use FileExportUtils**: Always use the centralized utility methods
2. **Consistent Formatting**: Use `getEnhancedAmountDisplay()` for all amount displays
3. **Error Handling**: Implement proper try-catch blocks around export operations
4. **User Feedback**: Use the provided success/error snackbar methods

### For Users
1. **Regular Exports**: Export data regularly for backup purposes
2. **File Management**: Organize exported files in appropriate folders
3. **Verification**: Always verify currency symbols display correctly after export
4. **Sharing**: Use the "Open" button in success messages for quick file access

## File Locations

Exported files are saved to:
- **Android**: `/storage/emulated/0/Android/data/com.yourapp/files/Documents/`
- **iOS**: App Documents directory (accessible through Files app)

## Support

If you encounter issues:
1. Check the console logs for error messages
2. Verify currency codes are supported
3. Test with sample data using the validation utilities
4. Ensure sufficient device storage space

## Future Enhancements

Planned improvements:
- **Custom Templates**: User-selectable export templates
- **Cloud Integration**: Direct upload to Google Drive/Dropbox
- **Email Integration**: Send exports directly via email
- **Batch Processing**: Export multiple account statements
- **Advanced Filtering**: More granular export options

---

*This guide covers the enhanced Excel and PDF export functionality. For technical implementation details, see `EXCEL_PDF_IMPROVEMENTS.md`.*