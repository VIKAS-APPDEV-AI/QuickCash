import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services package
import 'package:quickcash/Screens/UserProfileScreen/AdditionalInformationScreen/model/additionalInformationApi.dart';
import 'package:quickcash/util/apiConstants.dart';
import '../../../../constants.dart';

class AdditionalInfoScreen extends StatefulWidget {
  const AdditionalInfoScreen({super.key});

  @override
  State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final AdditionalInformationApi _additionalInformationApi =
      AdditionalInformationApi();

  // Add text controllers to bind to the text fields
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _documentSubmittedController =
      TextEditingController();
  final TextEditingController _documentNoController = TextEditingController();
  final TextEditingController _referralLinkController = TextEditingController();

  void _copyReferralLink() {
    Clipboard.setData(ClipboardData(text: _referralLinkController.text))
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Referral link copied to clipboard!')),
      );
    });
  }

  @override
  void dispose() {
    _stateController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _documentSubmittedController.dispose();
    _documentNoController.dispose();
    _referralLinkController.dispose();
    super.dispose();
  }

  // Api Integration -------
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    mAdditionalInformation();
  }

  Future<void> mAdditionalInformation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _additionalInformationApi.additionalInformation();

      if (response.state != null) {
        _stateController.text = response.state!;
      }
      if (response.city != null) {
        _cityController.text = response.city!;
      }
      if (response.postalCode != null) {
        _zipCodeController.text = response.postalCode!;
      }

      if (response.documentSubmitted != null) {
        // Capitalize the first letter of 'documentSubmitted' to 'Document Submitted'
        _documentSubmittedController.text =
            mCapitalizeFirstLetter(response.documentSubmitted!);
      }

      if (response.documentNo != null) {
        _documentNoController.text = response.documentNo!;
      }

      // Check if referralDetails is not null and not empty
      if (response.referralDetails != null &&
          response.referralDetails!.isNotEmpty) {
        final referralCode =
            response.referralDetails!.first.referralCode?.toString() ?? '';
        final referralLink = '${ApiConstants.baseReferralCodeUrl}$referralCode';
        _referralLinkController.text = referralLink;
      } else {
        // Handle the case where referralDetails is empty or null
        _referralLinkController.text = ''; // Or set a default value
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  // Helper method to capitalize the first letter of a string
  String mCapitalizeFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding),

                  if (isLoading)
                    const CircularProgressIndicator(
                      color: kPrimaryColor,
                    ),
                  // Show loading indicator
                  if (errorMessage !=
                      null) // Show error message if there's an error
                    Text(errorMessage!,
                        style: const TextStyle(color: Colors.red)),
                  const SizedBox(
                    height: defaultPadding,
                  ),

                  // State
                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: _stateController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value) {},
                    readOnly: true,
                    style: const TextStyle(color: kPrimaryColor),
                    decoration: InputDecoration(
                      labelText: "State",
                      labelStyle: const TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(),
                      ),
                    ),
                  ),

                  // City
                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: _cityController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value) {},
                    readOnly: true,
                    style: const TextStyle(color: kPrimaryColor),
                    decoration: InputDecoration(
                      labelText: "City",
                      labelStyle: const TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(),
                      ),
                    ),
                  ),

                  // Zip Code
                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: _zipCodeController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value) {},
                    readOnly: true,
                    style: const TextStyle(color: kPrimaryColor),
                    decoration: InputDecoration(
                      labelText: "Zip Code",
                      labelStyle: const TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(),
                      ),
                    ),
                  ),

                  // Document Submitted
                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: _documentSubmittedController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value) {},
                    readOnly: true,
                    style: const TextStyle(color: kPrimaryColor),
                    decoration: InputDecoration(
                      labelText: "Document Submitted",
                      labelStyle: const TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(),
                      ),
                    ),
                  ),

                  // Document Number
                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: _documentNoController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value) {},
                    readOnly: true,
                    style: const TextStyle(color: kPrimaryColor),
                    decoration: InputDecoration(
                      labelText: "Document Number",
                      labelStyle: const TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(),
                      ),
                    ),
                  ),

                  // Referral Link
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _referralLinkController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value) {},
                    readOnly: true,
                    maxLines: 4,
                    minLines: 1,
                    style: const TextStyle(color: kPrimaryColor),
                    decoration: InputDecoration(
                      labelText: "Referral Link",
                      labelStyle: const TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.copy, color: kPrimaryColor),
                        onPressed: _copyReferralLink, // Call the copy function
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
