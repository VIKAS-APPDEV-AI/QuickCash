import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/PaymentQRCodeScreen/updateQrCodeScreen/model/updateQrCodeApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/PaymentQRCodeScreen/updateQrCodeScreen/model/updateQrCodeModel.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';

import '../../../../../util/apiConstants.dart';
import '../../../../../util/customSnackBar.dart';

class UpdatePaymentQRCodeScreen extends StatefulWidget{
  final String? qrCodeId;
  final String? qrCodeTitle;
  final String? qrCodeImage;
  final String? qrCodeType;

  const UpdatePaymentQRCodeScreen({super.key, required this.qrCodeId, required this.qrCodeTitle, required this.qrCodeImage, required this.qrCodeType});

  @override
  State<UpdatePaymentQRCodeScreen> createState() => _UpdatePaymentQRCodeScreenState();
}

class _UpdatePaymentQRCodeScreenState extends State<UpdatePaymentQRCodeScreen>{
  final _formKey = GlobalKey<FormState>();
  final QrCodeUpdateApi _qrCodeUpdateApi = QrCodeUpdateApi();

  final TextEditingController title = TextEditingController();
  String? selectedType = "yes";
  String? imagePath;
  String? imageUrl;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    mSetQrCodeDetails();
    super.initState();
  }

  Future<void> mSetQrCodeDetails() async{
    title.text = widget.qrCodeTitle!;
    imageUrl = '${ApiConstants.baseQRCodeImageUrl}${widget.qrCodeImage}';
  }

  // Update Qrcode Details api ---------------------------
  Future<void> mUpdateQrCode() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try{
        final request = QrCodeUpdateRequest(userId: AuthManager.getUserId(), title: title.text, type: selectedType!);
        final response = await _qrCodeUpdateApi.qrCodeUpdate(request, widget.qrCodeId);


        if(response.message == "Payment QR Code details has been updated successfully"){
          setState(() {
            isLoading = false;
            errorMessage = null;
            CustomSnackBar.showSnackBar(context: context, message: "QrCode Data has been Updated!", color: kPrimaryColor);
          });
        }else{
          setState(() {
            isLoading = false;
            errorMessage = null;
            CustomSnackBar.showSnackBar(context: context, message: "We are facing some issue!", color: kPrimaryColor);
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Edit QR Code",
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

                  if(imageUrl !=null)
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
                            imageUrl.toString(),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 250,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                height: 250,
                                width: double.infinity,

                                child: Icon(
                                  Icons.image_outlined,
                                  color: kPrimaryColor,
                                  size: 120, // Adjust the icon size as needed
                                ),
                              );
                            },
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
                  )
                  else
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
                  if (errorMessage != null) // Show error message if there's an error
                    Text(errorMessage!, style: const TextStyle(color: Colors.red)),



                  const SizedBox(
                    height: 45.0,
                  ),
                  Center(
                    child: SizedBox(
                      width: 180,
                      height: 50.0,
                      child: FloatingActionButton.extended(
                        onPressed: isLoading ? null : mUpdateQrCode,
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
