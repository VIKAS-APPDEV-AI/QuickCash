import 'package:flutter/material.dart';

import '../../../constants.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({super.key,});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Welcome To Quickcash",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28,color: kPrimaryColor),
        ),
        const SizedBox(height: defaultPadding * 2),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: Image.asset("assets/images/image3.jpg"),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}