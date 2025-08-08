import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickcash/Screens/DashboardScreen/BeneficiaryScreen/select_beneficiary_screen.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/PayRecipientsScree/recipientListModel/receipientModel.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/PayRecipientsScree/recipientListModel/recipientApi.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/UpdateRecipientScreen/updateRecipientScreen.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/DashboardTicketScreen.dart';
import 'package:quickcash/constants.dart';

class ShowBeneficiaryScreen extends StatefulWidget {
  const ShowBeneficiaryScreen({super.key});

  @override
  State<ShowBeneficiaryScreen> createState() => _ShowBeneficiaryScreen();
}

class _ShowBeneficiaryScreen extends State<ShowBeneficiaryScreen> {
  final RecipientsListApi _recipientsListApi = RecipientsListApi();
  List<Recipient> recipientsListData = [];

  bool isLoading = false;

  @override
  void initState() {
    mRecipients();
    super.initState();
  }

  Future<void> mRecipients() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _recipientsListApi.recipientsListApi();

      if (response.recipients != null && response.recipients!.isNotEmpty) {
        setState(() {
          isLoading = false;
          recipientsListData = response.recipients!;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Recipients",
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
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Beneficiary",
                    style: TextStyle(
                        color:
                            Theme.of(context).extension<AppColors>()!.primary,
                        fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(Icons.add,
                        color: Theme.of(context)
                            .extension<AppColors>()!
                            .primary), // Replace with your desired icon
                    onPressed: () {
                      // Navigate to PayRecipientsScreen when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SelectBeneficiaryScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: defaultPadding,
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color:
                            Theme.of(context).extension<AppColors>()!.primary,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recipientsListData.length,
                      itemBuilder: (context, index) {
                        final recipients = recipientsListData[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: smallPadding),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UpdateRecipientScreen(
                                        mRecipientId: recipients.id)),
                              );
                            },
                            child: Card(
                              elevation: 4.0,
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 0),
                              child: Padding(
                                padding: const EdgeInsets.all(defaultPadding),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.badge, // Example of a Material icon
                                      size: 60.0, // Icon size
                                      color: Theme.of(context)
                                          .extension<AppColors>()!
                                          .primary, // Icon color
                                    ),
                                    const SizedBox(width: defaultPadding),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${recipients.name}',
                                            style:  TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Theme.of(context).extension<AppColors>()!.primary,
                                            ),
                                          ),
                                          Text(
                                            '${recipients.iban}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
            ],
          ),
        ),
      ),
    );
  }
}
