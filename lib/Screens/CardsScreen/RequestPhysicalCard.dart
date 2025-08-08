import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:quickcash/Screens/CardsScreen/PhysicalCardConfirmation.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/DashboardTicketScreen.dart';
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const DeliveryProcessingScreen()),
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
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.only(bottom: defaultPadding),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          cursorColor: Theme.of(context).extension<AppColors>()!.primary,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).extension<AppColors>()!.primary, width: 2),
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Dark theme for elegance
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A1A),
                Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.8),
                Colors.black,
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: const Text(
            "Request Physical Card",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
        ),
         actions: [
          IconButton(
            icon: Icon(CupertinoIcons.bell_fill),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.05), // Responsive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.02),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 600),
                    child: const Text(
                      "Add Physical Card Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(179, 7, 7, 7),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: size.height * 0.24, // Responsive height
                        padding: const EdgeInsets.all(smallPadding),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).extension<AppColors>()!.primary,
                              Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.7),
                              Colors.black87,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
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
                                width: size.width * 0.1,
                              ),
                            ),
                            Positioned(
                              top: size.height * 0.1,
                              left: 10,
                              child: const Text(
                                "••••    ••••    ••••    ••••",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'OCRA',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: defaultPadding,
                              left: defaultPadding,
                              child: Text(
                                nameController.text.isEmpty
                                    ? "Your Name Here"
                                    : nameController.text.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: size.height * 0.05,
                              right: defaultPadding,
                              child: Text(
                                "valid thru",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: size.width * 0.035,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: defaultPadding,
                              right: 35,
                              child: Text(
                                '••/••',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
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
                  SizedBox(height: size.height * 0.02),
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: GestureDetector(
                      onTap: () {
                        if (currency.isNotEmpty) {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
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
                                child: Text(
                                  currencyItem.currencyCode!,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                            color: Colors.white,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                          horizontal: 16.0,
                          vertical: 15.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedCurrency ?? "Select Currency",
                              style: TextStyle(
                                color: selectedCurrency == null
                                    ? Colors.white70
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Theme.of(context).extension<AppColors>()!.primary,
                              size: size.width * 0.07,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    SizedBox(height: size.height * 0.02),
                    FadeIn(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: size.height * 0.04),
                  Center(
                    child: isLoading
                        ? FadeIn(
                            duration: const Duration(milliseconds: 300),
                            child: SpinKitWaveSpinner(
                              color: Theme.of(context).extension<AppColors>()!.primary,
                              size: size.width * 0.15,
                            ),
                          )
                        : ZoomIn(
                            duration: const Duration(milliseconds: 600),
                            child: SizedBox(
                              width: size.width * 0.5,
                              child: ElevatedButton(
                                onPressed: _addCard,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
                                  padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.02,
                                    horizontal: size.width * 0.05,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                  shadowColor: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.4),
                                ),
                                child: const Text(
                                  'Submit Request',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}