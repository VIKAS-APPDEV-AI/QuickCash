import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:quickcash/Screens/KYCScreen/KycUpdateModel/kycUpdateApi.dart';
import 'package:quickcash/Screens/KYCScreen/KycUpdateModel/kycUpdateModel.dart';
import 'package:quickcash/components/background.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/util/customSnackBar.dart';

import '../HomeScreen/home_screen.dart';

class KycHomeScreen extends StatefulWidget {
  const KycHomeScreen({super.key});

  @override
  State<KycHomeScreen> createState() => _KycHomeScreenState();
}

class _KycHomeScreenState extends State<KycHomeScreen> {
  final KycUpdateApi _kycUpdateApi = KycUpdateApi();

  final TextEditingController mEmail = TextEditingController();
  final TextEditingController mPrimaryPhoneNo = TextEditingController();
  final TextEditingController mAdditionalPhoneNo = TextEditingController();
  final TextEditingController _documentsNoController = TextEditingController();

  final GlobalKey<FormState> _formKeyPrimary = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyAdditional = GlobalKey<FormState>();

  bool isUpdateLoading = false;
  String? mPrimaryNoStatus = 'Verify';
  String? mAdditionalNoStatus = 'Verify';

  String? imagePathFront;
  String? imagePathBack;
  String? imagePathAddress;
  String selectedDocument = 'Select Document';
  String selectedResidentialDocument = 'Select Document';

  @override
  void initState() {
    mSetData();
    super.initState();
  }

  Future<void> mSetData() async {
    mEmail.text = AuthManager.getUserEmail();
  }

  Future<void> mPrimaryNoVerifiedData(String primaryNoVerified) async {
    setState(() {
      mPrimaryNoStatus = primaryNoVerified;
    });
  }

  Future<void> mAdditionalNoVerifiedData(String additionalNoVerified) async {
    setState(() {
      mAdditionalNoStatus = additionalNoVerified;
    });
  }

