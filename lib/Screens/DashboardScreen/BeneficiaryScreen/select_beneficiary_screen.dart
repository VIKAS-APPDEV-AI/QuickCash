import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickcash/Screens/DashboardScreen/BeneficiaryScreen/addBeneficiaryModel/addBeneficiaryApi.dart';
import 'package:quickcash/Screens/DashboardScreen/BeneficiaryScreen/addBeneficiaryModel/addBeneficiaryModel.dart';
import 'package:quickcash/Screens/DashboardScreen/BeneficiaryScreen/beneficiaryCurrencyModel/beneficiaryCurrencyApi.dart';
import 'package:quickcash/Screens/DashboardScreen/BeneficiaryScreen/beneficiaryCurrencyModel/beneficiaryCurrencyModel.dart';
import 'package:quickcash/Screens/DashboardScreen/BeneficiaryScreen/show_beneficiary.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/DashboardTicketScreen.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../constants.dart';
import '../../../util/customSnackBar.dart';

class SelectBeneficiaryScreen extends StatefulWidget {
  const SelectBeneficiaryScreen({super.key});

  @override
  State<SelectBeneficiaryScreen> createState() => _SelectBeneficiaryScreen();
}

class _SelectBeneficiaryScreen extends State<SelectBeneficiaryScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController country = TextEditingController();
  final TextEditingController mFullName = TextEditingController();
  final TextEditingController mEmail = TextEditingController();
  final TextEditingController mMobileNo = TextEditingController();
  final TextEditingController mBankName = TextEditingController();
  final TextEditingController mIban = TextEditingController();
  final TextEditingController mBicCode = TextEditingController();
  final TextEditingController mAddress = TextEditingController();

  final BeneficiaryCurrencyApi _beneficiaryCurrencyApi =
      BeneficiaryCurrencyApi();
  final AddBeneficiaryApi _addBeneficiaryApi = AddBeneficiaryApi();
  String? selectedCurrency;
  String? mCurrencyCode;
  List<BeneficiaryCurrencyData> currency = [];

  String? selectedCountry;
  bool isLoading = false;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller and fade animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _animationController!.forward();
    mGetCurrency();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    mFullName.dispose();
    mEmail.dispose();
    mMobileNo.dispose();
    mBankName.dispose();
    mIban.dispose();
    mBicCode.dispose();
    mAddress.dispose();
    country.dispose();
    super.dispose();
  }

  Future<void> mGetCurrency() async {
    try {
      final response = await _beneficiaryCurrencyApi.beneficiaryCurrencyApi();
      if (response.data.isNotEmpty) {
        setState(() {
          currency = response.data;
        });
      }
    } catch (e) {
      CustomSnackBar.showSnackBar(
        context: context,
        message: "Failed to load currencies",
        color: Colors.red,
      );
    }
  }

  Future<void> mAddBeneficiary() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCountry != null) {
        setState(() {
          isLoading = true;
        });

        try {
          final request = AddBeneficiaryRequest(
            userId: AuthManager.getUserId(),
            name: mFullName.text,
            email: mEmail.text,
            address: mAddress.text,
            mobile: mMobileNo.text,
            iban: mIban.text,
            bicCode: mBicCode.text,
            country: selectedCountry!,
            rType: "Individual",
            currency: mCurrencyCode!,
            status: true,
            bankName: mBankName.text,
          );
          final response = await _addBeneficiaryApi.addBeneficiaryApi(request);

          if (response.message == "Receipient is added Successfully!!!") {
            setState(() {
              isLoading = false;
              CustomSnackBar.showSnackBar(
                context: context,
                message: "Beneficiary is added Successfully",
                color: Colors.green,
              );
              mFullName.clear();
              mEmail.clear();
              mMobileNo.clear();
              mBankName.clear();
              mIban.clear();
              mBicCode.clear();
              mAddress.clear();
              selectedCountry = null;
              selectedCurrency = null;
              mCurrencyCode = null;
            });
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const ShowBeneficiaryScreen(),
              ),
            );
          } else {
            setState(() {
              CustomSnackBar.showSnackBar(
                context: context,
                message: "We are facing some issue!",
                color: Colors.red,
              );
              isLoading = false;
            });
          }
        } catch (error) {
          setState(() {
            isLoading = false;
            CustomSnackBar.showSnackBar(
              context: context,
              message: "Something went wrong!",
              color: Theme.of(context).extension<AppColors>()!.primary,
            );
          });
        }
      } else {
        CustomSnackBar.showSnackBar(
          context: context,
          message: "Please Select Country",
          color: Theme.of(context).extension<AppColors>()!.primary,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).extension<AppColors>()!.primary;

    return Scaffold(
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
        title: const Text(
          "Add Beneficiary",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bell_fill),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600
                    ? constraints.maxWidth * 0.15
                    : 16.0,
                vertical: 24.0,
              ),
              child: _fadeAnimation != null
                  ? FadeTransition(
                      opacity: _fadeAnimation!,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Personal Details"),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: mFullName,
                              label: "Full Name",
                              icon: Icons.person,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter your full name';
                                if (value.length < 3)
                                  return 'Name must be at least 3 characters long';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: mEmail,
                              label: "Email",
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter your email';
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: mMobileNo,
                              label: "Mobile Number",
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter your mobile number';
                                if (value.length < 10 || value.length > 15) {
                                  return 'Mobile number must be between 10 to 15 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle("Bank Details"),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: mBankName,
                              label: "Bank Name",
                              icon: Icons.account_balance,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter your bank name';
                                if (value.length < 3)
                                  return 'Bank name must be at least 3 characters long';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: mIban,
                              label: "IBAN / Account Number",
                              icon: Icons.credit_card,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter your IBAN or account number';
                                if (value.length < 8)
                                  return 'IBAN/AC must be at least 8 characters long';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: mBicCode,
                              label: "Routing/IFSC/BIC/Swift Code",
                              icon: Icons.code,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter the routing number or equivalent';
                                if (value.length < 6)
                                  return 'Routing number must be at least 6 characters long';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle("Location Details"),
                            const SizedBox(height: 16),
                            _buildCountryPicker(primaryColor),
                            const SizedBox(height: 16),
                            _buildCurrencyPicker(primaryColor),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: mAddress,
                              label: "Recipient Address",
                              icon: Icons.location_on,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter the recipient address';
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            if (isLoading)
                              Center(
                                child: CircularProgressIndicator(
                                    color: primaryColor),
                              ),
                            const SizedBox(height: 16),
                            Center(
                              child: AnimatedScaleButton(
                                onPressed: isLoading ? null : mAddBeneficiary,
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        constraints.maxWidth > 600 ? 18 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).extension<AppColors>()!.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        maxLines: maxLines,
        minLines: 1,
        cursorColor: Theme.of(context).extension<AppColors>()!.primary,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Theme.of(context).extension<AppColors>()!.primary),
          prefixIcon: Icon(icon,
              color: Theme.of(context).extension<AppColors>()!.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).extension<AppColors>()!.primary,
                width: 2),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor.withOpacity(0.1),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildCountryPicker(Color primaryColor) {
    return GestureDetector(
      onTap: () {
        showCountryPicker(
          context: context,
          onSelect: (Country country) {
            setState(() {
              selectedCountry = country.name;
              this.country.text = country.name;
            });
          },
        );
      },
      child: TextFormField(
        controller: country,
        enabled: false,
        cursorColor: primaryColor,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
        decoration: InputDecoration(
          labelText: 'Country',
          hintText: selectedCountry ?? "Select Country",
          hintStyle: TextStyle(color: Theme.of(context).hintColor),
          prefixIcon: Icon(Icons.public, color: primaryColor),
          suffixIcon: Icon(Icons.arrow_drop_down, color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor.withOpacity(0.1),
        ),
        validator: (value) {
          if (selectedCountry == null) return 'Please select a country';
          return null;
        },
      ),
    );
  }

  Widget _buildCurrencyPicker(Color primaryColor) {
    return GestureDetector(
      onTap: () {
        if (currency.isNotEmpty) {
          showDialog<BeneficiaryCurrencyData>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text('Select Currency',
                    style: TextStyle(color: primaryColor)),
                content: SingleChildScrollView(
                  child: ListBody(
                    children:
                        currency.map((BeneficiaryCurrencyData currencyItem) {
                      return ListTile(
                        title: Text(
                          currencyItem.currencyName,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                        onTap: () {
                          Navigator.pop(context, currencyItem);
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ).then((BeneficiaryCurrencyData? selectedItem) {
            if (selectedItem != null) {
              setState(() {
                selectedCurrency = selectedItem.currencyName;
                mCurrencyCode = selectedItem.currencyCode;
              });
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
          color: Theme.of(context).cardColor.withOpacity(0.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.monetization_on, color: primaryColor),
                const SizedBox(width: 12),
                Text(
                  selectedCurrency ?? "Select Currency",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              ],
            ),
            Icon(Icons.arrow_drop_down, color: primaryColor),
          ],
        ),
      ),
    );
  }
}

class AnimatedScaleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const AnimatedScaleButton(
      {super.key, required this.onPressed, required this.child});

  @override
  _AnimatedScaleButtonState createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).extension<AppColors>()!.primary;
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        if (widget.onPressed != null) widget.onPressed!();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
