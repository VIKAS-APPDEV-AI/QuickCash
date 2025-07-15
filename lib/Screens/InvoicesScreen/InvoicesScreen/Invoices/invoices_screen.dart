import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/InvoicesScreen/InvoicesScreen/Invoices/invoiceDeleteModel/invoiceDeleteApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/InvoicesScreen/Invoices/invoiceRecurringModel/invoiceRecurringApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/InvoicesScreen/Invoices/invoiceRecurringModel/invoiceRecurringModel.dart';
import 'package:quickcash/Screens/InvoicesScreen/InvoicesScreen/Invoices/invoiceReminderModel/invoiceReminderApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/InvoicesScreen/UpdateInvoiceScreen/update_invoice_screen.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/SettingsScreen/settingsModel/settingsApi.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/util/customSnackBar.dart';

import '../../InvoiceDashboardScreen/AddInvoice/add_invoice_screen.dart';
import 'invoiceModel/invoicesApi.dart';
import 'invoiceModel/invoicesModel.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final SettingsApi _settingsApi = SettingsApi();
  final InvoicesApi _invoicesApi = InvoicesApi();
  final InvoiceReminderApi _invoiceReminderApi = InvoiceReminderApi();
  final DeleteInvoiceApi _deleteInvoiceApi = DeleteInvoiceApi();
  final InvoiceRecurringApi _invoiceRecurringApi = InvoiceRecurringApi();
  List<InvoicesData> invoiceList = [];

  bool isLoading = true;
  bool isInvoiceData = false;
  String? errorMessage;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
      case 'paid':
        return kGreenColor;
      case 'Unpaid':
      case 'unpaid':
        return kRedColor;
      case 'Partial':
      case 'partial':
        return Colors.purpleAccent;
      default:
        return kPrimaryColor;
    }
  }

  @override
  void initState() {
    mSettingsDetails();
    mInvoicesApi("Yes");
    super.initState();
  }

  // Invoices Api -------
  Future<void> mInvoicesApi(String s) async {
    setState(() {
      if (s == "Yes") {
        isLoading = true;
        errorMessage = null;
      }
    });

    try {
      final response = await _invoicesApi.invoicesApi();
      if (response.invoicesList != null && response.invoicesList!.isNotEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = null;
          invoiceList = response.invoicesList!;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Invoices List';
          CustomSnackBar.showSnackBar(
              context: context,
              message: "No Invoices List",
              color: kPrimaryColor);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        print('Error: $error');
        CustomSnackBar.showSnackBar(
            context: context, message: errorMessage!, color: kRedColor);
      });
    }
  }

  // Delete Invoice Api --------------------
  Future<void> mDeleteInvoice(String? invoiceId) async {
    setState(() {
      isLoading = false;
      errorMessage = null;
    });

    try {
      final response = await _deleteInvoiceApi.deleteInvoiceApi(invoiceId!);

      if (response.message == "Invoice data has been deleted successfully") {
        mInvoicesApi("No");
        Navigator.of(context).pop();
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Invoice data has been deleted successfully",
            color: kGreenColor);
      } else {
        setState(() {
          isLoading = false;
          errorMessage = null;
          Navigator.of(context).pop();
          CustomSnackBar.showSnackBar(
              context: context,
              message: "We are facing some issue!",
              color: kRedColor);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        Navigator.of(context).pop();
        CustomSnackBar.showSnackBar(
            context: context, message: errorMessage!, color: kRedColor);
      });
    }
  }

  // Invoice Reminder Api -------------------------
  Future<void> mInvoiceReminder(String? invoiceId) async {
    setState(() {
      isLoading = false;
      errorMessage = null;
    });

    try {
      final response = await _invoiceReminderApi.invoiceReminderApi(invoiceId!);

      if (response.message == "Reminder has been sent") {
        setState(() {
          isLoading = false;
          errorMessage = null;
          CustomSnackBar.showSnackBar(
              context: context,
              message: "Reminder has been sent on email address",
              color: kGreenColor);
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = null;
          Navigator.of(context).pop();
          CustomSnackBar.showSnackBar(
              context: context,
              message: "We are facing some issue!",
              color: kRedColor);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        Navigator.of(context).pop();
        CustomSnackBar.showSnackBar(
            context: context, message: errorMessage!, color: kRedColor);
      });
    }
  }

// Invoice Recurring Api
  Future<void> mInvoiceRecurring(String? invoiceId, String recurringStatus,
      String? selectedRecurringCycle) async {
    try {
      String recurringCycleNumber = '';

      if (selectedRecurringCycle != null && selectedRecurringCycle.isNotEmpty) {
        switch (selectedRecurringCycle.toLowerCase()) {
          case 'day':
            recurringCycleNumber = '1'; // Send the number as a string
            break;
          case 'weekly':
            recurringCycleNumber = '7';
            break;
          case 'monthly':
            recurringCycleNumber = '31';
            break;
          case 'half yearly':
            recurringCycleNumber = '180';
            break;
          case 'yearly':
            recurringCycleNumber = '365';
            break;
          default:
            throw Exception("Invalid recurring cycle");
        }
      }

      final request = InvoiceRecurringRequest(
        userId: AuthManager.getUserId(),
        recurring: recurringStatus,
        recurringCycle: recurringCycleNumber,
      );

      final response =
          await _invoiceRecurringApi.invoiceRecurringApi(request, invoiceId);

      if (response.message == "Invoice details has been updated successfully") {
        setState(() {
          CustomSnackBar.showSnackBar(
              context: context,
              message: "Recurring Status Saved Successfully!",
              color: kGreenColor);
          Navigator.of(context).pop();
          mInvoicesApi("No");
        });
      } else {
        setState(() {
          CustomSnackBar.showSnackBar(
              context: context,
              message: "We are facing some issue!",
              color: kRedColor);
          Navigator.of(context).pop();
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        Navigator.of(context).pop();
        CustomSnackBar.showSnackBar(
            context: context, message: errorMessage!, color: kRedColor);
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

  void copyInvoiceUrl(String? url) {
    if (url != null) {
      Clipboard.setData(ClipboardData(text: url)).then((_) {
        CustomSnackBar.showSnackBar(
          context: context,
          message: 'Invoice URL Copied!',
          color: kPrimaryColor,
        );
      });
    } else {
      // Show an error or handle the case when referralLink is null
      CustomSnackBar.showSnackBar(
        context: context,
        message: 'Invoice URL is not available!',
        color: Colors.red,
      );
    }
  }


  Future<void> mSettingsDetails() async {
    try {
      final response = await _settingsApi.settingsApi();

      if(response.message == "Invoice Settings Data!"){
        setState(() {
          isInvoiceData = true;
        });
      }else{
        setState(() {
          isInvoiceData = false;
        });
      }

    } catch (error) {
      setState(() {
        isInvoiceData = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.transparent),
        title: const Text(
          "Invoices",
          style: TextStyle(color: Colors.transparent),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 150,
                          child: FloatingActionButton.extended(
                            onPressed: () {
                              if (AuthManager.getKycStatus() == "completed") {
                                if(isInvoiceData == true){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const AddInvoiceScreen()),
                                  );

                                }else{
                                  CustomSnackBar.showSnackBar(context: context, message: "Please got to Invoice/Setting and fill all details.", color: kPrimaryColor);
                                }
                              }else{
                                CustomSnackBar.showSnackBar(context: context, message: "Your KYC is not completed", color: kPrimaryColor);
                              }
                            },
                            backgroundColor: kPrimaryColor,
                            label: const Text(
                              'Add Invoice',
                              style:
                                  TextStyle(color: kWhiteColor, fontSize: 15),
                            ),
                            icon: const Icon(Icons.add, color: kWhiteColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: invoiceList.length,
                      itemBuilder: (context, index) {
                        final invoiceLists = invoiceList[index];
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: defaultPadding),
                          // Add spacing
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(defaultPadding),
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Invoice Number:',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    if (invoiceLists.recurring == "yes")
                                      const Expanded(
                                        child: Icon(
                                          Icons.repeat,
                                          // Use any icon from the Icons class
                                          color: Colors.white,
                                        ),
                                      ),
                                    Text(
                                      invoiceLists.invoiceNumber!,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: smallPadding,
                                ),
                                const Divider(
                                  color: kPrimaryLightColor,
                                ),
                                const SizedBox(
                                  height: smallPadding,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Invoice Date:',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    Text(
                                      formatDate(invoiceLists.createdAt),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: smallPadding,
                                ),
                                const Divider(
                                  color: kPrimaryLightColor,
                                ),
                                const SizedBox(
                                  height: smallPadding,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Due Date:',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    Text(
                                      formatDate(invoiceLists.dueDate),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: smallPadding,
                                ),
                                const Divider(
                                  color: kPrimaryLightColor,
                                ),
                                const SizedBox(
                                  height: smallPadding,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Amount:',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    Text(
                                      "${invoiceLists.currencyText} ${invoiceLists.total}",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: smallPadding,
                                ),
                                const Divider(
                                  color: kPrimaryLightColor,
                                ),
                                const SizedBox(
                                  height: smallPadding,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Transaction:',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    Text(
                                      "${invoiceLists.currencyText} ${invoiceLists.paidAmount}",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: smallPadding,
                                ),
                                const Divider(
                                  color: kPrimaryLightColor,
                                ),
                                const SizedBox(
                                  height: smallPadding,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Status:',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    FilledButton.tonal(
                                      onPressed: () {},
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                _getStatusColor(
                                                    invoiceLists.status!)),
                                        elevation: WidgetStateProperty
                                            .resolveWith<double>((states) {
                                          if (states
                                              .contains(WidgetState.pressed)) {
                                            return 4; // Higher elevation when pressed
                                          }
                                          return 4; // Default elevation
                                        }),
                                      ),
                                      child: Text(
                                        '${invoiceLists.status![0].toUpperCase()}${invoiceLists.status!.substring(1)}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: smallPadding,
                                ),
                                const Divider(
                                  color: kPrimaryLightColor,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // IconButton with text
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Conditionally show the Edit icon based on status
                                        if (invoiceLists.status == 'Unpaid' ||
                                            invoiceLists.status ==
                                                'unpaid') ...[
                                          /*Column(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const UpdateInvoiceScreen()),
                                                  );
                                                },
                                              ),
                                              const Text(
                                                'Edit',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),*/
                                          const SizedBox(
                                            width: smallPadding,
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  mDeleteInvoiceDialog(
                                                      invoiceLists.id);
                                                },
                                              ),
                                              const Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],

                                        const SizedBox(
                                          width: smallPadding,
                                        ),
                                        Column(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.link,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                copyInvoiceUrl(
                                                    invoiceLists.url);
                                              },
                                            ),
                                            const Text(
                                              'Invoice URL',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: smallPadding,
                                        ),
                                        Column(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.watch_later_outlined,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                mInvoiceReminder(
                                                    invoiceLists.id);
                                              },
                                            ),
                                            const Text(
                                              'Reminder',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: smallPadding,
                                        ),
                                        Column(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.repeat,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                if (invoiceLists.recurring ==
                                                    "yes") {
                                                  //CustomSnackBar.showSnackBar(context: context, message: "Recurring Status Saved Successfully!", color: kGreenColor);
                                                  stopRecurringDialog(
                                                      invoiceLists.id, "no");
                                                } else {
                                                  startRecurringDialog(
                                                      invoiceLists.id, "yes");
                                                }
                                              },
                                            ),
                                            Text(
                                              invoiceLists.recurring == "yes"
                                                  ? 'Stop Recurring'
                                                  : 'Start Recurring',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: smallPadding,
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> startRecurringDialog(
      String? invoiceId, String recurringStatus) async {
    String selectedRecurring = 'Select Recurring';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recurring'),
          content: Form(
            // Wrap in Form to enable validation
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: largePadding),
                DropdownButtonFormField<String>(
                  value: selectedRecurring,
                  style: const TextStyle(color: kPrimaryColor),
                  decoration: InputDecoration(
                    labelText: 'Recurring',
                    labelStyle: const TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  items: [
                    'Select Recurring',
                    'Day',
                    'Weekly',
                    'Monthly',
                    'Half Yearly',
                    'Yearly',
                  ].map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category,
                          style: const TextStyle(
                              color: kPrimaryColor, fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedRecurring = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == 'Select Category') {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedRecurring == "Select Recurring") {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please select a recurring option')));
                } else {
                  mInvoiceRecurring(
                      invoiceId, recurringStatus, selectedRecurring);
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> mDeleteInvoiceDialog(String? invoiceId) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Invoice"),
            content: const Text("Do you really want to delete this invoice?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // No
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () {
                  mDeleteInvoice(invoiceId);
                },
                child: const Text("Yes"),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> stopRecurringDialog(
      String? invoiceId, String recurringStatus) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Stop Recurring"),
            content: const Text("Do you really want to stop recurring?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // No
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () {
                  mInvoiceRecurring(invoiceId, recurringStatus, "");
                },
                child: const Text("Yes"),
              ),
            ],
          ),
        )) ??
        false;
  }
}
