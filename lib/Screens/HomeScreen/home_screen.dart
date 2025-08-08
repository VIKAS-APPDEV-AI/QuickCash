import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome// Added import for FinPayWelcomeScreen
import 'package:provider/provider.dart';
import 'package:quickcash/Screens/CardsScreen/WelcomCardScreen.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/BuyAndSellScreen/buy_and_sell_home_screen.dart';
import 'package:quickcash/Screens/CryptoScreen/WalletAddress/walletAddress_screen.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/ThemeToggle.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/dashboard_screen.dart';
import 'package:quickcash/Screens/HomeScreen/my_drawer_header.dart';
import 'package:quickcash/Screens/InvoicesScreen/CategoriesScreen/categories_screen.dart';
import 'package:quickcash/Screens/InvoicesScreen/ClientsScreen/ClientsScreen/clients_screen.dart';
import 'package:quickcash/Screens/InvoicesScreen/InvoiceDashboardScreen/invoiceDashboardScreen/invoice_dashboard_screen.dart';
import 'package:quickcash/Screens/InvoicesScreen/InvoiceTransactions/invoice_transactions_screen.dart';
import 'package:quickcash/Screens/InvoicesScreen/InvoicesScreen/Invoices/invoices_screen.dart';
import 'package:quickcash/Screens/InvoicesScreen/ManualInvoicePayment/manualInvoiceScreen/manual_invoice_screen.dart';
import 'package:quickcash/Screens/InvoicesScreen/ProductsScreen/ProductScreen/products_screen.dart';
import 'package:quickcash/Screens/InvoicesScreen/QuotesScreen/quoteScreen/quotes_screen.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/settingsMainScreen.dart';
import 'package:quickcash/Screens/LoginScreen/login_screen.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/Screens/ReferAndEarnScreen/refer_and_earn_screen.dart';
import 'package:quickcash/Screens/SpotTradeScreen/spot_trade_screen.dart';
import 'package:quickcash/Screens/StatemetScreen/StatementScreen/statement_screen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/tickets_screen.dart';
import 'package:quickcash/Screens/TransactionScreen/TransactionScreen/transaction_screen.dart';
import 'package:quickcash/Screens/UserProfileScreen/profile_main_screen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/customSnackBar.dart';
import 'package:quickcash/utils/themeProvider.dart';
import '../../util/auth_manager.dart';
import '../KYCScreen/kycHomeScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var currentPage = DrawerSections.dashboard;
  bool isCryptoExpanded = false; // Track submenu state for Crypto
  bool isInvoicesExpanded = false; // Track submenu state for Invoices
  int _selectedIndex =
      0; // Track the selected index for the bottom navigation bar

  @override
  void initState() {
    super.initState();
    // Set status bar style to avoid overlap
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  // Map the bottom navigation bar index to DrawerSections
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          currentPage = DrawerSections.dashboard; // Home
          break;
        case 1:
          currentPage = DrawerSections.transaction; // Transactions
          break;
        case 2:
          currentPage = DrawerSections.cards; // Cards
          break;
        case 3:
          currentPage = DrawerSections.userProfile; // Profile
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    Widget container;

    switch (currentPage) {
      case DrawerSections.dashboard:
        container = const DashboardScreen();
        break;
      case DrawerSections.cards:
        container =
            const FinPayWelcomeScreen(); // Updated to FinPayWelcomeScreen
        break;
      case DrawerSections.transaction:
        container = const TransactionScreen();
        break;
      case DrawerSections.statement:
        container = const StatementScreen();
        break;
      case DrawerSections.buySell:
        container = const BuyAndSellScreen();
        break;
      case DrawerSections.walletAddress:
        container = const WalletAddressScreen();
        break;
      case DrawerSections.userProfile:
        container = const ProfileMainScreen();
        break;
      case DrawerSections.spotTrade:
        container = const SpotTradeScreen();
        break;
      case DrawerSections.tickets:
        container = const TicketsScreen();
        break;
      case DrawerSections.referAndEarn:
        container = const ReferAndEarnScreen();
        break;
      case DrawerSections.invoiceDashboard:
        container = const InvoiceDashboardScreen();
        break;
      case DrawerSections.clients:
        container = const ClientsScreen();
        break;
      case DrawerSections.categories:
        container = const CategoriesScreen();
        break;
      case DrawerSections.products:
        container = const ProductsScreen();
        break;
      case DrawerSections.quotes:
        container = const QuotesScreen();
        break;
      case DrawerSections.invoicesSub:
        container = const InvoicesScreen();
        break;
      case DrawerSections.manualInvoicePayment:
        container = const ManualInvoiceScreen();
        break;
      case DrawerSections.invoiceTransactions:
        container = const InvoiceTransactionsScreen();
        break;
      case DrawerSections.settings:
        container = const SettingsMainScreen();
        break;
      default:
        container = const DashboardScreen(); // Fallback
    }

    return WillPopScope(
      onWillPop: () async {
        if (currentPage != DrawerSections.dashboard) {
          setState(() {
            currentPage = DrawerSections.dashboard;
            _selectedIndex = 0; // Reset to Home when back is pressed
          });
          return false; // Prevent default back action
        } else {
          return await _showExitDialog(); // Show exit dialog if on Dashboard
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 20, 20, 20), // Primary color
                  Color(0xFF8A2BE2), // Slightly lighter for gradient effect
                  Color(0x00000000), // Transparent at the bottom
                ],
                stops: [0.0, 0.7, 1.0],
              ),
            ),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              color: Colors.white,
              iconSize: 30,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ThemeToggleButton(isDark: isDark),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => NotificationScreen(),
                    ));
              },
              color: Colors.white,
              iconSize: 25,
            ),
            if (AuthManager.getKycStatus() != "completed")
              GestureDetector(
                onTap: () {
                  if (AuthManager.getKycDocFront().isNotEmpty) {
                    CustomSnackBar.showSnackBar(
                        context: context,
                        message:
                            "Your details are already submitted, Admin will approve after review your kyc details!",
                        color:
                            Theme.of(context).extension<AppColors>()!.primary);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KycHomeScreen(),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.asset(
                    "assets/icons/kycpending.png",
                    width: 30,
                    height: 30,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () {
                  CustomSnackBar.showSnackBar(
                      context: context,
                      message: "KYC Verified",
                      color: Theme.of(context).extension<AppColors>()!.primary);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.asset(
                    "assets/icons/kycverify.png",
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                bool shouldLogout = await mLogoutDialog(); // Show logout dialog
                if (shouldLogout) {
                  // Additional actions after logout can be added here if needed
                }
              },
              color: Colors.white,
              iconSize: 25,
            ),
          ],
        ),
        body: SafeArea(
          child: container,
        ),
        drawer: Drawer(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const MyHeaderDrawer(),
                mMyDrawerList(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet),
              label: 'Cards',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
        ),
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit"),
            content: const Text("Do you really want to exit?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // No
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Yes
                child: const Text("Yes"),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> mLogoutDialog() async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(20),
            content: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 250, // Reduced maxWidth to make the dialog narrower
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Character image
                  Image.asset(
                    'assets/images/logout.png', // Replace with your asset path
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    'Are You Logging Out?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  // Subtitle
                  const Text(
                    'Come back soon!!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel Button
                      SizedBox(
                        width: 100, // Reduced width
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(false); // Dismiss dialog, return false
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Background color
                            foregroundColor: Colors.black, // Text/icon color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary, // Border color for Cancel button
                                width: 1.5, // Border width
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, // Reduced horizontal padding
                              vertical:
                                  8, // Reduced vertical padding to reduce height
                            ),
                            minimumSize:
                                const Size(0, 36), // Reduced minimum height
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14, // Reduced font size
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10), // Add spacing between buttons
                      // Log Out Button
                      SizedBox(
                        width: 100, // Reduced width
                        child: ElevatedButton(
                          onPressed: () async {
                            // Log the user out
                            AuthManager.logout();
                            Navigator.of(context)
                                .pop(true); // Close dialog, return true
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .extension<AppColors>()!
                                .primary, // Teal background
                            foregroundColor: Colors.white, // Text/icon color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary, // Darker teal border for Log Out button
                                width: 1.5, // Border width
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, // Reduced horizontal padding
                              vertical:
                                  8, // Reduced vertical padding to reduce height
                            ),
                            minimumSize:
                                const Size(0, 36), // Reduced minimum height
                          ),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 14, // Reduced font size
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )) ??
        false;
  }

  Widget mMyDrawerList() {
    return Container(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          menuItem(
            1,
            "Dashboard",
            Image.asset("assets/icons/menu_dashboard.png",
                width: 24, height: 24),
            currentPage == DrawerSections.dashboard,
          ),
          menuItem(
            2,
            "Cards",
            Image.asset("assets/icons/menu_card.png", width: 24, height: 24),
            currentPage == DrawerSections.cards,
          ),
          menuItem(
            3,
            "Transaction",
            Image.asset("assets/icons/menu_transaction.png",
                width: 24, height: 24),
            currentPage == DrawerSections.transaction,
          ),
          menuItem(
            4,
            "Statement",
            Image.asset("assets/icons/menu_statement.png",
                width: 24, height: 24),
            currentPage == DrawerSections.statement,
          ),
          menuItem(
            5,
            "Crypto",
            Image.asset("assets/icons/menu_crypto.png", width: 24, height: 24),
            currentPage == DrawerSections.crypto,
            isDropdown: true,
            isExpanded: isCryptoExpanded,
            onTap: () {
              setState(() {
                isCryptoExpanded = !isCryptoExpanded;
                if (isCryptoExpanded) {
                  isInvoicesExpanded = false;
                }
              });
            },
          ),
          if (isCryptoExpanded) ...[
            submenuItem(
              " - Buy / Sell / Swap",
              () {
                Navigator.pop(context);
                setState(() {
                  currentPage = DrawerSections.buySell;
                  _selectedIndex = 0; // Reset to Home for non-bottom-nav pages
                });
              },
            ),
            submenuItem(
              " - Wallet Address",
              () {
                Navigator.pop(context);
                setState(() {
                  currentPage = DrawerSections.walletAddress;
                  _selectedIndex = 0; // Reset to Home for non-bottom-nav pages
                });
              },
            ),
          ],
          menuItem(
            6,
            "User Profile",
            Image.asset("assets/icons/menu_userprofile.png",
                width: 24, height: 24),
            currentPage == DrawerSections.userProfile,
          ),
          menuItem(
            7,
            "Spot Trade",
            Image.asset("assets/icons/menu_spot_trade.png",
                width: 24, height: 24),
            currentPage == DrawerSections.spotTrade,
          ),
          menuItem(
            8,
            "Tickets",
            Image.asset("assets/icons/menu_support.png", width: 24, height: 24),
            currentPage == DrawerSections.tickets,
          ),
          menuItem(
            9,
            "Refer & Earn",
            Image.asset("assets/icons/menu_refer_reward.png",
                width: 24, height: 24),
            currentPage == DrawerSections.referAndEarn,
          ),
          menuItem(
            10,
            "Invoices",
            Image.asset("assets/icons/menu_invoice.png", width: 24, height: 24),
            currentPage == DrawerSections.invoices,
            isDropdown: true,
            isExpanded: isInvoicesExpanded,
            onTap: () {
              setState(() {
                isInvoicesExpanded = !isInvoicesExpanded;
                if (isInvoicesExpanded) {
                  isCryptoExpanded = false;
                }
              });
            },
          ),
          if (isInvoicesExpanded) ...[
            submenuItem(
              " - Invoice Dashboard",
              () {
                Navigator.pop(context);
                setState(() {
                  currentPage = DrawerSections.invoiceDashboard;
                  _selectedIndex = 0; // Reset to Home for non-bottom-nav pages
                });
              },
            ),
            submenuItem(
              " - Clients",
              () {
                Navigator.pop(context);
                setState(() {
                  currentPage = DrawerSections.clients;
                  _selectedIndex = 0; // Reset to Home for non-bottom-nav pages
                });
              },
            ),
            submenuItem(
              " - Categories",
              () {
                Navigator.pop(context);
                setState(() {
                  currentPage = DrawerSections.categories;
                  _selectedIndex = 0; // Reset to Home for non-bottom-nav pages
                });
              },
            ),
            submenuItem(
              " - Products",
              () {
                Navigator.pop(context);
                setState(() {
                  currentPage = DrawerSections.products;
                  _selectedIndex = 0; // Reset to Home for non-bottom-nav pages
                });
              },
            ),
            submenuItem(
              " - Quotes",
              () {
                Navigator.pop(context);
                setState(() {
                  currentPage = DrawerSections.quotes;
                  _selectedIndex = 0; // Reset to Home for non-bottom-nav pages
                });
              },
            ),
            submenuItem(
              " - Invoices",
              () {
                Navigator.pop(context);
                setState(() {
                  currentPage = DrawerSections.invoicesSub;
                  _selectedIndex = 0; // Reset to Home for non-bottom-nav pages
                });
              },
            ),
            submenuItem(
              " - Manual Invoice Payment",
              () {
                Navigator.pop(context);
                setState(() {
                  currentPage = DrawerSections.manualInvoicePayment;
                  _selectedIndex = 0; // Reset to Home for non-bottom-nav pages
                });
              },
            ),
            submenuItem(
              " - Invoice Transactions",
              () {
                Navigator.pop(context);
                setState(() {
                  currentPage = DrawerSections.invoiceTransactions;
                  _selectedIndex = 0; // Reset to Home for non-bottom-nav pages
                });
              },
            ),
            submenuItem(
              " - Settings",
              () {
                Navigator.pop(context);
                setState(() {
                  currentPage = DrawerSections.settings;
                  _selectedIndex = 0; // Reset to Home for non-bottom-nav pages
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget menuItem(int id, String title, Widget icon, bool selected,
      {bool isDropdown = false, bool isExpanded = false, Function()? onTap}) {
    return Material(
      color: selected ? Color(0xFFF1E6FF) : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap();
          } else {
            setState(() {
              currentPage = DrawerSections.values[id - 1];
              // Update _selectedIndex based on the selected page
              if (currentPage == DrawerSections.dashboard) {
                _selectedIndex = 0;
              } else if (currentPage == DrawerSections.transaction) {
                _selectedIndex = 1;
              } else if (currentPage == DrawerSections.cards) {
                _selectedIndex = 2;
              } else if (currentPage == DrawerSections.userProfile) {
                _selectedIndex = 3;
              } else {
                _selectedIndex = 0; // Default to Home for other pages
              }
              Navigator.pop(context); // Close the drawer
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 20),
              Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          Theme.of(context).extension<AppColors>()!.primary)),
              const Spacer(),
              if (isDropdown)
                Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget submenuItem(String title, Function() onTap) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).extension<AppColors>()!.primary)),
          ],
        ),
      ),
    );
  }
}

enum DrawerSections {
  dashboard,
  cards,
  transaction,
  statement,
  crypto,
  userProfile,
  spotTrade,
  tickets,
  referAndEarn,
  invoices,
  walletAddress,
  buySell,
  invoiceDashboard,
  clients,
  categories,
  products,
  quotes,
  invoicesSub,
  manualInvoicePayment,
  invoiceTransactions,
  settings,
}