  // Kyc Update Api **************
  Future<void> mKycUpdate() async {
    setState(() {
      isUpdateLoading = true;
    });

    try {
      if (mPrimaryNoStatus != "Verify") {
        if (mAdditionalNoStatus != "Verify") {
          if (selectedDocument != "Select Document") {
            if (_documentsNoController.text.isNotEmpty) {
              if (imagePathFront != null) {
                if (imagePathBack != null) {
                  if (selectedResidentialDocument != "Select Document") {
                    if (imagePathAddress != null) {
                      final request = KycUpdateRequest(
                          userId: AuthManager.getUserId(),
                          emailId: mEmail.text,
                          primaryPhoneNo: mPrimaryPhoneNo.text,
                          additionalPhoneNo: mAdditionalPhoneNo.text,
                          documentType: selectedDocument,
                          documentNumber: _documentsNoController.text,
                          addressDocumentType: selectedResidentialDocument,
                          status: "Processed",
                          emailVerified: true,
                          primaryPhoneVerified: true,
                          additionalPhoneVerified: true,
                          documentPhotoFront: imagePathFront !=null ? File(imagePathFront!) : null,
                          documentPhotoBack: imagePathBack !=null ? File(imagePathBack!) : null,
                          addressProofPhoto: imagePathAddress !=null ? File(imagePathAddress!) : null);

                      final response = await _kycUpdateApi.kycUpdateApi(request, AuthManager.getKycId());

                      if(response.message == "Kyc Updated !!!"){
                        setState(() {
                          isUpdateLoading = false;
                          CustomSnackBar.showSnackBar(context: context, message: "You kyc documents uploaded successfully, Wait for admin side approval", color: kPrimaryColor);
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        });
                      }else{
                        setState(() {
                          CustomSnackBar.showSnackBar(context: context, message: "We are facing some issue, Please try after some time.", color: kPrimaryColor);
                        });
                      }

                    } else {
                      CustomSnackBar.showSnackBar(
                          context: context,
                          message: "Upload residential document",
                          color: kPrimaryColor);
                    }
                  } else {
                    CustomSnackBar.showSnackBar(
                        context: context,
                        message: "Please select residential document type",
                        color: kPrimaryColor);
                  }
                } else {
                  CustomSnackBar.showSnackBar(
                      context: context,
                      message: "Upload document back side",
                      color: kPrimaryColor);
                }
              } else {
                CustomSnackBar.showSnackBar(
                    context: context,
                    message: "Upload document front side",
                    color: kPrimaryColor);
              }
            } else {
              CustomSnackBar.showSnackBar(
                  context: context,
                  message: "Please enter selected documentId no",
                  color: kPrimaryColor);
            }
          } else {
            CustomSnackBar.showSnackBar(
                context: context,
                message: "Please select a document type",
                color: kPrimaryColor);
          }
        } else {
          CustomSnackBar.showSnackBar(
              context: context,
              message: "Your additional number not verify",
              color: kPrimaryColor);
        }
      } else {
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Your primary number not verify",
            color: kPrimaryColor);
      }
    } catch (error) {
      setState(() {
        isUpdateLoading = false;
        CustomSnackBar.showSnackBar(
          context: context,
          message: "Something went wrong!",
          color: kRedColor,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Let's Verify KYC",
                style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 28),
              ),
            ),
            const SizedBox(
              height: defaultPadding,
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(smallPadding),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        "To fully activate your account and access all features, please complete the KYC (Know your Customer) process. It's quick and essential for your security and compliance. Don't miss out. Finish your KYC today!",
                        style: TextStyle(
                            color: kPrimaryColor, fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center, // Ensure text is centered
                      ),
                    ),
                    Card(
                      elevation: 4.0,
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 0),
                      child: Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: Column(
                          children: [
                            const Text(
                              'Contact Details',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: kPrimaryColor),
                            ),
                            const SizedBox(height: 25),
                            TextFormField(
                              controller: mEmail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              cursorColor: kPrimaryColor,
                              style: const TextStyle(color: kPrimaryColor),
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: "Your Email",
                                labelStyle:
                                    const TextStyle(color: kPrimaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(),
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                              enabled: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: largePadding),
                            Form(
                              key: _formKeyPrimary,
                              child: IntlPhoneField(
                                controller: mPrimaryPhoneNo,
                                keyboardType: TextInputType.phone,
                                focusNode: FocusNode(),
                                style: const TextStyle(color: kPrimaryColor),
                                dropdownIcon: const Icon(Icons.arrow_drop_down,
                                    size: 28, color: kPrimaryColor),
                                decoration: InputDecoration(
                                  labelText: 'Mobile Number',
                                  labelStyle:
                                      const TextStyle(color: kPrimaryColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(),
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                                initialCountryCode: 'NP',
                                onChanged: (phone) {},
                                enabled: mPrimaryNoStatus != "Verified",
                                validator: (value) {
                                  if (value == null ||
                                      value.completeNumber.isEmpty) {
                                    return 'Please enter primary phone number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(
                              height: smallPadding,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 125,
                                  height: 47.0,
                                  child: FloatingActionButton.extended(
                                    onPressed: () {
                                      if (mPrimaryNoStatus == "Verify") {
                                        if (_formKeyPrimary.currentState
                                                ?.validate() ??
                                            false) {
                                          mPrimaryNoVerifyDialog(context);
                                        } else {
                                          CustomSnackBar.showSnackBar(
                                            context: context,
                                            message:
                                                "Please enter a valid primary phone number",
                                            color: kPrimaryColor,
                                          );
                                        }
                                      } else {
                                        CustomSnackBar.showSnackBar(
                                          context: context,
                                          message:
                                              "Primary phone number is already verified",
                                          color: kPrimaryColor,
                                        );
                                      }
                                    },
                                    label: Text(
                                      '$mPrimaryNoStatus',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    backgroundColor: kPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: largePadding),
                            Form(
                              key: _formKeyAdditional,
                              // Assign the global key
                              child: IntlPhoneField(
                                controller: mAdditionalPhoneNo,
                                keyboardType: TextInputType.phone,
                                focusNode: FocusNode(),
                                style: const TextStyle(color: kPrimaryColor),
                                dropdownIcon: const Icon(Icons.arrow_drop_down,
                                    size: 28, color: kPrimaryColor),
                                decoration: InputDecoration(
                                  labelText: 'Mobile Number',
                                  labelStyle:
                                      const TextStyle(color: kPrimaryColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(),
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                                initialCountryCode: 'NP',
                                onChanged: (phone) {},
                                enabled: mAdditionalNoStatus != "Verified",
                                validator: (value) {
                                  if (value == null ||
                                      value.completeNumber.isEmpty) {
                                    return 'Please enter additional phone number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(
                              height: smallPadding,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 125,
                                  height: 47.0,
                                  child: FloatingActionButton.extended(
                                    onPressed: () {
                                      if (mAdditionalNoStatus == "Verify") {
                                        if (_formKeyAdditional.currentState
                                                ?.validate() ??
                                            false) {
                                          mAdditionalNoVerifyDialog(context);
                                        } else {
                                          CustomSnackBar.showSnackBar(
                                            context: context,
                                            message:
                                                "Please enter a valid additional phone number",
                                            color: kPrimaryColor,
                                          );
                                        }
                                      } else {
                                        CustomSnackBar.showSnackBar(
                                          context: context,
                                          message:
                                              "Additional phone number is already verified",
                                          color: kPrimaryColor,
                                        );
                                      }
                                    },
                                    label: Text(
                                      '$mAdditionalNoStatus',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    backgroundColor: kPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: largePadding),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: largePadding,
                    ),
                    Card(
                      elevation: 4.0,
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 0),
                      child: Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Document Details',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: kPrimaryColor),
                              ),
                            ),

                            // Document Type Dropdown
                            const SizedBox(height: 25),
                            DropdownButtonFormField<String>(
                              value: selectedDocument,
                              // This binds to the selectedRole state
                              style: const TextStyle(
                                  color: kPrimaryColor, fontSize: 17),
                              decoration: InputDecoration(
                                labelText: 'ID Of Individual',
                                labelStyle:
                                    const TextStyle(color: kPrimaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(),
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                              items: [
                                'Select Document',
                                'Passport',
                                'Driving License'
                              ].map((String role) {
                                return DropdownMenuItem(
                                  value: role,
                                  // Ensure this value is unique and matches the `selectedRole`
                                  child: Text(role),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedDocument =
                                      newValue!; // Update the selected role
                                });
                              },
                            ),

                            // Document ID Number
                            const SizedBox(height: defaultPadding),
                            TextFormField(
                              controller: _documentsNoController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              cursorColor: kPrimaryColor,
                              onSaved: (value) {},
                              readOnly: false,
                              style: const TextStyle(color: kPrimaryColor),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Document ID No';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: "Document Id No",
                                labelStyle:
                                    const TextStyle(color: kPrimaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(),
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                            ),

                            const SizedBox(
                              height: 25,
                            ),
                            const Text(
                              'Upload Document (Front)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: kPrimaryColor),
                            ),
                            const SizedBox(
                              height: 0,
                            ),
                            Card(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: imagePathFront != null
                                        ? Image.file(
                                            File(imagePathFront!),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 180,
                                          )
                                        : Image.asset(
                                            'assets/images/thumbnail.png',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 180,
                                          ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final XFile? image =
                                            await picker.pickImage(
                                                source: ImageSource.gallery);

                                        if (image != null) {
                                          setState(() {
                                            imagePathFront = image
                                                .path; // Store the image path
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Image selected')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('No image selected.')),
                                          );
                                        }
                                      },
                                      child: const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.edit,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: largePadding,
                            ),
                            const Text(
                              'Upload Document (Back)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: kPrimaryColor),
                            ),
                            const SizedBox(
                              height: 0,
                            ),
                            Card(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: imagePathBack != null
                                          ? Image.file(
                                              File(imagePathBack!),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 180,
                                            )
                                          : Image.asset(
                                              'assets/images/thumbnail.png',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 180,
                                            )),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final XFile? image =
                                            await picker.pickImage(
                                                source: ImageSource.gallery);

                                        if (image != null) {
                                          setState(() {
                                            imagePathBack = image
                                                .path; // Store the image path
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Image selected')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('No image selected.')),
                                          );
                                        }
                                      },
                                      child: const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.edit,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: defaultPadding),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: largePadding,
                    ),
                    Card(
                      elevation: 4.0,
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 0),
                      child: Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'Residential Address',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: kPrimaryColor),
                              ),
                            ),

                            // Document Type Dropdown
                            const SizedBox(height: 25),
                            DropdownButtonFormField<String>(
                              value: selectedResidentialDocument,
                              style: const TextStyle(
                                  color: kPrimaryColor, fontSize: 17),
                              decoration: InputDecoration(
                                labelText: 'Residential Document',
                                labelStyle:
                                    const TextStyle(color: kPrimaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(),
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                              items: [
                                'Select Document',
                                'Bank Statement',
                                'Credit Card Statement',
                                'Utility Bill'
                              ].map((String role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedResidentialDocument = newValue!;
                                });
                              },
                            ),

                            const SizedBox(
                              height: 25,
                            ),
                            const Text(
                              'Upload Residential Document',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: kPrimaryColor),
                            ),
                            const SizedBox(
                              height: 0,
                            ),
                            Card(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: imagePathAddress != null
                                        ? Image.file(
                                            File(imagePathAddress!),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 180,
                                          )
                                        : Image.asset(
                                            'assets/images/thumbnail.png',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 180,
                                          ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final XFile? image =
                                            await picker.pickImage(
                                                source: ImageSource.gallery);

                                        if (image != null) {
                                          setState(() {
                                            imagePathAddress = image.path;
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Image selected')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('No image selected.')),
                                          );
                                        }
                                      },
                                      child: const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.edit,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: defaultPadding),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    if (isUpdateLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: kPrimaryColor,
                        ),
                      ),
                    const SizedBox(height: largePadding),
                    const SizedBox(
                      height: smallPadding,
                    ),
                    Center(
                      child: SizedBox(
                        width: 185,
                        height: 47.0,
                        child: FloatingActionButton.extended(
                          onPressed: isUpdateLoading ? null : mKycUpdate,
                          label: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          backgroundColor: kPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  // Primary No OTP Verify *****
  Future<void> mPrimaryNoVerifyDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PrimaryNoScreen(
          onPrimaryNoVerified: (String primaryNoVerified) async {
            await mPrimaryNoVerifiedData(primaryNoVerified);
          },
        );
      },
    );
  }

  // Additional No Verify *****
  Future<void> mAdditionalNoVerifyDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AdditionalNoScreen(
          onAdditionalNoVerified: (String additionalNoVerified) async {
            await mAdditionalNoVerifiedData(additionalNoVerified);
          },
        );
      },
    );
  }
}

class PrimaryNoScreen extends StatefulWidget {
  final Function(String) onPrimaryNoVerified;

  const PrimaryNoScreen({super.key, required this.onPrimaryNoVerified});

  @override
  State<PrimaryNoScreen> createState() => _PrimaryNoScreenState();
}

class _PrimaryNoScreenState extends State<PrimaryNoScreen> {
  final TextEditingController mOTP = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  String? mGeneratedOTP;

  @override
  void initState() {
    mOTPGenerate();
    super.initState();
  }

  // Function to generate a product code based on the current timestamp
  String generateCodeFromTimestamp() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampStr = timestamp.toString();
    return timestampStr.substring(timestampStr.length - 4);
  }

  void mOTPGenerate() {
    setState(() {
      String newCode = generateCodeFromTimestamp();
      mGeneratedOTP = newCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 350,
        height: 330,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Verify OTP',
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: kPrimaryColor),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: largePadding,
              ),
              Center(
                child: Card(
                  elevation: 4.0,
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Padding(
                    padding: const EdgeInsets.all(smallPadding),
                    child: Column(
                      children: [
                        Text(
                          '    $mGeneratedOTP    ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: kPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: mOTP,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                style: const TextStyle(color: kPrimaryColor),
                decoration: InputDecoration(
                  labelText: "Enter OTP",
                  labelStyle: const TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                maxLength: 4,
              ),
              const SizedBox(height: 35),
              const SizedBox(
                height: smallPadding,
              ),
              Center(
                child: SizedBox(
                  width: 185,
                  height: 47.0,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      if (mOTP.text.isNotEmpty) {
                        if (mGeneratedOTP == mOTP.text) {
                          widget.onPrimaryNoVerified("Verified");
                          Navigator.of(context).pop();
                        } else {
                          CustomSnackBar.showSnackBar(
                              context: context,
                              message: "Please enter a valid OTP",
                              color: kPrimaryColor);
                        }
                      } else {
                        CustomSnackBar.showSnackBar(
                            context: context,
                            message: "Please enter otp",
                            color: kPrimaryColor);
                      }
                    },
                    label: const Text(
                      'Proceed',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    backgroundColor: kPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

class AdditionalNoScreen extends StatefulWidget {
  final Function(String) onAdditionalNoVerified;

  const AdditionalNoScreen({super.key, required this.onAdditionalNoVerified});

  @override
  State<AdditionalNoScreen> createState() => _AdditionalNoScreenState();
}

class _AdditionalNoScreenState extends State<AdditionalNoScreen> {
  final TextEditingController mOTP = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  String? mGeneratedOTP;

  @override
  void initState() {
    mOTPGenerate();
    super.initState();
  }

  // Function to generate a product code based on the current timestamp
  String generateCodeFromTimestamp() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampStr = timestamp.toString();
    return timestampStr.substring(timestampStr.length - 4);
  }

  void mOTPGenerate() {
    setState(() {
      String newCode = generateCodeFromTimestamp();
      mGeneratedOTP = newCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 350,
        height: 330,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Verify OTP',
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: kPrimaryColor),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: largePadding,
              ),
              Center(
                child: Card(
                  elevation: 4.0,
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Padding(
                    padding: const EdgeInsets.all(smallPadding),
                    child: Column(
                      children: [
                        Text(
                          '    $mGeneratedOTP    ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: kPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: mOTP,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                style: const TextStyle(color: kPrimaryColor),
                decoration: InputDecoration(
                  labelText: "Enter OTP",
                  labelStyle: const TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                maxLength: 4,
              ),
              const SizedBox(height: 35),
              const SizedBox(
                height: smallPadding,
              ),
              Center(
                child: SizedBox(
                  width: 185,
                  height: 47.0,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      if (mOTP.text.isNotEmpty) {
                        if (mGeneratedOTP == mOTP.text) {
                          widget.onAdditionalNoVerified("Verified");
                          Navigator.of(context).pop();
                        } else {
                          CustomSnackBar.showSnackBar(
                              context: context,
                              message: "Please enter a valid OTP",
                              color: kPrimaryColor);
                        }
                      } else {
                        CustomSnackBar.showSnackBar(
                            context: context,
                            message: "Please enter otp",
                            color: kPrimaryColor);
                      }
                    },
                    label: const Text(
                      'Proceed',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    backgroundColor: kPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
