import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:quickcash/Screens/ForgotScreen/model/forgotPasswordApi.dart';
import 'package:quickcash/Screens/LoginScreen/login_screen.dart';
import 'package:quickcash/Screens/SignupScreen/components/OtpField.dart';
import 'package:quickcash/Screens/UserProfileScreen/SecurityScreen/security_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';
import '../../../util/customSnackBar.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordForm> {
  final _fromKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
      TextEditingController(); // Add the controller
  String? email;
  bool isVerified = false;
  int generateOtp = 0;
  bool isOtpLoading = false;

  final ForgotPasswordApi _forgotPasswordApi = ForgotPasswordApi();

  bool isLoading = false;
  String? errorMessage;

// For Flutter projects

  Future<void> _sendOtpToEmail(String email, int otp) async {
    // Gmail credentials from .env
    final String username = dotenv.env['SMTP_MAIL_USER']!;
    final String password = dotenv.env['SMTP_MAIL_PASSWORD']!;

    // Gmail SMTP server configuration
    final smtpServer = SmtpServer(
      dotenv.env['SMTP_MAIL_HOST']!,
      port: int.parse(dotenv.env['SMTP_MAIL_PORT']!),
      ssl: dotenv.env['SMTP_MAIL_ENCRYPTION'] == 'ssl',
      username: username,
      password: password,
    );

    // Email content
    final message = Message()
      ..from = Address(username, 'quickcash')
      ..recipients.add(email)
      ..subject = 'Quickcash Change Password OTP Verification'
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
          Please use the following OTP to Change your Account Password. The OTP is valid for <strong>5 minutes</strong>.
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
    }

    print("Sending OTP $otp to email $email");
  }

  Future<void> mForgotPassword() async {
    if (_fromKey.currentState!.validate()) {
      _fromKey.currentState!.save();

      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        final response = await _forgotPasswordApi.forgotPassword(email!);

        setState(() {
          isLoading = false;
        });

        final prefs2 = await SharedPreferences.getInstance();

        // Retrieve the saved message
        final savedMessage = prefs2.getString('message');

        print("API Response: ${response.message}");

        if (savedMessage == "Success") {
          _emailController.clear(); // Clear the text field on success

          // Call _generateAndSendOtp function to send OTP after successful reset request
          _generateAndSendOtp(email!);

          // Optionally, show a custom Snackbar for success
          // CustomSnackBar.showSnackBar(
          //   context: context,
          //   message:
          //       '',
          //   color: Colors.green, // Set the color of the SnackBar
          // );
        } else {
          // Handle failure scenario
          CustomSnackBar.showSnackBar(
            context: context,
            message: 'We are facing some issue!',
            color: Colors.red, // Set the color of the SnackBar
          );
          print("Message from response: ${response.message}");
        }
      } catch (error) {
        setState(() {
          isLoading = false;
          errorMessage = error.toString();
        });
      }
    }
  }

  void _generateAndSendOtp(String email) async {
    print("OTP generation triggered for $email");
    setState(() {
      isOtpLoading = true;
      generateOtp =
          Random().nextInt(9000) + 1000; // Generate random 4-digit OTP
    });
    print("Generated OTP: $generateOtp");

    try {
      // Show progress indicator dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).extension<AppColors>()!.primary),
          );
        },
      );

      // Send OTP to the email
      await _sendOtpToEmail(email, generateOtp);

      // Show success message in the SnackBar
      // CustomSnackBar.showSnackBar(
      //   context: context,
      //   message: 'OTP Sent Successfully to $email',
      //   color: Colors.green, // Set the color of the SnackBar
      // );

      // Dismiss progress dialog
      Navigator.of(context).pop();

      // Show the OTP dialog for verification
      _showOtpDialog(email);
    } catch (e) {
      // Print the error if OTP sending fails
      //print("Failed to send OTP: $e"); //For Debugging

      // Dismiss progress dialog
      Navigator.of(context).pop();

      setState(() {
        CustomSnackBar.showSnackBar(
          context: context,
          message: "Failed to send OTP: $e",
          color: Colors.red, // Set the color of the SnackBar
        );
      });
    } finally {
      setState(() {
        isOtpLoading = false;
      });
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
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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

  void _onOtpVerified(bool success) async {
    Navigator.of(context).pop(); // Close the dialog

    if (success) {
      // setState(() {
      //   // Mark the email as verified
      // });

      try {
        // Fetch token from the forgotPassword API
        final response = await _forgotPasswordApi.forgotPassword(email!);

        // Extract the token from the response
        // final token = response.token; // Adjust based on your model

        //print(token);
        // Navigate to SecurityScreen with the token
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => SecurityScreen(),
          ),
        );
      } catch (e) {
        // Handle error
        CustomSnackBar.showSnackBar(
          context: context,
          message: "Failed to fetch token: $e",
          color: Colors.red,
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _fromKey,
        child: Column(
          children: [
            Center(
              child: Text(
                'Please enter your email address. You will receive a OTP via email to create a new password.',
                style: TextStyle(
                  color: Theme.of(context).extension<AppColors>()!.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 35),
            TextFormField(
              controller: _emailController, // Use the controller here
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: Theme.of(context).extension<AppColors>()!.primary,
              onSaved: (value) {
                email = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                // Regex for basic email validation
                final regex =
                    RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$');
                if (!regex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: "Your Email",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.email),
                ),
              ),
            ),

            if (isLoading)
              CircularProgressIndicator(
                color: Theme.of(context).extension<AppColors>()!.primary,
              ), // Show loading indicator
            if (errorMessage != null) // Show error message if there's an error
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(
              height: defaultPadding,
            ),

            ElevatedButton(
              onPressed: isLoading ? null : mForgotPassword,
              child: const Text(
                "Reset Password",
              ),
            ),
            const SizedBox(height: defaultPadding),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const LoginScreen();
                        },
                      ),
                    );
                  },
                  child: Text(
                    'Remember Your Password?',
                    style: TextStyle(
                      color: Theme.of(context).extension<AppColors>()!.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
