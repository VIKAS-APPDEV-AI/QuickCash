import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:quickcash/Screens/DashboardScreen/ExchangeScreen/reviewExchangeMoneyScreen/addExchangeModel/addExchangeMoneyModel.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:dio/dio.dart'; // For DioException handling
import 'package:quickcash/util/currency_utils.dart';
import '../../../../util/customSnackBar.dart';
import '../../../HomeScreen/home_screen.dart';
import 'addExchangeModel/addExchangeApi.dart';

class ReviewExchangeMoneyScreen extends StatefulWidget {
  // From Data
  final String? fromAccountId;
  final String? fromCountry;
  final String? fromCurrency;
  final String? fromIban;
  final double? fromAmount;
  final String? fromCurrencySymbol;
  final double? fromTotalFees;
  final double? fromRate;
  final String? fromExchangeAmount;

  // To Data
  final String? toAccountId;
  final String? toCountry;
  final String? toCurrency;
  final String? toIban;
  final double? toAmount;
  final String? toCurrencySymbol;
  final String? toExchangedAmount;

  const ReviewExchangeMoneyScreen({
    super.key,
    this.fromAccountId,
    this.fromCountry,
    this.fromCurrency,
    this.fromIban,
    this.fromAmount,
    this.fromCurrencySymbol,
    this.fromTotalFees,
    this.fromRate,
    this.fromExchangeAmount,
    this.toAccountId,
    this.toCountry,
    this.toCurrency,
    this.toIban,
    this.toAmount,
    this.toCurrencySymbol,
    this.toExchangedAmount,
  });

  @override
  State<ReviewExchangeMoneyScreen> createState() => _ReviewExchangeMoneyScreen();
}

class _ReviewExchangeMoneyScreen extends State<ReviewExchangeMoneyScreen> {
  final AddExchangeApi _addExchangeApi = AddExchangeApi();
  bool isLoading = false;

  // From Data
  String? mFromAccountId;
  String? mFromCountry;
  String? mFromCurrency;
  String? mFromIban;
  double? mFromAmount;
  String? mFromCurrencySymbol;
  double? mFromTotalFees;
  double? mFromRate;
  String? mExchangeAmount;
  double? mTotalCharge;

  // To Data
  String? mToAccountId;
  String? mToCountry;
  String? mToCurrency;
  String? mToIban;
  double? mToAmount;
  String? mToCurrencySymbol;
  String? mToExchangedAmount;

  @override
  void initState() {
    super.initState();
    mSetReviewData();
  }

  Future<void> mSetReviewData() async {
    setState(() {
      // From Data
      mFromAccountId = widget.fromAccountId;
      mFromCountry = widget.fromCountry;
      mFromCurrency = widget.fromCurrency;
      mFromIban = widget.fromIban;
      mFromAmount = widget.fromAmount;
      mFromCurrencySymbol = widget.fromCurrencySymbol;
      mFromTotalFees = widget.fromTotalFees;
      mFromRate = widget.fromRate;
      mExchangeAmount = widget.fromExchangeAmount;

      if (mExchangeAmount != null && mFromTotalFees != null) {
        double exchangeAmount = double.tryParse(mExchangeAmount!) ?? 0.0;
        mTotalCharge = exchangeAmount + (mFromTotalFees ?? 0.0);
      }

      // To Data
      mToAccountId = widget.toAccountId;
      mToCountry = widget.toCountry;
      mToCurrency = widget.toCurrency;
      mToIban = widget.toIban;
      mToAmount = widget.toAmount;
      mToCurrencySymbol = widget.toCurrencySymbol;
      mToExchangedAmount = widget.toExchangedAmount;
    });
  }

