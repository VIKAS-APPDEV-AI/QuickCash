import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quickcash/Screens/UserProfileScreen/BeneficiaryAccountListScreen/model/beneficiaryAccountApi.dart';
import 'package:quickcash/Screens/UserProfileScreen/BeneficiaryAccountListScreen/model/beneficiaryAccountModel.dart';
import 'package:quickcash/util/CurrencyImageList.dart';
import 'package:quickcash/util/currency_utils.dart' as CurrencyFlagHelper;

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
    final colors = Theme.of(context).extension<AppColors>()!;
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
                              style:
                                  TextStyle(color: Colors.black, fontSize: 13)),
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
                        color: colors.background,
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
                          color: colors.purple, // Purple border color
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
                              child: SizedBox(
                                height: 70,
                                width: 70,
                                child: (beneficiaryList.currency
                                            ?.toUpperCase() ==
                                        'EUR')
                                    ? CurrencyFlagHelper.getEuFlagWidget()
                                    : CountryFlag.fromCountryCode(
                                        CurrencyCountryMapper.getCountryCode(
                                            beneficiaryList.currency),
                                        height: 70,
                                        width: 70,
                                        shape: const Circle(),
                                      ),
                              ),
                            ),

                            const SizedBox(
                              height: largePadding,
                            ),

                            Text(
                              "Currency:",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .extension<AppColors>()!
                                      .primary,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              beneficiaryList.currency ?? 'N/A',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .extension<AppColors>()!
                                      .primary),
                            ),

                            const SizedBox(
                                height: 8), // Small space between rows
                            Text(
                              "IBAN / Routing / Account Number",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .extension<AppColors>()!
                                      .primary,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              beneficiaryList.iban ?? 'N/A',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .extension<AppColors>()!
                                      .primary),
                            ),

                            const SizedBox(
                              height: smallPadding,
                            ),

                            Text(
                              "BIC / IFSC:",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .extension<AppColors>()!
                                      .primary,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              beneficiaryList.bic ?? 'N/A',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .extension<AppColors>()!
                                      .primary),
                            ),

                            const SizedBox(
                                height: 8), // Small space between rows
                            Text(
                              "Balance:",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .extension<AppColors>()!
                                      .primary,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${beneficiaryList.balance ?? 0.0}',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .extension<AppColors>()!
                                      .primary),
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
