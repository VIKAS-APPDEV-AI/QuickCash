import 'package:flutter/material.dart';

import '../constants.dart';

class CustomSnackBar {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    required Color color,
    Duration duration = const Duration(milliseconds: 3000),
  }) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,style: const TextStyle(color: kWhiteColor),),
        backgroundColor: color,
        duration: duration,
      ),
    );
  }
}
