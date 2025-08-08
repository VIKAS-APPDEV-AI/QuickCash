import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:quickcash/Screens/SignupScreen/components/OtpField.dart';
import 'package:quickcash/Screens/SignupScreen/model/signupApi.dart';
import 'package:quickcash/util/customSnackBar.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

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
            color: Theme.of(context).colorScheme.error,
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

  int _generateRandomOtp() {
    final random = Random();
    return 1000 + random.nextInt(9000); // Generates a 4-digit OTP
  }

  void _generateAndSendOtp(String email) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      generateOtp = _generateRandomOtp();
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
        color: Theme.of(context).colorScheme.secondary,
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
        color: Theme.of(context).colorScheme.error,
      );
    }
  }

  Future<void> _sendOtpToEmail(String email, int otp) async {
    final String username = dotenv.env['SMTP_MAIL_USER']!;
    final String password = dotenv.env['SMTP_MAIL_PASSWORD']!;
    final smtpServer = SmtpServer(
      dotenv.env['SMTP_MAIL_HOST']!,
      port: int.parse(dotenv.env['SMTP_MAIL_PORT']!),
      ssl: dotenv.env['SMTP_MAIL_ENCRYPTION'] == 'ssl',
      username: username,
      password: password,
    );

    final message = Message()
      ..from = Address(username, 'QuickCash')
      ..recipients.add(email)
      ..subject = 'QuickCash OTP Verification'
      ..html = '''
  <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f9f9f9; padding: 30px;">
    <div style="max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
      <div style="background-color: #6F35A5; padding: 20px; text-align: center;">
        <h1 style="color: #ffffff; margin: 0; font-size: 24px;">QuickCash</h1>
      </div>
      <div style="padding: 30px;">
        <p style="font-size: 16px; color: #333333;">Hi, $email</p>
        <p style="font-size: 15px; color: #555555;">
          Thank you for choosing <strong>QuickCash</strong>.<br>
          Please use the following OTP to verify your email address. The OTP is valid for <strong>5 minutes</strong>.
        </p>
        <div style="text-align: center; margin: 30px 0;">
          <span style="display: inline-block; background-color: #6F35A5; color: #ffffff; font-size: 24px; letter-spacing: 4px; padding: 12px 30px; border-radius: 8px; font-weight: bold;">
            $otp
          </span>
        </div>
        <p style="font-size: 14px; color: #888888;">
          If you didn’t request this OTP, please ignore this email or contact support if you have concerns.
        </p>
        <p style="font-size: 14px; color: #555555; margin-top: 30px;">
          Regards,<br>
          <strong>QuickCash Team</strong>
        </p>
      </div>
      <div style="background-color: #f0f0f0; padding: 15px; text-align: center; font-size: 12px; color: #999999;">
        © ${DateTime.now().year} QuickCash. All rights reserved.
      </div>
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
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: Dialog(
          backgroundColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 400,
              maxHeight: 450,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: OTPSCREEN(
                    email: email,
                    generatedOtp: generateOtp,
                    onVerified: _onOtpVerified,
                  ),
                ),
              ),
            ),
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
        color: Theme.of(context).colorScheme.error,
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
              cursorColor: Theme.of(context).colorScheme.primary,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              onSaved: (value) {
                fullName = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "Full Name",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                cursorColor: Theme.of(context).colorScheme.primary,
                enabled: !isVerified, // 👈 Disable when verified
                style: TextStyle(
                  color: isVerified
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                      : Theme.of(context).colorScheme.onSurface,
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
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Icon(
                      Icons.email,
                      color: isVerified
                          ? Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5)
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  suffixIcon: isVerified
                      ? Padding(
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        )
                      : null,
                  fillColor: isVerified
                      ? Theme.of(context).colorScheme.surfaceVariant
                      : Theme.of(context).colorScheme.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
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
              cursorColor: Theme.of(context).colorScheme.primary,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
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
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(
                    Icons.lock,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: _togglePasswordVisibilty,
                  icon: Icon(
                    _obsecureText ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
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
                cursorColor: Theme.of(context).colorScheme.primary,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: selectedCountry ?? "Select Country",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.flag,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
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
            // if (errorMessage != null)
            //   Padding(
            //     padding: const EdgeInsets.symmetric(vertical: 8.0),
            //     child: Text(
            //       errorMessage!,
            //       style: TextStyle(color: Theme.of(context).colorScheme.error),
            //       textAlign: TextAlign.center,
            //     ),
            //   ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: isLoading ? null : mSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
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
                Expanded(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      children: [
                        const TextSpan(
                            text: 'By Continuing, you agree to our\n'),
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              const url =
                                  'https://quickcash.oyefin.com/privacy-policy';
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                CustomSnackBar.showSnackBar(
                                  context: context,
                                  message:
                                      "Could not open Terms and Conditions",
                                  color: Theme.of(context).colorScheme.error,
                                );
                              }
                            },
                        ),
                        const TextSpan(text: ' and have read our '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              const url =
                                  'https://quickcash.oyefin.com/privacy-policy';
                              final uri = Uri.parse(url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                CustomSnackBar.showSnackBar(
                                  context: context,
                                  message: "Could not open Privacy Policy",
                                  color: Theme.of(context).colorScheme.error,
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
