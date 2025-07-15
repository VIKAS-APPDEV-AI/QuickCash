import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickcash/Screens/DashboardScreen/DashboardProvider/DashboardProvider.dart';
import 'package:quickcash/Screens/WelcomeScreen/welcome_screen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/LoadingWidget.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/Screens/TransactionScreen/TransactionDetailsScreen/transaction_details_screen.dart';

// Define a simple state management class for authentication and loading
class AuthenticationState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false; // Add loading state

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 👇 Load environment variables first
  await dotenv.load(fileName: ".env");

  debugPrint('Stripe Key from .env: ${dotenv.env['stripePublishableKey']}');

  if (!kIsWeb) {
    Stripe.publishableKey = dotenv.env['stripePublishableKey'] ?? 'default_key';
    debugPrint('Stripe Key set to: ${Stripe.publishableKey}');
  }

  await AuthManager.init();

  await AuthManager.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthenticationState()),
        ChangeNotifierProvider(create: (context) => DashboardProvider()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
      ],
      child: const QuickCashApp(),
    ),
  );
}

class QuickCashApp extends StatelessWidget {
  const QuickCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationState>(
      builder: (context, authState, child) {
          return MaterialApp(
          title: 'Quickcash',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: kPrimaryColor,
            scaffoldBackgroundColor: Colors.white,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                foregroundColor: Colors.white,
                backgroundColor: kPrimaryColor,
                maximumSize: const Size(double.infinity, 56),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: kPrimaryLightColor,
              iconColor: kPrimaryColor,
              prefixIconColor: kPrimaryColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide.none,
              ),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              // Yaha apni desired font lagale
              Theme.of(context).textTheme,
            ),
          ),
          home: Stack(
            children: [
              // Main content
              const WelcomeScreen(), // Example home screen; replace with your actual home screen or navigation logic
              // Show loading indicator when isLoading is true
              if (authState.isLoading)
              const LoadingWidget(), // Use the Lottie animation as the global loading indicator
            ],
          ),
        );
      },
    );
  }
}
