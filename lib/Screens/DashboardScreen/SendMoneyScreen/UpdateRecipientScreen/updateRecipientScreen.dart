import 'dart:async';
import 'dart:ui';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListApi.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListModel.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/UpdateRecipientScreen/RecipientDetailsModel/receipientDetailsApi.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/UpdateRecipientScreen/RecipientExchangeMoneyModel/recipientExchangeMoneyApi.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/UpdateRecipientScreen/RecipientExchangeMoneyModel/recipientExchangeMoneyModel.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/UpdateRecipientScreen/UpdateRecipientModel/UpdateRecipientApi.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/UpdateRecipientScreen/UpdateRecipientModel/updateRecipientModel.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/DashboardTicketScreen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/currency_utils.dart';
import '../../../../util/auth_manager.dart';
import '../../../../util/customSnackBar.dart';
import '../../../HomeScreen/home_screen.dart';

class UpdateRecipientScreen extends StatefulWidget {
  final String? mRecipientId;

  const UpdateRecipientScreen({super.key, this.mRecipientId});

  @override
  State<UpdateRecipientScreen> createState() => _UpdateRecipientScreenState();
}

class _UpdateRecipientScreenState extends State<UpdateRecipientScreen> {
  final RecipientsDetailsApi _recipientsDetailsApi = RecipientsDetailsApi();
  final RecipientExchangeMoneyApi _recipientExchangeMoneyApi =
      RecipientExchangeMoneyApi();
  final RecipientUpdateApi _recipientUpdateApi = RecipientUpdateApi();

  TextEditingController mIbanController = TextEditingController();
  TextEditingController mBicCodeController = TextEditingController();
  TextEditingController mCurrencyController = TextEditingController();
  TextEditingController mAmountController = TextEditingController();

  bool isLoading = false; // For initial recipient details loading
  bool isSubmitLoading = false; // For submit button loading
  bool isSubmit = false; // To control submit button visibility
  bool isExchangeLoading = false; // For exchange API loading

  // From Currency (Recipient's currency)
  String? mFromCurrency;

  // To Currency (Selected account's currency)
  String? mToAccountId = '';
  String? mToCountry = '';
  String? mToCurrency = 'Select';
  String? mToIban = '';
  bool? mToStatus;
  double? mToAmount = 0.0;
  String? mToCurrencySymbol = '';
  String? mFromCurrencySymbol = '';
  double? mFromRate;
  double? mFees = 0.0;
  String? mTotalAmount = "0.0";
  double? mGetTotalAmount = 0.0;

  // Debounce Timer
  Timer? _debounce;

  Future<void> mSetSelectedAccountData(
      String mSelectedAccountId,
      String mSelectedCountry,
      String mSelectedCurrency,
      String mSelectedIban,
      bool mSelectedStatus,
      double mSelectedAmount) async {
    setState(() {
      mToAccountId = mSelectedAccountId;
      mToCountry = mSelectedCountry;
      mToCurrency = mSelectedCurrency;
      mToIban = mSelectedIban;
      mToStatus = mSelectedStatus;
      mToAmount = mSelectedAmount;
      mToCurrencySymbol = getCurrencySymbol(mToCurrency!);
    });
    print(
        'Selected Account: accountId=$mToAccountId, currency=$mToCurrency, balance=$mToAmount');
  }

  @override
  void initState() {
    mShowRecipientDetail();
    super.initState();
  }

  // Dispose the debounce timer and controllers
  @override
  void dispose() {
    _debounce?.cancel();
    mIbanController.dispose();
    mBicCodeController.dispose();
    mCurrencyController.dispose();
    mAmountController.dispose();
    super.dispose();
  }

  // Recipient Details Get Api
  Future<void> mShowRecipientDetail() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _recipientsDetailsApi
          .recipientsDetailsApi(widget.mRecipientId!);

