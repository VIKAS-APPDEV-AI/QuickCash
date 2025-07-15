import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickcash/Screens/TransactionScreen/TransactionDetailsScreen/model/transactionDetailsApi.dart';
import 'package:quickcash/Screens/TransactionScreen/TransactionDetailsScreen/model/transactionDetailsModel.dart';
import 'package:quickcash/constants.dart';

class TransactionDetailPage extends StatefulWidget {
  final String? transactionId;

  const TransactionDetailPage({super.key, this.transactionId});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final TransactionDetailsListApi _transactionDetailsListApi =
      TransactionDetailsListApi();
  Future<TransactionDetailsListResponse?>? _initialFetchFuture;

  @override
  void initState() {
    super.initState();
    _initialFetchFuture = _fetchInitialData();
  }

  Future<TransactionDetailsListResponse?> _fetchInitialData() async {
    if (widget.transactionId == null) {
      print("Transaction ID is null");
      return null;
    }
    try {
      final response = await _transactionDetailsListApi
          .transactionDetailsListApi(widget.transactionId!);
      print("Initial API Response: ${jsonEncode(response.toJson())}");
      return response;
    } catch (error) {
      print("Fetch error: $error");
      return null;
    }
  }

  Future<void> _refreshData(BuildContext context) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.setLoading(true);
    provider.clearError();

