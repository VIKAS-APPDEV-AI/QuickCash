import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/TaxScreen/AddTaxScreen/model/addTaxApi.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/DashboardTicketScreen.dart';
import 'package:quickcash/util/customSnackBar.dart';

import '../../../../../constants.dart';
import '../../../../../util/auth_manager.dart';
import '../updateTaxDetailsScreen/model/taxUpdateModel.dart';

class AddTaxScreen extends StatefulWidget {
  const AddTaxScreen({super.key});

  @override
  State<AddTaxScreen> createState() => _AddTaxScreenState();
}

class _AddTaxScreenState extends State<AddTaxScreen> {
  final AddTaxApi _addTaxApi = AddTaxApi();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController name = TextEditingController();
  final TextEditingController taxRate = TextEditingController();
  String? selectedType = "yes";
  bool isLoading = false;
  String? errorMessage;

  Future<void> mAddTax() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        final request = TaxUpdateRequest(userId: AuthManager.getUserId(),
            name: name.text,
            value: taxRate.text,
            type: selectedType!);
        final response = await _addTaxApi.addTaxApi(request);

        if(response.message == "Tax data has been saved !!!"){
          setState(() {
            isLoading = false;
            errorMessage = null;
            name.clear();
            taxRate.clear();
            CustomSnackBar.showSnackBar(context: context, message: "Tax Data has been Submitted!", color: Theme.of(context).extension<AppColors>()!.primary);
          });
        }else{
          setState(() {
            isLoading = false;
            errorMessage = null;
            CustomSnackBar.showSnackBar(context: context, message: "We are facing some issue!", color: Theme.of(context).extension<AppColors>()!.primary);
          });
        }

      } catch (error) {
        setState(() {
          isLoading = false;
          errorMessage = error.toString();
          CustomSnackBar.showSnackBar(
              context: context, message: errorMessage!, color: Colors.red);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Tax",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 6, 6, 6), // Dark neo-banking color
                      Color(0xFF8A2BE2), // Gradient transition
                      Color(0x00000000), // Transparent fade
                    ],
                    stops: [0.0, 0.7, 1.0],
                  ),
                ),
              ),
          actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bell_fill),
            onPressed: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => NotificationScreen(),
                  ));
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.headphones),
            onPressed: () {
             Navigator.push(context, CupertinoPageRoute(builder: (context) => DashboardTicketScreen(),));
            },
            tooltip: 'Support',
          ),
          const SizedBox(width: 8),
        ],
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
                    controller: name,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: Theme.of(context).extension<AppColors>()!.primary,
                    onSaved: (value) {},
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                    readOnly: false,
                    style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary),
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle:
                          TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(
                    height: defaultPadding,
                  ),
                  TextFormField(
                    controller: taxRate,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    cursorColor: Theme.of(context).extension<AppColors>()!.primary,
                    onSaved: (value) {},
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter tax rate';
                      }
                      return null;
                    },
                    readOnly: false,
                    style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary),
                    decoration: InputDecoration(
                      labelText: "Tax Rate",
                      labelStyle:
                          TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 35),
                   Text(
                    "Default",
                    style: TextStyle(
                        color: Theme.of(context).extension<AppColors>()!.primary,
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
                       Text('Yes', style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary)),
                      Radio<String>(
                        value: 'no',
                        groupValue: selectedType,
                        onChanged: (String? value) {
                          setState(() {
                            selectedType = value;
                          });
                        },
                      ),
                      Text('No', style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary)),
                    ],
                  ),

                  const SizedBox(height: defaultPadding,),
                  if (isLoading) Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).extension<AppColors>()!.primary,
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
                        onPressed: isLoading ? null : mAddTax,
                        label: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
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
