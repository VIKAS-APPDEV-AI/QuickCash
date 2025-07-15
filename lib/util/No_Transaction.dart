import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quickcash/constants.dart';

class NoTransactions extends StatelessWidget {
  const NoTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Card(
          color: kPrimaryColor,
          elevation: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Lottie.asset(
                    'assets/lottie/NoTransactions.json', // Replace with your Lottie file path
                    height: 100,
                    //width: 0, // Adjust size as needed
                  ),
                  const SizedBox(height: 0),
                  const Text(
                    "You haven’t made any transactions yet",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
