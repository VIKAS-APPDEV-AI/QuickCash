import 'package:flutter/material.dart';
import 'package:quickcash/Screens/DashboardScreen/BeneficiaryScreen/show_beneficiary.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/PayRecipientsScree/pay_recipients_screen.dart';
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
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Send Money",
          style: TextStyle(color: Colors.white),
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
                    MaterialPageRoute(builder: (context) => const PayRecipientsScreen()),
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
                          Icons.add_box,
                          size: 60,
                          color: kPrimaryColor,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Someone New',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Pay a recipient\'s bank account',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.navigate_next_rounded, color: kPrimaryColor),
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
                    MaterialPageRoute(builder: (context) => const ShowBeneficiaryScreen()),
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
                          Icons.person,
                          size: 60,
                          color: kPrimaryColor,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recipient',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Pay a recipient\'s bank account',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.navigate_next_rounded, color: kPrimaryColor),
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
                          color: kPrimaryColor,
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
                        Icon(Icons.navigate_next_rounded, color: kPrimaryColor),
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
                          color: kPrimaryColor,
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
                        Icon(Icons.navigate_next_rounded, color: kPrimaryColor),
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