  // Add Exchange API
  Future<void> mAddExchangeApi() async {
    setState(() {
      isLoading = true;
    });

    try {
      String info = 'Convert ${mFromCurrency ?? 'Unknown'} to ${mToCurrency ?? 'Unknown'}';
      String amountText = '${mToCurrencySymbol ?? ''} ${mToExchangedAmount ?? '0.00'}';

      if (mFromAccountId == null || mToAccountId == null || mExchangeAmount == null || mToExchangedAmount == null) {
        throw Exception("Missing required exchange details");
      }

      print("mExchangeAmount: $mExchangeAmount");
      print("mToExchangedAmount: $mToExchangedAmount");

      double exchangeAmount = double.tryParse(mExchangeAmount!) ?? 0.0;

      // Validate inputs
      if (mExchangeAmount!.isEmpty || double.tryParse(mExchangeAmount!) == null) {
        throw Exception("Invalid exchange amount: $mExchangeAmount");
      }
      if (mToExchangedAmount!.isEmpty || double.tryParse(mToExchangedAmount!) == null) {
        throw Exception("Invalid exchanged amount: $mToExchangedAmount");
      }

      final request = AddExchangeRequest(
        userId: AuthManager.getUserId(),
        sourceAccount: mFromAccountId!, // Corrected: Source loses money
        transferAccount: mToAccountId!, // Corrected: Target gains money
        transType: "Exchange",
        fee: mFromTotalFees ?? 0.0,
        info: info,
        country: mToCountry ?? 'Unknown',
        fromAmount: exchangeAmount, // Amount deducted from source
        amount: mToExchangedAmount!, // Sent as String per working model
        amountText: amountText,
        fromAmountText: exchangeAmount.toStringAsFixed(2),
        fromCurrency: mFromCurrency ?? 'Unknown',
        toCurrency: mToCurrency ?? 'Unknown',
        status: "Success",
      );

      print("Request Payload: ${request.toJson()}");
      final response = await _addExchangeApi.addExchangeApi(request);
      print("API Response: ${response.toString()}");

      if (response.message == "Transaction is added Successfully!!!") {
        setState(() {
          isLoading = false;
          CustomSnackBar.showSnackBar(
            context: context,
            message: "Exchange has been done Successfully",
            color: kGreenColor,
          );
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        });
      } else {
        setState(() {
          isLoading = false;
          CustomSnackBar.showSnackBar(
            context: context,
            message: "We are facing some issue!",
            color: kPrimaryColor,
          );
        });
      }
    } catch (error) {
      print("Error in mAddExchangeApi: $error");
      if (error is DioException && error.response != null) {
        print("Server Response Data: ${error.response!.data}");
      }
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackBar(
          context: context,
          message: "Something went wrong! $error",
          color: kPrimaryColor,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Review Exchange Money",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4.0,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Exchange",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor),
                          ),
                          Text(
                            "${mFromCurrencySymbol ?? ''} ${mExchangeAmount ?? '0.00'}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: kPrimaryLightColor),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Rate",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor),
                          ),
                          Text(
                            "1${mFromCurrencySymbol ?? ''} = ${mToCurrencySymbol ?? ''}${mFromRate?.toStringAsFixed(5) ?? '0'}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: kPrimaryLightColor),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Fee",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor),
                          ),
                          Text(
                            "${mFromCurrencySymbol ?? ''} ${mFromTotalFees?.toStringAsFixed(2) ?? '0.00'}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: kPrimaryLightColor),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Charge",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor),
                          ),
                          Text(
                            "${mFromCurrencySymbol ?? ''} ${mTotalCharge?.toStringAsFixed(2) ?? '0.00'}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: kPrimaryLightColor),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Will get Exactly",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor),
                          ),
                          Text(
                            "${mToCurrencySymbol ?? ''} ${mToExchangedAmount ?? '0.00'}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding),
              Card(
                elevation: 4.0,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Source Account",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
                      ),
                      const SizedBox(height: defaultPadding),
                      Card(
                        elevation: 1.0,
                        color: kPrimaryLightColor,
                        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        child: Padding(
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Row(
                            children: [
                             // Use EU flag for EUR, country flag for others
                              if (mFromCurrency?.toUpperCase() == 'EUR')
                                getEuFlagWidget()
                              else
                                CountryFlag.fromCountryCode(
                                  width: 55,
                                  height: 55,
                                  mFromCountry ?? 'US', // Fallback to 'US'
                                  shape: const Circle(),
                                ),
                              const SizedBox(width: defaultPadding),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${mFromCurrency ?? ''} Account',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: kPrimaryColor),
                                    ),
                                    Text(
                                      mFromIban ?? 'N/A',
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 2,
                                    ),
                                    Text(
                                      "${mFromCurrencySymbol ?? ''} ${mFromAmount?.toStringAsFixed(2) ?? '0.00'}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: largePadding),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: isLoading ? null : mAddExchangeApi,
                  child: const Text(
                    'Exchange',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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