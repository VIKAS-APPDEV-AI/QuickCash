import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  Future<void> _sendOtpToEmail(String email, int otp) async {
    // Your SMTP server credentials
    String username = 'shivamg@itio.in'; // Replace with your email
    String password =
        '08F302E2946734E5198AC39C662EDFDA76BE'; // Replace with your email password or app-specific password

    // SMTP server configuration
    final smtpServer = SmtpServer(
      'smtp.elasticemail.com', // Use your SMTP server (e.g., Gmail's server)
      port: 2525, // SMTP port
      username: username,
      password: password,
    );

    // Email content
    final message = Message()
      ..from = Address(username, 'quickcash')
      ..recipients.add(email) // Recipient email
      ..subject = 'quickcash OTP Verification' // Email subject
      ..html = '''
      <div style="font-family: Helvetica,Arial,sans-serif;min-width:1000px;overflow:auto;line-height:2">
        <div style="margin:50px auto;width:70%;padding:20px 0">
          <div style="border-bottom:1px solid #eee">
            <a href="" style="font-size:1.4em;color: #00466a;text-decoration:none;font-weight:600">$email</a>
          </div>
          <p style="font-size:1.1em">Hi,</p>
          <p>Thank you for choosing quickcash. Use the following OTP to Verify Your Email ID. OTP is valid for 5 minutes:</p>
          <h2 style="background: #00466a;margin: 0 auto;width: max-content;padding: 0 10px;color: #fff;border-radius: 4px;">
            $otp
          </h2>
          <p style="font-size:0.9em;">Regards,<br/>quickcash</p>
          <hr style="border:none;border-top:1px solid #eee" />
        </div>
      </div>
    ''';

    try {
      // Send the email
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
          //   color: kGreenColor, // Set the color of the SnackBar
          // );
        } else {
          // Handle failure scenario
          CustomSnackBar.showSnackBar(
            context: context,
            message: 'We are facing some issue!',
            color: kRedColor, // Set the color of the SnackBar
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
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        },
      );

      // Send OTP to the email
      await _sendOtpToEmail(email, generateOtp);

      // Show success message in the SnackBar
      // CustomSnackBar.showSnackBar(
      //   context: context,
      //   message: 'OTP Sent Successfully to $email',
      //   color: kGreenColor, // Set the color of the SnackBar
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
          color: kRedColor, // Set the color of the SnackBar
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
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: SizedBox(
            height: 400,
            width: 450,
            child: Dialog(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: OTPSCREEN(
                email: email,
                generatedOtp: generateOtp,
                onVerified: _onOtpVerified,
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
          color: kRedColor,
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
            
            const Center(
              child: Text(
                'Please enter your email address. You will receive a OTP via email to create a new password.',
                style: TextStyle(
                  color: kPrimaryColor,
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
              cursorColor: kPrimaryColor,
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
              const CircularProgressIndicator(
                color: kPrimaryColor,
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
                  child: const Text(
                    'Remember Your Password?',
                    style: TextStyle(
                      color: kPrimaryColor,
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
