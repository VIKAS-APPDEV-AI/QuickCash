import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickcash/Screens/DashboardScreen/BeneficiaryScreen/show_beneficiary.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/PayRecipientsScree/pay_recipients_screen.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/DashboardTicketScreen.dart';
import 'package:quickcash/constants.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Send Money",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bell_fill),
            onPressed: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => NotificationScreen(),
                  ));
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.headphones),
            onPressed: () {
             Navigator.push(context, CupertinoPageRoute(builder: (context) => DashboardTicketScreen(),));
            },
            tooltip: 'Support',
          ),
          const SizedBox(width: 8),
        ],
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Card - Someone New
              GestureDetector(
                onTap: () {
                  // Navigate to PayRecipientsScreen when tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PayRecipientsScreen()),
                  );
                },
                child: Card(
                  elevation: 4.0,
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_box,
                          size: 60,
                          color:
                              Theme.of(context).extension<AppColors>()!.primary,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Someone New',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).extension<AppColors>()!.black,),
                              ),
                              Text(
                                'Pay a recipient\'s bank account',
                                style: TextStyle(color: Colors.grey,),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.navigate_next_rounded,
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .primary),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: defaultPadding),

              GestureDetector(
                onTap: () {
                  // Navigate to PayRecipientsScreen when tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ShowBeneficiaryScreen()),
                  );
                },
                child: Card(
                  elevation: 4.0,
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 60,
                          color:
                              Theme.of(context).extension<AppColors>()!.primary,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recipient',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).extension<AppColors>()!.black),
                              ),
                              Text(
                                'Pay a recipient\'s bank account',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.navigate_next_rounded,
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .primary),
                      ],
                    ),
                  ),
                ),
              ),

              // Second Card

              const SizedBox(height: defaultPadding),

              /*  GestureDetector(
                onTap: () {
                  // Navigate to PayRecipientsScreen when tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyAccountsScreen()),
                  );
                },
                child: const Card(
                  elevation: 4.0,
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance,
                          size: 60,
                          color: Theme.of(context).extension<AppColors>()!.primary,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Accounts',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Change Primary account from available sub accounts',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.navigate_next_rounded, color: Theme.of(context).extension<AppColors>()!.primary),
                      ],
                    ),
                  ),
                ),

              ),


              const SizedBox(height: defaultPadding),

              GestureDetector(
                onTap: () {
                  // Navigate to PayRecipientsScreen when tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExchangeMoneyScreen()),
                  );
                },
                child: const Card(
                  elevation: 4.0,
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Row(
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          size: 60,
                          color: Theme.of(context).extension<AppColors>()!.primary,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Exchange',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Move funds between accounts',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.navigate_next_rounded, color: Theme.of(context).extension<AppColors>()!.primary),
                      ],
                    ),
                  ),
                ),
              ),
*/
            ],
          ),
        ),
      ),
    );
  }
}
