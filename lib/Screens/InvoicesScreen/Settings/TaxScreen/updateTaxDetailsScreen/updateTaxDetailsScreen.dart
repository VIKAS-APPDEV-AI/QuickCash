import 'package:flutter/material.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/TaxScreen/updateTaxDetailsScreen/model/taxUpdateModel.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/TaxScreen/updateTaxDetailsScreen/model/updateTaxDetailApi.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/util/customSnackBar.dart';

import '../../../../../constants.dart';

class UpdateTaxScreen extends StatefulWidget {
  final String? taxId;
  final String? taxName;
  final double? taxValue;
  final String? taxType;
  const UpdateTaxScreen({super.key, required this.taxId, required this.taxName, required this.taxValue, required this.taxType});

  @override
  State<UpdateTaxScreen> createState() => _UpdateTaxScreenState();
}

class _UpdateTaxScreenState extends State<UpdateTaxScreen> {
  final TaxUpdateApi _taxUpdateApi = TaxUpdateApi();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController name = TextEditingController();
  final TextEditingController taxRate = TextEditingController();
  String? selectedType = "yes";
  bool isLoading = false;
  String? errorMessage;


  @override
  void initState() {
    mSetTaxData();
    super.initState();
  }

  Future<void> mSetTaxData() async {
    name.text = widget.taxName!;
    taxRate.text = widget.taxValue.toString();
    selectedType = widget.taxType!;
  }

  Future<void> mUpdateTax() async{
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
        final response = await _taxUpdateApi.taxUpdate(request, widget.taxId);

        if(response.message == "Tax data has been saved !!!"){
         setState(() {
           isLoading = false;
           errorMessage = null;
           CustomSnackBar.showSnackBar(context: context, message: "Tax Data has been Updated!", color: kPrimaryColor);
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
          "Update Tax",
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
                    controller: name,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value) {},
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                    readOnly: false,
                    style: const TextStyle(color: kPrimaryColor),
                    decoration: InputDecoration(
                      labelText: "Name",
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
                    height: defaultPadding,
                  ),
                  TextFormField(
                    controller: taxRate,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    cursorColor: kPrimaryColor,
                    onSaved: (value) {},
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter tax rate';
                      }
                      return null;
                    },
                    readOnly: false,
                    style: const TextStyle(color: kPrimaryColor),
                    decoration: InputDecoration(
                      labelText: "Tax Rate",
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
                  const SizedBox(height: 35),
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
                        onPressed: isLoading ? null : mUpdateTax,
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
