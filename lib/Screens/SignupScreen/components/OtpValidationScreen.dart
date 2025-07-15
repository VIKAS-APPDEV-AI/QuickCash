import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:pinput/pinput.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/customSnackBar.dart';

class FilledRoundedPinPut extends StatefulWidget {
  final String Email;
  final int generatedOtp;
  final Function(bool) onVerified;

  const FilledRoundedPinPut({
    Key? key,
    required this.generatedOtp,
    required this.onVerified,
    required this.Email,
  }) : super(key: key);

  @override
  _FilledRoundedPinPutState createState() => _FilledRoundedPinPutState();
}

class _FilledRoundedPinPutState extends State<FilledRoundedPinPut> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  late Timer _timer;
  int _remainingTime = 300;
  bool _isOtpExpired = false;
  bool _isResendEnabled = false;
  late int _currentOtp; // Track the current OTP

  String errorMessage = '';

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.generatedOtp;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer.cancel();
        setState(() {
          _isResendEnabled = true;
          _isOtpExpired = true;
        });
      }
    });
  }

  void _verifyOtp() {
    if (_isOtpExpired) {
      setState(() {
        errorMessage = "OTP has expired. Please resend the OTP.";
      });
      return;
    }

    final enteredOtp = int.tryParse(controller.text);
    if (enteredOtp == _currentOtp) {
      widget.onVerified(true);
    } else {
      setState(() {
        errorMessage = "Invalid OTP. Please try again.";
      });
    }
  }

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
      ..from = Address(
          username, 'quickcash') // Valid sender address with a friendly name
      ..recipients.add(email) // Recipient email
      ..subject = 'Verify Your Email Account' // Clear, concise subject line
      ..html = '''
  <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
    <div style="text-align: center; border-bottom: 1px solid #ddd; padding-bottom: 10px; margin-bottom: 20px;">
      <h1 style="color: #00466a; font-size: 24px; margin: 0;">quickcash</h1>
    </div>
    <p style="font-size: 16px; margin: 10px 0;">Dear User,</p>
    <p style="font-size: 16px; margin: 10px 0;">We received a request to verify your email address for your quickcash account. Please use the following one-time password (OTP) to complete the verification process:</p>
    <p style="font-size: 20px; font-weight: bold; color: #fff; background-color: #00466a; display: inline-block; padding: 10px 20px; border-radius: 5px;">$otp</p>
    <p style="font-size: 16px; margin: 10px 0;">This OTP is valid for 5 minutes. If you did not request this, please ignore this email.</p>
    <p style="font-size: 16px; margin: 10px 0;">If you have any questions, feel free to contact our support team.</p>
    <p style="font-size: 14px; color: #666; margin: 20px 0;">Regards,<br/>quickcash Team</p>
    <hr style="border-top: 1px solid #ddd; margin: 20px 0;" />
    <p style="font-size: 12px; color: #666; text-align: center;">You are receiving this email because you signed up for quickcash. If you did not initiate this request, please <a href="#" style="color: #00466a; text-decoration: none;">unsubscribe</a>.</p>
  </div>
  '''
      ..text = '''
  Dear User,

  We received a request to verify your email address for your quickcash account. Use the following OTP to complete the process: $otp. 

  This OTP is valid for 5 minutes. If you did not request this, please ignore this email.

  Regards,
  quickcash Team
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

  void _resendOtp() {
    if (_isResendEnabled) {
      // Generate a new OTP
      int newOtp = generateRandomOtp();

      setState(() {
        _currentOtp = newOtp;
        _isResendEnabled = false;
        _isOtpExpired = false;
        _remainingTime = 300; // Reset timer to 5 minutes
        // Restart the timer
      });

      @override
      void dispose() {
        controller.dispose();
        super.dispose;
      }

      // Send the new OTP to the email
      _sendOtpToEmail(widget.Email, newOtp);

      _startTimer();

      CustomSnackBar.showSnackBar(
        context: context,
        message: 'OTP Resent Successfully!',
        color: kGreenColor, // Set the color of the SnackBar
      );

      print('New OTP: $newOtp');
    }
  }

// Utility function to generate a random 4-digit OTP
  int generateRandomOtp() {
    return 1000 + (DateTime.now().millisecondsSinceEpoch % 9000).toInt();
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color.fromRGBO(114, 178, 238, 1);
    const errorColor = Color.fromRGBO(255, 234, 238, 1);
    const fillColor = Color.fromRGBO(222, 231, 240, .57);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.poppins(
        fontSize: 22,
        color: const Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    String getFormattedTime(int seconds) {
      int minutes = (seconds / 60).floor();
      int remainingSeconds = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'OTP Verification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Enter The Code Sent To The',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'Email ID: ${widget.Email}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Pinput(
              length: 4,
              controller: controller,
              focusNode: focusNode,
              defaultPinTheme: defaultPinTheme,
              errorPinTheme: defaultPinTheme.copyWith(
                decoration: BoxDecoration(
                  color: errorColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOtp,
              child: const Text(
                'Verify',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Did\'t get the OTP ?',
                  style: TextStyle(fontSize: 13),
                ),
                InkWell(
                    onTap: _resendOtp,
                    child: Text(
                      _isResendEnabled
                          ? 'Resend'
                          : 'Resend in ${getFormattedTime(_remainingTime)}',
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6F35A5),
                          fontWeight: FontWeight.w800),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
