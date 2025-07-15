import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/DashboardScreen/AllAccountsScreen/AccountDetailsScreen/accountDetailsScreen.dart';
import 'package:quickcash/Screens/DashboardScreen/AllAccountsScreen/AccountDetailsScreen/selectScreen.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListApi.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/currency_utils.dart';

import '../Dashboard/AccountsList/accountsListModel.dart';

class AllAccountsScreen extends StatefulWidget {
  const AllAccountsScreen({super.key});

  @override
  State<AllAccountsScreen> createState() => _AllAccountsScreenState();
}

class _AllAccountsScreenState extends State<AllAccountsScreen> {
  final AccountsListApi _accountsListApi = AccountsListApi();
  List<AccountsListsData> accountsListData = [];
  List<AccountsListsData> filteredAccountsList = [];
  bool isLoading = false;
  String? errorMessage;
  int? _selectedIndex;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    mAccounts();
    _searchController.addListener(_filterAccounts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> mAccounts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _accountsListApi.accountsListApi();

      if (response.accountsList != null && response.accountsList!.isNotEmpty) {
        setState(() {
          accountsListData = response.accountsList!;
          filteredAccountsList = response.accountsList!;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Account Found';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  void _filterAccounts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredAccountsList = accountsListData
          .where((account) => account.country!.toLowerCase().contains(query))
          .toList();
    });
  }

  String getCurrencySymbol(String currencyCode) {
    var format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.currencySymbol;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 75,
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "All Accounts",
          style: TextStyle(color: kWhiteColor),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              width: 50,
              height: 30,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: kWhiteColor),
                child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectCurrencyScreen(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.add,
                      color: kPrimaryColor,
                      size: 25,
                      weight: 10,
                    )),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Account by Name",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultPadding),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: mAccounts,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredAccountsList.isEmpty
                      ? const Center(child: Text("No Account Found"))
                      : ListView.builder(
                          itemCount: filteredAccountsList.length,
                          itemBuilder: (context, index) {
                            final accountsData = filteredAccountsList[index];
                            final isSelected = index == _selectedIndex;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: smallPadding),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = index;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AccountDetailsScreen(
                                          accountId: accountsData.accountId,
                                        ),
                                      ),
                                    );
                                  });
                                },
                                child: Card(
                                  elevation: 5,
                                  color:
                                      isSelected ? kPrimaryColor : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(defaultPadding),
                                  ),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(defaultPadding),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Use EU flag for EUR, country flag for others
                                            if (accountsData.currency
                                                    ?.toUpperCase() ==
                                                'EUR')
                                              getEuFlagWidget()
                                            else
                                              CountryFlag.fromCountryCode(
                                                width: 35,
                                                height: 35,
                                                accountsData.country!,
                                                shape: const Circle(),
                                              ),
                                            if (accountsData.currency
                                                    ?.toUpperCase() ==
                                                'USD')
                                              SizedBox(
                                                width: 100,
                                                height: 30,
                                                child: ElevatedButton(
                                                  onPressed: () {},
                                                  child: const Text(
                                                    'Default',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: defaultPadding),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Account Name",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : kPrimaryColor,
                                              ),
                                            ),
                                            Text(
                                              "${accountsData.Accountname}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : kPrimaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: defaultPadding),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Balance",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : kPrimaryColor,
                                              ),
                                            ),
                                            Text(
                                              "${getCurrencySymbol(accountsData.currency!)} ${accountsData.amount!.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : kPrimaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),

      //floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Ensures it's at bottom-right
    );
  }
}
