import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickcash/Screens/UserProfileScreen/DocumentsScreen/documentsUpdateModel/documentsUpdateApi.dart';
import 'package:quickcash/Screens/UserProfileScreen/DocumentsScreen/documentsUpdateModel/documentsUpdateModel.dart';
import 'package:quickcash/Screens/UserProfileScreen/DocumentsScreen/model/documentsApi.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/util/customSnackBar.dart';
import 'package:quickcash/util/error_handler.dart'; // ✅ Add this
import '../../../constants.dart';
import '../../../util/apiConstants.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DocumentsApi _documentsApi = DocumentsApi();
  final DocumentUpdateApi _documentUpdateApi = DocumentUpdateApi();
  

  String selectedRole = 'Select ID Of Individual';
  String? imagePath;
  String? documentPhotoFrontUrl;
  final TextEditingController _documentsNoController = TextEditingController();

  bool isLoading = false;
  bool isUpdateLoading = false;

  final Map<String, String> documentTypeMap = {
    'passport': 'Passport',
    'driving license': 'Driving License',
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
      }
    });

    try {
      final response = await _documentsApi.documentsApi();

      if (response.documentsDetails?.isNotEmpty ?? false) {
        final document = response.documentsDetails!.first;

        if (document.documentPhotoFront != null) {
          documentPhotoFrontUrl =
              '${ApiConstants.baseKYCImageUrl}${document.documentPhotoFront}';
        }

        if (document.documentsNo != null) {
          _documentsNoController.text = document.documentsNo!;
        }

        String fetchedType = document.documentsType ?? '';
        String mappedType = documentTypeMap[fetchedType.toLowerCase()] ??
            'Select ID Of Individual';

        setState(() {
          selectedRole = mappedType;
        });
      }
    } catch (error) {
      final message = getFriendlyErrorMessage(error);
      CustomSnackBar.showSnackBar(
        context: context,
        message: message,
        color: Theme.of(context).colorScheme.error,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> mUpdateDocument() async {
    if (selectedRole == "Select ID Of Individual") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please Select ID Of Individual')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isUpdateLoading = true;
    });

    try {
      final request = UpdateDocumentRequest(
        userId: AuthManager.getUserId(),
        documentsType: selectedRole,
        documentNo: _documentsNoController.text,
        docImage: imagePath != null ? File(imagePath!) : null,
      );

      final response = await _documentUpdateApi.updateDocumentApi(request);

      if (response.message == "Profile updated successfully") {
        CustomSnackBar.showSnackBar(
          context: context,
          message: "Documents updated successfully!",
          color: Theme.of(context).extension<AppColors>()!.primary,
        );
        mDocumentsApi("No");
      } else {
        CustomSnackBar.showSnackBar(
          context: context,
          message: "We are facing some issue!",
          color: Theme.of(context).extension<AppColors>()!.primary,
        );
      }
    } catch (error) {
      final message = getFriendlyErrorMessage(error);
      CustomSnackBar.showSnackBar(
        context: context,
        message: message,
        color: Theme.of(context).colorScheme.error,
      );
    } finally {
      setState(() {
        isUpdateLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: [
                const SizedBox(height: defaultPadding),
                if (isLoading)
                  CircularProgressIndicator(color: Theme.of(context).extension<AppColors>()!.primary),
                const SizedBox(height: defaultPadding),
                if (documentPhotoFrontUrl != null)
                  buildImageCard(documentPhotoFrontUrl!)
                else if (isLoading)
                  buildPlaceholderCard(),
                const SizedBox(height: defaultPadding),
                TextFormField(
                  controller: _documentsNoController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  cursorColor: Theme.of(context).extension<AppColors>()!.primary,
                  style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Document ID No';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Document ID No",
                    labelStyle: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  style:  TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: 17),
                  decoration: InputDecoration(
                    labelText: 'ID Of Individual',
                    labelStyle: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    'Select ID Of Individual',
                    'Passport',
                    'Driving License'
                  ].map((String role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedRole = newValue!;
                    });
                  },
                ),
                const SizedBox(height: defaultPadding),
                if (isUpdateLoading)
                   Center(
                      child: CircularProgressIndicator(color: Theme.of(context).extension<AppColors>()!.primary)),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
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
        ),
      ),
    );
  }

  Widget buildImageCard(String url) {
    return Card(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imagePath != null
                ? Image.file(File(imagePath!),
                    fit: BoxFit.cover, width: double.infinity, height: 200)
                : Image.network(url,
                    fit: BoxFit.fitHeight, width: double.infinity, height: 200),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: editButton(),
          ),
        ],
      ),
    );
  }

  Widget buildPlaceholderCard() {
    return Card(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imagePath != null
                ? Image.file(File(imagePath!),
                    fit: BoxFit.cover, width: double.infinity, height: 250)
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
            child: editButton(),
          ),
        ],
      ),
    );
  }

  Widget editButton() {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() => imagePath = image.path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image selected')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected.')),
          );
        }
      },
      child:  CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.edit, color: Theme.of(context).extension<AppColors>()!.primary),
      ),
    );
  }
}
