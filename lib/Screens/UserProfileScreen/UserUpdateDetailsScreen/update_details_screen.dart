import 'package:flutter/material.dart';
import 'package:quickcash/Screens/UserProfileScreen/UserProfileScreen/model/userProfileApi.dart';
import 'package:quickcash/Screens/UserProfileScreen/UserUpdateDetailsScreen/model/userUpdateDetailsApi.dart';
import 'package:quickcash/constants.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';

import '../../../util/auth_manager.dart';
import 'model/userUpdateDetailsModel.dart';

class UpdateDetailsScreen extends StatefulWidget {
  const UpdateDetailsScreen({super.key});

  @override
  State<UpdateDetailsScreen> createState() => _UpdateDetailsScreenState();
}

class _UpdateDetailsScreenState extends State<UpdateDetailsScreen> {
  final UserProfileApi _userProfileApi = UserProfileApi();
  final UserProfileUpdateApi _profileUpdateApi = UserProfileUpdateApi();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedRole = 'Select Title';

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController postalCode = TextEditingController();
  final TextEditingController address = TextEditingController();



  // Get User Details Api Integration -----------------------------------------
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    mUserProfile();
  }

  Future<void> mUserProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _userProfileApi.userProfile();

      AuthManager.saveUserImage(response.ownerProfile!);

      if (response.name != null) {
        name.text = response.name!;
      }
      if (response.email != null) {
        email.text = response.email!;
      }
      if (response.mobile != null) {
        mobile.text = response.mobile!;
      }
      if (response.country != null) {
        country.text = response.country!;
      }
      if (response.state != null) {
        state.text = response.state!;
      }
      if (response.city != null) {
        city.text = response.city!;
      }
      if (response.address != null) {
        address.text = response.address!;
      }
      if(response.postalCode !=null){
        postalCode.text = response.postalCode!;
      }

      if (response.title !=null) {
        selectedRole = response.title!;
      }


      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        selectedRole;
      });
    }
  }


  // User Profile Update Api ------------------
  Future<void> mUserProfileUpdate() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    int mobileNumber = int.parse(mobile.text);
    int postal = int.parse(postalCode.text);

    try {
      final request = UserProfileUpdateRequest(
        userId: AuthManager.getUserId(),
        name: name.text,
        email: email.text,
        mobile: mobileNumber,
        address: address.text,
        country: country.text,
        state: state.text,
        city: city.text,
        postalCode: postal,
        title: selectedRole,
      );

      final response = await _profileUpdateApi.userProfileUpdate(request);


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Profile updated successfully')),
      );


      setState(() {
        mUserProfile();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: defaultPadding),

                    if (isLoading)
                      const CircularProgressIndicator(
                        color: kPrimaryColor,
                      ),
                    // Show loading indicator
                    // if (errorMessage != null) // Show error message if there's an error
                    //   Text(errorMessage!,
                    //   style: const TextStyle(color: Colors.red)),
                    //   const SizedBox(
                    //   height: defaultPadding,
                    // ),
                    // User Name
                    TextFormField(
                      controller: name,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      cursorColor: kPrimaryColor,
                      onSaved: (value) {},
                      readOnly: false,
                      style: const TextStyle(color: kPrimaryColor),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        labelStyle: const TextStyle(color: kPrimaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),

                    // User Email
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      cursorColor: kPrimaryColor,
                      onSaved: (value) {},
                      readOnly: false,
                      style: const TextStyle(color: kPrimaryColor),
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
                        labelText: "Your Email",
                        labelStyle: const TextStyle(color: kPrimaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),

                    // User Phone Number
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: mobile,
                      // Bind the controller
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      cursorColor: kPrimaryColor,
                      onSaved: (value) {},
                      readOnly: false,
                      style: const TextStyle(color: kPrimaryColor),
                      decoration: InputDecoration(
                        labelText: "Mobile Number",
                        labelStyle: const TextStyle(color: kPrimaryColor),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide()),
                      ),
                    ),
                    /*IntlPhoneField(
                      controller: mobile,
                      keyboardType: TextInputType.phone,
                      focusNode: FocusNode(),
                      style: const TextStyle(color: kPrimaryColor),
                      dropdownIcon: const Icon(Icons.arrow_drop_down, size: 28, color: kPrimaryColor),
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        labelStyle: const TextStyle(color: kPrimaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(),
                        ),
                      ),
                      initialCountryCode: 'NP',
                      onChanged: (phone) {
                        phone = mobile as PhoneNumber;
                      },
                      validator: (value) {
                        if (value == null || value.completeNumber.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),*/

                    // User Address
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: address,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.none,
                      cursorColor: kPrimaryColor,
                      onSaved: (value) {},
                      readOnly: false,
                      minLines: 1,
                      maxLines: 6,
                      style: const TextStyle(color: kPrimaryColor),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Address",
                        labelStyle: const TextStyle(color: kPrimaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),

                    // Country State City
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
                        suffixIcon: const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(),

                        ),
                      ),
                    ),

                    // Postal Code
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: postalCode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      cursorColor: kPrimaryColor,
                      onSaved: (value) {},
                      readOnly: false,
                      style: const TextStyle(color: kPrimaryColor),
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

                    // Title
                    const SizedBox(height: defaultPadding),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      style: const TextStyle(color: kPrimaryColor),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: const TextStyle(color: kPrimaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(),
                        ),
                      ),
                      items: ['Select Title','CEO', 'CFO', 'President', 'Manager', 'Others'].map((String role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedRole = newValue!;
                        });
                      },
                    ),

                    // Update Button
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
                        onPressed: () {

                          if (country.text.isEmpty || state.text.isEmpty || city.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select country, state, and city')),
                            );
                          }else if(selectedRole == "Select Title") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select title')),
                            );

                          } else if(_formKey.currentState!.validate()){
                            mUserProfileUpdate();
                          }

                        },
                        child: const Text('Update', style: TextStyle(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
