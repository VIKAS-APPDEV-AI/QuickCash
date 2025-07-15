import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickcash/Screens/DashboardScreen/AddMoneyScreen/Add_Money_Provider.dart/AddMoneyProvider.dart';
import 'package:quickcash/Screens/DashboardScreen/AddMoneyScreen/Add_Money_Provider.dart/Add_Money_Screen_Logic.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/model/currencyApiModel/Model/currencyModel.dart';
import 'package:quickcash/util/customSnackBar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AddMoneyScreenUI extends StatefulWidget {
  final AddMoneyScreenLogic logic;

  const AddMoneyScreenUI({super.key, required this.logic});

  @override
  State<AddMoneyScreenUI> createState() => _AddMoneyScreenUIState();
}

class _AddMoneyScreenUIState extends State<AddMoneyScreenUI> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.logic.setupPaymentErrorHandler(_handlePaymentError);
    widget.logic.mGetCurrency().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    widget.logic.showPaymentPopupMessage(context, false, 'Payment Failed: ${response.message}');
    widget.logic.mAddPaymentSuccess(context, "", "cancelled", "Razorpay");
  }

  @override
  void dispose() {
    widget.logic.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(BuildContext context, AddMoneyProvider provider) async {
    print('Refresh triggered');
    widget.logic.mAmountController.clear();
    provider.resetAllFields();
    await widget.logic.mGetCurrency();
    if (mounted) {
      setState(() {});
    }
    print('Refresh completed');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddMoneyProvider(),
      child: Consumer<AddMoneyProvider>(
        builder: (context, provider, child) {
          print('Building UI - Current values: '
              'depositFees=${provider.depositFees}, '
              'amountCharge=${provider.amountCharge}, '
              'conversionAmount=${provider.conversionAmount}, '
              'isLoading=${provider.isLoading}, '
              'selectedSendCurrency=${provider.selectedSendCurrency}');

          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: kPrimaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                "Add Money",
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () => _onRefresh(context, provider),
              color: kPrimaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: defaultPadding),
                        _buildCurrencySelector(context, provider),
                        const SizedBox(height: defaultPadding),
                        _buildTransferTypeSelector(context, provider),
                        const SizedBox(height: defaultPadding),
                        _buildAmountField(context, provider),
                        const SizedBox(height: defaultPadding),
                        if (provider.isLoading) _buildLoadingIndicator(),
                        const SizedBox(height: defaultPadding),
                        _buildFeeDisplay(provider),
                        const SizedBox(height: smallPadding),
                        const Divider(),
                        const SizedBox(height: smallPadding),
                        _buildAmountChargeDisplay(provider),
                        const SizedBox(height: smallPadding),
                        const Divider(),
                        const SizedBox(height: smallPadding),
                        _buildConversionAmountDisplay(provider),
                        const SizedBox(height: defaultPadding * 2),
                        _buildAddMoneyButton(context, provider),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context, AddMoneyProvider provider) {
    return GestureDetector(
      onTap: () {
        if (widget.logic.currency.isNotEmpty) {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Select Currency', style: TextStyle(color: kPrimaryColor)),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: widget.logic.currency.map((CurrencyListsData currencyItem) {
                      return ListTile(
                        title: Text(
                          currencyItem.currencyCode!,
                          style: const TextStyle(
                              color: kPrimaryColor, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.pop(context, currencyItem.currencyCode);
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ).then((String? newValue) {
            if (newValue != null) {
              provider.setSelectedSendCurrency(newValue);
              provider.setToCurrencySymbol(widget.logic.getCurrencySymbol(newValue));
              widget.logic.mAmountController.clear();
              provider.resetAllFields();
              if (mounted) setState(() {});
            }
          });
        } else {
          CustomSnackBar.showSnackBar(
            context: context,
            message: "Currency list is empty. Please try again.",
            color: kPrimaryColor,
          );
        }
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kPrimaryColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                provider.selectedSendCurrency ?? "Select Currency",
                style: const TextStyle(color: kPrimaryColor),
              ),
              const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransferTypeSelector(BuildContext context, AddMoneyProvider provider) {
    return GestureDetector(
      onTap: () => _showTransferTypeDropDown(context, true, provider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimaryColor),
          boxShadow: [
            BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (provider.selectedTransferType != null)
                  Image.asset(
                    _getImageForTransferType(provider.selectedTransferType!),
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: Colors.red),
                  ),
                const SizedBox(width: 8.0),
                Text(
                  provider.selectedTransferType ?? 'Transfer Type',
                  style: const TextStyle(color: kPrimaryColor),
                ),
              ],
            ),
            const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField(BuildContext context, AddMoneyProvider provider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
           color: kPrimaryColor,
           spreadRadius: 0,
           blurRadius: 2,
           offset: const Offset(0, 0),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.logic.mAmountController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        cursorColor: kPrimaryColor,
        style: const TextStyle(color: kPrimaryColor),
        decoration: InputDecoration(
          labelText: "Amount",
          labelStyle: const TextStyle(color: kPrimaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimaryColor),
          ),
          filled: true,
          fillColor: Colors.white,
          prefixText: provider.toCurrencySymbol,
          prefixStyle: const TextStyle(color: kPrimaryColor),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            provider.resetAllFields();
            return 'Please enter an amount';
          }
          final amount = double.tryParse(value);
          if (amount == null || amount <= 0) {
            provider.resetAllFields();
            return 'Please enter a valid amount greater than zero';
          }
          return null;
        },
        onChanged: (value) {
          print('Amount changed to: "$value"');
          if (value.isEmpty) {
            provider.resetAllFields();
            if (mounted) setState(() {});
            return;
          }
          if (provider.selectedSendCurrency == null) {
            CustomSnackBar.showSnackBar(
                context: context, message: "Please select currency", color: kGreenColor);
            provider.resetAllFields();
            return;
          }
      
          final enteredAmount = double.tryParse(value) ?? 0.0;
          if (enteredAmount > 0) {
            widget.logic.mExchangeMoneyApi(context);
          } else {
            provider.resetAllFields();
            if (mounted) setState(() {});
          }
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(color: kPrimaryColor),
    );
  }

  Widget _buildFeeDisplay(AddMoneyProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Deposit Fee:",
          style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
        ),
        provider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                  strokeWidth: 2,
                ),
              )
            : Text(
                provider.depositFees == 0.0
                    ? "${provider.toCurrencySymbol ?? ''}0.00"
                    : "${provider.toCurrencySymbol ?? ''}${provider.depositFees.toStringAsFixed(2)}",
                style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
              ),
      ],
    );
  }

  Widget _buildAmountChargeDisplay(AddMoneyProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Total Amount (incl. fee):",
          style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
        ),
        provider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                  strokeWidth: 2,
                ),
              )
            : Text(
                provider.amountCharge == '0.0'
                    ? "${provider.toCurrencySymbol ?? ''}0.00"
                    : "${provider.toCurrencySymbol ?? ''}${provider.amountCharge}",
                style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
              ),
      ],
    );
  }

  Widget _buildConversionAmountDisplay(AddMoneyProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Conversion Amount:",
          style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
        ),
        provider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                  strokeWidth: 2,
                ),
              )
            : Text(
                provider.conversionAmount == '0.0'
                    ? "${widget.logic.mFromCurrencySymbol ?? ''}0.00"
                    : "${widget.logic.mFromCurrencySymbol ?? ''}${provider.conversionAmount}",
                style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
              ),
      ],
    );
  }

  Widget _buildAddMoneyButton(BuildContext context, AddMoneyProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: provider.isLoading || widget.logic.isAddLoading
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  if (provider.selectedSendCurrency == null) {
                    CustomSnackBar.showSnackBar(
                        context: context, message: "Please select a currency", color: kPrimaryColor);
                    return;
                  }
                  if (provider.selectedTransferType == null) {
                    CustomSnackBar.showSnackBar(
                        context: context,
                        message: "Please select a transfer type",
                        color: kPrimaryColor);
                    return;
                  }
                  if (provider.amountCharge == '0.0' || provider.conversionAmount == '0.0') {
                    CustomSnackBar.showSnackBar(
                        context: context,
                        message: "Please enter a valid amount and wait for calculation",
                        color: kPrimaryColor);
                    return;
                  }
                  if (provider.selectedTransferType ==
                      "UPI * Currently Support Only INR Currency") {
                    if (provider.selectedSendCurrency == "INR") {
                      widget.logic.openRazorpay(context);
                    } else {
                      CustomSnackBar.showSnackBar(
                          context: context, message: "UPI supports only INR", color: kPrimaryColor);
                    }
                  } else if (provider.selectedTransferType ==
                      "Stripe * Support Other Currencies") {
                    widget.logic.handleStripePayment(context, _formKey);
                  } else {
                    CustomSnackBar.showSnackBar(
                        context: context,
                        message: "Unsupported Payment Method",
                        color: kPrimaryColor);
                  }
                }
              },
        child: widget.logic.isAddLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text('Add Money', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  String _getFlagForTransferType(String transferType) {
    switch (transferType) {
      case "Stripe * Support Other Currencies":
        return 'Stripe';
      case "UPI * Currently Support Only INR Currency":
        return 'UPI';
      default:
        return '';
    }
  }

  String _getImageForTransferType(String transferType) {
    switch (transferType) {
      case "Stripe * Support Other Currencies":
        return 'assets/icons/stripe.png';
      case "UPI * Currently Support Only INR Currency":
        return 'assets/icons/upi.png';
      default:
        return 'assets/icons/default.png';
    }
  }

  void _showTransferTypeDropDown(
      BuildContext context, bool isTransfer, AddMoneyProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 25),
            _buildTransferOptions(
                'Stripe * Support Other Currencies', 'assets/icons/stripe.png', isTransfer, provider),
            _buildTransferOptions(
                'UPI * Currently Support Only INR Currency', 'assets/icons/upi.png', isTransfer, provider),
          ],
        );
      },
    );
  }

  Widget _buildTransferOptions(
      String type, String logoPath, bool isTransfer, AddMoneyProvider provider) {
    return ListTile(
      title: Row(
        children: [
          Image.asset(logoPath, height: 24),
          const SizedBox(width: 8.0),
          Text(type),
        ],
      ),
      onTap: () {
        if (isTransfer) {
          provider.setSelectedTransferType(type);
          widget.logic.mAmountController.clear();
          provider.resetAllFields();
          if (mounted) setState(() {});
        }
        Navigator.pop(context);
      },
    );
  }
}