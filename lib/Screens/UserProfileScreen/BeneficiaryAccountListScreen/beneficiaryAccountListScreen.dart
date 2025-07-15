import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quickcash/Screens/UserProfileScreen/BeneficiaryAccountListScreen/model/beneficiaryAccountApi.dart';
import 'package:quickcash/Screens/UserProfileScreen/BeneficiaryAccountListScreen/model/beneficiaryAccountModel.dart';

import '../../../constants.dart';

class BeneficiaryAccountListScreen extends StatefulWidget {
  const BeneficiaryAccountListScreen({super.key});

  @override
  State<BeneficiaryAccountListScreen> createState() =>
      _BeneficiaryAccountListState();
}

class _BeneficiaryAccountListState extends State<BeneficiaryAccountListScreen> {
  final BeneficiaryListApi _beneficiaryListApi = BeneficiaryListApi();

  List<BeneficiaryAccountListDetails> beneficiaryAccountData = [];

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    mBeneficiaryAccountList();
  }

  Future<void> mBeneficiaryAccountList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _beneficiaryListApi.beneficiaryAccountListApi();

      if (response.beneficiaryAccountList != null &&
          response.beneficiaryAccountList!.isNotEmpty) {
        setState(() {
          beneficiaryAccountData = response.beneficiaryAccountList!;
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
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (errorMessage != null)
              Column(
              
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                           Lottie.asset('assets/lottie/NoTransactions.json',
                      height: 120),
                  const SizedBox(height: 0),
                  const Text("There is no Beneficiary Account Here",
                      style: TextStyle(color: Colors.black, fontSize: 13)),
                        ],
                      ),
                        
                    ],
                  ),
                  
                ],
              ),
            if (!isLoading &&
                errorMessage == null &&
                beneficiaryAccountData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: beneficiaryAccountData.length,
                  itemBuilder: (context, index) {
                    final beneficiaryList = beneficiaryAccountData[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: defaultPadding),
                      // Margin for card spacing
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        // Background color of the container
                        borderRadius: BorderRadius.circular(smallPadding),
                        // Rounded corners for the container
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: kPurpleColor, // Purple border color
                          width: 1, // Border width
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        // Padding for content inside the container
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display currency code inside a circle
                            Center(
                              child: CircleAvatar(
                                radius: 50,
                                // Size of the circle
                                backgroundColor: kPrimaryColor,
                                // Background color of the circle
                                child: Text(
                                  beneficiaryList.currency ??
                                      'N/A', // Display the currency code
                                  style: const TextStyle(
                                    fontSize: 30,
                                    // Font size of the currency code
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // Text color
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: largePadding,
                            ),

                            const Text(
                              "Currency:",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              beneficiaryList.currency ?? 'N/A',
                              style: const TextStyle(color: kPrimaryColor),
                            ),

                            const SizedBox(
                                height: 8), // Small space between rows
                            const Text(
                              "IBAN / Routing / Account Number",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              beneficiaryList.iban ?? 'N/A',
                              style: const TextStyle(color: kPrimaryColor),
                            ),

                            const SizedBox(
                              height: smallPadding,
                            ),

                            const Text(
                              "BIC / IFSC:",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              beneficiaryList.bic ?? 'N/A',
                              style: const TextStyle(color: kPrimaryColor),
                            ),

                            const SizedBox(
                                height: 8), // Small space between rows
                            const Text(
                              "Balance:",
                              style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${beneficiaryList.balance ?? 0.0}',
                              style: const TextStyle(color: kPrimaryColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
