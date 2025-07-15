import 'package:flutter/material.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/Screens/LoginScreen/login_screen.dart';

class TokenExpireDialog {
  static Future<bool> showTokenExpireDialog(BuildContext context) async {
    return (await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => AlertDialog(
        title: const Text("Login Again"),
        content: const Text("Token has been expired, Please Login Again!"),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              // Log the user out
              AuthManager.logout();
              Navigator.of(context).pop(true);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    )) ?? false;
  }
}