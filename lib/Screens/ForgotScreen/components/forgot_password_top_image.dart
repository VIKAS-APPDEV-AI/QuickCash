import 'package:flutter/material.dart';
import '../../../constants.dart';

class ForgotPasswordTopImage extends StatelessWidget {
  const ForgotPasswordTopImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add Row with back arrow and title
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: kPrimaryColor,
              ),
              onPressed: () {
                Navigator.pop(context); // Go back to previous screen
              },
            ),
            Expanded(
              child: Center(
                child: const Text(
                  "Forgot Password",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ),
            // Add an empty SizedBox to balance the layout
            SizedBox(width: 48), // Matches IconButton width
          ],
        ),
        const SizedBox(height: defaultPadding * 5),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: Image.asset("assets/images/image4.jpg"),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}