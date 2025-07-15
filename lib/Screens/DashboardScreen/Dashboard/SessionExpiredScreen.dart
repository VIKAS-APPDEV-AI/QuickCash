import 'package:flutter/material.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/Screens/LoginScreen/login_screen.dart';

class SessionExpiredScreen extends StatelessWidget {
  const SessionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_clock, size: 80, color: kPrimaryColor),
              const SizedBox(height: 20),
              Text(
                "Your Login Session Has Expired",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "For security reasons, your session has timed out. Please log in again to continue.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  //textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  print("Login Again button pressed - Calling AuthManager.logout()..."); // Debug print
                  await AuthManager.logout(); // Explicitly call logout to clear all tokens and data
                  print("Logout completed - Navigating to LoginScreen..."); // Debug print
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Login Again",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Contact support functionality here"),
                    ),
                  );
                },
                child: const Text(
                  "Contact Support",
                  style: TextStyle(fontSize: 14, color: kPrimaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}