import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import this for date formatting
import 'package:quickcash/Screens/InvoicesScreen/ManualInvoicePayment/AddManualPaymentScreen/addManualPaymentModel/addManualPaymentApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/ManualInvoicePayment/AddManualPaymentScreen/addManualPaymentModel/addManualPaymentModel.dart';
import 'package:quickcash/Screens/InvoicesScreen/ManualInvoicePayment/AddManualPaymentScreen/getManualPaymentDataModel/getManualPaymentApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/ManualInvoicePayment/AddManualPaymentScreen/getManualPaymentDataModel/getManualPaymentModel.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../util/customSnackBar.dart';

class AddManualPaymentScreen extends StatefulWidget {
  const AddManualPaymentScreen({super.key});

  @override
  State<AddManualPaymentScreen> createState() => _AddManualPaymentScreenState();
}

class _AddManualPaymentScreenState extends State<AddManualPaymentScreen> with WidgetsBindingObserver {
  final GetManualPaymentApi _getManualPaymentApi = GetManualPaymentApi();
  final AddManualPaymentApi _addManualPaymentApi = AddManualPaymentApi();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController amountPay = TextEditingController();
  final TextEditingController mNotes = TextEditingController();

  String? selectedInvoice = 'Select Invoice'; // Default value

  List<GetManualPaymentData> manualPaymentDetailsList = [];
  bool isLoading = false;
  String? errorMessage;

  double? dueAmount = 0.0;
  double? paidAmount = 0.0;
  String? currency = "";

  @override
  void initState() {
    super.initState();
    mGetManualPaymentDetails();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // Get Manual Payment Details Api
  Future<void> mGetManualPaymentDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _getManualPaymentApi.getManualPaymentDetailsApi();

      if (response.getManualPaymentList != null && response.getManualPaymentList!.isNotEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = null;
          manualPaymentDetailsList = response.getManualPaymentList!;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No data';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        CustomSnackBar.showSnackBar(context: context, message: errorMessage!, color: kRedColor);
      });
    }
  }


  // Add Manual Payment Details Api
  Future<void> mAddManualPayment(invoiceId, String amount, String notes) async{
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try{
      double mAmount = double.parse(amount);

      final request = AddManualPaymentRequest(userId: AuthManager.getUserId(), invoiceNumber: selectedInvoice!, currency: currency!, invoiceId: invoiceId, notes: notes, amount: mAmount, paymentDate: _dateController.text, mode: "Cash", dueAmount: dueAmount!, paidAmount: paidAmount!);
      final response = await _addManualPaymentApi.addManualPayment(request);

      if(response.message == "Payment has been done Successfully"){
        setState(() {
          isLoading = false;
          errorMessage =null;
          CustomSnackBar.showSnackBar(context: context, message: "Payment has been done Successfully", color: kGreenColor);
          amountPay.clear();
          Navigator.pop(context);
        });
      }else if(response.message == "Please make sure enter amount should not be more than Invoice generated amount!"){
        setState(() {
          CustomSnackBar.showSnackBar(context: context, message: "Please make sure enter amount should not be more than Invoice generated amount!", color: kRedColor);
          isLoading = false;
          errorMessage = null;
        });
      }else{
        setState(() {
          isLoading = false;
          CustomSnackBar.showSnackBar(context: context, message: errorMessage!, color: kRedColor);
        });
      }

    }catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        CustomSnackBar.showSnackBar(context: context, message: errorMessage!, color: kRedColor);
      });
    }


  }





  void updateAmountFields(String? invoiceNumber) {
    final selectedPayment = manualPaymentDetailsList.firstWhere(
          (payment) => payment.invoiceNumber == invoiceNumber,
      orElse: () => GetManualPaymentData(),
    );

    if (selectedPayment.id != null) {
      setState(() {
        dueAmount = selectedPayment.dueAmount ?? 0.0;
        paidAmount = selectedPayment.paidAmount ?? 0.0;
        currency = selectedPayment.currencyText ?? " ";
      });
    }else{
      setState(() {
        dueAmount = 0.0;
        paidAmount = 0.0;
        currency = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Add Manual Payment",
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
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: largePadding),
              DropdownButtonFormField<String?>(
                value: selectedInvoice,
                style: const TextStyle(color: kPrimaryColor),
                decoration: InputDecoration(
                  labelText: 'Invoice',
                  labelStyle: const TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                items: [
                  'Select Invoice', // Default value
                  ...manualPaymentDetailsList
                      .map((payment) => payment.invoiceNumber)
                ].map((String? invoice) {
                  return DropdownMenuItem<String?>(
                    value: invoice,
                    child: Text(invoice ?? '', style: const TextStyle(color: kPrimaryColor, fontSize: 16)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedInvoice = newValue;
                    updateAmountFields(newValue);
                  });
                },
                validator: (value) {
                  if (value == 'Select Invoice') {
                    return 'Please select an invoice';
                  }
                  return null;
                },
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) {},
                readOnly: true,
                controller: TextEditingController(text: '$currency ${dueAmount?.toString() ?? '0.0'}'),
                style: const TextStyle(color: kPrimaryColor),
                decoration: InputDecoration(
                  labelText: "Due Amount",
                  labelStyle: const TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide()),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) {},
                readOnly: true,
                controller: TextEditingController(text: '$currency ${paidAmount?.toString() ?? '0.0'}'),
                style: const TextStyle(color: kPrimaryColor),
                decoration: InputDecoration(
                  labelText: "Paid Amount",
                  labelStyle: const TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide()),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: largePadding),
              TextFormField(
                controller: _dateController, // Use the controller here
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) {},
                readOnly: true,
                style: const TextStyle(color: kPrimaryColor),
                decoration: InputDecoration(
                  labelText: "Payment Date",
                  labelStyle: const TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: amountPay,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) {},
                readOnly: false,
                style: const TextStyle(color: kPrimaryColor),
                decoration: InputDecoration(
                  labelText: "Amount",
                  labelStyle: const TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide()),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                onSaved: (value) {},
                readOnly: true,
                style: const TextStyle(color: kPrimaryColor),
                decoration: InputDecoration(
                  labelText: "Payment Mode",
                  labelStyle: const TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide()),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                initialValue: 'CASH', // Replace this with actual dynamic value if available
              ),
              const SizedBox(height: largePadding),
              TextFormField(
                controller: mNotes,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                cursorColor: kPrimaryColor,
                style: const TextStyle(color: kPrimaryColor),
                minLines: 6,
                maxLines: 12,
                decoration: InputDecoration(
                  labelText: "Notes",
                  labelStyle: const TextStyle(color: kPrimaryColor, fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a note';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: (){

                    final selectedPayment = manualPaymentDetailsList.firstWhere(
                          (payment) => payment.invoiceNumber == selectedInvoice,
                      orElse: () => GetManualPaymentData(),
                    );

                    if(selectedInvoice != "Select Invoice"){
                      if(amountPay.text.isNotEmpty){
                        mAddManualPayment(selectedPayment.id,amountPay.text,mNotes.text);
                      }else{
                        CustomSnackBar.showSnackBar(context: context, message: "Please enter a amount", color: kRedColor);
                      }
                    }else{
                      CustomSnackBar.showSnackBar(context: context, message: "Please select invoice", color: kRedColor);

                    }
                  }, // Call printInvoiceId when the button is pressed
                  child: const Text('Pay', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}
