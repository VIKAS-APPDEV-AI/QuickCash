import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/lottie/CoinFlip.json', // Path to your Lottie JSON file
        width: 250, // Optional: Adjust size as needed
        height: 250, // Optional: Adjust size as needed
        fit: BoxFit.contain,
      ),
    );
  }
}
