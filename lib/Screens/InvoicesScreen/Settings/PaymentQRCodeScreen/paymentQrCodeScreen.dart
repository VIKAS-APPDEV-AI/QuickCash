import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/PaymentQRCodeScreen/AddPaymentQRCodeScreen/addPaymentQRCodeScreen.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/PaymentQRCodeScreen/PaymentQRCodeDetailsModel/paymentQRCodeDetailModel.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/PaymentQRCodeScreen/PaymentQRCodeDetailsModel/paymentQRCodeDetailsApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/PaymentQRCodeScreen/PaymentQRCodeDetailsModel/qrCodeDeleteApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/PaymentQRCodeScreen/updateQrCodeScreen/updateQrCodeScreen.dart';

import '../../../../constants.dart';
import '../../../../util/apiConstants.dart';
import '../../../../util/customSnackBar.dart';

class PaymentQRCodeScreen extends StatefulWidget {
  const PaymentQRCodeScreen({super.key});

  @override
  State<PaymentQRCodeScreen> createState() => _PaymentQRCodeScreen();
}

class _PaymentQRCodeScreen extends State<PaymentQRCodeScreen> {
  final QRCodeDetailsApi _qrCodeDetailsApi = QRCodeDetailsApi();
  final QrCodeDeleteApi _qrCodeDeleteApi = QrCodeDeleteApi();
  List<QRCodeDetailsItem> qrCodeDetailsList = [];

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    mQRCodeDetails("Yes");
    super.initState();
  }

  Future<void> mQRCodeDetails(String s) async {
    setState(() {
      if (s == "Yes") {
        isLoading = true;
        errorMessage = null;
      }
    });

    try {
      final response = await _qrCodeDetailsApi.qrCodeDetailsApi();

      if (response.qrCodeDetailsList != null &&
          response.qrCodeDetailsList!.isNotEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = null;
          qrCodeDetailsList = response.qrCodeDetailsList!;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No QR-Code List';
          CustomSnackBar.showSnackBar(
              context: context, message: "No Tax List", color: kPrimaryColor);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        CustomSnackBar.showSnackBar(
            context: context, message: errorMessage!, color: kRedColor);
      });
    }
  }

  Future<void> mQrCodeDelete(String? qrCodeId) async {
    setState(() {
      isLoading = false;
      errorMessage = null;
    });
    try{
      final response = await _qrCodeDeleteApi.qrCodeDeleteApi(qrCodeId!);

      if(response.message == "QR Code data has been deleted successfully"){
        setState(() {
          isLoading = false;
          errorMessage = null;
          Navigator.of(context).pop(false);
          mQRCodeDetails("No");
          CustomSnackBar.showSnackBar(context: context, message: "QR Code data has been deleted successfully", color: kPrimaryColor);
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
                  width: 180,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AddPaymentQRCodeScreen()),
                      );
                    },
                    backgroundColor: kPrimaryColor,
                    label: const Text(
                      'Add QR Code',
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
                    itemCount: qrCodeDetailsList.length,
                    itemBuilder: (context, index) {
                      final qrCodeDetails = qrCodeDetailsList[index];
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
                                  Text(formatDate(qrCodeDetails.createdAt),
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
                                  Text(qrCodeDetails.title!,
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
                                    'Image:',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                  if(qrCodeDetails.image !=null)

                                    ClipOval(
                                      child: Image.network(
                                        '${ApiConstants.baseQRCodeImageUrl}${qrCodeDetails.image}',
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 50,
                                            width: 50,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle, // Circular container
                                              color: kPrimaryColor, // Background color of the circle
                                            ),
                                            child: const Icon(
                                              Icons.image_outlined,
                                              color: kWhiteColor,
                                              size: 40, // Adjust the icon size as needed
                                            ),
                                          );
                                        },
                                      ),
                                    ),


                                ],
                              ),
                              const Divider(color: kPrimaryLightColor),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Default:',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                  Switch(
                                    value: qrCodeDetails.isDefaultSwitch, // Use the updated value
                                    onChanged: (bool newValue) {
                                      setState(() {
                                        qrCodeDetails.isDefaultSwitch = newValue; // Update the switch state for this specific item
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
                                                        UpdatePaymentQRCodeScreen(qrCodeId: qrCodeDetails.id,qrCodeTitle: qrCodeDetails.title, qrCodeImage: qrCodeDetails.image, qrCodeType: qrCodeDetails.isDefault)),
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
                                              mDeleteQrCodeDialog(qrCodeDetails.id);
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
                    })
          ],
        ),
      ),
    ));
  }

  Future<bool> mDeleteQrCodeDialog(String? qrCodeId) async {
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
              mQrCodeDelete(qrCodeId);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    )) ?? false;
  }

}
