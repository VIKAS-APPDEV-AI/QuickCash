import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/PaymentQRCodeScreen/AddPaymentQRCodeScreen/model/addPaymentQrCodeApi.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';

import '../../../../../util/customSnackBar.dart';
import 'model/QrCodeAddModel.dart';

class AddPaymentQRCodeScreen extends StatefulWidget{
  const AddPaymentQRCodeScreen({super.key});

  @override
  State<AddPaymentQRCodeScreen> createState() => _AddPaymentQRCodeScreenState();
}

class _AddPaymentQRCodeScreenState extends State<AddPaymentQRCodeScreen>{
  final QrCodeAddApi _qrCodeAddApi = QrCodeAddApi();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController title = TextEditingController();
  final TextEditingController taxRate = TextEditingController();
  String? selectedType = "yes";
  String? imagePath;

  bool isLoading = false;
  String? errorMessage;

  Future<void> mAddPaymentQrCode() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        final request = QrCodeAddRequest(
          userId: AuthManager.getUserId(),
          title: title.text,
          type: selectedType!,
          qrCodeImage: imagePath != null ? File(imagePath!) : null,
        );
        final response = await _qrCodeAddApi.qrCodeAdd(request);

        if (response.message == "QrCode details is added Successfully!!!") {
          setState(() {
            isLoading = false;
            errorMessage = null;
            title.clear();
            imagePath = null; // Reset the image path
            CustomSnackBar.showSnackBar(
              context: context,
              message: "QrCode details is added Successfully!",
              color: kPrimaryColor,
            );
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = null;
            CustomSnackBar.showSnackBar(
              context: context,
              message: "We are facing some issue!",
              color: kPrimaryColor,
            );
          });
        }
      } catch (error) {
        setState(() {
          isLoading = false;
          errorMessage = error.toString();
          CustomSnackBar.showSnackBar(
            context: context,
            message: errorMessage!,
            color: kRedColor,
          );
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add QR Code",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 35,
                  ),
                  TextFormField(
                    controller: title,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value) {},
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                    readOnly: false,
                    style: const TextStyle(color: kPrimaryColor),
                    decoration: InputDecoration(
                      labelText: "Title",
                      labelStyle:
                      const TextStyle(color: kPrimaryColor, fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(
                    height: largePadding,
                  ),

                  const Padding(padding: EdgeInsets.only(left: smallPadding),
                  child: Text("Upload Payment QR-code",style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),),),

                  const SizedBox(height: 2.0,),
                  Card(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imagePath != null
                              ? Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 250,
                          )
                              : Image.network(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmN0el3AEK0rjTxhTGTBJ05JGJ7rc4_GSW6Q&s',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 250,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                  source: ImageSource.gallery);

                              if (image != null) {
                                setState(() {
                                  imagePath =
                                      image.path; // Store the image path
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Image selected')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('No image selected.')),
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


                  const SizedBox(height: largePadding),
                  const Text(
                    "Default",
                    style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Radio<String>(
                        value: 'yes',
                        groupValue: selectedType,
                        onChanged: (String? value) {
                          setState(() {
                            selectedType = value;
                          });
                        },
                      ),
                      const Text('Yes', style: TextStyle(color: kPrimaryColor)),
                      Radio<String>(
                        value: 'no',
                        groupValue: selectedType,
                        onChanged: (String? value) {
                          setState(() {
                            selectedType = value;
                          });
                        },
                      ),
                      const Text('No', style: TextStyle(color: kPrimaryColor)),
                    ],
                  ),

                  const SizedBox(height: defaultPadding,),
                  if (isLoading) const Center(
                    child: CircularProgressIndicator(
                      color: kPrimaryColor,
                    ),
                  ), // Show loading indicator


                  const SizedBox(
                    height: 45.0,
                  ),
                  Center(
                    child: SizedBox(
                      width: 180,
                      height: 50.0,
                      child: FloatingActionButton.extended(
                        onPressed: isLoading ? null : mAddPaymentQrCode,
                        label: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        backgroundColor: kPrimaryColor,
                      ),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
