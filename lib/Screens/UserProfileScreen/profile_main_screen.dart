import 'package:flutter/material.dart';
import 'package:quickcash/Screens/UserProfileScreen/AccountListsScreen/accounts_list_screen.dart';
import 'package:quickcash/Screens/UserProfileScreen/AdditionalInformationScreen/additional_information_screen.dart';
import 'package:quickcash/Screens/UserProfileScreen/BeneficiaryAccountListScreen/beneficiaryAccountListScreen.dart';
import 'package:quickcash/Screens/UserProfileScreen/DocumentsScreen/documents_screen.dart';
import 'package:quickcash/Screens/UserProfileScreen/LoginHistoryScreen/login_history.dart';
import 'package:quickcash/Screens/UserProfileScreen/SecurityScreen/ChangePasswordModel/ProfileChangePassword.dart';
import 'package:quickcash/Screens/UserProfileScreen/SecurityScreen/security_screen.dart';
import 'package:quickcash/Screens/UserProfileScreen/UserUpdateDetailsScreen/update_details_screen.dart';
import 'package:quickcash/Screens/UserProfileScreen/UserProfileScreen/userInformation_screen.dart';

List<String> titles = <String>[
  'User Information',
  'Login History',
  'Update Details',
  'Documents',
  'Additional Information',
  'Accounts List',
  'BeneficiaryAccountListScreen'
];

class ProfileMainScreen extends StatefulWidget {
  const ProfileMainScreen({super.key});

  @override
  State<ProfileMainScreen> createState() => _ProfileMainScreen();
}

class _ProfileMainScreen extends State<ProfileMainScreen> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    colorScheme.primary.withOpacity(0.05);
    colorScheme.primary.withOpacity(0.15);
    const int tabsCount = 7;

    return DefaultTabController(
      initialIndex: 0,
      length: tabsCount,
      child: Scaffold(
        body: Column(
          children: [
            // Padding to avoid overlapping with the status bar
            Padding(
              padding: const EdgeInsets.only(top: 0.0), // Adjust as needed
              child: TabBar(
                isScrollable: true,
                tabs: <Widget>[
                  Tab(text: titles[0]),
                  Tab(text: titles[1]),
                  Tab(text: titles[2]),
                  Tab(text: titles[3]),
                  Tab(text: titles[4]),
                  Tab(text: titles[5]),
                  Tab(text: titles[6]),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: <Widget>[
                  // User Information Tab
                  UserInformationScreen(),
                  LoginHistoryScreen(),
                 // ProfileSecurityScreen(),
                  UpdateDetailsScreen(),
                  DocumentsScreen(),
                  AdditionalInfoScreen(),
                  AccountsListScreen(),
                  BeneficiaryAccountListScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
