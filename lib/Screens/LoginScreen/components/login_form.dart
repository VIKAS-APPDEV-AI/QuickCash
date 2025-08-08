import 'package:flutter/material.dart';
import 'package:quickcash/Screens/ForgotScreen/forgot_pasword_screen.dart';
import 'package:quickcash/Screens/HomeScreen/home_screen.dart';
import 'package:quickcash/Screens/LoginScreen/components/PopUpMessagesSnackbar.dart';
import 'package:quickcash/components/check_already_have_an_account.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/Screens/SignupScreen/signup_screen.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/util/error_handler.dart';
import '../models/loginApi.dart';
import 'package:local_auth/local_auth.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final LoginApi _loginApi = LoginApi();
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _obsecureText = true;
  bool isLoading = false;
  String? errorMessage;

  bool _isPasswordValid(String password) {
    final regex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%&*,.?])(?=.*[0-9]).{8,}$');
    return regex.hasMatch(password);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print("Email: ${email.text}");
      print("Password: ${password.text}");

      try {
        final response = await _loginApi.login(email.text, password.text);

        print("Login Response: ${response.toString()}");
        print('User ID: ${response.userId}');
        print('Token: ${response.token}');
        print('Name: ${response.name}');
        print('Email: ${response.email}');
        print('Owner Profile: ${response.ownerProfile}');
        print('KycStatus: ${response.kycStatus}');

        await AuthManager.saveCredentials(email.text, password.text);
        await AuthManager.login(response.token);
        await AuthManager.saveUserId(response.userId);
        await AuthManager.saveUserName(response.name);
        await AuthManager.saveUserEmail(response.email);
        await AuthManager.saveUserImage(
            response.ownerProfile?.toString() ?? '');

        if (response.kycStatus == false) {
          await AuthManager.saveKycStatus("completed");
        } else {
          await AuthManager.saveKycStatus(response.kycStatus.toString());
        }

        setState(() {
          isLoading = false;
        });

        CustomSnackbar.show(context, "Login successful!");

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (error) {
        print("Login Error: $error");

        setState(() {
          isLoading = false;
        });

        // 🔥 Friendly user-facing message
        String userMessage = getFriendlyErrorMessage(error);
        CustomSnackbar.show(context, userMessage, isError: true);
      }
    }
  }

  Future<void> _loginWithFingerprint() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        setState(() {
          isLoading = false;
        });
        CustomSnackbar.show(context, "Biometric not available on this device",
            isError: true);
        return;
      }

      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to log in',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        final credentials = await AuthManager.getCredentials();
        if (credentials['email'] == null || credentials['password'] == null) {
          setState(() {
            isLoading = false;
          });
          CustomSnackbar.show(context, "No stored credentials found.",
              isError: true);
          return;
        }

        email.text = credentials['email']!;
        password.text = credentials['password']!;
        await _login();
      } else {
        setState(() {
          isLoading = false;
        });
        CustomSnackbar.show(context, "Fingerprint authentication failed.",
            isError: true);
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      CustomSnackbar.show(context, "Error: $error", isError: true);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _togglePasswordVisibilty() {
    setState(() {
      _obsecureText = !_obsecureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              cursorColor: Color(0xFF9568ff),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                final regex =
                    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                if (!regex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "Your Email",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.email, color: AppColors.light.primary,),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultPadding),
              child: TextFormField(
                controller: password,
                textInputAction: TextInputAction.done,
                obscureText: _obsecureText,
                cursorColor: Color(0xFF9568ff),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (!_isPasswordValid(value)) {
                    return 'Password must contain at least one lowercase letter, one uppercase letter, one number, and one special character.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Your Password",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.lock, color: AppColors.light.primary,),
                  ),
                  suffixIcon: IconButton(
                    onPressed: _togglePasswordVisibilty,
                    icon: Icon(
                      _obsecureText ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.light.primary,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child:  Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.light.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            if (isLoading)
              const CircularProgressIndicator(
                color: Color(0xFF9568ff),
              ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              child: const Text("Sign In"),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 120,
                    child: Divider(
                      color: Color(0xFF9568ff),
                      thickness: 1,
                    )),
                SizedBox(
                  width: 10,
                ),
                Text("Or"),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                    width: 120,
                    child: Divider(
                      color: Color(0xFF9568ff),
                      thickness: 1,
                    )),
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<bool>(
              future: _localAuth.canCheckBiometrics,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data == true) {
                  return GestureDetector(
                    onTap: isLoading
                        ? null
                        : () async {
                            await _loginWithFingerprint(); // Properly call the async function
                          },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fingerprint, size: 20),
                        SizedBox(width: 10),
                        Text("Login With FingerPrints"),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 30),
            AlreadyHaveAnAccountCheck(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
