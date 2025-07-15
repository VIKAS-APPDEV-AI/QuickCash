import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/DashboardScreen/AllAccountsScreen/AccountDetailsScreen/model/accountDetailsApi.dart';  // Import your API cardModel

import '../../../../constants.dart';
import '../../../../util/customSnackBar.dart';

class AccountDetailsScreen extends StatefulWidget {
  final String? accountId;

  const AccountDetailsScreen({super.key, this.accountId});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final AccountDetailsApi _accountDetailsApi = AccountDetailsApi();

  final TextEditingController? accountNo = TextEditingController();
  final TextEditingController? ifscCode = TextEditingController();
  final TextEditingController currency = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  String? name;
  double? amount;  // Use double? for amount

  @override
  void initState() {
    super.initState();
    mAccountDetails();
  }

  // Fetch account details from API
  Future<void> mAccountDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _accountDetailsApi.accountDetailsApi(widget.accountId!);

      // Set the controller values directly after fetching the response
      accountNo?.text = response.accountNo?.toString() ?? '0';
      ifscCode?.text = response.ifscCode?.toString() ?? '0';
      currency.text = response.currency ?? "";
      name = response.name ?? "";
      amount = response.amount ?? 0.0;  // Assign amount directly (no need to cast)

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  void _copyIFSCCode() {
      Clipboard.setData(ClipboardData(text: ifscCode!.text)).then((_) {
        CustomSnackBar.showSnackBar(
          context: context,
          message: 'IFSC Code copied to clipboard!',
          color: kPrimaryColor,
        );
      });
  }

  void _copyAccountNo() {
    Clipboard.setData(ClipboardData(text: accountNo!.text)).then((_) {
      CustomSnackBar.showSnackBar(
        context: context,
        message: 'Account No copied to clipboard!',
        color: kPrimaryColor,
      );
    });
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
        title: const Text(
          "Account Details",
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
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: defaultPadding,
              ),
              // Displaying the USD amount (Currency + amount)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Amount:",
                    style: TextStyle(
                        color: kPrimaryColor, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    amount != null
                        ? "${getCurrencySymbol(currency.text)} ${amount!.toStringAsFixed(2)}"
                        : "${currency.text} 0.00", // Safely display the formatted amount
                    style: const TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: smallPadding),
              const Divider(color: kPrimaryLightColor),
              const SizedBox(height: smallPadding),

              // Account Number TextField
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: accountNo,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      cursorColor: kPrimaryColor,
                      readOnly: true,  // Set readOnly to true as it’s just for display
                      style: const TextStyle(color: kPrimaryColor),
                      decoration: InputDecoration(
                        labelText: "Account No.",
                        labelStyle: const TextStyle(
                            color: kPrimaryColor, fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: kPrimaryColor),
                    onPressed: _copyAccountNo,
                  ),
                ],
              ),
              const SizedBox(height: smallPadding),
              const Divider(color: kPrimaryLightColor),
              const SizedBox(height: smallPadding),

              // IFSC Code TextField
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: ifscCode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      cursorColor: kPrimaryColor,
                      readOnly: true,  // Set readOnly to true
                      style: const TextStyle(color: kPrimaryColor),
                      decoration: InputDecoration(
                        labelText: "IFSC Code",
                        labelStyle: const TextStyle(
                            color: kPrimaryColor, fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: kPrimaryColor),
                    onPressed: _copyIFSCCode,
                  ),
                ],
              ),
              const SizedBox(height: smallPadding),
              const Divider(color: kPrimaryLightColor),
              const SizedBox(height: smallPadding),

              // Currency TextField
              TextFormField(
                controller: currency,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                readOnly: true,  // Set readOnly to true
                style: const TextStyle(color: kPrimaryColor),
                decoration: InputDecoration(
                  labelText: "Currency",
                  labelStyle: const TextStyle(
                      color: kPrimaryColor, fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
