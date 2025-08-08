import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:quickcash/Screens/CardsScreen/card_screen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/Screens/CardsScreen/addCardModel/addCardApi.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListApi.dart';
import 'package:quickcash/util/auth_manager.dart';

class AddCardScreen extends StatefulWidget {
  final VoidCallback onCardAdded;

  const AddCardScreen({super.key, required this.onCardAdded});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final AddCardApi _addCardApi = AddCardApi();
  final AccountsListApi _accountsListApi = AccountsListApi();

  String? selectedCurrency;
  List<String> currencies = [];
  TextEditingController name = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrenciesFromAccounts();
  }

  Future<void> _getCurrenciesFromAccounts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _accountsListApi.accountsListApi();
      if (response.accountsList != null && response.accountsList!.isNotEmpty) {
        final uniqueCurrencies = response.accountsList!
            .map((account) => account.currency!)
            .toSet()
            .toList();
        setState(() {
          currencies = uniqueCurrencies;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No accounts found. Please add an account first.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load account currencies: $e';
      });
    }
  }

  Future<void> _addCard() async {
    if (selectedCurrency == null) {
      setState(() {
        errorMessage = 'Please select a currency';
      });
      return;
    }
    if (name.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your name';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _addCardApi.addCardApi(
        AuthManager.getUserId(),
        name.text,
        selectedCurrency!,
      );

      if (response.message == "Card is added Successfully!!!") {
        setState(() {
          isLoading = false;
          name.clear();
          widget.onCardAdded();
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CardsScreen()),
        );
      } else if (response.message ==
          "Same Currency Account is already added in our record") {
        setState(() {
          isLoading = false;
          errorMessage = 'Same Currency Account is already added in our record';
        });
        await _showRedirectDialog();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CardsScreen()),
        );
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to add card: ${response.message}';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $error';
      });
      if (error.toString().contains("Same Currency Account is already added in our record")) {
        await _showRedirectDialog();
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const CardsScreen()),
        );
      }
    }
  }

  Future<void> _showRedirectDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).extension<AppColors>()!.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'You already added this card.\nWe are navigating you to Card Screen.',
                textAlign: TextAlign.center,
                style:  TextStyle(
                  color: Theme.of(context).extension<AppColors>()!.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final padding = isSmallScreen ? defaultPadding : defaultPadding * 1.5;

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
                Color.fromARGB(255, 6, 6, 6),
                Color(0xFF8A2BE2),
                Color(0x00000000),
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Virtual Card",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bell),
            onPressed: () => print('Notifications tapped'),
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.headphones),
            onPressed: () => print('Support tapped'),
            tooltip: 'Support',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
               Text(
                "Add virtual card details here",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).extension<AppColors>()!.primary,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  height: 200.0,
                  padding: const EdgeInsets.all(smallPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[700]!,
                        Colors.grey[900]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 25,
                        left: defaultPadding,
                        child: Image.asset(
                          'assets/icons/chip.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const Positioned(
                        top: 80,
                        left: 10,
                        child: Text(
                          "••••    ••••    ••••    ••••",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'OCRA',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: defaultPadding,
                        left: defaultPadding,
                        child: Text(
                          name.text.isEmpty ? "Your Name Here" : name.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 38,
                        right: defaultPadding,
                        child: Text(
                          "valid thru",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: defaultPadding,
                        right: 35,
                        child: Text(
                          '••/••',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 45),
              TextFormField(
                controller: name,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                cursorColor: Theme.of(context).extension<AppColors>()!.primary,
                style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary),
                decoration: InputDecoration(
                  labelText: "Your Name",
                  labelStyle: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: defaultPadding),
              DropdownButtonFormField<String>(
                value: selectedCurrency,
                hint:  Text(
                  "Select Currency",
                  style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: 16),
                ),
                icon:  Icon(Icons.arrow_drop_down, color: Theme.of(context).extension<AppColors>()!.primary),
                style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: 16),
                decoration: InputDecoration(
                  labelText: "Currency",
                  labelStyle: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:  BorderSide(color: Theme.of(context).extension<AppColors>()!.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:  BorderSide(color: Theme.of(context).extension<AppColors>()!.primary, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:  BorderSide(color: Theme.of(context).extension<AppColors>()!.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                ),
                items: currencies.isNotEmpty
                    ? currencies.map((String currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(
                            currency,
                            style:  TextStyle(
                              color: Theme.of(context).extension<AppColors>()!.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList()
                    : [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            "No currencies available",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                onChanged: currencies.isNotEmpty
                    ? (String? newValue) {
                        setState(() {
                          selectedCurrency = newValue;
                        });
                      }
                    : null,
                isExpanded: true,
                dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                menuMaxHeight: 300,
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
              ),
              // if (currencies.isEmpty && errorMessage == null)
              //   const Padding(
              //     padding: EdgeInsets.only(top: 8.0),
              //     child: Text(
              //       "No account currencies available",
              //       style: TextStyle(color: Colors.red, fontSize: 14),
              //     ),
              //   ),
              // if (errorMessage != null) ...[
              //   const SizedBox(height: 20),
              //   Text(
              //     errorMessage!,
              //     style: const TextStyle(color: Colors.red),
              //   ),
              // ],
              const SizedBox(height: 45),
              Center(
                child: isLoading
                    ?  SpinKitWaveSpinner(color: Theme.of(context).extension<AppColors>()!.primary, size: 75)
                    : SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: _addCard,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}