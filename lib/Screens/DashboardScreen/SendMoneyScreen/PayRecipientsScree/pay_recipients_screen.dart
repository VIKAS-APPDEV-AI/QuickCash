import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListApi.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListModel.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/PayRecipientsScree/exchangeCurrencyModel/exchangeCurrencyApi.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/PayRecipientsScree/makePaymentModel/makePaymentApi.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/PayRecipientsScree/makePaymentModel/makePaymentModel.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/DashboardTicketScreen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/currency_utils.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui'; // For BackdropFilter

import '../../../../util/auth_manager.dart';
import '../../../../util/customSnackBar.dart';
import '../../../HomeScreen/home_screen.dart';
import 'exchangeCurrencyModel/exchangeCurrencyModel.dart';

class PayRecipientsScreen extends StatefulWidget {
  const PayRecipientsScreen({super.key});

  @override
  State<PayRecipientsScreen> createState() => _PayRecipientsScreen();
}

class _PayRecipientsScreen extends State<PayRecipientsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ExchangeCurrencyApi _exchangeCurrencyApi = ExchangeCurrencyApi();
  final RecipientMakePaymentApi _recipientMakePaymentApi =
      RecipientMakePaymentApi();

  final TextEditingController mSendAmountController = TextEditingController();
  final TextEditingController mReceiveAmountController =
      TextEditingController();

  final TextEditingController mFullName = TextEditingController();
  final TextEditingController mEmail = TextEditingController();
  final TextEditingController mMobileNo = TextEditingController();
  final TextEditingController mBankName = TextEditingController();
  final TextEditingController mIban = TextEditingController();
  final TextEditingController mBicCode = TextEditingController();
  final TextEditingController mAddress = TextEditingController();

  String? selectedSendCurrency;
  String? selectedReceiveCurrency;
  bool isLoading = false;
  bool isAddLoading = false;

  // Send Currency -----
  String? mSendCountry = '';
  String? mSendCurrency = 'Select Currency';
  double? mSendCurrencyAmount = 0.0;
  String? mSendCurrencySymbol = '';
  double? mTotalCharge = 0.0;
  String? mTotalPayable = '0.0';

  // Receive Currency
  String? mReceiveCountry = '';
  String? mReceiveCurrency = 'Select Currency';
  double? mReceiveCurrencyAmount = 0.0;
  String? mReceiveCurrencySymbol = '';

  // Send Currency Set
  Future<void> mSelectedSendCurrency(mSelectedSendCountry,
      mSelectedSendCurrency, mSelectedSendCurrencyAmount) async {
    setState(() {
      mSendCountry = mSelectedSendCountry;
      mSendCurrency = mSelectedSendCurrency;
      mSendCurrencyAmount = mSelectedSendCurrencyAmount;
      mSendCurrencySymbol = getCurrencySymbol(mSendCurrency!);
    });
  }

  // Receive Currency Set
  Future<void> mSelectedReceiveCurrency(mSelectedReceiveCountry,
      mSelectedReceiveCurrency, mSelectedReceiveCurrencyAmount) async {
    setState(() {
      mReceiveCountry = mSelectedReceiveCountry;
      mReceiveCurrency = mSelectedReceiveCurrency;
      mReceiveCurrencyAmount = mSelectedReceiveCurrencyAmount;
      mReceiveCurrencySymbol = getCurrencySymbol(mReceiveCurrency!);
    });
    if (mSendCurrency != 'Select Currency' &&
        mSendAmountController.text.isNotEmpty &&
        double.tryParse(mSendAmountController.text) != null &&
        double.parse(mSendAmountController.text) <= mSendCurrencyAmount!) {
      await mExchangeMoneyApi();
    }
  }

  String getCurrencySymbol(String currencyCode) {
    var format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.currencySymbol;
  }

  // Exchange Money Api **************
  Future<void> mExchangeMoneyApi() async {
    setState(() {
      isLoading = true;
    });

    try {
      final request = ExchangeCurrencyRequest(
          userId: AuthManager.getUserId(),
          amount: mSendAmountController.text,
          fromCurrency: mSendCurrency!,
          toCurrency: mReceiveCurrency!);
      final response = await _exchangeCurrencyApi.exchangeCurrencyApi(request);

      if (response.message == "Success") {
        setState(() {
          isLoading = false;
          mTotalCharge = response.data.totalFees;
          mTotalPayable = response.data.totalCharge.toString();
          mReceiveAmountController.text =
              response.data.convertedAmount.toStringAsFixed(2);
        });
      } else {
        setState(() {
          isLoading = false;
          CustomSnackBar.showSnackBar(
              context: context,
              message: "We are facing some issue!",
              color: Theme.of(context).extension<AppColors>()!.primary);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Reset all values
  void _resetAllValues() {
    setState(() {
      // Clear TextEditingControllers
      mSendAmountController.clear();
      mReceiveAmountController.clear();
      mFullName.clear();
      mEmail.clear();
      mMobileNo.clear();
      mBankName.clear();
      mIban.clear();
      mBicCode.clear();
      mAddress.clear();

      // Reset Send Currency variables
      mSendCountry = '';
      mSendCurrency = 'Select Currency';
      mSendCurrencyAmount = 0.0;
      mSendCurrencySymbol = '';
      mTotalCharge = 0.0;
      mTotalPayable = '0.0';

      // Reset Receive Currency variables
      mReceiveCountry = '';
      mReceiveCurrency = 'Select Currency';
      mReceiveCurrencyAmount = 0.0;
      mReceiveCurrencySymbol = '';

      // Reset loading states
      isLoading = false;
      isAddLoading = false;

      // Reset selected currencies
      selectedSendCurrency = null;
      selectedReceiveCurrency = null;
    });
  }

  // Insufficient Balance Dialog
  void _showInsufficientBalanceDialog(
      double enteredAmount, double estimatedFee, double estimatedTotal) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;
            final lottieSize = screenWidth > 600 ? 200.0 : 140.0;

            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Dialog(
                backgroundColor: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: dialogWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            Center(
                              child: Lottie.asset(
                                'assets/lottie/BalanceError.json',
                                width: lottieSize,
                                height: lottieSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.black54),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _resetAllValues(); // Reset values when dialog is closed
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Insufficient Balance',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Your Entered Amount:- $mSendCurrencySymbol ${enteredAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Estimated Fee:- $mSendCurrencySymbol ${estimatedFee.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Estimated Total Amount:- $mSendCurrencySymbol ${estimatedTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'According to your account balance ($mSendCurrencySymbol ${mSendCurrencyAmount!.toStringAsFixed(2)}), you will not be able to pay the estimated total amount.',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _resetAllValues(); // Reset values after dialog is dismissed
    });
  }

  Future<void> mMakePayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isAddLoading = true;
      });

      try {
        String amountText =
            '$mSendCurrencySymbol ${mSendAmountController.text}';
        String conversionAmountText =
            '$mReceiveCurrencySymbol ${mReceiveAmountController.text}';

        final request = RecipientMakePaymentRequest(
            userId: AuthManager.getUserId(),
            iban: mIban.text,
            bicCode: mBicCode.text,
            fee: mTotalCharge.toString(),
            amount: mSendAmountController.text,
            conversionAmount: mReceiveAmountController.text,
            conversionAmountText: conversionAmountText,
            amountText: amountText,
            fromCurrency: mSendCurrency!,
            toCurrency: mReceiveCurrency!,
            status: "pending",
            name: mFullName.text,
            email: mEmail.text,
            address: mAddress.text,
            mobile: mMobileNo.text,
            bankName: mBankName.text);
        final response = await _recipientMakePaymentApi.makePaymentApi(request);

        if (response.message == "Receipient is added Successfully!!!") {
          setState(() {
            isAddLoading = false;
            CustomSnackBar.showSnackBar(
                context: context,
                message: "Recipient is added Successfully ",
                color: Theme.of(context).extension<AppColors>()!.primary);
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          });
        } else {
          setState(() {
            isAddLoading = false;
            CustomSnackBar.showSnackBar(
                context: context,
                message: "We are facing some issue",
                color: Theme.of(context).extension<AppColors>()!.primary);
          });
        }
      } catch (error) {
        setState(() {
          isAddLoading = false;
          CustomSnackBar.showSnackBar(
              context: context,
              message: "Something went wrong!",
              color: Theme.of(context).extension<AppColors>()!.primary);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Recipient",
          style: TextStyle(color: Colors.white),
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
             Navigator.push(context, CupertinoPageRoute(builder: (context) => DashboardTicketScreen(),));
            },
            tooltip: 'Support',
          ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 20, 20, 20), // Primary color
                Color(0xFF8A2BE2), // Slightly lighter for gradient effect
                Color(0x00000000), // Transparent at the bottom
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: defaultPadding),
                Card(
                  elevation: 4.0,
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            "Payment Information",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: defaultPadding),
                        Card(
                          elevation: 4.0,
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 0),
                          child: Padding(
                            padding: const EdgeInsets.all(defaultPadding),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    mSendCurrencyBottomSheet(context);
                                  },
                                  child: Card(
                                    elevation: 1.0,
                                    color: AppColors.light.primaryLight,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(defaultPadding),
                                      child: Row(
                                        children: [
                                          if (mSendCurrency?.toUpperCase() ==
                                              'EUR')
                                            getEuFlagWidget()
                                          else
                                            CountryFlag.fromCountryCode(
                                              width: 35,
                                              height: 35,
                                              mSendCountry!,
                                              shape: const Circle(),
                                            ),
                                          const SizedBox(width: defaultPadding),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$mSendCurrency',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .extension<AppColors>()!
                                                        .primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.arrow_drop_down,
                                              color: Theme.of(context)
                                                  .extension<AppColors>()!
                                                  .primary),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: smallPadding),
                                Row(
                                  children: [
                                    Text(
                                      'Send Avg Balance = ',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .extension<AppColors>()!
                                              .primary),
                                    ),
                                    Text(
                                      '${getCurrencySymbol(mSendCurrency!)}${mSendCurrencyAmount?.toStringAsFixed(2) ?? '0.00'}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .extension<AppColors>()!
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: largePadding),
                                TextFormField(
                                  controller: mSendAmountController,
                                  decoration: InputDecoration(
                                    prefix: Text(
                                      '${getCurrencySymbol(mSendCurrency!)} ',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .extension<AppColors>()!
                                              .primary),
                                    ),
                                    labelText: 'Send',
                                    labelStyle: TextStyle(
                                        color: Theme.of(context)
                                            .extension<AppColors>()!
                                            .primary),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(),
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                  ),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  cursorColor: Theme.of(context)
                                      .extension<AppColors>()!
                                      .primary,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .extension<AppColors>()!
                                          .primary),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter sender amount';
                                    }
                                    return null;
                                  },
                                  maxLines: 3,
                                  minLines: 1,
                                  onChanged: (value) {
                                    if (mSendCurrency != "Select Currency") {
                                      if (mReceiveCurrency !=
                                          "Select Currency") {
                                        if (mSendAmountController
                                            .text.isNotEmpty) {
                                          double? enteredAmount =
                                              double.tryParse(
                                                  mSendAmountController.text);
                                          if (enteredAmount == null) {
                                            CustomSnackBar.showSnackBar(
                                                context: context,
                                                message:
                                                    "Please enter a valid amount",
                                                color: Theme.of(context)
                                                    .extension<AppColors>()!
                                                    .primary);
                                            return;
                                          }

                                          if (mSendCurrencyAmount == 0) {
                                            CustomSnackBar.showSnackBar(
                                                context: context,
                                                message:
                                                    "You don't have sufficient amount",
                                                color: Theme.of(context)
                                                    .extension<AppColors>()!
                                                    .primary);
                                            return;
                                          }

                                          // Calculate total amount (entered amount + charge)
                                          double totalAmount = enteredAmount +
                                              (mTotalCharge ?? 0.0);

                                          // Check if total amount exceeds available balance
                                          if (totalAmount >
                                              mSendCurrencyAmount!) {
                                            _showInsufficientBalanceDialog(
                                              enteredAmount,
                                              mTotalCharge ?? 0.0,
                                              totalAmount,
                                            );
                                            return;
                                          }

                                          if (enteredAmount <=
                                              mSendCurrencyAmount!) {
                                            setState(() {
                                              mExchangeMoneyApi();
                                            });
                                          } else {
                                            setState(() {
                                              CustomSnackBar.showSnackBar(
                                                  context: context,
                                                  message:
                                                      "Please enter a valid amount",
                                                  color: Theme.of(context)
                                                      .extension<AppColors>()!
                                                      .primary);
                                            });
                                          }
                                        } else {
                                          mReceiveAmountController.clear();
                                          CustomSnackBar.showSnackBar(
                                              context: context,
                                              message:
                                                  "Please enter sender amount",
                                              color: Theme.of(context)
                                                  .extension<AppColors>()!
                                                  .primary);
                                        }
                                      } else {
                                        CustomSnackBar.showSnackBar(
                                            context: context,
                                            message:
                                                "Please select Recipient will receive currency",
                                            color: Theme.of(context)
                                                .extension<AppColors>()!
                                                .primary);
                                      }
                                    } else {
                                      CustomSnackBar.showSnackBar(
                                          context: context,
                                          message:
                                              "Please select send currency",
                                          color: Theme.of(context)
                                              .extension<AppColors>()!
                                              .primary);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 1,
                                width: double.maxFinite,
                                color: Color(0xA66F35A5),
                              ),
                              Material(
                                elevation: 6.0,
                                shape: const CircleBorder(),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: isLoading
                                      ? Center(
                                          child: CircularProgressIndicator(
                                            color: Theme.of(context)
                                                .extension<AppColors>()!
                                                .primary,
                                          ),
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.arrow_downward,
                                            size: 30,
                                            color: Theme.of(context)
                                                .extension<AppColors>()!
                                                .primary,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 4.0,
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 0),
                          child: Padding(
                            padding: const EdgeInsets.all(defaultPadding),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    mReceiveCurrencyBottomSheet(context);
                                  },
                                  child: Card(
                                    elevation: 1.0,
                                    color: AppColors.light.primaryLight,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 0),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(defaultPadding),
                                      child: Row(
                                        children: [
                                          if (mReceiveCurrency?.toUpperCase() ==
                                              'EUR')
                                            getEuFlagWidget()
                                          else
                                            CountryFlag.fromCountryCode(
                                              width: 35,
                                              height: 35,
                                              mReceiveCountry!,
                                              shape: const Circle(),
                                            ),
                                          const SizedBox(width: defaultPadding),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$mReceiveCurrency',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .extension<AppColors>()!
                                                        .primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.arrow_drop_down,
                                              color: Theme.of(context)
                                                  .extension<AppColors>()!
                                                  .primary),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: largePadding),
                                TextFormField(
                                  controller: mReceiveAmountController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    prefix: Text(
                                      '${getCurrencySymbol(mReceiveCurrency!)} ',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .extension<AppColors>()!
                                              .primary),
                                    ),
                                    labelText: 'Recipient will receive',
                                    labelStyle: TextStyle(
                                        color: Theme.of(context)
                                            .extension<AppColors>()!
                                            .primary),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(),
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter recipient will receive amount';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  cursorColor: Theme.of(context)
                                      .extension<AppColors>()!
                                      .primary,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .extension<AppColors>()!
                                          .primary),
                                  maxLines: 2,
                                  minLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        const SizedBox(height: 30),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Charge',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .extension<AppColors>()!
                                        .primary)),
                            Text('$mSendCurrencySymbol $mTotalCharge',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .extension<AppColors>()!
                                        .primary)),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Payable',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .extension<AppColors>()!
                                        .primary,
                                    fontWeight: FontWeight.bold)),
                            Text('$mSendCurrencySymbol $mTotalPayable',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .extension<AppColors>()!
                                        .primary,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: defaultPadding)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: defaultPadding),
                Card(
                  elevation: 4.0,
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      children: [
                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: mFullName,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          cursorColor:
                              Theme.of(context).extension<AppColors>()!.primary,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary),
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (mSendCurrencyAmount == 0) {
                              return "You don't have sufficient amount";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: mEmail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          cursorColor:
                              Theme.of(context).extension<AppColors>()!.primary,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary),
                          decoration: InputDecoration(
                            labelText: "Your Email",
                            labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: mMobileNo,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          cursorColor:
                              Theme.of(context).extension<AppColors>()!.primary,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary),
                          decoration: InputDecoration(
                            labelText: "Mobile Number",
                            labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: mBankName,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          cursorColor:
                              Theme.of(context).extension<AppColors>()!.primary,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary),
                          decoration: InputDecoration(
                            labelText: "Bank Name",
                            labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your bank name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: mIban,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          cursorColor:
                              Theme.of(context).extension<AppColors>()!.primary,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary),
                          decoration: InputDecoration(
                            labelText: "IBAN / AC",
                            labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your IBAN or account number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: mBicCode,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          cursorColor:
                              Theme.of(context).extension<AppColors>()!.primary,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary),
                          decoration: InputDecoration(
                            labelText: "Routing/IFSC/BIC/SwiftCode",
                            labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the routing number or equivalent';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: mAddress,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          cursorColor:
                              Theme.of(context).extension<AppColors>()!.primary,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary),
                          decoration: InputDecoration(
                            labelText: "Recipient Address",
                            labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the recipient address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: largePadding),
                        if (isAddLoading)
                          Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary,
                            ),
                          ),
                        const SizedBox(height: 35),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: isAddLoading ? null : mMakePayment,
                            child: const Text('Make Payment',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void mSendCurrencyBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Container(
              height: 600,
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SendCurrencyBottomSheet(
                onSendCurrencySelected: (
                  String country,
                  String currency,
                  double amount,
                ) async {
                  await mSelectedSendCurrency(
                    country,
                    currency,
                    amount,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void mReceiveCurrencyBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Container(
              height: 600,
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ReceiveCurrencyBottomSheet(
                onReceiveCurrencySelected: (
                  String country,
                  String currency,
                  double amount,
                ) async {
                  await mSelectedReceiveCurrency(
                    country,
                    currency,
                    amount,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class SendCurrencyBottomSheet extends StatefulWidget {
  final Function(String, String, double) onSendCurrencySelected;

  const SendCurrencyBottomSheet(
      {super.key, required this.onSendCurrencySelected});

  @override
  State<SendCurrencyBottomSheet> createState() =>
      _SendCurrencyBottomSheetState();
}

class _SendCurrencyBottomSheetState extends State<SendCurrencyBottomSheet> {
  final AccountsListApi _accountsListApi = AccountsListApi();
  List<AccountsListsData> accountsListData = [];
  bool isLoading = false;
  String? errorMessage;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    mAccounts();
  }

  Future<void> mAccounts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _accountsListApi.accountsListApi();

      if (response.accountsList != null && response.accountsList!.isNotEmpty) {
        setState(() {
          accountsListData = response.accountsList!;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Account Found';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
        body: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Currency',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).extension<AppColors>()!.primary,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close,
                  color: Theme.of(context).extension<AppColors>()!.primary),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).extension<AppColors>()!.primary,
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : ListView.builder(
                                  itemCount: accountsListData.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final accountsData =
                                        accountsListData[index];
                                    final isSelected = index == _selectedIndex;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5,
                                          horizontal: smallPadding),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedIndex = index;
                                            widget.onSendCurrencySelected(
                                              accountsData.country ?? '',
                                              accountsData.currency ?? '',
                                              accountsData.amount ?? 0.0,
                                            );
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Card(
                                          elevation: 5,
                                          color: isSelected
                                              ? Theme.of(context)
                                                  .extension<AppColors>()!
                                                  .primary
                                              : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                defaultPadding),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(
                                                defaultPadding),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    if (accountsData.currency
                                                            ?.toUpperCase() ==
                                                        'EUR')
                                                      getEuFlagWidget()
                                                    else
                                                      CountryFlag
                                                          .fromCountryCode(
                                                        width: 35,
                                                        height: 35,
                                                        accountsData.country!,
                                                        shape: const Circle(),
                                                      ),
                                                    Text(
                                                      "${accountsData.currency}",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isSelected
                                                            ? Colors.white
                                                            : Theme.of(context)
                                                                .extension<
                                                                    AppColors>()!
                                                                .primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                    height: defaultPadding),
                                                const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  )),
      ],
    ));
  }
}

class ReceiveCurrencyBottomSheet extends StatefulWidget {
  final Function(String, String, double) onReceiveCurrencySelected;

  const ReceiveCurrencyBottomSheet(
      {super.key, required this.onReceiveCurrencySelected});

  @override
  State<ReceiveCurrencyBottomSheet> createState() =>
      _ReceiveCurrencyBottomSheetState();
}

class _ReceiveCurrencyBottomSheetState
    extends State<ReceiveCurrencyBottomSheet> {
  final AccountsListApi _accountsListApi = AccountsListApi();
  List<AccountsListsData> accountsListData = [];
  bool isLoading = false;
  String? errorMessage;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    mAccounts();
  }

  Future<void> mAccounts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _accountsListApi.accountsListApi();

      if (response.accountsList != null && response.accountsList!.isNotEmpty) {
        setState(() {
          accountsListData = response.accountsList!;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Account Found';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
        body: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Currency',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).extension<AppColors>()!.primary,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close,
                  color: Theme.of(context).extension<AppColors>()!.primary),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).extension<AppColors>()!.primary,
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : ListView.builder(
                                  itemCount: accountsListData.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final accountsData =
                                        accountsListData[index];
                                    final isSelected = index == _selectedIndex;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5,
                                          horizontal: smallPadding),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedIndex = index;
                                            widget.onReceiveCurrencySelected(
                                              accountsData.country ?? '',
                                              accountsData.currency ?? '',
                                              accountsData.amount ?? 0.0,
                                            );
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Card(
                                          elevation: 5,
                                          color: isSelected
                                              ? Theme.of(context)
                                                  .extension<AppColors>()!
                                                  .primary
                                              : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                defaultPadding),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(
                                                defaultPadding),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    if (accountsData.currency
                                                            ?.toUpperCase() ==
                                                        'EUR')
                                                      getEuFlagWidget()
                                                    else
                                                      CountryFlag
                                                          .fromCountryCode(
                                                        width: 35,
                                                        height: 35,
                                                        accountsData.country!,
                                                        shape: const Circle(),
                                                      ),
                                                    Text(
                                                      "${accountsData.currency}",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isSelected
                                                            ? Colors.white
                                                            : Theme.of(context)
                                                                .extension<
                                                                    AppColors>()!
                                                                .primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                    height: defaultPadding),
                                                const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  )),
      ],
    ));
  }
}
