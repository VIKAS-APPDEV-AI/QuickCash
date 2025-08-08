import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:quickcash/Screens/CardsScreen/card_screen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/Screens/CardsScreen/addCardModel/addCardApi.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListApi.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListModel.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'dart:ui';

class CustomCurrencyDropdown extends StatefulWidget {
  final List<AccountsListsData> accounts;
  final String? selectedCurrency;
  final Function(String) onCurrencySelected;

  const CustomCurrencyDropdown({
    super.key,
    required this.accounts,
    this.selectedCurrency,
    required this.onCurrencySelected,
  });

  @override
  _CustomCurrencyDropdownState createState() => _CustomCurrencyDropdownState();
}

class _CustomCurrencyDropdownState extends State<CustomCurrencyDropdown> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleOverlay(BuildContext context) {
    if (_isOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
    } else {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
      _isOpen = true;
    }
    setState(() {});
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _overlayEntry?.remove();
                _overlayEntry = null;
                _isOpen = false;
                setState(() {});
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 8,
            width: size.width,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: widget.accounts.length,
                      itemBuilder: (context, index) {
                        final account = widget.accounts[index];
                        return _CurrencyMenuItem(
                          account: account,
                          onTap: () {
                            widget.onCurrencySelected(account.currency!);
                            _overlayEntry?.remove();
                            _overlayEntry = null;
                            _isOpen = false;
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final fontSize = isSmallScreen ? 16.0 : 18.0;

    return GestureDetector(
      onTap: () {
        _controller.forward().then((_) => _controller.reverse());
        if (widget.accounts.isNotEmpty) {
          _toggleOverlay(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No account currencies available'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(color: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (widget.selectedCurrency != null)
                    CountryFlag.fromCountryCode(
                      widget.accounts
                          .firstWhere((account) => account.currency == widget.selectedCurrency)
                          .country!,
                      width: 24,
                      height: 24,
                      shape: const Circle(),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    widget.selectedCurrency ?? "Select Currency",
                    style: TextStyle(
                      color: Theme.of(context).extension<AppColors>()!.primary,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Theme.of(context).extension<AppColors>()!.primary,
                size: isSmallScreen ? 24 : 28,
              ),
            ],
          ),
        ),
        ),
      );
    }
}

class _CurrencyMenuItem extends StatefulWidget {
  final AccountsListsData account;
  final VoidCallback onTap;

  const _CurrencyMenuItem({required this.account, required this.onTap});

  @override
  _CurrencyMenuItemState createState() => _CurrencyMenuItemState();
}

class _CurrencyMenuItemState extends State<_CurrencyMenuItem> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final fontSize = isSmallScreen ? 14.0 : 16.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CountryFlag.fromCountryCode(
                  widget.account.country!,
                  width: 24,
                  height: 24,
                  shape: const Circle(),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.account.currency!,
                  style: TextStyle(
                    color: Theme.of(context).extension<AppColors>()!.primary,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddCardScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onCardAdded;

  const AddCardScreen({super.key, required this.onCardAdded});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final AddCardApi _addCardApi = AddCardApi();
  final AccountsListApi _accountsListApi = AccountsListApi();

  String? selectedCurrency;
  List<AccountsListsData> accounts = [];
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
        setState(() {
          accounts = response.accountsList!;
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
          widget.onCardAdded({
            'name': name.text,
            'currency': selectedCurrency!,
          });
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CardsScreen()),
        );
      } else if (response.message == "Same Currency Account is already added in our record") {
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
          MaterialPageRoute(builder: (context) => const CardsScreen()),
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
              CustomCurrencyDropdown(
                accounts: accounts,
                selectedCurrency: selectedCurrency,
                onCurrencySelected: (String currency) {
                  setState(() {
                    selectedCurrency = currency;
                  });
                },
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
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