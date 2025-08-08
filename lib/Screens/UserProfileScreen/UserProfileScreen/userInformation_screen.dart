import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:quickcash/Screens/UserProfileScreen/UserProfileScreen/model/userProfileApi.dart';
import 'package:quickcash/util/apiConstants.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../constants.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final UserProfileApi _userProfileApi = UserProfileApi();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _totalAccountsController = TextEditingController();
  final TextEditingController _defaultCurrencyController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    mUserProfile();
  }

  Future<void> mUserProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _userProfileApi.userProfile();
      AuthManager.saveUserImage(response.ownerProfile!);

      if (response.ownerProfile != null) {
        profileImageUrl = '${ApiConstants.baseImageUrl}${AuthManager.getUserId()}/${response.ownerProfile}';
      }

      _fullNameController.text = response.name ?? '';
      _emailController.text = response.email ?? '';
      _mobileController.text = response.mobile ?? '';
      _countryController.text = response.country ?? '';
      _defaultCurrencyController.text = response.defaultCurrency?.toString() ?? '';
      _addressController.text = response.address ?? '';
      _totalAccountsController.text = response.accountDetails?.length.toString() ?? '0';

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 90,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: Colors.white,
              hideBottomControls: false,
              lockAspectRatio: false,
            ),
            IOSUiSettings(title: 'Crop Image'),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            profileImageUrl = croppedFile.path;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image cropped successfully'), backgroundColor: Colors.green),
          );

          await _uploadProfileImage(croppedFile.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image crop cancelled'), backgroundColor: Colors.orange),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking/cropping image: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _uploadProfileImage(String filePath) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/upload_profile_image');
      final request = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = AuthManager.getUserId()
        ..files.add(await http.MultipartFile.fromPath('profile_image', filePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusCode}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload error: $e'), backgroundColor: Colors.red),
      );
    }
  }

 void _showChangeProfilePhotoDialog(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isSmallScreen = size.width < 600;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.white,
    builder: (_) => Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Change Profile Photo',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          ListTile(
            leading: Icon(
              Icons.camera_alt_outlined,
              color: Theme.of(context).extension<AppColors>()!.primary,
              size: isSmallScreen ? 20 : 24,
            ),
            title: Text(
              'Take a Photo',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          Divider(
            height: 1,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade600
                : Colors.grey.shade300,
          ),
          ListTile(
            leading: Icon(
              Icons.photo_library_outlined,
              color: Theme.of(context).extension<AppColors>()!.primary,
              size: isSmallScreen ? 20 : 24,
            ),
            title: Text(
              'Choose from Gallery',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).extension<AppColors>()?.primary ?? Colors.deepPurple;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: profileImageUrl != null
                              ? (profileImageUrl!.startsWith('http')
                                  ? NetworkImage(profileImageUrl!)
                                  : FileImage(File(profileImageUrl!)))
                              : const AssetImage('assets/images/DefaultProfile.png') as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () => _showChangeProfilePhotoDialog(context),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    _fullNameController.text.isEmpty ? "Your Name" : _fullNameController.text,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _emailController.text,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),

                  _buildTextField("Full Name", _fullNameController, context),
                  _buildTextField("Mobile Number", _mobileController, context),
                  _buildTextField("Country", _countryController, context),
                  _buildTextField("Total Accounts", _totalAccountsController, context),
                  _buildTextField("Default Currency", _defaultCurrencyController, context),
                  _buildTextField("Address", _addressController, context),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 13),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
