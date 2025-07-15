import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:quickcash/Screens/SignupScreen/components/OtpField.dart';
import 'package:quickcash/Screens/SignupScreen/model/signupApi.dart';
import 'package:quickcash/util/customSnackBar.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer
import 'package:url_launcher/url_launcher.dart'; // For launching URLs

import '../../../components/check_already_have_an_account.dart';
import '../../../constants.dart';
import '../../../util/auth_manager.dart';
import '../../HomeScreen/home_screen.dart';
import '../../LoginScreen/login_screen.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _emailController = TextEditingController();
  bool isVerified = false;
  int generateOtp = 0;
  bool _obsecureText = true;
  bool isLoading = false;

  Timer? _debounce;

  void _togglePasswordVisibilty() {
    setState(() {
      _obsecureText = !_obsecureText;
    });
  }

  final _formKey = GlobalKey<FormState>();
  String? fullName;
  String? email;
  String? password;
  String? selectedCountry;

  final SignUpApi _signUpApi = SignUpApi();

  String? errorMessage;

  bool _isPasswordValid(String password) {
    final regex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%&*,.?])(?=.*[0-9]).{8,}$');
    return regex.hasMatch(password);
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$');
    bool isValid = regex.hasMatch(email.trim());
    print('Email: $email, Valid: $isValid');
    return isValid;
  }

  Future<void> mSignUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (selectedCountry != null && selectedCountry != "Select Country") {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });

        try {
          final response = await _signUpApi.signup(
              fullName!, email!, password!, selectedCountry!, "");
          await AuthManager.saveUserId(response.userId!);
          await AuthManager.saveToken(response.token!);
          await AuthManager.saveUserName(response.name!);
          await AuthManager.saveUserEmail(response.email!);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } catch (error) {
          setState(() {
            isLoading = false;
            errorMessage = "Signup failed: ${error.toString()}";
          });
          CustomSnackBar.showSnackBar(
            context: context,
            message: "Signup failed: ${error.toString()}",
            color: kRedColor,
          );
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Please select a country.";
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onEmailChanged() {
    final email = _emailController.text.trim();
    print('Email changed: $email');

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 1000), () {
      if (_isValidEmail(email) && !isVerified && email.isNotEmpty) {
        print('Email is valid and complete: $email, triggering OTP');
        if (!isLoading) {
          _generateAndSendOtp(email);
        } else {
          print('Form already loading, skipping OTP: $email');
        }
      } else {
        print('Email invalid, already verified, or empty: $email');
        setState(() {
          errorMessage = _isValidEmail(email)
              ? null
              : "Please enter a valid email address";
        });
      }
    });
  }

  void _generateAndSendOtp(String email) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Lottie.asset(
              'assets/lottie/emailLoading.json',
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            ),
          );
        },
      );

      await _sendOtpToEmail(email, generateOtp);

      CustomSnackBar.showSnackBar(
        context: context,
        message: 'OTP Sent Successfully to $email',
        color: kGreenColor,
      );

      Navigator.of(context).pop();
      _showOtpDialog(email);
    } catch (e) {
      Navigator.of(context).pop();
      setState(() {
        isLoading = false;
        errorMessage = "Failed to send OTP: ${e.toString()}";
      });
      CustomSnackBar.showSnackBar(
        context: context,
        message: "Failed to send OTP: ${e.toString()}",
        color: kRedColor,
      );
    }
  }

  Future<void> _sendOtpToEmail(String email, int otp) async {
    String username = '8e8f35001@smtp-brevo.com';
    String password = 'wxLQ4UIADtXZCBMb';
    final smtpServer = SmtpServer(
      'smtp-relay.brevo.com',
      port: 587,
      username: username,
      password: password,
    );

    final message = Message()
      ..from = Address(username, 'quickcash')
      ..recipients.add(email)
      ..subject = 'quickcash OTP Verification'
      ..html = '''
      <div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
        <div style="margin:50px auto;width:70%;padding:20px 0">
          <div style="border-bottom:1px solid #eee">
            <a href="" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">$email</a>
          </div>
          <p style="font-size:1.1em">Hi,</p>
          <p>Thank you for choosing quickcash. Use the following OTP to Verify Your Email ID. OTP is valid for 5 minutes:</p>
          <h2 style="background: #00466a;margin: 0 auto;width: max-content;padding: 0 10px;color: #fff;border-radius: 4px;">$otp</h2>
          <p style="font-size:0.9em;">Regards,<br/>quickcash</p>
          <hr style="border:none;border-top:1px solid #eee" />
        </div>
      </div>
    ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: ${sendReport.toString()}');
    } catch (e) {
      print('Error sending email: $e');
      rethrow;
    }
  }

  void _showOtpDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SizedBox(
            height: 450,
            width: 600,
            child: OTPSCREEN(
              email: email,
              generatedOtp: generateOtp,
              onVerified: _onOtpVerified,
            ),
          ),
        );
      },
    );
  }

  void _onOtpVerified(bool success) {
    Navigator.of(context).pop();
    if (success) {
      setState(() {
        isVerified = true;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        errorMessage = "OTP verification failed. Please try again.";
      });
      CustomSnackBar.showSnackBar(
        context: context,
        message: "OTP verification failed. Please try again.",
        color: kRedColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              cursorColor: kPrimaryColor,
              style: const TextStyle(
                  color: kPrimaryColor, fontWeight: FontWeight.w500),
              onSaved: (value) {
                fullName = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: "Full Name",
                hintStyle: TextStyle(color: kHintColor),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.person),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                cursorColor: kPrimaryColor,
                style: TextStyle(
                  color: isVerified ? Colors.black26 : kPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
                onSaved: (value) {
                  email = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!_isValidEmail(value)) {
                    return 'Please enter a valid email (e.g., abc@gmail.com)';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Your Email",
                  hintStyle: const TextStyle(color: kHintColor),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Icon(
                      Icons.email,
                      color: isVerified ? Colors.black26 : kPrimaryColor,
                    ),
                  ),
                  suffixIcon: null,
                  fillColor: isVerified ? Colors.black12 : kPrimaryLightColor,
                  filled: true,
                  errorText: _emailController.text.isNotEmpty &&
                          !isVerified &&
                          !_isValidEmail(_emailController.text)
                      ? "Please enter a valid email address"
                      : null,
                ),
              ),
            ),
            TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: _obsecureText,
              cursorColor: kPrimaryColor,
              style: const TextStyle(
                  color: kPrimaryColor, fontWeight: FontWeight.w500),
              onSaved: (value) {
                password = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (!_isPasswordValid(value)) {
                  return 'Password must contain at least one lowercase, uppercase, number, and special character.';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "Your Password",
                hintStyle: const TextStyle(color: kHintColor),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
                suffixIcon: IconButton(
                  onPressed: _togglePasswordVisibilty,
                  icon: Icon(
                    _obsecureText ? Icons.visibility : Icons.visibility_off,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),
            GestureDetector(
              onTap: () {
                showCountryPicker(
                  context: context,
                  onSelect: (Country country) {
                    setState(() {
                      selectedCountry = country.name;
                    });
                  },
                );
              },
              child: TextFormField(
                textInputAction: TextInputAction.done,
                enabled: false,
                controller: TextEditingController(text: selectedCountry),
                cursorColor: kPrimaryColor,
                style: const TextStyle(
                    color: kPrimaryColor, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: selectedCountry ?? "Select Country",
                  hintStyle: const TextStyle(color: kHintColor),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(Icons.flag),
                  ),
                  suffixIcon: const Icon(
                    Icons.arrow_drop_down,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Lottie.asset(
                    'assets/lottie/loading.json',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: isLoading ? null : mSignUp,
              child: const Text("Sign Up"),
            ),
            const SizedBox(height: defaultPadding),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const LoginScreen();
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Red curved arrow
               
                const SizedBox(width: 10),
                // RichText for clickable and bold links
                Expanded(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(text: 'By Continuing, you agree to our\n'),
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              const url = 'https://yourwebsite.com/terms'; // Replace with your Terms URL
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                CustomSnackBar.showSnackBar(
                                  context: context,
                                  message: "Could not open Terms and Conditions",
                                  color: kRedColor,
                                );
                              }
                            },
                        ),
                        const TextSpan(text: ' and have read our '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              const url = 'https://yourwebsite.com/privacy'; // Replace with your Privacy Policy URL
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                CustomSnackBar.showSnackBar(
                                  context: context,
                                  message: "Could not open Privacy Policy",
                                  color: kRedColor,
                                );
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