    try {
      final response = await _transactionDetailsListApi
          .transactionDetailsListApi(widget.transactionId!);
      print("Refresh API Response: $response");
      provider.updateTransactionDetails(response);
    } catch (error) {
      provider.setError(error.toString());
    } finally {
      provider.setLoading(false);
    }
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return 'Date not available';
    try {
      DateTime date = DateTime.parse(dateTime);
      return DateFormat('dd-MM-yy hh:mm:ss a').format(date); // Updated format to match the image
    } catch (e) {
      print("Date parsing error: $e");
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Transaction Details",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: FutureBuilder<TransactionDetailsListResponse?>(
          future: _initialFetchFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              );
            }

            final provider =
                Provider.of<TransactionProvider>(context, listen: false);
            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Text(
                  snapshot.hasError
                      ? "Error: ${snapshot.error}"
                      : "No data available",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!provider.isInitialized) {
                provider.updateTransactionDetails(snapshot.data!);
                provider.markInitialized();
              }
            });

            return Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                // Define getCurrencySymbol
                String getCurrencySymbol(String? currencyCode) {
                  if (currencyCode == null) return '';
                  if (currencyCode == "AWG") return 'ƒ';
                  var format = NumberFormat.simpleCurrency(name: currencyCode);
                  return format.currencySymbol;
                }

                // Updated getCurrencySymbolForAmount
                String getCurrencySymbolForAmount() {
                  final fullType =
                      "${provider.extraType ?? ''}-${provider.transactionType ?? ''}"
                          .toLowerCase();
                  if (fullType.contains("debit")) {
                    return getCurrencySymbol(
                        provider.fromCurrency); // Use fromCurrency for debit
                  } else if (fullType == "credit-exchange") {
                    return getCurrencySymbol(provider
                        .fromCurrency); // Use fromCurrency for credit exchange
                  } else if (fullType == "credit-add money") {
                    return getCurrencySymbol(provider
                        .toCurrency); // Use toCurrency for credit add money
                  }
                  return getCurrencySymbol(provider
                      .toCurrency); // Default to toCurrency for other credits
                }

                // Check if it's a conversion case
                bool shouldShowConversion() {
                  final fullType =
                      "${provider.extraType ?? ''}-${provider.transactionType ?? ''}"
                          .toLowerCase();
                  return fullType == "credit-exchange" ||
                         fullType == "credit-add money" ||
                         fullType == "debit-beneficiary transfer money";
                }

                // Determine conversion display for credit-exchange
                String getConversionText() {
                  final fullType =
                      "${provider.extraType ?? ''}-${provider.transactionType ?? ''}"
                          .toLowerCase();
                  if (fullType == "credit-exchange") {
                    return "(Convert ${getCurrencySymbol(provider.fromCurrency)}${provider.amount?.toStringAsFixed(2) ?? '0.00'} to ${getCurrencySymbol(provider.toCurrency)}${provider.conversionAmount?.toStringAsFixed(2) ?? '0.00'})";
                  } else if (fullType == "credit-add money") {
                    return "(Convert ${getCurrencySymbol(provider.toCurrency)}${provider.amount?.toStringAsFixed(2) ?? '0.00'} to ${getCurrencySymbol(provider.fromCurrency)}${provider.conversionAmount?.toStringAsFixed(2) ?? '0.00'})";
                  } else if (fullType == "debit-beneficiary transfer money") {
                    return "(Convert ${getCurrencySymbol(provider.toCurrency)}${provider.amount?.toStringAsFixed(2) ?? '0.00'} to ${getCurrencySymbol(provider.fromCurrency)}${provider.conversionAmount?.toStringAsFixed(2) ?? '0.00'})";
                  }
                  return "";

                }
                // Helper method to format transaction type display
                String _getDisplayTransactionType(
                      TransactionProvider provider) {
                  String transType =
                      provider.transactionType?.toLowerCase() ?? 'n/a';
                  String extraType = provider.extraType ?? 'n/a';

                  if (transType == 'beneficiary transfer money') {
                    return 'Transfer Money';
                  }

                  return "$extraType - $transType".trim();
                }

                // Helper method to build table rows
                TableRow _buildTableRow(String label, String value) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              value,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _refreshData(context),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: defaultPadding),
                          if (provider.errorMessage != null)
                            Text(
                              provider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          const SizedBox(height: defaultPadding),

                          // Transaction Details Card
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: kPrimaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(defaultPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Transaction Details Section 
                                  const Center(
                                    child: Text(
                                      "Transaction Details",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Table(
                                    border:
                                        TableBorder.all(color: Colors.white38),
                                    children: [
                                      _buildTableRow(
                                          "Trx:", provider.transactionId ?? "N/A"),
                                      _buildTableRow("Requested Date:",
                                          _formatDate(provider.requestDate)),
                                      _buildTableRow("Fee:",
                                          "${getCurrencySymbolForAmount()} ${provider.fee?.toStringAsFixed(2) ?? '0.00'}"),
                                      _buildTableRow("Bill Amount:",
                                          "${getCurrencySymbolForAmount()} ${provider.billAmount?.toStringAsFixed(2) ?? '0.00'}"),
                                      _buildTableRow("Transaction Type:",
                                          _getDisplayTransactionType(provider)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(color: Colors.white38),

                                  // Sender Information Section
                                  const SizedBox(height: 20),
                                  const Center(
                                    child: Text(
                                      "Sender Information",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Table(
                                    border:
                                        TableBorder.all(color: Colors.white38),
                                    children: [
                                      _buildTableRow("Sender Name:",
                                          provider.senderName ?? "N/A"),
                                      _buildTableRow("Account Number:",
                                          provider.senderAccountNo ?? "N/A"),
                                      _buildTableRow("Sender Address:",
                                          provider.senderAddress ?? "N/A"),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Divider(color: Colors.white38),

                                  // Receiver Information Section
                                  const SizedBox(height: 20),
                                  const Center(
                                    child: Text(
                                      "Receiver Information",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Table(
                                    border:
                                        TableBorder.all(color: Colors.white38),
                                    children: [
                                      _buildTableRow("Receiver Name:",
                                          provider.receiverName ?? "N/A"),
                                      _buildTableRow("Account Number:",
                                          provider.receiverAccountNo ?? "N/A"),
                                      _buildTableRow("Receiver Address:",
                                          provider.receiverAddress ?? "N/A"),
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 16.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  "Transaction Status:",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                FilledButton.tonal(
                                                  onPressed: () {},
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStateProperty.all(
                                                            Colors.green),
                                                    foregroundColor:
                                                        WidgetStateProperty.all(
                                                            Colors.white),
                                                    shape: WidgetStateProperty
                                                        .all(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                20),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    (provider.status == null ||
                                                            provider.status!
                                                                .isEmpty)
                                                        ? 'Unknown'
                                                        : (provider.status!
                                                                    .toLowerCase() ==
                                                                'succeeded'
                                                            ? 'Success'
                                                            : '${provider.status![0].toUpperCase()}${provider.status!.substring(1).toLowerCase()}'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(color: Colors.white38),

                                  // Bank Status Section
                                  const SizedBox(height: 20),
                                  const Center(
                                    child: Text(
                                      "Bank Status",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Table(
                                    border:
                                        TableBorder.all(color: Colors.white38),
                                    children: [
                                      _buildTableRow(
                                          "Trx:", provider.transactionId ?? "N/A"),
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 16.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  "Trans Amt:",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "${getCurrencySymbolForAmount()} ${provider.amount?.toStringAsFixed(2) ?? '0.00'}",
                                                      style: const TextStyle(
                                                          color: Colors.white,),
                                                    ),
                                                    if (shouldShowConversion())
                                                      Text(
                                                        getConversionText(),
                                                        style: const TextStyle(
                                                            color: Colors.white, fontSize: 12),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      _buildTableRow("Settel. Date:",
                                          _formatDate(provider.requestDate)),
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 16.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  "Trans Status:",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                FilledButton.tonal(
                                                  onPressed: () {},
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        WidgetStateProperty.all(
                                                            Colors.green),
                                                    foregroundColor:
                                                        WidgetStateProperty.all(
                                                            Colors.white),
                                                    shape: WidgetStateProperty
                                                        .all(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                20),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    (provider.status == null ||
                                                            provider.status!
                                                                .isEmpty)
                                                        ? 'Unknown'
                                                        : (provider.status!
                                                                    .toLowerCase() ==
                                                                'succeeded'
                                                            ? 'Success'
                                                            : '${provider.status![0].toUpperCase()}${provider.status!.substring(1).toLowerCase()}'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class TransactionProvider with ChangeNotifier {
  String? transactionId;
  String? requestDate;
  double? fee;
  double? billAmount;
  double? amount;
  String? transactionType;
  String? extraType;
  String? fromCurrency;
  String? toCurrency;
  double? conversionAmount;
  String? senderName;
  String? senderAccountNo;
  String? senderAddress;
  String? receiverName;
  String? receiverAccountNo;
  String? receiverAddress;
  String? status;
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

  void updateTransactionDetails(TransactionDetailsListResponse response) {
    transactionId = response.trx;
    fromCurrency = response.fromCurrency;
    toCurrency = response.toCurrency;
    conversionAmount = response.conversionAmount ?? 0.0;
    fee = response.fee ?? 0.0;
    billAmount = (response.billAmount ?? 0.0) + (response.fee ?? 0.0);
    amount = response.billAmount ?? 0.0;
    transactionType = response.transactionType ?? 'N/A';
    extraType = response.extraType ?? 'N/A';
    requestDate = response.requestedDate;

    senderName = response.senderDetail?.isNotEmpty == true
        ? response.senderDetail!.first.senderName
        : 'N/A';
    senderAccountNo = response.senderDetail?.isNotEmpty == true
        ? response.senderDetail!.first.senderAccountNumber
        : 'N/A';
    senderAddress = response.senderDetail?.isNotEmpty == true
        ? response.senderDetail!.first.senderAddress
        : 'N/A';

    receiverName = response.receiverDetail?.isNotEmpty == true
        ? response.receiverDetail!.first.receiverName
        : 'N/A';
    receiverAccountNo = response.receiverDetail?.isNotEmpty == true
        ? response.receiverDetail!.first.receiverAccountNumber
        : 'N/A';
    receiverAddress = response.receiverDetail?.isNotEmpty == true
        ? response.receiverDetail!.first.receiverAddress
        : 'N/A';

    status = response.status ?? 'N/A';
    notifyListeners();
  }
}