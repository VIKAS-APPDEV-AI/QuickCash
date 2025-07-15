import 'dart:io';

import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/InvoicesScreen/ClientsScreen/EditClientsFormScreen/model/updateClientsApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/ClientsScreen/EditClientsFormScreen/model/updateClientsModel.dart';
import 'package:quickcash/Screens/InvoicesScreen/ClientsScreen/ViewClientsScreen/model/viewClientsApi.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/customSnackBar.dart';

import '../../../../util/apiConstants.dart';
import '../../../../util/auth_manager.dart';

class EditClientsFormScreen extends StatefulWidget {
  final String? clientsID;
  const EditClientsFormScreen({super.key, required this.clientsID});

  @override
  State<EditClientsFormScreen> createState() => _EditClientsFormScreenState();
}

class _EditClientsFormScreenState extends State<EditClientsFormScreen> {
  final ViewClientsApi _viewClientsApi = ViewClientsApi();
  final ClientUpdateApi _clientUpdateApi = ClientUpdateApi();

  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController postalCode = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController note = TextEditingController();
  final TextEditingController lastUpdate = TextEditingController();

  TextEditingController country = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController city = TextEditingController();
  String? imagePath; // Variable to store the selected image path

  bool isLoading = true;
  String? errorMessage;
  String? profileImageUrl;

  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation

  @override
  void initState() {
    mViewClientApi();
    super.initState();
  }

  Future<void> mViewClientApi() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _viewClientsApi.viewClientsApi(widget.clientsID);

      firstName.text = response.firstName ?? "N/A";
      lastName.text = response.lastName ?? "N/A";
      email.text = response.email ?? 'N/A';
      mobile.text = response.mobile?.toString() ?? '0';

      country.text = response.country ?? 'N/A';
      state.text = response.state ?? 'N/A';
      city.text = response.city ?? 'N/A';
      postalCode.text = response.postalCode ?? 'N/A';
      address.text = response.address ?? 'N/A';
      note.text = response.notes ?? 'N/A';
      lastUpdate.text = formatDate(response.lastUpdate!);

      // Set the profile image URL dynamically
      if (response.profilePhoto != null) {
        profileImageUrl =
        '${ApiConstants.baseImageUrl}${AuthManager.getUserId()}/${response.profilePhoto}';
      }

      setState(() {
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

  // Function to format the date
  String formatDate(String? dateTime) {
    if (dateTime == null) {
      return 'Date not available';
    }
    DateTime date = DateTime.parse(dateTime);
    return DateFormat('dd-MM-yyyy').format(date);
  }

  // Update Client Api ----
  Future<void> mUpdateClient() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      int mobileNumber = int.parse(mobile.text);
      int postal = int.parse(postalCode.text);

      try {

        if(imagePath !=null){
          final request = ClientUpdateRequest(
            userId: AuthManager.getUserId(),
            firstName: firstName.text,
            lastName: lastName.text,
            email: email.text,
            mobile: mobileNumber,
            postalCode: postal,
            country: country.text,
            state: state.text,
            city: city.text,
            address: address.text,
            notes: note.text,
            profilePhoto: imagePath !=null ? File(imagePath!) : null
          );

          final response = await _clientUpdateApi.clientUpdate(request, widget.clientsID);

          CustomSnackBar.showSnackBar(context: context, message: response.message!, color: kGreenColor);

          setState(() {
            isLoading = false;
            errorMessage = null;
            mViewClientApi();
          });

        }else{
          final request = ClientUpdateRequest(
            userId: AuthManager.getUserId(),
            firstName: firstName.text,
            lastName: lastName.text,
            email: email.text,
            mobile: mobileNumber,
            postalCode: postal,
            country: country.text,
            state: state.text,
            city: city.text,
            address: address.text,
            notes: note.text,
          );

          final response = await _clientUpdateApi.clientUpdate(request, widget.clientsID);

          CustomSnackBar.showSnackBar(context: context, message: response.message!, color: kGreenColor);

          setState(() {
            isLoading = false;
            errorMessage = null;
            mViewClientApi();
          });
        }

      } catch (error) {
        setState(() {
          isLoading = false;
          errorMessage = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Edit Client Form",
          style: TextStyle(color: Colors.white),
        ),
      ),
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
            key: _formKey, // Assign the global key to the form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: defaultPadding),
                if (errorMessage != null)
                  Text(errorMessage!,
                      style: const TextStyle(color: Colors.red)),

                const SizedBox(height: largePadding),
                // First Name
                TextFormField(
                  controller: firstName,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  onSaved: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "First Name",
                    labelStyle: const TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                  ),
                ),

                // Last Name
                const SizedBox(height: largePadding),
                TextFormField(
                  controller: lastName,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  onSaved: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Last Name",
                    labelStyle: const TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                  ),
                ),

                // Email
                const SizedBox(height: largePadding),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  onSaved: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                  ),
                ),

                // Mobile
                const SizedBox(height: largePadding),
                TextFormField(
                  controller: mobile,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  cursorColor: kPrimaryColor,
                  onSaved: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Mobile Number",
                    labelStyle: const TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                  ),
                ),

                // Postal Code
                const SizedBox(height: largePadding),
                TextFormField(
                  controller: postalCode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  cursorColor: kPrimaryColor,
                  onSaved: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your postal code';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Postal Code",
                    labelStyle: const TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                  ),
                ),

                // Country State City Picker
                const SizedBox(height: largePadding),
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
                    suffixIcon: const Icon(Icons.arrow_drop_down,
                        color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                  ),
                ),

                // Address
                const SizedBox(height: largePadding),
                TextFormField(
                  controller: address,
                  keyboardType: TextInputType.text,
                  cursorColor: kPrimaryColor,
                  textInputAction: TextInputAction.none,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    labelStyle: const TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                  ),
                  maxLines: 5,
                  minLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Address is required';
                    }
                    return null; // Validation passed
                  },
                ),

                // Notes
                const SizedBox(height: largePadding),
                TextFormField(
                  controller: note,
                  keyboardType: TextInputType.text,
                  cursorColor: kPrimaryColor,
                  textInputAction: TextInputAction.none,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    labelStyle: const TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                  ),
                  maxLines: 5,
                  minLines: 1,
                ),

                const SizedBox(height: largePadding),

                // Profile Image Section
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
                            final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);

                            if (image != null) {
                              setState(() {
                                imagePath = image.path; // Store the image path
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

                // Save Button
                const SizedBox(height: 35),
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
                    onPressed: isLoading ? null : mUpdateClient,
                    child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
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
