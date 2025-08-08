import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/TransactionList/transactionListApi.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/TransactionList/transactionListModel.dart';
import 'package:quickcash/Screens/TransactionScreen/TransactionDetailsScreen/transaction_details_screen.dart';
import 'package:quickcash/constants.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/util/AnimatedContainerWidget.dart';
import 'package:quickcash/util/No_Transaction.dart';
import 'package:excel/excel.dart' as excel;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListApi.dart';

class ViewAllTransaction extends StatefulWidget {
  const ViewAllTransaction({super.key});

  @override
  State<ViewAllTransaction> createState() => _ViewAllTransactionState();
}

class _ViewAllTransactionState extends State<ViewAllTransaction> {
  final TransactionListApi _transactionListApi = TransactionListApi();
  final AccountsListApi _accountsListApi = AccountsListApi();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedTransactionType;
  String? _selectedStatus;
  String? _selectedAccount;

  final List<String> _transactionTypes = ['Add Money', 'Exchange', 'Money Transfer'];
  final List<String> _statuses = ['Pending', 'Complete', 'Denied'];
  List<String> _accounts = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchAccountsList();
  }

  Future<void> _fetchAccountsList() async {
    try {
      final response = await _accountsListApi.accountsListApi();
      if (response.accountsList != null) {
        final currencies = response.accountsList!
            .map((account) => account.currency)
            .where((currency) => currency != null)
            .cast<String>()
            .toSet()
            .toList();
        setState(() {
          _accounts = currencies;
        });
      } else {
        setState(() {
          _accounts = ['No Accounts'];
        });
      }
    } catch (e) {
      print('Error fetching accounts list: $e');
      setState(() {
        _accounts = ['No Accounts'];
      });
    }
  }

  Future<void> _loadTransactions(BuildContext context) async {
    final provider = Provider.of<TransactionListProvider>(context, listen: false);
    provider.setLoading(true);
    provider.clearError();

    try {
      final response = await _transactionListApi.transactionListApi();
      provider.updateTransactionList(response);
      if (response.transactionList == null || response.transactionList!.isEmpty) {
        Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: Lottie.asset(
              'assets/lottie/NoTransactions.json',
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
        );
      }
    } catch (e) {
      provider.setError(e.toString());
    } finally {
      provider.setLoading(false);
    }
  }

  Future<void> _refreshData(BuildContext context) async {
    await _loadTransactions(context);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).extension<AppColors>()!.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedTransactionType = null;
      _selectedStatus = null;
      _selectedAccount = null;
    });
  }

  List<TransactionListDetails> _filterTransactions(List<TransactionListDetails> transactions) {
    return transactions.where((transaction) {
      bool matches = true;

      if (_startDate != null || _endDate != null) {
        DateTime? transactionDate;
        try {
          transactionDate = DateTime.parse(transaction.transactionDate ?? '');
          transactionDate = DateTime(transactionDate.year, transactionDate.month, transactionDate.day);
        } catch (e) {
          return false;
        }

        if (_startDate != null) {
          DateTime normalizedStartDate = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
          if (transactionDate.isBefore(normalizedStartDate)) matches = false;
        }
        if (_endDate != null) {
          DateTime normalizedEndDate = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
          if (transactionDate.isAfter(normalizedEndDate)) matches = false;
        }
      }

      if (_selectedTransactionType != null &&
          transaction.transactionType?.toLowerCase() != _selectedTransactionType!.toLowerCase()) {
        matches = false;
      }

      if (_selectedStatus != null) {
        String normalizedTransactionStatus = transaction.transactionStatus?.toLowerCase() ?? '';
        String normalizedSelectedStatus = _selectedStatus!.toLowerCase();
        if (normalizedSelectedStatus == "complete") {
          if (normalizedTransactionStatus != "success" && normalizedTransactionStatus != "succeeded") {
            matches = false;
          }
        } else if (normalizedTransactionStatus != normalizedSelectedStatus) {
          matches = false;
        }
      }

      if (_selectedAccount != null) {
        String currency = transaction.fromCurrency ?? transaction.to_currency ?? '';
        if (currency != _selectedAccount) matches = false;
      }

      return matches;
    }).toList();
  }

  Future<void> _downloadExcel(List<TransactionListDetails> transactions) async {
    try {
      var excelInstance = excel.Excel.createExcel();
      excel.Sheet sheet = excelInstance['Sheet1'];

      sheet.cell(excel.CellIndex.indexByString("A1")).value = excel.TextCellValue("Date");
      sheet.cell(excel.CellIndex.indexByString("B1")).value = excel.TextCellValue("Transaction ID");
      sheet.cell(excel.CellIndex.indexByString("C1")).value = excel.TextCellValue("Type");
      sheet.cell(excel.CellIndex.indexByString("D1")).value = excel.TextCellValue("Amount");
      sheet.cell(excel.CellIndex.indexByString("E1")).value = excel.TextCellValue("Balance");
      sheet.cell(excel.CellIndex.indexByString("F1")).value = excel.TextCellValue("Status");

      for (int i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];
        final amountDisplay = _getAmountDisplay(transaction);
        final fullType = "${transaction.extraType?.toLowerCase() ?? ''}-${transaction.transactionType?.toLowerCase() ?? ''}";

        final currencySymbol = fullType.contains('credit-exchange')
            ? _getCurrencySymbol(transaction.to_currency)
            : _getCurrencySymbol(transaction.fromCurrency);

        final balanceValue = transaction.balance?.toStringAsFixed(2) ?? '0.00';
        String balanceText = '$currencySymbol$balanceValue';

        if (!balanceText.runes.every((r) => r < 128)) {
          balanceText = '${transaction.fromCurrency?.toUpperCase() ?? 'N/A'} $balanceValue';
        }

        final status = (transaction.transactionStatus?.isEmpty ?? true)
            ? 'Unknown'
            : (transaction.transactionStatus!.toLowerCase() == 'succeeded'
                ? 'Success'
                : transaction.transactionStatus![0].toUpperCase() +
                    transaction.transactionStatus!.substring(1).toLowerCase());

        sheet.cell(excel.CellIndex.indexByString("A${i + 2}")).value = excel.TextCellValue(
          transaction.transactionDate != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(transaction.transactionDate!))
              : 'N/A',
        );
        sheet.cell(excel.CellIndex.indexByString("B${i + 2}")).value =
            excel.TextCellValue(transaction.transactionId ?? 'N/A');
        sheet.cell(excel.CellIndex.indexByString("C${i + 2}")).value =
            excel.TextCellValue(transaction.transactionType ?? 'N/A');
        sheet.cell(excel.CellIndex.indexByString("D${i + 2}")).value = excel.TextCellValue(amountDisplay);
        sheet.cell(excel.CellIndex.indexByString("E${i + 2}")).value = excel.TextCellValue(balanceText);
        sheet.cell(excel.CellIndex.indexByString("F${i + 2}")).value = excel.TextCellValue(status);
      }

      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.xlsx";

      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excelInstance.encode()!);

      await OpenFile.open(path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Excel file downloaded successfully!',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () => OpenFile.open(path),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error downloading Excel: $e',
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

  Future<void> _generatePDF(List<TransactionListDetails> transactions) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(level: 0, child: pw.Text("Transaction List")),
              pw.Table.fromTextArray(
                headers: ['Date', 'Transaction ID', 'Type', 'Amount', 'Balance', 'Status'],
                data: transactions.map((transaction) {
                  String amountDisplay = _getAmountDisplay(transaction);
                  String fullType = "${transaction.extraType?.toLowerCase() ?? ''}-${transaction.transactionType?.toLowerCase() ?? ''}";
                  return [
                    transaction.transactionDate != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(transaction.transactionDate!)) : 'N/A',
                    transaction.transactionId ?? 'N/A',
                    transaction.transactionType ?? 'N/A',
                    amountDisplay,
                    '${fullType.contains('credit-exchange') ? _getCurrencySymbol(transaction.to_currency) : _getCurrencySymbol(transaction.fromCurrency)}${transaction.balance?.toStringAsFixed(2) ?? '0.00'}',
                    transaction.transactionStatus?.isEmpty ?? true
                        ? 'Unknown'
                        : (transaction.transactionStatus!.toLowerCase() == 'succeeded'
                            ? 'Success'
                            : transaction.transactionStatus!.substring(0, 1).toUpperCase() + transaction.transactionStatus!.substring(1).toLowerCase()),
                  ];
                }).toList(),
              ),
            ];
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PDF generated successfully!',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () => OpenFile.open(path),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error generating PDF: $e',
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

  String _getCurrencySymbol(String? currencyCode) {
    if (currencyCode == null) return '';
    if (currencyCode == "AWG") return 'ƒ';
    return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
  }

  String _getAmountDisplay(TransactionListDetails transaction) {
    String transType = transaction.transactionType?.toLowerCase() ?? '';
    String? extraType = transaction.extraType?.toLowerCase();
    String fullType = "$extraType-$transType";
    String currencySymbol = fullType.contains('credit-exchange') ? _getCurrencySymbol(transaction.to_currency) : _getCurrencySymbol(transaction.fromCurrency);

    double displayAmount = transaction.amount ?? 0.0;
    double fees = transaction.fees ?? 0.0;
    double cryptobillAmount = fees + displayAmount;
    double? conversionAmount = transaction.conversionAmount != null ? double.tryParse(transaction.conversionAmount!) ?? 0.0 : null;

    if (fullType == 'credit-exchange' && conversionAmount != null) return "+$currencySymbol${conversionAmount.toStringAsFixed(2)}";
    if (fullType == 'credit-add money' && conversionAmount != null) return "+$currencySymbol${conversionAmount.toStringAsFixed(2)}";
    if (transType == 'add money') return "+$currencySymbol${displayAmount.toStringAsFixed(2)}";
    if (fullType == 'credit-crypto' && conversionAmount != null) return "+$currencySymbol${displayAmount.toStringAsFixed(2)}";
    if (fullType == 'debit-crypto' && conversionAmount != null) return "-$currencySymbol${cryptobillAmount.toStringAsFixed(2)}";
    if (fullType == 'debit-wallet to card') return "-$currencySymbol${displayAmount.toStringAsFixed(2)}";
    if (transType == 'external transfer' || fullType == 'debit-beneficiary transfer money' || transType == 'exchange') {
      return "-$currencySymbol${(fees + displayAmount).toStringAsFixed(2)}";
    }
    return "$currencySymbol${displayAmount.toStringAsFixed(2)}";
  }

 Widget _buildFilterDrawer() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Drawer(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
      width: isSmallScreen ? size.width * 0.75 : size.width * 0.4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800.withOpacity(0.0) : Colors.white.withOpacity(0.0),
              Theme.of(context).brightness == Brightness.dark ? Colors.black54 : Colors.black12,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 20,
              vertical: isSmallScreen ? 8 : 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).extension<AppColors>()!.primary,
                        shadows: [
                          Shadow(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey.shade600,
                        size: isSmallScreen ? 24 : 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white54
                      : Colors.black54,
                  thickness: 1,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Date Range', Icons.calendar_today, isSmallScreen: isSmallScreen),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: _buildDateField(
                          _startDate == null ? 'Start Date' : DateFormat('dd MMM yyyy').format(_startDate!),
                          _startDate == null
                              ? Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey.shade600
                              : Theme.of(context).extension<AppColors>()!.primary,
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: _buildDateField(
                          _endDate == null ? 'End Date' : DateFormat('dd MMM yyyy').format(_endDate!),
                          _endDate == null
                              ? Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey.shade600
                              : Theme.of(context).extension<AppColors>()!.primary,
                          isSmallScreen: isSmallScreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                _buildSectionTitle('Transaction Type', Icons.swap_horiz, isSmallScreen: isSmallScreen),
                const SizedBox(height: 15),
                _buildDropdown(
                  value: _selectedTransactionType,
                  items: _transactionTypes,
                  hint: 'Select Type',
                  onChanged: (value) => setState(() => _selectedTransactionType = value),
                  isSmallScreen: isSmallScreen,
                ),
                const SizedBox(height: 35),
                _buildSectionTitle('Status', Icons.check_circle_outline, isSmallScreen: isSmallScreen),
                const SizedBox(height: 10),
                _buildDropdown(
                  value: _selectedStatus,
                  items: _statuses,
                  hint: 'Select Status',
                  onChanged: (value) => setState(() => _selectedStatus = value),
                  isSmallScreen: isSmallScreen,
                ),
                const SizedBox(height: 35),
                _buildSectionTitle('Account', Icons.account_balance_wallet, isSmallScreen: isSmallScreen),
                const SizedBox(height: 10),
                _buildDropdown(
                  value: _selectedAccount,
                  items: _accounts,
                  hint: 'Select Account',
                  onChanged: (value) => setState(() => _selectedAccount = value),
                  isSmallScreen: isSmallScreen,
                ),
                const SizedBox(height: 50),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                          shadowColor: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.3),
                        ),
                        child: Text(
                          'APPLY FILTERS',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _resetFilters();
                          setState(() {});
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                          side: BorderSide(
                            color: Theme.of(context).extension<AppColors>()!.primary,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'RESET',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).extension<AppColors>()!.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {required bool isSmallScreen}) {
    return Row(
      children: [
        Icon(
          icon,
          size: isSmallScreen ? 18 : 20,
          color: Theme.of(context).extension<AppColors>()!.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 15 : 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String text, Color textColor, {required bool isSmallScreen}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade600
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: textColor,
            ),
          ),
          Icon(
            Icons.calendar_today,
            size: isSmallScreen ? 18 : 20,
            color: Theme.of(context).extension<AppColors>()!.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(
          hint,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey,
          ),
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          fillColor: Colors.transparent,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 10),
        ),
        style: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
        dropdownColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Theme.of(context).extension<AppColors>()!.primary,
          size: isSmallScreen ? 20 : 24,
        ),
      ),
    );
  }

  Widget _buildExcelButton({
    required VoidCallback onPressed,
    required bool isSmallScreen,
    required bool isDownloading,
  }) {
    return GestureDetector(
      onTap: isDownloading ? null : onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: isSmallScreen ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isDownloading
              ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300)
              : Theme.of(context).extension<AppColors>()!.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isDownloading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Image.asset(
                    'assets/images/excel.png',
                    width: isSmallScreen ? 16 : 20,
                    height: isSmallScreen ? 16 : 20,
                  ),
            const SizedBox(width: 8),
            Text(
              'Excel',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPDFButton({
    required VoidCallback onPressed,
    required bool isSmallScreen,
    required bool isGenerating,
  }) {
    return GestureDetector(
      onTap: isGenerating ? null : onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: isSmallScreen ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isGenerating
              ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300)
              : Theme.of(context).extension<AppColors>()!.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Image.asset(
                    'assets/images/pdf.png',
                    width: isSmallScreen ? 16 : 20,
                    height: isSmallScreen ? 16 : 20,
                  ),
            const SizedBox(width: 8),
            Text(
              'PDF',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return ChangeNotifierProvider(
      create: (_) => TransactionListProvider(),
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final provider = Provider.of<TransactionListProvider>(context, listen: false);
            if (!provider.isInitialized) {
              _loadTransactions(context);
              provider.markInitialized();
            }
          });

          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              toolbarHeight: 70,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  size: isSmallScreen ? 20 : 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Transactions',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  fontSize: isSmallScreen ? 16 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              actions: [
                _buildExcelButton(
                  onPressed: () {
                    final provider = Provider.of<TransactionListProvider>(context, listen: false);
                    final filteredTransactions = _filterTransactions(provider.transactionList);
                    if (filteredTransactions.isNotEmpty) {
                      _downloadExcel(filteredTransactions);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.info, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No transactions to download',
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          elevation: 6,
                        ),
                      );
                    }
                  },
                  isSmallScreen: isSmallScreen,
                  isDownloading: false,
                ),
                const SizedBox(width: 8),
                _buildPDFButton(
                  onPressed: () {
                    final provider = Provider.of<TransactionListProvider>(context, listen: false);
                    final filteredTransactions = _filterTransactions(provider.transactionList);
                    if (filteredTransactions.isNotEmpty) {
                      _generatePDF(filteredTransactions);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.info, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No transactions to generate PDF',
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          elevation: 6,
                        ),
                      );
                    }
                  },
                  isSmallScreen: isSmallScreen,
                  isGenerating: false,
                ),
                IconButton(
                  icon: Icon(
                    Icons.filter_alt,
                    color: Theme.of(context).extension<AppColors>()!.primary,
                    size: isSmallScreen ? 24 : 28,
                  ),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  tooltip: 'Open Filters',
                ),
                SizedBox(width: isSmallScreen ? 4 : 8),
              ],
            ),
            drawer: _buildFilterDrawer(),
            body: Consumer<TransactionListProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: SpinKitWaveSpinner(
                      color: Theme.of(context).extension<AppColors>()!.primary,
                      size: 75,
                    ),
                  );
                }

                final filteredTransactions = _filterTransactions(provider.transactionList);

                return RefreshIndicator(
                  onRefresh: () => _refreshData(context),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: isSmallScreen ? 8 : 16),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 20),
                          child: Divider(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white54
                                : Colors.black54,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : defaultPadding),
                        if (provider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              provider.errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          )
                        else if (filteredTransactions.isEmpty)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: isSmallScreen ? 200 : 300,
                                height: isSmallScreen ? 200 : 300,
                                child: Lottie.asset(
                                  'assets/lottie/NoTransactions.json',
                                  fit: BoxFit.contain,
                                  repeat: true,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Transactions Found',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) {
                              return TransactionCard(
                                transaction: filteredTransactions[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TransactionDetailPage(
                                        transactionId: filteredTransactions[index].trxId,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class TransactionCard extends StatefulWidget {
  final TransactionListDetails transaction;
  final VoidCallback onTap;

  const TransactionCard({super.key, required this.transaction, required this.onTap});

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool _isExpanded = false;

  String _formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM, hh:mm a').format(DateTime.parse(dateTime));
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String _getCurrencySymbol(String? currencyCode) {
    if (currencyCode == null) return '';
    if (currencyCode == "AWG") return 'ƒ';
    return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'succeeded':
      case 'success':
      case 'complete':
        return Colors.green;
      case 'failed':
      case 'denied':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey;
    }
  }

  Color _getAmountColor(String transType, String? extraType) {
    String fullType = "${extraType?.toLowerCase() ?? ''}-$transType".toLowerCase();
    if (fullType == 'credit-exchange' || fullType == 'credit-add money' || transType == 'add money' || fullType == 'credit-crypto') {
      return Colors.green;
    }
    if (fullType == 'debit-crypto' || transType == 'external transfer' || fullType == 'debit-beneficiary transfer money' || transType == 'exchange' || fullType == 'debit-exchange' || fullType == 'debit-external transfer' || fullType == 'debit-wallet to card') {
      return Colors.red;
    }
    return Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  IconData _getTransactionIcon(String transType, String? extraType) {
    String fullType = "${extraType?.toLowerCase() ?? ''}-$transType".toLowerCase();
    if (fullType == 'credit-exchange' || fullType == 'debit-exchange' || fullType == 'debit-beneficiary transfer money') {
      return Icons.sync;
    }
    if (fullType == 'credit-add money') {
      return Icons.arrow_forward;
    }
    if (fullType == 'credit-crypto' || fullType == 'debit-crypto') {
      return Icons.currency_bitcoin;
    }
    if (transType == 'external transfer' || fullType == 'debit-external transfer' || fullType == 'debit-wallet to card') {
      return Icons.sync;
    }
    return Icons.arrow_downward;
  }

  Color _getIconColor(String transType, String? extraType) {
    String fullType = "${extraType?.toLowerCase() ?? ''}-$transType".toLowerCase();
    if (fullType == 'credit-exchange' || fullType == 'credit-add money' || transType == 'add money' || fullType == 'credit-crypto') {
      return Colors.green;
    }
    if (fullType == 'debit-exchange' || fullType == 'debit-crypto' || transType == 'external transfer' || fullType == 'debit-beneficiary transfer money' || transType == 'exchange' || fullType == 'debit-external transfer' || fullType == 'debit-wallet to card') {
      return Colors.red;
    }
    return Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  String _getAmountDisplay(TransactionListDetails transaction) {
    String transType = transaction.transactionType?.toLowerCase() ?? '';
    String? extraType = transaction.extraType?.toLowerCase();
    String fullType = "$extraType-$transType";
    String currencySymbol = fullType.contains('credit-exchange') ? _getCurrencySymbol(widget.transaction.to_currency) : _getCurrencySymbol(widget.transaction.fromCurrency);

    double displayAmount = transaction.amount ?? 0.0;
    double fees = transaction.fees ?? 0.0;
    double cryptobillAmount = fees + displayAmount;
    double? conversionAmount = transaction.conversionAmount != null ? double.tryParse(transaction.conversionAmount!) ?? 0.0 : null;

    if (fullType == 'credit-exchange' && conversionAmount != null) return "+$currencySymbol${conversionAmount.toStringAsFixed(2)}";
    if (fullType == 'credit-add money' && conversionAmount != null) return "+$currencySymbol${conversionAmount.toStringAsFixed(2)}";
    if (transType == 'add money') return "+$currencySymbol${displayAmount.toStringAsFixed(2)}";
    if (fullType == 'credit-crypto' && conversionAmount != null) return "+$currencySymbol${displayAmount.toStringAsFixed(2)}";
    if (fullType == 'debit-crypto' && conversionAmount != null) return "-$currencySymbol${cryptobillAmount.toStringAsFixed(2)}";
    if (fullType == 'debit-wallet to card') return "-$currencySymbol${displayAmount.toStringAsFixed(2)}";
    if (transType == 'external transfer' || fullType == 'debit-beneficiary transfer money' || transType == 'exchange') {
      return "-$currencySymbol${(fees + displayAmount).toStringAsFixed(2)}";
    }
    return "$currencySymbol${displayAmount.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    String transType = widget.transaction.transactionType?.toUpperCase() ?? '';
    String? extraType = widget.transaction.extraType?.toLowerCase();
    String fullType = "$extraType-$transType";

    String title = transType;
    String subtitle = "Trans ID: ${widget.transaction.transactionId ?? 'N/A'}";

    return AnimatedContainerWidget(
      fadeCurve: Easing.legacyAccelerate,
      child: Card(
        margin: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 6 : 8,
          horizontal: isSmallScreen ? 12 : 16,
        ),
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade600
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                      decoration: BoxDecoration(
                        color: _getIconColor(transType, extraType).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getTransactionIcon(transType, extraType),
                        color: _getIconColor(transType, extraType),
                        size: isSmallScreen ? 20 : 23,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 2 : 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDate(widget.transaction.transactionDate),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 2 : 4),
                        Text(
                          _getAmountDisplay(widget.transaction),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 15,
                            fontWeight: FontWeight.bold,
                            color: _getAmountColor(transType, extraType),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.grey,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          onPressed: () => setState(() => _isExpanded = !_isExpanded),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  Divider(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.grey.shade300,
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Date:",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      Text(
                        _formatDate(widget.transaction.transactionDate),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Transaction ID:",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      Text(
                        widget.transaction.transactionId ?? 'N/A',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Amount:",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      Text(
                        _getAmountDisplay(widget.transaction),
                        style: TextStyle(
                          color: _getAmountColor(transType, extraType),
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Type:",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      Text(
                        widget.transaction.transactionType ?? 'N/A',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Balance:",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      Text(
                        '${fullType.contains('credit-exchange') ? _getCurrencySymbol(widget.transaction.to_currency) : _getCurrencySymbol(widget.transaction.fromCurrency)}${widget.transaction.balance?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Status:",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12,
                          vertical: isSmallScreen ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.transaction.transactionStatus),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.transaction.transactionStatus?.isEmpty ?? true
                              ? 'Unknown'
                              : (widget.transaction.transactionStatus!.toLowerCase() == 'succeeded'
                                  ? 'Success'
                                  : widget.transaction.transactionStatus!.substring(0, 1).toUpperCase() +
                                      widget.transaction.transactionStatus!.substring(1).toLowerCase()),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionListProvider with ChangeNotifier {
  List<TransactionListDetails> transactionList = [];
  bool isLoading = false;
  String? errorMessage;
  bool isInitialized = false;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void markInitialized() {
    isInitialized = true;
  }

  void updateTransactionList(TransactionListResponse response) {
    transactionList = response.transactionList ?? [];
    notifyListeners();
  }
}