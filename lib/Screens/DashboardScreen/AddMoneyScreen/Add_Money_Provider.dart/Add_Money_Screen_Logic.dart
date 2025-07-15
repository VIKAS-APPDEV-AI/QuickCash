import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickcash/Screens/DashboardScreen/AddMoneyScreen/AddPaymentSuccessModel/addPaymentSuccessApi.dart';
import 'package:quickcash/Screens/DashboardScreen/AddMoneyScreen/AddPaymentSuccessModel/addPaymentSuccessModel.dart';
import 'package:quickcash/Screens/DashboardScreen/AddMoneyScreen/AddPaymentSuccessScreen/addPaymentSuccessScreen.dart';
import 'package:quickcash/Screens/DashboardScreen/AddMoneyScreen/Add_Money_Provider.dart/AddMoneyProvider.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/PayRecipientsScree/exchangeCurrencyModel/NewCurrencyExchangeAPI.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/model/currencyApiModel/Model/currencyModel.dart';
import 'package:quickcash/model/currencyApiModel/Services/currencyApi.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/util/customSnackBar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../SendMoneyScreen/PayRecipientsScree/exchangeCurrencyModel/CurrencyExchangeModel.dart';

class AddMoneyScreenLogic {
  final Razorpay _razorpay = Razorpay();
  final AddPaymentSuccessApi _addPaymentSuccessApi = AddPaymentSuccessApi();
  final CurrencyApi _currencyApi = CurrencyApi();
  final ExchangeCurrencyApiNew _exchangeCurrencyApi = ExchangeCurrencyApiNew();

  final String apiUrl = "https://quickcash.oyefin.com/api/v1/stripe/create-intent";
  final TextEditingController mAmountController = TextEditingController();
  List<CurrencyListsData> currency = [];
  bool isAddLoading = false;

  // From Account
  String? mFromAccountId;
  String? mFromCountry;
  String? mFromCurrency;
  String? mFromAccountName;
  String? mFromIban;
  bool? mFromStatus;
  double? mFromAmount;
  String? mFromCurrencySymbol;

  AddMoneyScreenLogic({
    String? accountId,
    String? accountName,
    String? country,
    String? currency,
    String? iban,
    bool? status,
    double? amount,
  }) {
    mFromAccountId = accountId;
    mFromCountry = country;
    mFromCurrency = currency;
    mFromAccountName = accountName;
    mFromIban = iban;
    mFromStatus = status;
    mFromAmount = amount;
    init();
  }

