import 'package:flutter/material.dart';
import 'package:quickcash/Screens/UserProfileScreen/AccountListsScreen/model/accountsListApi.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/CurrencyImageList.dart';
import 'package:quickcash/util/currency_utils.dart' as CurrencyFlagHelper;
import 'model/accountsListModel.dart';
import 'package:country_flags/country_flags.dart';

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
      final response = await _accountsListApi.fetchAccounts();

      if (response.accountDetails != null &&
          response.accountDetails!.isNotEmpty) {
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(smallPadding),
        child: Column(
          children: [
            const SizedBox(height: largePadding),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (errorMessage != null)
              Center(
                child: Text(errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),
            if (!isLoading && errorMessage == null && accountData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: accountData.length,
                  itemBuilder: (context, index) {
                    var account = accountData[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(defaultPadding),
                        ),
                        child: Container(
                          width: 320,
                          padding: const EdgeInsets.all(defaultPadding),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.grey[100]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(defaultPadding),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: largePadding),
                              Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 70,
                                      width: 70,
                                      child: account.currency?.toUpperCase() ==
                                              'EUR'
                                          ? CurrencyFlagHelper.getEuFlagWidget()
                                          : CountryFlag.fromCountryCode(
                                              CurrencyCountryMapper
                                                  .getCountryCode(
                                                      account.currency),
                                              height: 70,
                                              width: 70,
                                              shape: const Circle(),
                                            ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      account.currency?.toUpperCase() ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? const Color.fromARGB(
                                                255, 15, 15, 15)
                                            : const Color.fromARGB(
                                                255, 15, 15, 15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              const Divider(),
                              const SizedBox(height: defaultPadding),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                      'Currency', account.currency ?? 'N/A'),
                                  _buildInfoRow('IBAN / Routing / Acc. No.',
                                      account.iban ?? 'N/A'),
                                  _buildInfoRow('BIC / IFSC',
                                      account.bicCode?.toString() ?? 'N/A'),
                                  _buildInfoRow(
                                      'Balance',
                                      account.amount != null
                                          ? account.amount!.toStringAsFixed(2)
                                          : '0.00'),
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

  Widget _buildInfoRow(String title, String value) {
    final color = Theme.of(context).extension<AppColors>()!.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
