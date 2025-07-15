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
          // if (_accounts.isNotEmpty && _selectedAccount == null) {
          //   _selectedAccount = _accounts[0];
          // }
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
    } catch (error) {
      provider.setError(error.toString());
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
            colorScheme: const ColorScheme.light(
              primary: kPrimaryColor,
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
        var transaction = transactions[i];
        String amountDisplay = _getAmountDisplay(transaction);
        String fullType = "${transaction.extraType?.toLowerCase() ?? ''}-${transaction.transactionType?.toLowerCase() ?? ''}";

        sheet.cell(excel.CellIndex.indexByString("A${i + 2}")).value = excel.TextCellValue(
            transaction.transactionDate != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(transaction.transactionDate!)) : 'N/A');
        sheet.cell(excel.CellIndex.indexByString("B${i + 2}")).value = excel.TextCellValue(transaction.transactionId ?? 'N/A');
        sheet.cell(excel.CellIndex.indexByString("C${i + 2}")).value = excel.TextCellValue(transaction.transactionType ?? 'N/A');
        sheet.cell(excel.CellIndex.indexByString("D${i + 2}")).value = excel.TextCellValue(amountDisplay);
        sheet.cell(excel.CellIndex.indexByString("E${i + 2}")).value = excel.TextCellValue(
            '${fullType.contains('credit-exchange') ? _getCurrencySymbol(transaction.to_currency) : _getCurrencySymbol(transaction.fromCurrency)}${transaction.balance?.toStringAsFixed(2) ?? '0.00'}');
        sheet.cell(excel.CellIndex.indexByString("F${i + 2}")).value = excel.TextCellValue(
            transaction.transactionStatus?.isEmpty ?? true
                ? 'Unknown'
                : (transaction.transactionStatus!.toLowerCase() == 'succeeded'
                    ? 'Success'
                    : transaction.transactionStatus!.substring(0, 1).toUpperCase() + transaction.transactionStatus!.substring(1).toLowerCase()));
      }

      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excelInstance.encode()!);

      await OpenFile.open(path);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Excel file downloaded successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error downloading Excel: $e')));
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF generated successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
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
    //if (fullType == 'debit-Beneficiary Transfer Money' && conversionAmount != null) return "-$currencySymbol${conversionAmount.toStringAsFixed(2)}";
    if (transType == 'external transfer' || fullType == 'debit-beneficiary transfer money' || transType == 'exchange') {
      return "-$currencySymbol${(fees + displayAmount).toStringAsFixed(2)}";
    }
    return "$currencySymbol${displayAmount.toStringAsFixed(2)}";
  }

  Widget _buildFilterDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [kWhiteColor.withOpacity(0.0), Colors.black12],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.black54, thickness: 1),
                const SizedBox(height: 20),

                // Date Range Section
                _buildSectionTitle('Date Range', Icons.calendar_today),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: _buildDateField(
                        
                          _startDate == null ? 'Start Date' : DateFormat('dd MMM yyyy').format(_startDate!),
                          _startDate == null ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: _buildDateField(
                          _endDate == null ? 'End Date' : DateFormat('dd MMM yyyy').format(_endDate!),
                          _endDate == null ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // Transaction Type
                _buildSectionTitle('Transaction Type', Icons.swap_horiz),
                const SizedBox(height: 15),
                _buildDropdown(
                  value: _selectedTransactionType,
                  items: _transactionTypes,
                  hint: 'Select Type',
                  onChanged: (value) => setState(() => _selectedTransactionType = value),
                ),
                const SizedBox(height: 35),

                // Status
                _buildSectionTitle('Status', Icons.check_circle_outline),
                const SizedBox(height: 10),
                _buildDropdown(
                  value: _selectedStatus,
                  items: _statuses,
                  hint: 'Select Status',
                  onChanged: (value) => setState(() => _selectedStatus = value),
                ),
                const SizedBox(height: 35),

                // Account
                _buildSectionTitle('Account', Icons.account_balance_wallet),
                const SizedBox(height: 10),
                _buildDropdown(
                  value: _selectedAccount,
                  items: _accounts,
                  hint: 'Select Account',
                  onChanged: (value) => setState(() => _selectedAccount = value),
                ),

                //const Spacer(),

                // Buttons
                SizedBox(height: 50,),
                Row(
                  children: [
                    Expanded(
                      //flex: 6,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                          shadowColor: kPrimaryColor.withOpacity(0.3),
                        ),
                        child: const Text(
                          'APPLY FILTERS',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: kPrimaryColor, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'RESET',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: kPrimaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String text, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 16, color: textColor),
          ),
          const Icon(Icons.calendar_today, size: 20, color: kPrimaryColor),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
        decoration: const InputDecoration(
          fillColor: Colors.transparent,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Transactions',
                style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Image.asset('assets/images/excel.png', width: 24, height: 24),
                  onPressed: () {
                    final provider = Provider.of<TransactionListProvider>(context, listen: false);
                    final filteredTransactions = _filterTransactions(provider.transactionList);
                    if (filteredTransactions.isNotEmpty) {
                      _downloadExcel(filteredTransactions);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No transactions to download')));
                    }
                  },
                  tooltip: 'Download as Excel',
                ),
                IconButton(
                  icon: Image.asset('assets/images/pdf.png', width: 24, height: 24),
                  onPressed: () {
                    final provider = Provider.of<TransactionListProvider>(context, listen: false);
                    final filteredTransactions = _filterTransactions(provider.transactionList);
                    if (filteredTransactions.isNotEmpty) {
                      _generatePDF(filteredTransactions);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No transactions to generate PDF')));
                    }
                  },
                  tooltip: 'View as PDF',
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt, color: kPrimaryColor, size: 28),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  tooltip: 'Open Filters',
                ),
                const SizedBox(width: 8),
              ],
            ),
            drawer: _buildFilterDrawer(),
            body: Consumer<TransactionListProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: SpinKitWaveSpinner(color: kPrimaryColor, size: 75));
                }

                final filteredTransactions = _filterTransactions(provider.transactionList);

                return RefreshIndicator(
                  onRefresh: () => _refreshData(context),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 0),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(color: Colors.black54),
                        ),
                        const SizedBox(height: defaultPadding),
                        if (provider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                          )
                        else if (filteredTransactions.isEmpty)
                          const NoTransactions()
                        else
                          Column(
                            children: filteredTransactions.map((transaction) => TransactionCard(
                              transaction: transaction,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TransactionDetailPage(transactionId: transaction.trxId),
                                  ),
                                );
                              },
                            )).toList(),
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
        return Colors.grey;
    }
  }

  Color _getAmountColor(String transType, String? extraType) {
    String fullType = "${extraType?.toLowerCase() ?? ''}-$transType".toLowerCase();
    if (fullType == 'credit-exchange' || fullType == 'credit-add money' || transType == 'add money' || fullType == 'credit-crypto') {
      return Colors.green;
    }
    if (fullType == 'debit-crypto' || transType == 'external transfer' || fullType == 'debit-beneficiary transfer money' || transType == 'exchange' || fullType == 'debit-exchange' || fullType == 'debit-external transfer') {
      return Colors.red;
    }
    return Colors.black;
  }

  IconData _getTransactionIcon(String transType, String? extraType) {
    String fullType = "${extraType?.toLowerCase() ?? ''}-$transType".toLowerCase();
    print(fullType);
    if (fullType == 'credit-exchange' || fullType == 'debit-exchange' || fullType == 'debit-beneficiary transfer money') {
      return Icons.sync; // Use the icon for exchange transactions
    } 
    if (fullType == 'credit-add money') {
      return Icons.arrow_forward; // Right arrow for credit (money coming in)
    }
    if (fullType == 'credit-crypto') {
      return Icons.currency_bitcoin; // Right arrow for credit (money coming in)
    }
    if (fullType == 'debit-crypto' || transType == 'external transfer') {
      return Icons.currency_bitcoin; // Left arrow for debit (money going out)
    }
    if (transType == 'external transfer') {
      return Icons.sync; // Left arrow for debit (money going out)
    }
    if (fullType == 'debit-external transfer') {
      return Icons.sync; // Left arrow for debit (money going out)
    }
    
    if (fullType == 'debit-beneficiary transfer money') {
      return Icons.sync; // Left arrow for debit (money going out)
    }
    return Icons.arrow_downward; // Default to downward arrow
  }

  Color _getIconColor(String transType, String? extraType) {
    String fullType = "${extraType?.toLowerCase() ?? ''}-$transType".toLowerCase();
    if (fullType == 'credit-exchange' || fullType == 'credit-add money' || transType == 'add money' || fullType == 'credit-crypto') {
      return Colors.green; // Green for credit
    }
    if (fullType == 'debit-exchange' || fullType == 'debit-crypto' || transType == 'external transfer' || fullType == 'debit-beneficiary transfer money' || transType == 'exchange' || fullType == 'debit-external transfer') {
      return Colors.red; // Red for debit
    }
    return Colors.black; // Default color
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
    if (transType == 'external transfer' || transType == 'exchange') {
      return "-$currencySymbol${(fees + displayAmount).toStringAsFixed(2)}";
    }
    if (fullType == 'debit-beneficiary transfer money') {
      return "-$currencySymbol${(fees + displayAmount).toStringAsFixed(2)}";
    }
    return "$currencySymbol${displayAmount.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    String transType = widget.transaction.transactionType?.toUpperCase() ?? '';
    String? extraType = widget.transaction.extraType?.toLowerCase();
    String fullType = "$extraType-$transType";

    String recipient = "User"; // Placeholder for recipient name
    String title = transType;
    String subtitle = "Trans ID: ${widget.transaction.transactionId ?? 'N/A'}";

    return AnimatedContainerWidget(
      fadeCurve: Easing.legacyAccelerate,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getIconColor(transType, extraType).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getTransactionIcon(transType, extraType),
                        color: _getIconColor(transType, extraType),
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
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
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getAmountDisplay(widget.transaction),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _getAmountColor(transType, extraType),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => _isExpanded = !_isExpanded),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Date:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(_formatDate(widget.transaction.transactionDate), style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Transaction ID:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(widget.transaction.transactionId ?? 'N/A', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Amount:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        _getAmountDisplay(widget.transaction),
                        style: TextStyle(
                          color: _getAmountColor(transType, extraType),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Type:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(widget.transaction.transactionType ?? 'N/A', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Balance:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        '${fullType.contains('credit-exchange') ? _getCurrencySymbol(widget.transaction.to_currency) : _getCurrencySymbol(widget.transaction.fromCurrency)}${widget.transaction.balance?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Status:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.transaction.transactionStatus),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.transaction.transactionStatus?.isEmpty ?? true
                              ? 'Unknown'
                              : (widget.transaction.transactionStatus!.toLowerCase() == 'succeeded'
                                  ? 'Success'
                                  : widget.transaction.transactionStatus!.substring(0, 1).toUpperCase() + widget.transaction.transactionStatus!.substring(1).toLowerCase()),
                          style: const TextStyle(color: Colors.white, fontSize: 16),
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