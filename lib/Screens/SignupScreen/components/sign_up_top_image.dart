import 'package:flutter/material.dart';

import '../../../constants.dart';

class SignUpScreenTopImage extends StatelessWidget {
  const SignUpScreenTopImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Text(
              "Sign Up",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Theme.of(context).extension<AppColors>()!.primary),
            ),
            const SizedBox(height: defaultPadding),
            Row(
              children: [
                const Spacer(),
                Expanded(
                  flex: 8,
                  child: Image.asset("assets/images/image2.png"),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: defaultPadding),
          ],
        ),
        // Back arrow icon at the top-left
        Positioned(
          top: 0,
          left: 0,
          child: IconButton(
            icon:  Icon(
              Icons.arrow_back,
              color: Theme.of(context).extension<AppColors>()!.primary,
              size: 28,
            ),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous screen
            },
          ),
        ),
      ],
    );
  }
}