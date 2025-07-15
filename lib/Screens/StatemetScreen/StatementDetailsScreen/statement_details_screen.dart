import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/constants.dart';

import '../../TransactionScreen/TransactionDetailsScreen/model/transactionDetailsApi.dart';

class StatementDetailsScreen extends StatefulWidget {
  final String? transactionId;

  const StatementDetailsScreen({super.key,this.transactionId});


  @override
  State<StatementDetailsScreen> createState() => _StatementDetailsScreenState();

}

class _StatementDetailsScreenState extends State<StatementDetailsScreen>{
  final TransactionDetailsListApi _transactionDetailsListApi = TransactionDetailsListApi();

  String? transactionId;
  String? requestDate;
  double? fee;
  double? billAmount;
  double? amount;
  String? transactionType;
  String? extraType;
  String? fromCurrency;

  String? senderName;
  String? senderAccountNo;
  String? senderAddress;

  String? receiverName;
  String? receiverAccountNo;
  String? receiverAddress;
  String? status;

  String? transactionAmount;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    mTransactionDetails();
  }

  Future<void> mTransactionDetails() async {
    // Check if the transaction ID is null
    if (widget.transactionId == null) {
      setState(() {
        errorMessage = "Transaction ID is missing!";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Fetch transaction details using the provided transaction ID
      final response = await _transactionDetailsListApi.transactionDetailsListApi(widget.transactionId!);

      setState(() {
        isLoading = false;

        transactionId = response.trx;
        fromCurrency = response.fromCurrency;
        fee = response.fee ?? 0.0;
        billAmount = (response.billAmount ?? 0.0) + (response.fee ?? 0.0);
        amount = (response.billAmount ?? 0.0);
        transactionType = response.transactionType ?? 'N/A';
        extraType = response.extraType ?? 'N/A';

        senderName = response.senderDetail?.isNotEmpty == true ? response.senderDetail?.first.senderName : 'N/A';
        senderAccountNo = response.senderDetail?.isNotEmpty == true ? response.senderDetail?.first.senderAccountNumber : 'N/A';
        senderAddress = response.senderDetail?.isNotEmpty == true ? response.senderDetail?.first.senderAddress : 'N/A';

        receiverName = response.receiverDetail?.isNotEmpty == true ? response.receiverDetail?.first.receiverName : 'N/A';
        receiverAccountNo = response.receiverDetail?.isNotEmpty == true ? response.receiverDetail?.first.receiverAccountNumber : 'N/A';
        receiverAddress = response.receiverDetail?.isNotEmpty == true ? response.receiverDetail?.first.receiverAddress : 'N/A';

        status = response.status ?? 'N/A';

        // Convert the input date string to a DateTime object
        requestDate = response.requestedDate != null
            ? DateFormat('yyyy-MM-dd hh:mm:ss:a').format(DateTime.parse(response.requestedDate!))
            : 'N/A';
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  String getCurrencySymbol(String currencyCode) {
    var format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.currencySymbol;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        // Change back button color here
        title: const Text(
          "Statements Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: kPrimaryColor,
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: defaultPadding),

              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: defaultPadding),

              // Transaction Details Card
              Card(
                color: kPrimaryColor,
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          "Transaction Details",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Trans ID:", style: TextStyle(color: Colors.white)),
                          Text(transactionId ?? " ", style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Requested Date:", style: TextStyle(color: Colors.white)),
                          Text(requestDate ?? " ", style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Fee:", style: TextStyle(color: Colors.white)),
                          Text((fee ?? 0).toString(), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Bill Amount:", style: TextStyle(color: Colors.white)),
                          Text((billAmount ?? 0).toString(), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Transaction Type:", style: TextStyle(color: Colors.white)),
                          Text('${extraType ?? 'N/A'} - ${transactionType ?? 'N/A'}', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sender Information Card
              Card(
                color: kPrimaryColor,
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    children: <Widget>[
                      const Center(
                        child: Text(
                          "Sender Information",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Sender Name:", style: TextStyle(color: Colors.white)),
                          Text(senderName ?? "", style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Account No:", style: TextStyle(color: Colors.white)),
                          Text(senderAccountNo ?? "", style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Sender Address:", style: TextStyle(color: Colors.white)),
                          Text(senderAddress ?? "", style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Receiver Information Card
              Card(
                color: kPrimaryColor,
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          "Receiver Information",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Receiver Name:", style: TextStyle(color: Colors.white)),
                          Text(receiverName ?? '', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Account Number:", style: TextStyle(color: Colors.white)),
                          Text(receiverAccountNo ?? '', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Receiver Address:", style: TextStyle(color: Colors.white)),
                          Text(receiverAddress ?? '', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Transaction Status:", style: TextStyle(color: Colors.white)),
                          FilledButton.tonal(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Colors.white),
                            ),
                            child: Text(
  (status == null || status!.isEmpty)
      ? 'Unknown'
      : (status!.toLowerCase() == 'succeeded'
          ? 'Success'
          : '${status![0].toUpperCase()}${status!.substring(1).toLowerCase()}'),
  style: TextStyle(color: Colors.green),
),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Bank Status Card
              Card(
                color: kPrimaryColor,
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    children: [
                      const Center(
                        child: Text(
                          "Bank Status",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Bank TransID:", style: TextStyle(color: Colors.white)),
                          Text(transactionId ?? " ", style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Trans Amt:", style: TextStyle(color: Colors.white)),
                          Text("${getCurrencySymbol(fromCurrency!)} $amount", style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Settlement Date:", style: TextStyle(color: Colors.white)),
                          Text(requestDate ?? "", style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Transaction Status:", style: TextStyle(color: Colors.white)),
                          FilledButton.tonal(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Colors.white),
                            ),
                            child: Text(
  (status == null || status!.isEmpty)
      ? 'Unknown'
      : (status!.toLowerCase() == 'succeeded'
          ? 'Success'
          : '${status![0].toUpperCase()}${status!.substring(1).toLowerCase()}'),
  style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}