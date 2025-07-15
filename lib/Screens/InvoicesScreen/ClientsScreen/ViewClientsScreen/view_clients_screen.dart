import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/InvoicesScreen/ClientsScreen/ViewClientsScreen/model/viewClientsApi.dart';
import 'package:quickcash/constants.dart';

import '../../../../util/apiConstants.dart';

class ViewClientsScreen extends StatefulWidget {
  final String? clientsID;
  const ViewClientsScreen({super.key,required this.clientsID});

  @override
  State<ViewClientsScreen> createState() => _ViewClientsScreenState();
}

class _ViewClientsScreenState extends State<ViewClientsScreen> {
  final ViewClientsApi  _viewClientsApi = ViewClientsApi();

  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController country = TextEditingController();
  final TextEditingController postalCode = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController note = TextEditingController();
  final TextEditingController lastUpdate = TextEditingController();

  bool isLoading =true;
  String? errorMessage;
  String? profileImageUrl;

  @override
  void initState() {
    mViewClientApi();
    super.initState();
  }

  Future<void> mViewClientApi() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try{

      final response  = await _viewClientsApi.viewClientsApi(widget.clientsID);

      name.text = '${response.firstName} ${response.lastName}';

      email.text = response.email ?? 'N/A';
      mobile.text = response.mobile?.toString() ?? '0';

      country.text = response.country ?? 'N/A';
      postalCode.text = response.postalCode ?? 'N/A';
      address.text = response.address ?? 'N/A';
      note.text = response.notes ?? 'N/A';
      lastUpdate.text = formatDate(response.lastUpdate!);

      // Set the profile image URL dynamically
      if (response.profilePhoto != null) {
        // Assuming response.ownerProfile contains the image filename
        profileImageUrl =
        '${ApiConstants.baseClientImageUrl}/${response.profilePhoto}';
      }

      setState(() {
        isLoading = false;
        errorMessage = null;
      });

    }catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
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
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "View Client",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: kPrimaryColor,
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                children: [
                  // Profile Image Section
                  if (profileImageUrl != null)
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                            NetworkImage(profileImageUrl!),
                          ),
                        ],
                      ),
                    )
                  else
                    const Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                            'assets/images/profile_pic.png'), // Default Image
                      ),
                    ),
                  const SizedBox(height: defaultPadding),

                  if (errorMessage != null)
                    Text(errorMessage!,
                        style: const TextStyle(color: Colors.red)),

                  const SizedBox(
                    height: defaultPadding,
                  ),


                  TextFormField(
                    controller: name,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value){},
                    readOnly: true,
                    style: const TextStyle(color: kPrimaryColor),

                    decoration: InputDecoration(
                      labelText: "Full Name",
                      labelStyle: const TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide()
                      ),
                    ),
                  ),

                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value) {},
                    readOnly: true,
                    style: const TextStyle(color: kPrimaryColor),

                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide()
                      ),
                    ),
                  ),

                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: mobile,
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
                          borderSide: const BorderSide()
                      ),
                    ),
                  ),

                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: country,
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
                          borderSide: const BorderSide()
                      ),
                    ),
                  ),

                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: postalCode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value) {},
                    readOnly: true,
                    style: const TextStyle(color: kPrimaryColor),

                    decoration: InputDecoration(
                      labelText: "Postal Code",
                      labelStyle: const TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide()
                      ),
                    ),
                  ),

                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: address,
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
                          borderSide: const BorderSide()
                      ),
                    ),
                  ),

                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: note,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value) {},
                    readOnly: true,
                    style: const TextStyle(color: kPrimaryColor),

                    decoration: InputDecoration(
                      labelText: "Note",
                      labelStyle: const TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide()
                      ),
                    ),
                    minLines: 1,
                    maxLines: 12,
                  ),

                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: lastUpdate,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value) {},
                    readOnly: true,
                    style: const TextStyle(color: kPrimaryColor),

                    decoration: InputDecoration(
                      labelText: "Last Update",
                      labelStyle: const TextStyle(color: kPrimaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide()
                      ),
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