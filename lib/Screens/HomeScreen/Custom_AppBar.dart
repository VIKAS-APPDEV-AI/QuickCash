import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/ThemeToggle.dart';
import 'package:quickcash/Screens/KYCScreen/kycHomeScreen.dart';
import 'package:quickcash/Screens/LoginScreen/login_screen.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/customSnackBar.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:provider/provider.dart';
import '../../utils/themeProvider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function()? onLogoutConfirmed;

  const CustomAppBar({Key? key, this.onLogoutConfirmed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Set transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark, // iOS
    ),
  );
  
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 20, 20, 20),
              Color(0xFF8A2BE2),
              Color(0x00000000),
            ],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
          color: Colors.white,
          iconSize: 30,
        ),
      ),
      actions: [
        ThemeToggleButton(isDark: isDark),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => NotificationScreen(),
              ),
            );
          },
          color: Colors.white,
          iconSize: 25,
        ),
        _buildKycStatusIcon(context),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _showLogoutDialog(context),
          color: Colors.white,
          iconSize: 25,
        ),
      ],
    );
  }

  Widget _buildKycStatusIcon(BuildContext context) {
    bool isKycDone = AuthManager.getKycStatus() == "completed";
    return GestureDetector(
      onTap: () {
        if (isKycDone) {
          CustomSnackBar.showSnackBar(
            context: context,
            message: "KYC Verified",
            color: Theme.of(context).extension<AppColors>()!.primary,
          );
        } else if (AuthManager.getKycDocFront().isNotEmpty) {
          CustomSnackBar.showSnackBar(
            context: context,
            message:
                "Your KYC details are already submitted. Please wait for admin approval.",
            color: Theme.of(context).extension<AppColors>()!.primary,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KycHomeScreen()),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Image.asset(
          isKycDone
              ? "assets/icons/kycverify.png"
              : "assets/icons/kycpending.png",
          width: 30,
          height: 30,
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logout.png', height: 50, width: 50),
                const SizedBox(height: 20),
                const Text(
                  'Are You Logging Out?',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Come back soon!!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _logoutDialogButton(
                      context,
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context, false),
                      isPrimary: false,
                    ),
                    _logoutDialogButton(
                      context,
                      text: 'Log Out',
                      onPressed: () {
                        AuthManager.logout();
                        Navigator.pop(context, true);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      isPrimary: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ) ??
        false;

    if (shouldLogout && onLogoutConfirmed != null) {
      onLogoutConfirmed!();
    }
  }

  Widget _logoutDialogButton(BuildContext context,
      {required String text,
      required VoidCallback onPressed,
      required bool isPrimary}) {
    return SizedBox(
      width: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? Theme.of(context).extension<AppColors>()!.primary
              : Colors.white,
          foregroundColor: isPrimary ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(
              color: Theme.of(context).extension<AppColors>()!.primary,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          minimumSize: const Size(0, 36),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isPrimary ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
