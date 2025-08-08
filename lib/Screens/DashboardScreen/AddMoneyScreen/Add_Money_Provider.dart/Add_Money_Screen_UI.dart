import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickcash/Screens/DashboardScreen/AddMoneyScreen/Add_Money_Provider.dart/AddMoneyProvider.dart';
import 'package:quickcash/Screens/DashboardScreen/AddMoneyScreen/Add_Money_Provider.dart/Add_Money_Screen_Logic.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/DashboardTicketScreen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/model/currencyApiModel/Model/currencyModel.dart';
import 'package:quickcash/util/CurrencyImageList.dart';
import 'package:quickcash/util/currency_utils.dart' as CurrencyFlagHelper;
import 'package:quickcash/util/customSnackBar.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AddMoneyScreenUI extends StatefulWidget {
  final AddMoneyScreenLogic logic;

  const AddMoneyScreenUI({super.key, required this.logic});

  @override
  State<AddMoneyScreenUI> createState() => _AddMoneyScreenUIState();
}

class _AddMoneyScreenUIState extends State<AddMoneyScreenUI>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize animations first
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _isInitialized = true;
    _animationController!.forward();

    // Set up payment handler and fetch currency
    widget.logic.setupPaymentErrorHandler(_handlePaymentError);
    widget.logic.mGetCurrency().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    widget.logic.showPaymentPopupMessage(
        context, false, 'Payment Failed: ${response.message}');
    widget.logic.mAddPaymentSuccess(context, "", "cancelled", "Razorpay");
  }

  @override
  void dispose() {
    _animationController?.dispose();
    widget.logic.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(
      BuildContext context, AddMoneyProvider provider) async {
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
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
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
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                "Add Money",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
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
            body: RefreshIndicator(
              onRefresh: () => _onRefresh(context, provider),
              color: Theme.of(context).extension<AppColors>()!.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: _isInitialized &&
                          _animationController != null &&
                          _fadeAnimation != null &&
                          _slideAnimation != null
                      ? FadeTransition(
                          opacity: _fadeAnimation!,
                          child: SlideTransition(
                            position: _slideAnimation!,
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
                                  if (provider.isLoading)
                                    _buildLoadingIndicator(),
                                  const SizedBox(height: defaultPadding),
                                  _buildInfoCard(provider),
                                  const SizedBox(height: defaultPadding * 2),
                                  _buildAddMoneyButton(context, provider),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .primary,
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

Widget _buildCurrencySelector(
    BuildContext context, AddMoneyProvider provider) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: provider.selectedSendCurrency != null
          ? ClipOval(
              child: Builder(
                builder: (context) {
                  try {
                    final currencyCode = provider.selectedSendCurrency!;
                    final countryCode =
                        CurrencyCountryMapper.getCountryCode(currencyCode);

                    if (countryCode == 'EU') {
                      return CurrencyFlagHelper.getEuFlagWidget();
                    }

                    return CountryFlag.fromCountryCode(
                      countryCode,
                      height: 24,
                      width: 24,
                      shape: const Circle(),
                    );
                  } catch (e) {
                    print(
                        'Failed to load flag for ${provider.selectedSendCurrency}: $e');
                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: Center(
                        child: Text(
                          provider.selectedSendCurrency![0],
                          style: TextStyle(
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            )
          : Icon(
              CupertinoIcons.money_dollar_circle,
              color: Theme.of(context).extension<AppColors>()!.primary,
            ),
      title: Text(
        provider.selectedSendCurrency ?? "Select Currency",
        style: TextStyle(
          color: Theme.of(context).extension<AppColors>()!.primary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_down,
        color: Theme.of(context).extension<AppColors>()!.primary,
      ),
      onTap: () {
        if (widget.logic.currency.isNotEmpty) {
          _showCurrencyDropdown(context, provider);
        } else {
          CustomSnackBar.showSnackBar(
            context: context,
            message: "Currency list is empty. Please try again.",
            color: Theme.of(context).extension<AppColors>()!.primary,
          );
        }
      },
    ),
  );
}


  void _showCurrencyDropdown(BuildContext context, AddMoneyProvider provider) {
    TextEditingController searchController = TextEditingController();
    List<CurrencyListsData> filteredCurrencies = widget.logic.currency;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Select Currency',
                          style: TextStyle(
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search currency...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Icon(CupertinoIcons.search,
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: TextStyle(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary),
                          onChanged: (value) {
                            setModalState(() {
                              filteredCurrencies = widget.logic.currency
                                  .where((currency) =>
                                      currency.currencyCode!
                                          .toLowerCase()
                                          .contains(value.toLowerCase()) ||
                                      _getCurrencyName(currency.currencyCode!)
                                          .toLowerCase()
                                          .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                        ),
                      ),
                      // Currency list
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: filteredCurrencies.length,
                          itemBuilder: (context, index) {
                            final currencyItem = filteredCurrencies[index];
                            return InkWell(
                              onTap: () {
                                provider.setSelectedSendCurrency(
                                    currencyItem.currencyCode);
                                provider.setToCurrencySymbol(_getCurrencySymbol(
                                    currencyItem.currencyCode!));
                                widget.logic.mAmountController.clear();
                                provider.resetAllFields();
                                if (mounted) setState(() {});
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                _getCurrencySymbol(
                                                    currencyItem.currencyCode!),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .extension<AppColors>()!
                                                      .primary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                currencyItem.currencyCode!,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .extension<AppColors>()!
                                                      .primary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            _getCurrencyName(
                                                currencyItem.currencyCode!),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ClipOval(
                                      child: Builder(
                                        builder: (context) {
                                          try {
                                            final countryCode =
                                                CurrencyCountryMapper
                                                    .getCountryCode(currencyItem
                                                        .currencyCode!);

                                            if (countryCode == 'EU') {
                                              return CurrencyFlagHelper
                                                  .getEuFlagWidget();
                                            }

                                            return CountryFlag.fromCountryCode(
                                              countryCode,
                                              height: 32,
                                              width: 32,
                                              shape: const Circle(),
                                            );
                                          } catch (e) {
                                            print(
                                                'Failed to load flag for ${currencyItem.currencyCode}: $e');
                                            return Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[200],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  currencyItem.currencyCode![0],
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .extension<AppColors>()!
                                                        .primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTransferTypeSelector(
      BuildContext context, AddMoneyProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: provider.selectedTransferType != null
            ? Image.asset(
                _getImageForTransferType(provider.selectedTransferType!),
                height: 24,
                width: 24,
                errorBuilder: (context, error, stackTrace) {
                  print(
                      'Failed to load transfer type image for ${provider.selectedTransferType}: $error');
                  return Icon(CupertinoIcons.exclamationmark_triangle,
                      color: Colors.red);
                },
              )
            : Icon(CupertinoIcons.creditcard,
                color: Theme.of(context).extension<AppColors>()!.primary),
        title: Text(
          provider.selectedTransferType ?? 'Select Transfer Type',
          style: TextStyle(
            color: Theme.of(context).extension<AppColors>()!.primary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Icon(CupertinoIcons.chevron_down,
            color: Theme.of(context).extension<AppColors>()!.primary),
        onTap: () => _showTransferTypeDropDown(context, true, provider),
      ),
    );
  }

  Widget _buildAmountField(BuildContext context, AddMoneyProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 53, 23, 23).withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: 16), // Ensures left-right padding
      child: TextFormField(
        controller: widget.logic.mAmountController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        cursorColor: Theme.of(context).extension<AppColors>()!.primary,
        style: TextStyle(
          color: Theme.of(context).extension<AppColors>()!.primary,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          fillColor: Colors.white,
          hintText: "Enter Amount",
          hintStyle: TextStyle(
            color: AppColors.light.hint,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Text(
              provider.toCurrencySymbol ?? '',
              style: TextStyle(
                color: AppColors.light.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            provider.resetAllFields();
            return 'Please enter an amount';
          }
          final amount = double.tryParse(value);
          if (amount == null || amount <= 0) {
            provider.resetAllFields();
            return 'Enter a valid amount greater than zero';
          }
          return null;
        },
        onChanged: (value) {
          if (value.isEmpty) {
            provider.resetAllFields();
            if (mounted) setState(() {});
            return;
          }
          if (provider.selectedSendCurrency == null) {
            CustomSnackBar.showSnackBar(
                context: context,
                message: "Please select currency",
                color: Theme.of(context).extension<AppColors>()!.primary);
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
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).extension<AppColors>()!.primary,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildInfoCard(AddMoneyProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoRow(
            'Deposit Fee',
            provider.isLoading
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).extension<AppColors>()!.primary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    provider.depositFees == 0.0
                        ? "${provider.toCurrencySymbol ?? ''}0.00"
                        : "${provider.toCurrencySymbol ?? ''}${provider.depositFees.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: Theme.of(context).extension<AppColors>()!.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
          const Divider(height: 24, thickness: 1, color: Colors.grey),
          _buildInfoRow(
            'Total Amount (incl. fee)',
            provider.isLoading
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).extension<AppColors>()!.primary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    provider.amountCharge == '0.0'
                        ? "${provider.toCurrencySymbol ?? ''}0.00"
                        : "${provider.toCurrencySymbol ?? ''}${provider.amountCharge}",
                    style: TextStyle(
                      color: Theme.of(context).extension<AppColors>()!.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
          const Divider(height: 24, thickness: 1, color: Colors.grey),
          _buildInfoRow(
            'Conversion Amount',
            provider.isLoading
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).extension<AppColors>()!.primary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    provider.conversionAmount == '0.0'
                        ? "${widget.logic.mFromCurrencySymbol ?? ''}0.00"
                        : "${widget.logic.mFromCurrencySymbol ?? ''}${provider.conversionAmount}",
                    style: TextStyle(
                      color: Theme.of(context).extension<AppColors>()!.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).extension<AppColors>()!.primary,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        value,
      ],
    );
  }

  Widget _buildAddMoneyButton(BuildContext context, AddMoneyProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          shadowColor: Theme.of(context)
              .extension<AppColors>()!
              .primary
              .withOpacity(0.4),
        ),
        onPressed: provider.isLoading || widget.logic.isAddLoading
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  if (provider.selectedSendCurrency == null) {
                    CustomSnackBar.showSnackBar(
                        context: context,
                        message: "Please select a currency",
                        color:
                            Theme.of(context).extension<AppColors>()!.primary);
                    return;
                  }
                  if (provider.selectedTransferType == null) {
                    CustomSnackBar.showSnackBar(
                        context: context,
                        message: "Please select a transfer type",
                        color:
                            Theme.of(context).extension<AppColors>()!.primary);
                    return;
                  }
                  if (provider.amountCharge == '0.0' ||
                      provider.conversionAmount == '0.0') {
                    CustomSnackBar.showSnackBar(
                        context: context,
                        message:
                            "Please enter a valid amount and wait for calculation",
                        color:
                            Theme.of(context).extension<AppColors>()!.primary);
                    return;

                    // if (provider.selectedTransferType ==
                    //     "UPI * Currently Support Only INR Currency") {
                    //   if (provider.selectedSendCurrency == "INR") {
                    //     widget.logic.openRazorpay(context);
                    //   } else {
                    //     CustomSnackBar.showSnackBar(
                    //         context: context,
                    //         message: "UPI supports only INR",
                    //         color: Theme.of(context).extension<AppColors>()!.primary);
                    //   }
                  } else if (provider.selectedTransferType ==
                      "Stripe * Support Other Currencies") {
                    widget.logic.handleStripePayment(context, _formKey);
                  } else {
                    CustomSnackBar.showSnackBar(
                        context: context,
                        message: "Unsupported Payment Method",
                        color:
                            Theme.of(context).extension<AppColors>()!.primary);
                    return;
                  }
                }
              },
        child: widget.logic.isAddLoading
            ? Center(
                child: const SizedBox(
                  height: 20,
                  width: 20,
                  child: SpinKitWaveSpinner(
                    color: Colors.white,
                    size: 70,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.add, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Add Money',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                'Select Transfer Type',
                style: TextStyle(
                  color: Theme.of(context).extension<AppColors>()!.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildTransferOptions('Stripe * Support Other Currencies',
                  'assets/icons/stripe.png', isTransfer, provider),
              // _buildTransferOptions('UPI * Currently Support Only INR Currency',
              //     'assets/icons/upi.png', isTransfer, provider),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransferOptions(String type, String logoPath, bool isTransfer,
      AddMoneyProvider provider) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Image.asset(
        logoPath,
        height: 24,
        width: 24,
        errorBuilder: (context, error, stackTrace) {
          print('Failed to load transfer type image for $type: $error');
          return const Icon(CupertinoIcons.exclamationmark_triangle,
              color: Colors.red);
        },
      ),
      title: Text(
        type,
        style: TextStyle(
          color: Theme.of(context).extension<AppColors>()!.primary,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
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

  String _getCurrencyName(String currencyCode) {
    const currencyNames = {
      'USD': 'United States Dollar',
      'INR': 'Indian Rupee',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'JPY': 'Japanese Yen',
      'AUD': 'Australian Dollar',
      'CAD': 'Canadian Dollar',
      'CHF': 'Swiss Franc',
      'CNY': 'Chinese Yuan',
      'NZD': 'New Zealand Dollar',
    };
    return currencyNames[currencyCode] ?? currencyCode;
  }

  String _getCurrencySymbol(String? currencyCode) {
    if (currencyCode == null) return '';
    if (currencyCode == "AWG") return 'ƒ';
    return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
  }
}
