import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickcash/Screens/UserProfileScreen/SecurityScreen/ChangePasswordModel/NewChangePassword.dart';
import 'package:quickcash/Screens/UserProfileScreen/SecurityScreen/ResusableWidget/Success.dart';
import 'package:quickcash/util/customSnackBar.dart';
//import 'package:quickcash/Screens/UserProfileScreen/SecurityScreen/ChangePasswordModel/changePasswordApi.dart';
//import 'package:quickcash/Screens/WelcomeScreen/welcome_screen.dart';
//import 'package:quickcash/util/auth_manager.dart';
//import 'package:quickcash/util/customSnackBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
//import 'SendOTPModel/sendOTPApi.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPasswordMatch = false;
  bool isOtpSent = false;

  //final SendOTPApi _securityApi = SendOTPApi();
  final NewChangePasswordApi _newchangePasswordApi = NewChangePasswordApi();

  bool _isPasswordValid(String password) {
  final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%&*,.?])(?=.*[0-9]).{8,}$');
  return regex.hasMatch(password);
}

  bool isLoading = false;
  String? errorMessage;

  // Future<void> mSendOtpApi() async {
  //   if (_formKey.currentState!.validate()) {
  //     if (_passwordController.text != _confirmPasswordController.text) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Passwords does not match!')),
  //       );
  //       setState(() {
  //         _isPasswordMatch = false;
  //       });
  //       return;
  //     } else {
  //       setState(() {
  //         _isPasswordMatch = true;
  //         isLoading = true;
  //         errorMessage = null;
  //       });

  //       try {
  //         final response = await _securityApi.sendOTP(
  //             AuthManager.getUserEmail(), AuthManager.getUserName());
  //         setState(() {
  //           isLoading = false;
  //           isOtpSent = true;
  //         });

  //         AuthManager.saveOTP(response.otp.toString());
  //         CustomSnackBar.showSnackBar(
  //           context: context,
  //           message: response.message!,
  //           color: kPrimaryColor,
  //         );
  //       } catch (error) {
  //         setState(() {
  //           isLoading = false;
  //           errorMessage = error.toString();
  //         });
  //       }
  //     }
  //   }
  // }

  Future<void> mChangePasswordApi() async {
    setState(() {
      isLoading = true;
    });

    try {
      //Retrive Token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        throw Exception("Token not found. Please log in again.");
      }

      final response = await _newchangePasswordApi.changePassword(
          token, _passwordController.text);

      setState(() {
        isLoading = false;
        errorMessage = null;
        //isOtpSent = false;
        _confirmPasswordController.clear();
        _passwordController.clear();
        //_otpController.clear();
        //AuthManager.saveOTP("");
      });

      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => const SuccessScreen()),
      );
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  void handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!')),
        );
        setState(() {
          _isPasswordMatch = false;
        });
        return;
      } else {
        setState(() {
          _isPasswordMatch = true;
          isLoading = true;
          errorMessage = null;
        });

        // Directly call the change password API without OTP validation
        mChangePasswordApi();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: kPrimaryColor,
      //   leading: InkWell(
      //       onTap: () {
      //         Navigator.pushReplacement(
      //             context,
      //             CupertinoPageRoute(
      //               builder: (context) => const WelcomeScreen(),
      //             ));
      //       },
      //       child: const Icon(
      //         CupertinoIcons.back,
      //         color: Colors.white,
      //       )),
      //   title: const Text(
      //     'Change Password',
      //     style: TextStyle(color: kWhiteColor),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 10,
            ),

            Image.asset(
              'assets/images/OtpScreen.jpg', // Add your image here
              width: double.infinity,
              height: 200, // Adjust the height as needed
              fit: BoxFit.contain,
            ),

            // Centered Form
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: defaultPadding),
                      if (isLoading)
                        const CircularProgressIndicator(color: kPrimaryColor),
                      if (errorMessage != null)
                        Text(errorMessage!,
                            style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: defaultPadding),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        textInputAction: TextInputAction.next,
                        obscureText: !_isPasswordVisible,
                        cursorColor: kPrimaryColor,
                        style: const TextStyle(color: kPrimaryColor),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (!_isPasswordValid(value)) {
                            return 'Password must contain at least one lowercase letter, one uppercase letter, one number, and one special character.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: const TextStyle(color: kPrimaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: kPrimaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),

                      // Confirm Password
                      const SizedBox(height: defaultPadding),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        cursorColor: kPrimaryColor,
                        style: const TextStyle(color: kPrimaryColor),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your confirm password';
                          }
                          if (!_isPasswordValid(value)) {
                            return 'Confirm password must contain at least one lowercase letter, one uppercase letter, one number, and one special character.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          labelStyle: const TextStyle(color: kPrimaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: kPrimaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),

                      // // OTP field visibility check
                      // if (_isPasswordMatch && isOtpSent) ...[
                      //   const SizedBox(height: defaultPadding),
                      //   TextFormField(
                      //     controller: _otpController,
                      //     keyboardType: TextInputType.number,
                      //     cursorColor: kPrimaryColor,
                      //     style: const TextStyle(color: kPrimaryColor),
                      //     validator: (value) {
                      //       if (value == null || value.isEmpty) {
                      //         return 'Please enter OTP';
                      //       }
                      //       return null;
                      //     },
                      //     decoration: InputDecoration(
                      //       labelText: "OTP",
                      //       labelStyle: const TextStyle(color: kPrimaryColor),
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //         borderSide: const BorderSide(),
                      //       ),
                      //     ),
                      //   ),
                      // ],

                      // Submit Button
                      const SizedBox(height: 35),
                      ElevatedButton(
                        onPressed: isLoading ? null : handleSubmit,
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
