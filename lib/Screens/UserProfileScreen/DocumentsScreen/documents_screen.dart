import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickcash/Screens/UserProfileScreen/DocumentsScreen/documentsUpdateModel/documentsUpdateApi.dart';
import 'package:quickcash/Screens/UserProfileScreen/DocumentsScreen/documentsUpdateModel/documentsUpdateModel.dart';
import 'package:quickcash/Screens/UserProfileScreen/DocumentsScreen/model/documentsApi.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../constants.dart';
import '../../../util/apiConstants.dart';
import '../../../util/customSnackBar.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DocumentsApi _documentsApi = DocumentsApi();
  final DocumentUpdateApi _documentUpdateApi = DocumentUpdateApi();

  String selectedRole = 'Select ID Of Individual'; // Default value for dropdown
  String? imagePath;
  String? documentPhotoFrontUrl;

  // Add Text controllers
  final TextEditingController _documentsNoController = TextEditingController();

  bool isLoading = false;
  bool isUpdateLoading = false;
  String? errorMessage;

  // Map the API response values to display-friendly values for the dropdown
  final Map<String, String> documentTypeMap = {
    'passport': 'Passport',
    'driving license': 'Driving License',
    // Add more mappings if necessary
  };

  @override
  void initState() {
    super.initState();
    mDocumentsApi("Yes");
  }

  Future<void> mDocumentsApi(String s) async {
    setState(() {
      if (s == "Yes") {
        isLoading = true;
        errorMessage = null;
      }
    });

    try {
      final response = await _documentsApi.documentsApi();

      // Check if the response has data
      if (response.documentsDetails?.isNotEmpty ?? false) {
        final document = response.documentsDetails!.first;

        // Set the document photo front URL
        if (document.documentPhotoFront != null) {
          documentPhotoFrontUrl =
              '${ApiConstants.baseKYCImageUrl}${document.documentPhotoFront}';
        }

        // Set the document number in the text controller
        if (document.documentsNo != null) {
          _documentsNoController.text = document.documentsNo!;
        }

        String fetchedDocumentType = document.documentsType ?? '';
        String mappedDocumentType = documentTypeMap[
                fetchedDocumentType.toLowerCase()] ??
            'Select ID Of Individual'; // Default to the 'Select ID Of Individual' if no valid type found

        setState(() {
          selectedRole =
              mappedDocumentType; // Set the selected role to the mapped value
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  Future<void> mUpdateDocument() async {
    if (selectedRole == "Select ID Of Individual") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please Select ID Of Individual')),
      );
    } else if (_formKey.currentState!.validate()) {
      setState(() {
        isUpdateLoading = true;
      });

      try {
        if (imagePath != null) {
          final request = UpdateDocumentRequest(
              userId: AuthManager.getUserId(),
              documentsType: selectedRole,
              documentNo: _documentsNoController.text,
              docImage: imagePath !=null ? File(imagePath!) : null);
          final response = await _documentUpdateApi.updateDocumentApi(request);

          if (response.message == "Profile updated successfully") {
            setState(() {
              isUpdateLoading = false;
              mDocumentsApi("No");
              CustomSnackBar.showSnackBar(
                  context: context,
                  message: "Documents Update Successfully!",
                  color: kPrimaryColor);
            });
          } else {
            setState(() {
              isUpdateLoading = false;
              CustomSnackBar.showSnackBar(
                  context: context,
                  message: "We are facing some issue!",
                  color: kPrimaryColor);
            });
          }
        } else {
          final request = UpdateDocumentRequest(
              userId: AuthManager.getUserId(),
              documentsType: selectedRole,
              documentNo: _documentsNoController.text);
          final response = await _documentUpdateApi.updateDocumentApi(request);

          if (response.message == "Profile updated successfully") {
            setState(() {
              isUpdateLoading = false;
              mDocumentsApi("No");
              CustomSnackBar.showSnackBar(
                  context: context,
                  message: "Documents Update Successfully!",
                  color: kPrimaryColor);
            });
          } else {
            setState(() {
              isUpdateLoading = false;
              CustomSnackBar.showSnackBar(
                  context: context,
                  message: "We are facing some issue!",
                  color: kPrimaryColor);
            });
          }
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: defaultPadding),

                    if (isLoading)
                      const CircularProgressIndicator(
                        color: kPrimaryColor,
                      ),
                    if (errorMessage !=
                        null) // Show error message if there's an error
                      Text(errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                    const SizedBox(
                      height: defaultPadding,
                    ),

                    if (documentPhotoFrontUrl != null)
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
                                      height: 200,
                                    )
                                  : Image.network(
                                      documentPhotoFrontUrl.toString(),
                                      fit: BoxFit.fitHeight,
                                      width: double.infinity,
                                      height: 200,
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
                    else if (isLoading)
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
                        labelText: "Document ID No",
                        labelStyle: const TextStyle(color: kPrimaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),

                    // Document Type Dropdown
                    const SizedBox(height: 25),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      // This binds to the selectedRole state
                      style:
                          const TextStyle(color: kPrimaryColor, fontSize: 17),
                      decoration: InputDecoration(
                        labelText: 'ID Of Individual',
                        labelStyle: const TextStyle(color: kPrimaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(),
                        ),
                      ),
                      items: [
                        'Select ID Of Individual',
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
                          selectedRole = newValue!; // Update the selected role
                        });
                      },
                    ),

                    const SizedBox(
                      height: defaultPadding,
                    ),
                    if (isUpdateLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: kPrimaryColor,
                        ),
                      ), // Show loading indicator

                    // Update Button
                    const SizedBox(height: 35),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: isUpdateLoading ? null : mUpdateDocument,
                        child: const Text('Update',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
