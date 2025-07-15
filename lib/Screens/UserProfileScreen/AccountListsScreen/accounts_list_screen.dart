import 'package:flutter/material.dart';
import 'package:quickcash/Screens/UserProfileScreen/AccountListsScreen/model/accountsListApi.dart';
import 'package:quickcash/constants.dart';
import 'model/accountsListModel.dart';

class AccountsListScreen extends StatefulWidget {
  const AccountsListScreen({super.key});

  @override
  State<AccountsListScreen> createState() => _AccountsListScreen();
}

class _AccountsListScreen extends State<AccountsListScreen> {
  final AccountsListApi _accountsListApi = AccountsListApi();

  bool isLoading = false;
  String? errorMessage;
  List<AccountDetail> accountData = [];

  @override
  void initState() {
    super.initState();
    mAccountsDetails();
  }

  Future<void> mAccountsDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _accountsListApi.accountListApi();

      if (response.accountDetails != null && response.accountDetails!.isNotEmpty) {
        setState(() {
          accountData = response.accountDetails!;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No accounts found.';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(smallPadding),
        child: Column(
          children: [
            const SizedBox(height: largePadding),
            if (isLoading)
              const Center(child: CircularProgressIndicator()),
            if (errorMessage != null)
              Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red))),
            if (!isLoading && errorMessage == null && accountData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: accountData.length,
                  itemBuilder: (context, index) {
                    var account = accountData[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(defaultPadding),
                        ),
                        child: Container(
                          width: 320,
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: largePadding),

                              // Display currency code inside a circle
                              Center(
                                child: CircleAvatar(
                                  radius: 60, // Size of the circle
                                  backgroundColor: kPrimaryColor, // Background color of the circle
                                  child: Text(
                                    account.currency ?? 'N/A', // Display the currency code
                                    style: const TextStyle(
                                      fontSize: 30, // Font size of the currency code
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // Text color
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 35),
                              const Divider(color: kWhiteColor),
                              const SizedBox(height: defaultPadding),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Currency: ${account.currency ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: smallPadding),
                                  const Divider(color: kWhiteColor),
                                  const SizedBox(height: smallPadding),

                                  const Text(
                                    'IBAN / Routing / Account Number:',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  Text(
                                    account.iban ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: smallPadding),
                                  const Divider(color: kWhiteColor),
                                  const SizedBox(height: smallPadding),

                                  const Text(
                                    'BIC / IFSC:',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  Text(
                                    account.bicCode?.toString() ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: smallPadding),
                                  const Divider(color: kWhiteColor),
                                  const SizedBox(height: smallPadding),

                                  const Text(
                                    'Balance:',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  Text(
                                    '${account.amount ?? 0.0}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
