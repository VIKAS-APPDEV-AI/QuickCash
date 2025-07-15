import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  // Function to pick image
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        profileImageUrl =
            pickedFile.path; // Update the profile image with the picked file
      });
    }
  }

  // Function to show the dialog for changing the profile photo
  void _showChangeProfilePhotoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Profile Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera); // Pick image from camera
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery); // Pick image from gallery
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Add text controllers to bind to the text fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _totalAccountsController = TextEditingController();
  final TextEditingController _defaultCurrencyController =
      TextEditingController();
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

      // Set the profile image URL dynamically
      if (response.ownerProfile != null) {
        // Assuming response.ownerProfile contains the image filename
        profileImageUrl = '${ApiConstants.baseImageUrl}${AuthManager.getUserId()}/${response.ownerProfile}';
      } else {
        // Handle if there is no image, and set a default URL or null
        profileImageUrl = null;
      }

      if (response.name != null) {
        _fullNameController.text = response.name!;
      }
      if (response.email != null) {
        _emailController.text = response.email!;
      }
      if (response.mobile != null) {
        _mobileController.text = response.mobile!;
      }
      if (response.country != null) {
        _countryController.text = response.country!;
      }
      if (response.defaultCurrency != null) {
        _defaultCurrencyController.text = response.defaultCurrency.toString();
      }
      if (response.address != null) {
        _addressController.text = response.address!;
      }
      _totalAccountsController.text =
          response.accountDetails?.length.toString() ?? '0';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      children: [
                        const SizedBox(height: defaultPadding),

                        // Profile Image Section
                        if (profileImageUrl != null)
                          Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: profileImageUrl != null
                                      ? NetworkImage(
                                          profileImageUrl!) // Use NetworkImage if the URL is not null
                                      : const AssetImage(
                                              'assets/images/DefaultProfile.png')
                                          as ImageProvider,
                                ),
                              ],
                            ),
                          )
                        else
                          Center(
                            child: CircleAvatar(
                                radius: 55,
                                backgroundImage: profileImageUrl != null
                                    ? NetworkImage(profileImageUrl!)
                                    : const AssetImage(
                                        'assets/images/DefaultProfile.png')
                                // Default Image
                                ),
                          ),

                        const SizedBox(height: defaultPadding),

                        Text(
                          _fullNameController.text,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor),
                        ),

                       const SizedBox(height: defaultPadding),

                        // if (errorMessage != null)
                        //   Text(errorMessage!,
                        //       style: const TextStyle(color: Colors.red)),

                        // const SizedBox(
                        //   height: defaultPadding,
                        // ),

                        // Update the text fields with TextEditingController
                        TextFormField(
                          controller: _fullNameController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          cursorColor: kPrimaryColor,
                          onSaved: (value) {},
                          readOnly: true,
                          style: const TextStyle(color: kPrimaryColor),
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            labelStyle: const TextStyle(color: kPrimaryColor),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide()),
                          ),
                        ),

                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          cursorColor: kPrimaryColor,
                          onSaved: (value) {},
                          readOnly: true,
                          style: const TextStyle(color: kPrimaryColor),
                          decoration: InputDecoration(
                            labelText: "Your Email",
                            labelStyle: const TextStyle(color: kPrimaryColor),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide()),
                          ),
                        ),

                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          cursorColor: kPrimaryColor,
                          onSaved: (value) {},
                          readOnly: true,
                          style: const TextStyle(color: kPrimaryColor),
                          decoration: InputDecoration(
                            labelText: "Mobile Number",
                            labelStyle: const TextStyle(color: kPrimaryColor),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide()),
                          ),
                        ),

                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: _countryController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          cursorColor: kPrimaryColor,
                          onSaved: (value) {},
                          readOnly: true,
                          style: const TextStyle(color: kPrimaryColor),
                          decoration: InputDecoration(
                            labelText: "Country",
                            labelStyle: const TextStyle(color: kPrimaryColor),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide()),
                          ),
                        ),

                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: _totalAccountsController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          cursorColor: kPrimaryColor,
                          onSaved: (value) {},
                          readOnly: true,
                          style: const TextStyle(color: kPrimaryColor),
                          decoration: InputDecoration(
                            labelText: "Total Accounts",
                            labelStyle: const TextStyle(color: kPrimaryColor),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide()),
                          ),
                        ),

                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: _defaultCurrencyController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          cursorColor: kPrimaryColor,
                          onSaved: (value) {},
                          readOnly: true,
                          style: const TextStyle(color: kPrimaryColor),
                          decoration: InputDecoration(
                            labelText: "Default Currency",
                            labelStyle: const TextStyle(color: kPrimaryColor),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide()),
                          ),
                        ),

                        const SizedBox(height: defaultPadding),
                        TextFormField(
                          controller: _addressController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          cursorColor: kPrimaryColor,
                          onSaved: (value) {},
                          readOnly: true,
                          style: const TextStyle(color: kPrimaryColor),
                          decoration: InputDecoration(
                            labelText: "Address",
                            labelStyle: const TextStyle(color: kPrimaryColor),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide()),
                          ),
                        ),

                        const SizedBox(height: 30.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
