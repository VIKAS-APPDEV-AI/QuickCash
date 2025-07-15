import 'package:flutter/material.dart';
import '../../components/background.dart';
import '../../util/auth_manager.dart';
import '../HomeScreen/home_screen.dart';
import 'components/login_signup_btn.dart';
import 'components/welcome_image.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Check if the user is logged in on initial load
    _checkUserLogin();
  }

  void _checkUserLogin() {
    if (AuthManager.getUserId().isNotEmpty) {
      setState(() {
        isUserLoggedIn = true;
      });

      // Delay the navigation to HomeScreen by 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) { // Check if the widget is still mounted
          // Navigate to HomeScreen after the delay
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      });
    } else {
      setState(() {
        isUserLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isUserLoggedIn
        ? const SizedBox.shrink(
      child: Background(
          child: SingleChildScrollView(
            child: SafeArea(child: WelcomeImage()),
          )),
    ) // If the user is logged in, do nothing and don't display welcome screen
        : const Background(
      child: SingleChildScrollView(
        child: SafeArea(
          child: MobileWelcomeScreen(),
        ),
      ),
    );
  }
}

class MobileWelcomeScreen extends StatelessWidget {
  const MobileWelcomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        WelcomeImage(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 14,
              child: LoginAndSignupBtn(),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}
