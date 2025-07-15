import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:quickcash/Screens/CardsScreen/PhysicalCardConfirmation.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/model/currencyApiModel/Model/currencyModel.dart';
import 'package:quickcash/model/currencyApiModel/Services/currencyApi.dart';
import 'package:quickcash/Screens/CardsScreen/addCardModel/addCardApi.dart';
import 'package:quickcash/util/auth_manager.dart';

class RequestPhysicalCard extends StatefulWidget {
  final VoidCallback onCardAdded;

  const RequestPhysicalCard({super.key, required this.onCardAdded});

  @override
  State<RequestPhysicalCard> createState() => _RequestPhysicalCardState();
}

class _RequestPhysicalCardState extends State<RequestPhysicalCard> {
  final AddCardApi _addCardApi = AddCardApi();
  final CurrencyApi _currencyApi = CurrencyApi();

  String? selectedCurrency;
  List<CurrencyListsData> currency = [];
  
  // Text Controllers for all required fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrency();
  }

  Future<void> _getCurrency() async {
    try {
      final response = await _currencyApi.currencyApi();
      if (response.currencyList != null && response.currencyList!.isNotEmpty) {
        setState(() {
          currency = response.currencyList!;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load currencies';
      });
    }
  }

  Future<void> _addCard() async {
    // Validation
    if (selectedCurrency == null) {
      setState(() => errorMessage = 'Please select a currency');
      return;
    }
    if (nameController.text.isEmpty) {
      setState(() => errorMessage = 'Please enter your name');
      return;
    }
    if (addressLine1Controller.text.isEmpty) {
      setState(() => errorMessage = 'Please enter address line 1');
      return;
    }
    if (cityController.text.isEmpty) {
      setState(() => errorMessage = 'Please enter city');
      return;
    }
    if (stateController.text.isEmpty) {
      setState(() => errorMessage = 'Please enter state/province');
      return;
    }
    if (postalCodeController.text.isEmpty) {
      setState(() => errorMessage = 'Please enter postal code');
      return;
    }
    if (countryController.text.isEmpty) {
      setState(() => errorMessage = 'Please enter country');
      return;
    }
    if (phoneController.text.isEmpty) {
      setState(() => errorMessage = 'Please enter phone number');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _addCardApi.addCardApi(
        AuthManager.getUserId(),
        nameController.text,
        selectedCurrency!,
        // You might want to add these additional fields to your API call
        // addressLine1: addressLine1Controller.text,
        // addressLine2: addressLine2Controller.text,
        // city: cityController.text,
        // state: stateController.text,
        // postalCode: postalCodeController.text,
        // country: countryController.text,
        // phone: phoneController.text,
      );

      if (response.message == "Card is added Successfully!!!") {
        setState(() {
          isLoading = false;
          nameController.clear();
          addressLine1Controller.clear();
          addressLine2Controller.clear();
          cityController.clear();
          stateController.clear();
          postalCodeController.clear();
          countryController.clear();
          phoneController.clear();
          widget.onCardAdded();
        });
        // Navigate to processing screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DeliveryProcessingScreen()),
        );
      } else if (response.message ==
          "Same Currency Account is already added in our record") {
        setState(() {
          isLoading = false;
          errorMessage = 'This currency account already exists';
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to add card';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        cursorColor: kPrimaryColor,
        style: const TextStyle(color: kPrimaryColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: kPrimaryColor, fontSize: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Request Physical Card",
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
                "Add Physical Card Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  height: 200.0,
                  padding: const EdgeInsets.all(smallPadding),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(16),
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
                          nameController.text.isEmpty ? "Your Name Here" : nameController.text,
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
              const SizedBox(height: 20),
              _buildTextField(
                controller: nameController,
                label: "Cardholder Name",
              ),
              _buildTextField(
                controller: addressLine1Controller,
                label: "Address Line 1",
              ),
              _buildTextField(
                controller: addressLine2Controller,
                label: "Address Line 2 (Optional)",
              ),
              _buildTextField(
                controller: cityController,
                label: "City",
              ),
              _buildTextField(
                controller: stateController,
                label: "State/Province",
              ),
              _buildTextField(
                controller: postalCodeController,
                label: "Postal Code",
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: countryController,
                label: "Country",
              ),
              _buildTextField(
                controller: phoneController,
                label: "Phone Number",
                keyboardType: TextInputType.phone,
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
                    ).then((String?

 newValue) {
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
              const SizedBox(height: 30),
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
                            'Submit Request',
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

// Assuming this is your DeliveryProcessingScreen from previous code