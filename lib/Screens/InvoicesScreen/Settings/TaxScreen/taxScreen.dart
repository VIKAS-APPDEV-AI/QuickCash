import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/TaxScreen/AddTaxScreen/AddTaxScreen.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/TaxScreen/model/taxDeleteApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/TaxScreen/model/taxDetailsApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/TaxScreen/model/taxDetailsModel.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/TaxScreen/updateTaxDetailsScreen/updateTaxDetailsScreen.dart';

import '../../../../constants.dart';
import '../../../../util/customSnackBar.dart';

class TaxScreen extends StatefulWidget {
  const TaxScreen({super.key});

  @override
  State<TaxScreen> createState() => _TaxScreen();
}

class _TaxScreen extends State<TaxScreen> {
  final TaxDetailsApi _taxDetailsApi = TaxDetailsApi();
  final TaxDeleteApi _taxDeleteApi = TaxDeleteApi();
  List<TaxDetailsItem> taxDetailsList = [];

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    mTaxDetails("Yes");
    super.initState();
  }

  Future<void> mTaxDetails(String s) async {
    setState(() {
      if(s =="Yes"){
        isLoading = true;
        errorMessage = null;
      }
    });

    try {
      final response = await _taxDetailsApi.taxDetailsApi();

      if (response.taxDetailsList != null && response.taxDetailsList!.isNotEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = null;
          taxDetailsList = response.taxDetailsList!;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Tax List';
          CustomSnackBar.showSnackBar(context: context, message: "No Tax List", color: kPrimaryColor);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        CustomSnackBar.showSnackBar(context: context, message: errorMessage!, color: kRedColor);
      });
    }
  }

  Future<void> mTaxDelete(String? taxId) async {
    setState(() {
      isLoading = false;
      errorMessage = null;
    });
    try{
      final response = await _taxDeleteApi.taxDeleteApi(taxId!);

      if(response.message == "Tax is successfully deleted"){
        setState(() {
          isLoading = false;
          errorMessage = null;
          Navigator.of(context).pop(false);
          mTaxDetails("No");
          CustomSnackBar.showSnackBar(context: context, message: "Tax data has been deleted successfully", color: kPrimaryColor);
        });
      }else{
        setState(() {
          isLoading = false;
          errorMessage = null;
          Navigator.of(context).pop(false);
          CustomSnackBar.showSnackBar(context: context, message: "We are facing some issue!", color: kPrimaryColor);
        });
      }

    }catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        CustomSnackBar.showSnackBar(context: context, message: errorMessage!, color: kRedColor);
      });
    }
  }

  // Function to format the date
  String formatDate(String? dateTime) {
    if (dateTime == null) {
      return 'Date not available';
    }
    DateTime date = DateTime.parse(dateTime);
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 150,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddTaxScreen()),
                        );
                      },
                      backgroundColor: kPrimaryColor,
                      label: const Text(
                        'Add Tax',
                        style: TextStyle(color: kWhiteColor, fontSize: 15),
                      ),
                      icon: const Icon(Icons.add, color: kWhiteColor),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
              )
                  : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: taxDetailsList.length,
                  itemBuilder: (context, index) {
                    final taxDetails = taxDetailsList[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: defaultPadding),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(defaultPadding),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Date:',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                Text(formatDate(taxDetails.createdAt),
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: smallPadding),
                            const Divider(color: kPrimaryLightColor),
                            const SizedBox(height: smallPadding),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Name:',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                Text(taxDetails.name!,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: smallPadding),
                            const Divider(color: kPrimaryLightColor),
                            const SizedBox(height: smallPadding),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Value:',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                Text(
                                  taxDetails.taxValue?.toString() ?? '0.0', // Safely handle null values
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: smallPadding),
                            const Divider(color: kPrimaryLightColor),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Default:',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                Switch(
                                  value: taxDetails.isDefaultSwitch, // Use the updated value
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      taxDetails.isDefaultSwitch = newValue; // Update the switch state for this specific item
                                    });
                                  },
                                  activeColor: kPurpleColor,
                                ),
                              ],
                            ),

                            const Divider(color: kPrimaryLightColor),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // IconButton with text
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: [
                                    // Conditionally show the Edit icon based on status
                                    Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  UpdateTaxScreen(taxId: taxDetails.id,taxName: taxDetails.name, taxValue: taxDetails.taxValue, taxType: taxDetails.isDefault)),
                                            );
                                          },
                                        ),
                                        const Text(
                                          'Edit',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      width: smallPadding,
                                    ),

                                    Column(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            mDeleteTaxDialog(taxDetails.id);
                                          },
                                        ),
                                        const Text(
                                          'Delete',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      width: defaultPadding,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> mDeleteTaxDialog(String? taxId) async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Quote"),
        content: const Text("Do you really want to delete this tax?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // No
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              mTaxDelete(taxId);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    )) ?? false;
  }
}
