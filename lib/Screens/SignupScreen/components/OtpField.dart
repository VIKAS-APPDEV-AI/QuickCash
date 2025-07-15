import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickcash/Screens/SignupScreen/components/OtpValidationScreen.dart';

class OTPSCREEN extends StatelessWidget {
    final String email;
  final int generatedOtp;
  final Function(bool) onVerified;
  const OTPSCREEN({super.key, required this.email, required this.generatedOtp, required this.onVerified});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
        Expanded(child: FilledRoundedPinPut(generatedOtp: generatedOtp, onVerified: onVerified, Email: email,)),
        ],
      )
    );
  }
}