import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickcash/Screens/DashboardScreen/ExchangeScreen/reviewExchangeMoneyScreen/addExchangeModel/addExchangeMoneyModel.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/DashboardTicketScreen.dart';
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
  State<ReviewExchangeMoneyScreen> createState() =>
      _ReviewExchangeMoneyScreen();
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
      String info =
          'Convert ${mFromCurrency ?? 'Unknown'} to ${mToCurrency ?? 'Unknown'}';
      String amountText =
          '${mToCurrencySymbol ?? ''} ${mToExchangedAmount ?? '0.00'}';

      if (mFromAccountId == null ||
          mToAccountId == null ||
          mExchangeAmount == null ||
          mToExchangedAmount == null) {
        throw Exception("Missing required exchange details");
      }

      print("mExchangeAmount: $mExchangeAmount");
      print("mToExchangedAmount: $mToExchangedAmount");

      double exchangeAmount = double.tryParse(mExchangeAmount!) ?? 0.0;

      // Validate inputs
      if (mExchangeAmount!.isEmpty ||
          double.tryParse(mExchangeAmount!) == null) {
        throw Exception("Invalid exchange amount: $mExchangeAmount");
      }
      if (mToExchangedAmount!.isEmpty ||
          double.tryParse(mToExchangedAmount!) == null) {
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
            color: Colors.green,
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
            color: Theme.of(context).extension<AppColors>()!.primary,
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
          color: Theme.of(context).extension<AppColors>()!.primary,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Review Exchange Money",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 6, 6, 6), // Dark neo-banking color
                Color(0xFF8A2BE2), // Gradient transition
                Color(0x00000000), // Transparent fade
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bell_fill),
            onPressed: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => NotificationScreen(),
                  ));
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.headphones),
            onPressed: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => DashboardTicketScreen(),
                  ));
            },
            tooltip: 'Support',
          ),
          const SizedBox(width: 8),
        ],
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
                          Text(
                            "Exchange",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                          ),
                          Text(
                            "${mFromCurrencySymbol ?? ''} ${mExchangeAmount ?? '0.00'}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? const Color.fromARGB(255, 15, 15, 15)
                                  : const Color.fromARGB(255, 15, 15, 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xA66F35A5)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Rate",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                          ),
                          Text(
                            "1${mFromCurrencySymbol ?? ''} = ${mToCurrencySymbol ?? ''}${mFromRate?.toStringAsFixed(5) ?? '0'}",
                            style:  TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode? const Color.fromARGB(255, 15, 15, 15): const Color.fromARGB(255, 15, 15, 15),),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xA66F35A5)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Fee",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                          ),
                          Text(
                            "${mFromCurrencySymbol ?? ''} ${mFromTotalFees?.toStringAsFixed(2) ?? '0.00'}",
                            style:  TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode? const Color.fromARGB(255, 15, 15, 15): const Color.fromARGB(255, 15, 15, 15),),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xA66F35A5)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Charge",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                          ),
                          Text(
                            "${mFromCurrencySymbol ?? ''} ${mTotalCharge?.toStringAsFixed(2) ?? '0.00'}",
                            style:  TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode? const Color.fromARGB(255, 15, 15, 15): const Color.fromARGB(255, 15, 15, 15),),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xA66F35A5)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Will get Exactly",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                          ),
                          Text(
                            "${mToCurrencySymbol ?? ''} ${mToExchangedAmount ?? '0.00'}",
                            style:  TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode? const Color.fromARGB(255, 15, 15, 15): const Color.fromARGB(255, 15, 15, 15),),
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
                      Text(
                        "Source Account",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .primary),
                      ),
                      const SizedBox(height: defaultPadding),
                      Card(
                        elevation: 1.0,
                        color: AppColors.light.primaryLight,
                        margin: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 0),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isDarkMode? const Color.fromARGB(255, 15, 15, 15): const Color.fromARGB(255, 15, 15, 15),),
                                    ),
                                    Text(
                                      mFromIban ?? 'N/A',
                                      style: TextStyle(fontSize: 14, color: isDarkMode? const Color.fromARGB(255, 15, 15, 15): const Color.fromARGB(255, 15, 15, 15),),
                                      maxLines: 2,
                                    ),
                                    Text(
                                      "${mFromCurrencySymbol ?? ''} ${mFromAmount?.toStringAsFixed(2) ?? '0.00'}",
                                      style:  TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16, color: isDarkMode? const Color.fromARGB(255, 15, 15, 15): const Color.fromARGB(255, 15, 15, 15),),
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
                Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).extension<AppColors>()!.primary),
                ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).extension<AppColors>()!.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
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