      if (response.message == "Reciepient list is Successfully fetched") {
        setState(() {
          isLoading = false;
          mIbanController.text = response.recipientDetails!.first.iban!;
          mBicCodeController.text = response.recipientDetails!.first.bicCode!;
          mCurrencyController.text = response.recipientDetails!.first.currency!;
          mFromCurrency = response.recipientDetails!.first.currency!;
          mFromCurrencySymbol = getCurrencySymbol(mFromCurrency!);
        });
      } else {
        setState(() {
          isLoading = false;
          Navigator.of(context).pop();
          CustomSnackBar.showSnackBar(
              context: context,
              message: "We are facing some issue!",
              color: Colors.red);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        Navigator.of(context).pop();
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Something went wrong!",
            color: Colors.red);
      });
    }
  }

  // Exchange Money Api
  Future<void> mExchangeMoneyApi() async {
    setState(() {
      isExchangeLoading = true;
    });

    try {
      print(
          'Exchange Money Request: userId=${AuthManager.getUserId()}, amount=${mAmountController.text}, fromCurrency=$mToCurrency, toCurrency=$mFromCurrency, accountId=$mToAccountId');
      final request = RecipientExchangeMoneyRequest(
        userId: AuthManager.getUserId(),
        amount: mAmountController.text,
        fromCurrency: mToCurrency!,
        toCurrency: mFromCurrency!,
        accountId: mToAccountId!, // Include accountId
      );
      final response =
          await _recipientExchangeMoneyApi.recipientExchangeMoneyApi(request);
      print('Exchange Money Response: ${response.toString()}');

      if (response.message == "Success") {
        setState(() {
          isExchangeLoading = false;
          isSubmit = true;
          mFees = response.data.totalFees;
          mTotalAmount = response.data.totalCharge.toString();
          mGetTotalAmount =
              response.data.convertedAmount; // Use API's convertedAmount
        });
      } else {
        setState(() {
          isExchangeLoading = false;
          isSubmit = false;
          CustomSnackBar.showSnackBar(
            context: context,
            message: response.message ?? "We are facing some issue!",
            color: Theme.of(context).extension<AppColors>()!.primary,
          );
        });
      }
    } catch (error) {
      setState(() {
        isExchangeLoading = false;
        isSubmit = false;
        CustomSnackBar.showSnackBar(
          context: context,
          message: "Something went wrong: $error",
          color: Colors.red,
        );
      });
    }
  }

  // Update Recipients Details Api
  Future<void> mUpdateRecipient() async {
    setState(() {
      isSubmitLoading = true;
    });

    try {
      String amountText =
          '$mToCurrencySymbol ${mAmountController.text}'; // Selected account's currency
      String conversionAmountText =
          '$mFromCurrencySymbol ${mGetTotalAmount?.toStringAsFixed(2) ?? '0.00'}'; // Recipient's currency

      print(
          'Update Recipient Request: userId=${AuthManager.getUserId()}, fee=$mFees, toCurrency=$mFromCurrency, recipientId=${widget.mRecipientId}, amount=${mAmountController.text}');
      final request = RecipientUpdateRequest(
          userId: AuthManager.getUserId(),
          fee: mFees.toString(),
          toCurrency: mFromCurrency!, // Recipient's currency
          recipientId: widget.mRecipientId!,
          amount: mAmountController.text,
          amountText: amountText,
          conversionAmount: mGetTotalAmount.toString(),
          conversionAmountText: conversionAmountText);
      final response = await _recipientUpdateApi.recipientUpdateApi(request);
      print('Update Recipient Response: ${response.toString()}');

      if (response.message ==
          "Bank Transfer transaction has been submitted Successfully!!!") {
        setState(() {
          isSubmitLoading = false;
          CustomSnackBar.showSnackBar(
              context: context,
              message:
                  "Bank Transfer transaction has been submitted Successfully!",
              color: Colors.green);
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        });
      } else {
        setState(() {
          isSubmitLoading = false;
          CustomSnackBar.showSnackBar(
              context: context,
              message: response.message ?? "We are facing some issue!",
              color: Colors.red);
        });
      }
    } catch (error) {
      setState(() {
        isSubmitLoading = false;
        isSubmit = false;
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Something went wrong: $error",
            color: Colors.red);
      });
    }
  }

  // Currency Symbol
  String getCurrencySymbol(String currencyCode) {
    var format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.currencySymbol;
  }

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
                                width: screenWidth > 600 ? 200 : 140,
                                height: screenWidth > 600 ? 200 : 140,
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
                              'Your Entered Amount:- $mToCurrencySymbol ${enteredAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Estimated Fee:- $mToCurrencySymbol ${estimatedFee.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            Text(
                              'Estimated Total Amount:- $mToCurrencySymbol ${estimatedTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'According to your account balance ($mToCurrencySymbol ${mToAmount!.toStringAsFixed(2)}), you will not be able to pay the estimated total amount.',
                              style: const TextStyle(
                                color: Colors.black,
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
    );
  }

  // Debounced function to handle amount changes
  void _onAmountChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      print('Selected Account: Currency=$mToCurrency, Balance=$mToAmount');
      if (mToCurrency != "Select") {
        if (value.isNotEmpty) {
          if (double.tryParse(value) != null) {
            double enteredAmount = double.parse(value);
            // Assume fees are 1% of the amount (adjust based on API behavior)
            double estimatedFee = enteredAmount * 0.01;
            double estimatedTotal = enteredAmount + estimatedFee;
            print(
                'Entered Amount: $enteredAmount, Estimated Fee: $estimatedFee, Estimated Total: $estimatedTotal, Available Balance: $mToAmount');
            if (estimatedTotal > mToAmount!) {
              setState(() {
                isExchangeLoading = false;
                mAmountController.text = '';
                mFees = 0.0;
                mTotalAmount = '0.0';
                mGetTotalAmount = 0.0;
                isSubmit = false;
              });
              _showInsufficientBalanceDialog(
                  enteredAmount, estimatedFee, estimatedTotal);
            } else {
              mExchangeMoneyApi();
            }
          } else {
            setState(() {
              isExchangeLoading = false;
              mAmountController.text = '';
              mFees = 0.0;
              mTotalAmount = '0.0';
              mGetTotalAmount = 0.0;
              isSubmit = false;
            });
            CustomSnackBar.showSnackBar(
              context: context,
              message: "Please enter a valid amount",
              color: Theme.of(context).extension<AppColors>()!.primary,
            );
          }
        } else {
          setState(() {
            isExchangeLoading = false;
            mAmountController.text = '';
            mFees = 0.0;
            mTotalAmount = '0.0';
            mGetTotalAmount = 0.0;
            isSubmit = false;
          });
          CustomSnackBar.showSnackBar(
            context: context,
            message: "Please enter an amount",
            color: Theme.of(context).extension<AppColors>()!.primary,
          );
        }
      } else {
        setState(() {
          isExchangeLoading = false;
          mAmountController.text = '';
          mFees = 0.0;
          mTotalAmount = '0.0';
          mGetTotalAmount = 0.0;
          isSubmit = false;
        });
        CustomSnackBar.showSnackBar(
          context: context,
          message: "Please select an account",
          color: Theme.of(context).extension<AppColors>()!.primary,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Beneficiary Account Details",
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
             Navigator.push(context, CupertinoPageRoute(builder: (context) => DashboardTicketScreen(),));
            },
            tooltip: 'Support',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).extension<AppColors>()!.primary),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: mIbanController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      cursorColor:
                          Theme.of(context).extension<AppColors>()!.primary,
                      readOnly: true,
                      style: TextStyle(
                          color: Theme.of(context)
                              .extension<AppColors>()!
                              .primary),
                      decoration: InputDecoration(
                        labelText: "IBAN / Account Number",
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
                    ),
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: mBicCodeController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      cursorColor:
                          Theme.of(context).extension<AppColors>()!.primary,
                      readOnly: true,
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
                    ),
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: mCurrencyController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      cursorColor:
                          Theme.of(context).extension<AppColors>()!.primary,
                      style: TextStyle(
                          color: Theme.of(context)
                              .extension<AppColors>()!
                              .primary),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Currency",
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
                    ),
                    const SizedBox(height: largePadding),
                    GestureDetector(
                      onTap: () {
                        mGetAllAccountBottomSheet(context);
                      },
                      child: Card(
                        elevation: 1.0,
                        color: AppColors.light.primaryLight,
                        margin: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 0),
                        child: Padding(
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Row(
                            children: [
                              if (mToCurrency?.toUpperCase() == 'EUR')
                                getEuFlagWidget()
                              else
                                CountryFlag.fromCountryCode(
                                  width: 55,
                                  height: 55,
                                  mToCountry!,
                                  shape: const RoundedRectangle(smallPadding),
                                ),
                              const SizedBox(width: defaultPadding),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$mToCurrency Account',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Theme.of(context)
                                            .extension<AppColors>()!
                                            .primary,
                                      ),
                                    ),
                                    Text(
                                      '$mToIban',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                        color: Theme.of(context)
                                            .extension<AppColors>()!
                                            .primary,
                                      ),
                                    ),
                                    Text(
                                      '${getCurrencySymbol(mToCurrency!)}${mToAmount!.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .extension<AppColors>()!
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.navigate_next_rounded,
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
                      controller: mAmountController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      cursorColor:
                          Theme.of(context).extension<AppColors>()!.primary,
                      style: TextStyle(
                          color: Theme.of(context)
                              .extension<AppColors>()!
                              .primary),
                      decoration: InputDecoration(
                        labelText: "Enter Amount",
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
                          return 'Please enter amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onChanged: _onAmountChanged,
                    ),
                    const SizedBox(height: 45),
                    Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Fee:",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .extension<AppColors>()!
                                        .primary,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "$mToCurrencySymbol ${mFees!.toStringAsFixed(2)}",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .extension<AppColors>()!
                                        .primary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Amount:",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .extension<AppColors>()!
                                        .primary,
                                    fontWeight: FontWeight.bold),
                              ),
                              isExchangeLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context)
                                            .extension<AppColors>()!
                                            .primary,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "$mToCurrencySymbol $mTotalAmount",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .extension<AppColors>()!
                                              .primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Get Total Amount:",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .extension<AppColors>()!
                                        .primary,
                                    fontWeight: FontWeight.bold),
                              ),
                              isExchangeLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context)
                                            .extension<AppColors>()!
                                            .primary,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "$mFromCurrencySymbol ${mGetTotalAmount?.toStringAsFixed(2) ?? '0.00'}",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .extension<AppColors>()!
                                              .primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: largePadding),
                    if (isSubmitLoading)
                      Center(
                        child: CircularProgressIndicator(
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .primary),
                      ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: isSubmit
                          ? ElevatedButton(
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
                              onPressed:
                                  isSubmitLoading ? null : mUpdateRecipient,
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void mGetAllAccountBottomSheet(BuildContext context) {
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
              child: AllAccountsBottomSheet(
                onAccountSelected: (
                  String accountId,
                  String country,
                  String currency,
                  String iban,
                  bool status,
                  double amount,
                ) async {
                  await mSetSelectedAccountData(
                    accountId,
                    country,
                    currency,
                    iban,
                    status,
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

class AllAccountsBottomSheet extends StatefulWidget {
  final Function(String, String, String, String, bool, double)
      onAccountSelected;

  const AllAccountsBottomSheet({super.key, required this.onAccountSelected});

  @override
  State<AllAccountsBottomSheet> createState() => _AllAccountsBottomSheetState();
}

class _AllAccountsBottomSheetState extends State<AllAccountsBottomSheet> {
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

  // Accounts List Api
  Future<void> mAccounts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _accountsListApi.accountsListApi();
      print('API Response: ${response.toString()}');
      print('Accounts List Length: ${response.accountsList?.length ?? 0}');

      if (response.accountsList != null && response.accountsList!.isNotEmpty) {
        setState(() {
          accountsListData = response.accountsList!;
          isLoading = false;
        });
        for (var account in accountsListData) {
          print(
              'Account: ${account.accountId}, Currency: ${account.currency}, IBAN: ${account.iban}');
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Account Found';
        });
        print('No accounts found in response');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
      print('Error fetching accounts: $error');
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
                'Select Account',
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
                        color:
                            Theme.of(context).extension<AppColors>()!.primary),
                  )
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 16),
                            ),
                            const SizedBox(height: defaultPadding),
                            ElevatedButton(
                              onPressed: mAccounts,
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
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )
                    : accountsListData.isEmpty
                        ? Center(
                            child: Text(
                              'No Accounts Available',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .extension<AppColors>()!
                                      .primary,
                                  fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: accountsListData.length,
                            itemBuilder: (context, index) {
                              final accountsData = accountsListData[index];
                              final isSelected = index == _selectedIndex;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: smallPadding),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                      widget.onAccountSelected(
                                        accountsData.accountId ?? '',
                                        accountsData.country ?? '',
                                        accountsData.currency ?? '',
                                        accountsData.iban ?? '',
                                        accountsData.status ?? false,
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
                                      borderRadius:
                                          BorderRadius.circular(defaultPadding),
                                    ),
                                    child: Container(
                                      padding:
                                          const EdgeInsets.all(defaultPadding),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (accountsData.currency
                                                      ?.toUpperCase() ==
                                                  'EUR')
                                                getEuFlagWidget()
                                              else
                                                CountryFlag.fromCountryCode(
                                                  width: 35,
                                                  height: 35,
                                                  accountsData.country!,
                                                  shape: const Circle(),
                                                ),
                                              Text(
                                                "${accountsData.currency}",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
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
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "IBAN",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Theme.of(context)
                                                          .extension<
                                                              AppColors>()!
                                                          .primary,
                                                ),
                                              ),
                                              Text(
                                                "${accountsData.iban}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
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
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Balance",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Theme.of(context)
                                                          .extension<
                                                              AppColors>()!
                                                          .primary,
                                                ),
                                              ),
                                              Text(
                                                "${getCurrencySymbol(accountsData.currency)}${accountsData.amount?.toStringAsFixed(2) ?? '0.00'}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
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
    );
  }
}
