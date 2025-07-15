import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:quickcash/Screens/CardsScreen/card_screen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/Screens/CardsScreen/addCardModel/addCardApi.dart';
import 'package:quickcash/model/currencyApiModel/Model/currencyModel.dart';
import 'package:quickcash/model/currencyApiModel/Services/currencyApi.dart';
import 'package:quickcash/util/auth_manager.dart';

class AddCardScreen extends StatefulWidget {
  final VoidCallback onCardAdded;

  const AddCardScreen({super.key, required this.onCardAdded});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final AddCardApi _addCardApi = AddCardApi();
  final CurrencyApi _currencyApi = CurrencyApi();

  String? selectedCurrency;
  List<CurrencyListsData> currency = [];
  TextEditingController name = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrency();
  }

  Future<void> _getCurrency() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _currencyApi.currencyApi();
      if (response.currencyList != null && response.currencyList!.isNotEmpty) {
        setState(() {
          currency = response.currencyList!;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No currencies found';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load currencies';
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
          widget.onCardAdded(); // Call the callback
        });
        // Navigate to CardsScreen and remove current screen from stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CardsScreen()),
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
          MaterialPageRoute(builder: (context) => CardsScreen()),
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
          CupertinoPageRoute(builder: (context) => CardsScreen()),
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
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                'You already added this card.\nWe are navigating you to Card Screen.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 4));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Virtual Card",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Add virtual card details here",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Container(
                  width: double.infinity,
                  height: 200.0,
                  padding: const EdgeInsets.all(smallPadding),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
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
                        child: Image.asset('assets/icons/chip.png'),
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
                cursorColor: kPrimaryColor,
                style: const TextStyle(color: kPrimaryColor),
                decoration: InputDecoration(
                  labelText: "Your Name",
                  labelStyle: const TextStyle(color: kPrimaryColor, fontSize: 16),
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
              GestureDetector(
                onTap: () {
                  if (currency.isNotEmpty) {
                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                    Offset offset = renderBox.localToGlobal(Offset.zero);
                    showMenu<String>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        offset.dx,
                        offset.dy + renderBox.size.height,
                        offset.dx + renderBox.size.width,
                        0.0,
                      ),
                      items: currency.map((CurrencyListsData currencyItem) {
                        return PopupMenuItem<String>(
                          value: currencyItem.currencyCode,
                          child: Text(currencyItem.currencyCode!),
                        );
                      }).toList(),
                    ).then((String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCurrency = newValue;
                        });
                      }
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 15.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kPrimaryColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedCurrency ?? "Select Currency",
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                    ],
                  ),
                ),
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
                    ? const SpinKitWaveSpinner(color: kPrimaryColor, size: 75)
                    : SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: _addCard,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
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