import 'dart:io';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/SettingsScreen/settingsModel/settingsApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/SettingsScreen/updateSettingsModel/updateSettingsApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/SettingsScreen/updateSettingsModel/updateSettingsModel.dart';
import 'package:quickcash/constants.dart';
import '../../../../util/apiConstants.dart';
import '../../../../util/auth_manager.dart';
import '../../../../util/customSnackBar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsApi _settingsApi = SettingsApi();
  final SettingsUpdateApi _settingsUpdateApi = SettingsUpdateApi();

  TextEditingController country = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController companyAddressController = TextEditingController();
  TextEditingController invoicePrefixController = TextEditingController();
  TextEditingController regardsTextController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  String? imagePath;
  String? logoUrl;
  String? settingsId;

  // Create a GlobalKey to manage form state
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;

  bool isUpdateLoading = false;

  @override
  void initState() {
    mSettingsDetails("Yes");
    super.initState();
  }

  Future<void> mSettingsDetails(String s) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _settingsApi.settingsApi();
      setState(() {
        companyNameController.text = response.companyName ?? '';
        mobileController.text = response.mobile ?? '';
        country.text = response.invoiceCountry ?? '';
        state.text = response.state ?? '';
        city.text = response.city ?? '';
        postalCodeController.text = response.zipcode ?? '';
        companyAddressController.text = response.address ?? '';
        invoicePrefixController.text = response.prefix ?? '';
        regardsTextController.text = response.regardstext ?? '';
        logoUrl = response.logo != null
            ? '${ApiConstants.baseSettingsImageUrl}${AuthManager.getUserId()}/${response.logo}'
            : null;
        settingsId = response.id ?? '';

        isLoading = false;
        errorMessage = null;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  Future<void> mUpdateSettings() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isUpdateLoading = true;
      });

      try {
        final request = UpdateSettingsRequest(
          userId: AuthManager.getUserId(),
          country: country.text,
          companyName: companyNameController.text,
          mobileNo: mobileController.text,
          state: state.text,
          city: city.text,
          zipCode: postalCodeController.text,
          address: companyAddressController.text,
          prefix: invoicePrefixController.text,
          regardsText: regardsTextController.text,
          logo: imagePath != null ? File(imagePath!) : null,
        );

        if (settingsId == null || settingsId!.isEmpty) {
          setState(() {
            isUpdateLoading = false;
            errorMessage = "Settings ID is missing.";
            CustomSnackBar.showSnackBar(
              context: context,
              message: "Settings ID is missing.",
              color: kRedColor,
            );
          });
          return;
        }

        final response = await _settingsUpdateApi.updateSettingsApi(request, settingsId!);

        if (response.message == "Data has been saved !!!") {
          setState(() {
            isUpdateLoading = false;
            errorMessage = null;
            mSettingsDetails("No");
            CustomSnackBar.showSnackBar(
              context: context,
              message: "Settings has been updated successfully!",
              color: kGreenColor,
            );
          });
        } else {
          setState(() {
            isUpdateLoading = false;
            errorMessage = "Failed to update settings.";
            CustomSnackBar.showSnackBar(
              context: context,
              message: "We are facing some issue!",
              color: kRedColor,
            );
          });
        }
      } catch (error) {
        setState(() {
          isUpdateLoading = false;
          errorMessage = error.toString();
          CustomSnackBar.showSnackBar(
            context: context,
            message: errorMessage!,
            color: kRedColor,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: largePadding),

                      if (errorMessage != null)
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),

                      // Company Name
                      TextFormField(
                        controller: companyNameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        cursorColor: kPrimaryColor,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your company name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Company Name",
                          labelStyle: const TextStyle(color: kPrimaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),

                      // Phone Number
                      const SizedBox(height: defaultPadding),
                      TextFormField(
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        cursorColor: kPrimaryColor,
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: const TextStyle(color: kPrimaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),

                      // Country, State, City Picker
                      const SizedBox(height: defaultPadding),
                      CountryStateCityPicker(
                        country: country,
                        state: state,
                        city: city,
                        dialogColor: Colors.white,
                        textFieldDecoration: InputDecoration(
                          filled: true,
                          counterStyle: const TextStyle(color: kPrimaryColor),
                          labelStyle: const TextStyle(color: kPrimaryColor),
                          hintStyle: const TextStyle(color: kPrimaryColor),
                          suffixStyle: const TextStyle(color: kPrimaryColor),
                          suffixIcon: const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(),
                          ),
                          fillColor: Colors.transparent,
                        ),
                      ),

                      // Postal Code
                      const SizedBox(height: largePadding),
                      TextFormField(
                        controller: postalCodeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        cursorColor: kPrimaryColor,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your zip code';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Zip Code",
                          labelStyle: const TextStyle(color: kPrimaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),

                      // Company Address
                      const SizedBox(height: largePadding),
                      TextFormField(
                        controller: companyAddressController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        cursorColor: kPrimaryColor,
                        minLines: 6,
                        maxLines: 12,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a company address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Company Address",
                          labelStyle: const TextStyle(color: kPrimaryColor, fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),

                      // Image Selection
                      const SizedBox(height: largePadding),
                      Card(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imagePath != null
                                  ? Image.file(
                                      File(imagePath!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 200,
                                      errorBuilder: (context, error, stackTrace) => Image.network(
                                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmN0el3AEK0rjTxhTGTBJ05JGJ7rc4_GSW6Q&s',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 200,
                                      ),
                                    )
                                  : logoUrl != null
                                      ? Image.network(
                                          logoUrl!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 200,
                                          errorBuilder: (context, error, stackTrace) => Image.network(
                                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmN0el3AEK0rjTxhTGTBJ05JGJ7rc4_GSW6Q&s',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 200,
                                          ),
                                        )
                                      : Image.network(
                                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmN0el3AEK0rjTxhTGTBJ05JGJ7rc4_GSW6Q&s',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 200,
                                        ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

                                  if (image != null) {
                                    setState(() {
                                      imagePath = image.path;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Image selected')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No image selected.')),
                                    );
                                  }
                                },
                                child: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.edit,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Invoice Settings
                      const SizedBox(height: largePadding),
                      const Text(
                        "Invoice Settings",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(color: kPrimaryLightColor),
                      const SizedBox(height: defaultPadding),

                      // Invoice Prefix
                      TextFormField(
                        controller: invoicePrefixController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        cursorColor: kPrimaryColor,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your invoice prefix';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Invoice Prefix",
                          labelStyle: const TextStyle(color: kPrimaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),

                      // Regards Text
                      const SizedBox(height: largePadding),
                      TextFormField(
                        controller: regardsTextController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        cursorColor: kPrimaryColor,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your regards text';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Regards Text",
                          labelStyle: const TextStyle(color: kPrimaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),

                      const SizedBox(height: defaultPadding),
                      if (isUpdateLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: kPrimaryColor,
                          ),
                        ),

                      const SizedBox(height: 45),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: isUpdateLoading ? null : mUpdateSettings,
                          child: const Text(
                            'Update',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}