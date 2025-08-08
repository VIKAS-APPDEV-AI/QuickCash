import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickcash/Screens/CardsScreen/WelcomCardScreen.dart';
import 'package:quickcash/Screens/DashboardScreen/DashboardProvider/DashboardProvider.dart';
import 'package:quickcash/Screens/WelcomeScreen/welcome_screen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/LoadingWidget.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/Screens/TransactionScreen/TransactionDetailsScreen/transaction_details_screen.dart';
import 'package:quickcash/utils/themeProvider.dart';

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
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const QuickCashApp(),
    ),
  );
}

class QuickCashApp extends StatelessWidget {
  const QuickCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Consumer<AuthenticationState>(
      builder: (context, authState, child) {
        return MaterialApp(
          title: 'Quickcash',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: Stack(
            children: [
              const WelcomeScreen(),
              if (authState.isLoading) const LoadingWidget(),
            ],
          ),
        );
      },
    );
  }
}