  void init() {
    mSetDefaultAccountData();
    mGetCurrency();
    Stripe.publishableKey = dotenv.env['stripePublishableKey'] ?? 'default_key';
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void setupPaymentErrorHandler(Function(PaymentFailureResponse) handler) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handler);
  }

  void dispose() {
    _razorpay.clear();
    mAmountController.dispose();
  }

  Future<void> mSetDefaultAccountData() async {
    mFromCurrencySymbol = getCurrencySymbol(mFromCurrency ?? 'USD');
  }

  Future<void> mGetCurrency() async {
    try {
      final response = await _currencyApi.currencyApi();
      if (response.currencyList != null && response.currencyList!.isNotEmpty) {
        currency = response.currencyList!;
      }
    } catch (e) {
      print('Error fetching currencies: $e');
    }
  }

  String getCurrencySymbol(String currencyCode) {
    return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
  }

  Future<double> getFeeAmount(double transactionAmount) async {
    try {
      final dio = Dio();
      final token = AuthManager.getToken();
      if (token == null) {
        print('getFeeAmount: No auth token available');
        return 23.0;
      }

      final response = await dio.get(
        "https://quickcash.oyefin.com/api/v1/admin/feetype/type?type=Debit",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      // Adjusted to handle statusCode 201 from your API
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['status'] == 201) {
        final feeData = response.data['data'][0]['feedetails'][0];
        final commissionType = feeData['commissionType'];
        final value = feeData['value'].toDouble();
        final minimumValue = feeData['minimumValue'].toDouble();

        double calculatedFee = commissionType == 'percentage' 
            ? transactionAmount * (value / 100)
            : value;
        double finalFee = calculatedFee > minimumValue ? calculatedFee : minimumValue;
        
        return finalFee;
      }
      print('getFeeAmount: Unexpected API response: ${response.statusCode}, ${response.data}');
      return 23.0;
    } catch (e) {
      print('getFeeAmount: Error: $e');
      return 23.0;
    }
  }

  Future<void> mExchangeMoneyApi(BuildContext context) async {
    final provider = Provider.of<AddMoneyProvider>(context, listen: false);
    if (provider.selectedSendCurrency == null) {
      CustomSnackBar.showSnackBar(
        context: context,
        message: "Please select a currency.",
        color: kPrimaryColor,
      );
      return;
    }

    if (mAmountController.text.isEmpty) {
      provider.resetAllFields();
      return;
    }

    provider.setIsLoading(true);
    if (context.mounted) {
      (context as Element).markNeedsBuild();
    }
    try {
      double inputAmount = double.tryParse(mAmountController.text) ?? 0.0;
      if (inputAmount <= 0) {
        provider.setIsLoading(false);
        provider.resetAllFields();
        if (context.mounted) {
          CustomSnackBar.showSnackBar(
            context: context,
            message: "Please enter a valid amount.",
            color: kPrimaryColor,
          );
        }
        return;
      }

      final exchangeRequest = ExchangeCurrencyRequestnew(
        toCurrency: mFromCurrency ?? 'USD',
        fromCurrency: provider.selectedSendCurrency ?? 'USD',
        amount: inputAmount,
      );
      final response = await _exchangeCurrencyApi.exchangeCurrencyApiNew(exchangeRequest);

      if (mAmountController.text.isEmpty) {
        provider.resetAllFields();
        provider.setIsLoading(false);
        return;
      }

      if (response.success && response.result != null) {
        double fee = await getFeeAmount(inputAmount);
        provider.setDepositFees(fee);
        provider.setConversionAmount(response.result!.convertedAmount.toStringAsFixed(2));
        provider.setAmountCharge((inputAmount + fee).toStringAsFixed(2));
        provider.setToCurrencySymbol(getCurrencySymbol(provider.selectedSendCurrency ?? 'USD'));
        provider.setIsLoading(false);
      } else {
        if (context.mounted) {
          CustomSnackBar.showSnackBar(
            context: context,
            message: "We are facing some issues!",
            color: kPrimaryColor,
          );
        }
      }
    } catch (error) {
      provider.setIsLoading(false);
      if (context.mounted) {
        CustomSnackBar.showSnackBar(
          context: context,
          message: error.toString(),
          color: kPrimaryColor,
        );
      }
    }
    if (context.mounted) {
      (context as Element).markNeedsBuild();
    }
  }

  Future<void> handleStripePayment(BuildContext context, GlobalKey<FormState> formKey) async {
    final provider = Provider.of<AddMoneyProvider>(context, listen: false);
    if (!_validatePaymentPrerequisites(context, formKey, provider)) return;

    isAddLoading = true;
    try {
      final dio = Dio();
      final token = AuthManager.getToken();
      final amount = double.tryParse(mAmountController.text) ?? 0.0;
      double fee = await getFeeAmount(amount);
      provider.setDepositFees(fee);
      provider.setAmountCharge((amount + fee).toStringAsFixed(2));

      final data = {
        "amount": double.tryParse(provider.amountCharge) ?? 0.0,
        "account": mFromAccountId ?? "",
        "user": AuthManager.getUserId() ?? "",
        "convertedAmount": double.tryParse(provider.conversionAmount) ?? 0.0,
        "fee": provider.depositFees,
        "currency": provider.selectedSendCurrency?.toLowerCase() ?? "",
        "from_currency": provider.selectedSendCurrency ?? "",
        "to_currency": mFromCurrency ?? "USD",
      };

      final response = await dio.post(
        apiUrl,
        data: data,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data["status"] == 201 && context.mounted) {
        final clientSecret = response.data["data"]["client_secret"];
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: "QuickCash",
            style: ThemeMode.light,
          ),
        );
        await Stripe.instance.presentPaymentSheet();

        await _completeStripePayment(context, dio, token, response.data["data"]["id"], "succeeded");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AwesomeSnackbarContent(
                title: 'Success!',
                message: "Payment completed successfully!",
                contentType: ContentType.success,
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          );
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => AddPaymentSuccessScreen(
                transactionId: response.data["data"]["id"],
                amount: '${getCurrencySymbol(provider.selectedSendCurrency ?? "USD")} ${provider.amountCharge}',
              ),
            ),
          );
        }
      } else {
        throw Exception("Failed to create payment intent");
      }
    } on StripeException catch (e) {
      if (context.mounted) {
        CustomSnackBar.showSnackBar(context: context, message: "Stripe Error: ${e.error.localizedMessage}", color: Colors.red);
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showSnackBar(context: context, message: "Payment Failed: $e", color: Colors.red);
      }
    } finally {
      isAddLoading = false;
    }
  }

  Future<void> _completeStripePayment(BuildContext context, Dio dio, String token, String transactionId, String status) async {
    final provider = Provider.of<AddMoneyProvider>(context, listen: false);

    final completeData = {
      "user": AuthManager.getUserId() ?? "",
      "status": status,
      "orderDetails": transactionId,
      "userData": AuthManager.getUserName().toString(),
      "account": mFromAccountId ?? "",
      "amount": double.tryParse(mAmountController.text) ?? 0.0,
      "fee": provider.depositFees,
      "amountText": "$mFromCurrencySymbol${double.tryParse(mAmountController.text) ?? 0.0}",
      "from_currency": mFromCurrency ?? "USD",
      "to_currency": provider.selectedSendCurrency ?? "",
      "convertedAmount": double.tryParse(provider.conversionAmount) ?? 0.0,
      "conversionAmountText": "$mFromCurrencySymbol${provider.conversionAmount}",
    };

    final response = await dio.post(
      "https://quickcash.oyefin.com/api/v1/stripe/complete-addmoney",
      data: completeData,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to complete add money");
    }
  }

  Future<void> openRazorpay(BuildContext context) async {
    final provider = Provider.of<AddMoneyProvider>(context, listen: false);
    if (provider.selectedSendCurrency != "INR") {
      CustomSnackBar.showSnackBar(context: context, message: "Only INR supported for UPI", color: kRedColor);
      return;
    }

    isAddLoading = true;
    try {
      final amount = (double.tryParse(provider.amountCharge) ?? 0.0) * 100;
      final options = {
        'key': 'rzp_test_TR6pZnguGgK8hQ',
        'amount': amount.toInt(),
        'name': 'QuickCash',
        'method': 'upi',
        'theme': {'color': "#6F35A5"},
      };
      _razorpay.open(options);
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showSnackBar(context: context, message: "Failed to open Razorpay: $e", color: kRedColor);
      }
    } finally {
      isAddLoading = false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    mAddPaymentSuccess(navigatorKey.currentContext, response.paymentId, "Success", "Razorpay");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('_handleExternalWallet: External wallet used: ${response.walletName}');
  }

  Future<void> mAddPaymentSuccess(BuildContext? context, String? paymentId, String status, String paymentGateway) async {
    if (context == null) {
      return;
    }
    final provider = Provider.of<AddMoneyProvider>(context, listen: false);
    isAddLoading = true;

    try {
      final request = AddPaymentSuccessRequest(
        userId: AuthManager.getUserId() ?? "",
        status: status,
        paymentId: paymentId ?? "",
        paymentGateway: paymentGateway,
        amount: mAmountController.text,
        fee: provider.depositFees.toString(),
        amountText: '${provider.toCurrencySymbol}${mAmountController.text}',
        fromCurrency: mFromCurrency ?? "USD",
        toCurrency: provider.selectedSendCurrency ?? "",
        conversionAmount: provider.conversionAmount,
        conversionAmountText: '$mFromCurrencySymbol${provider.conversionAmount}',
      );
      final response = await _addPaymentSuccessApi.addPaymentSuccessApi(request);

      if (response.message == "Payment has been done Successfully !!!" && status == "Success" && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddPaymentSuccessScreen(
              transactionId: paymentId ?? 'Unknown',
              amount: '${provider.toCurrencySymbol}${provider.amountCharge}',
            ),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        CustomSnackBar.showSnackBar(context: context, message: "Something went wrong: $error", color: kRedColor);
      }
    } finally {
      isAddLoading = false;
    }
  }

  bool _validatePaymentPrerequisites(BuildContext context, GlobalKey<FormState> formKey, AddMoneyProvider provider) {
    if (!formKey.currentState!.validate()) return false;
    if (provider.selectedSendCurrency == null) {
      CustomSnackBar.showSnackBar(context: context, message: "Please select a currency", color: kPrimaryColor);
      return false;
    }
    if (provider.selectedTransferType == null) {
      CustomSnackBar.showSnackBar(context: context, message: "Please select a transfer type", color: kPrimaryColor);
      return false;
    }
    return true;
  }

  void showPaymentPopupMessage(BuildContext context, bool isPaymentSuccess, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(isPaymentSuccess ? Icons.done : Icons.clear, color: isPaymentSuccess ? Colors.green : Colors.red),
            const SizedBox(width: 5),
            Text(isPaymentSuccess ? 'Payment Successful' : 'Payment Failed', style: const TextStyle(fontSize: 20)),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const Divider(color: Colors.grey),
              const SizedBox(height: 5),
              Text(message),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();