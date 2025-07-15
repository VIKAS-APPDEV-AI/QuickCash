import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/InvoicesScreen/QuotesScreen/quoteScreen/quoteDelete/quoteDeleteApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/QuotesScreen/quoteScreen/quoteModel/quotesApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/QuotesScreen/quoteScreen/quoteModel/quotesModel.dart';
import 'package:quickcash/Screens/InvoicesScreen/QuotesScreen/quoteScreen/quoteReminderModel/quoteReminderApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/QuotesScreen/updateQuoteScreen/updateQuoteScreen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/customSnackBar.dart';

import '../../InvoiceDashboardScreen/AddQuoteScreen/add_quote_screen.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final QuoteApi _quoteApi = QuoteApi();
  final QuoteReminderApi _quoteReminderApi = QuoteReminderApi();
  final QuoteDeleteApi _quoteDeleteApi = QuoteDeleteApi();

  List<QuoteData> quotesList = [];
  bool isLoading = false;
  String? errorMessage;


  @override
  void initState() {
    mQuote("Yes");
    super.initState();
  }

  // Quote List Api
  Future<void> mQuote(String s) async{
    setState(() {
     if(s == "Yes"){
       isLoading = true;
       errorMessage = null;
     }
    });

    try{
      final response = await _quoteApi.quoteApi();

      if(response.quoteList !=null && response.quoteList!.isNotEmpty){
        setState(() {
          isLoading = false;
          errorMessage = null;
          quotesList = response.quoteList!;
        });
      }else{
        setState(() {
          isLoading = false;
          errorMessage = 'No Quote List';
          CustomSnackBar.showSnackBar(context: context, message: "No Quote List", color: kPrimaryColor);
        });
      }

    }catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        print('Error: $error');
        CustomSnackBar.showSnackBar(context: context, message: errorMessage!, color: kRedColor);
      });
    }
  }


  // Quote Reminder Api
  Future<void> mQuoteReminder(String? quoteId) async {
    setState(() {
      isLoading = false;
      errorMessage = null;
    });

    try{
      final response = await _quoteReminderApi.quoteReminderApi(quoteId!);

      if(response.message == "Reminder has been sent"){
        CustomSnackBar.showSnackBar(context: context, message: "Reminder has been start", color: kGreenColor);

      }else{
        setState(() {
          setState(() {
            isLoading = false;
            errorMessage = null;
            CustomSnackBar.showSnackBar(context: context, message: "We are facing some issue!", color: kPrimaryColor);
          });
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

  // Quote Delete Api
  Future<void> mQuoteDelete(String? quoteId) async{
    setState(() {
      isLoading = false;
      errorMessage = null;
    });

    try{
      final response = await _quoteDeleteApi.quoteDeleteApi(quoteId!);

      if(response.message == "Quote data has been deleted successfully"){
        setState(() {
          isLoading = false;
          errorMessage = null;
          Navigator.of(context).pop(false);
          mQuote("No");
          CustomSnackBar.showSnackBar(context: context, message: "Quote data has been deleted successfully", color: kPrimaryColor);
        });
      }else{
        setState(() {
          isLoading = false;
          errorMessage = null;
          Navigator.of(context).pop(false);
          CustomSnackBar.showSnackBar(context: context, message: "We are facing some issue!", color: kPrimaryColor);
        });
      }

    }catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        Navigator.of(context).pop(false);
        CustomSnackBar.showSnackBar(context: context, message: errorMessage!, color: kRedColor);
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
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.transparent),
        title: const Text(
          "Quotes",
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const AddQuoteScreen()),
                        );
                       /* Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TestCodeScreen()),
                        );*/
                      },
                      backgroundColor: kPrimaryColor,
                      label: const Text(
                        'Add Quotes',
                        style:
                        TextStyle(color: kWhiteColor, fontSize: 15),
                      ),
                      icon: const Icon(Icons.add, color: kWhiteColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: largePadding,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quotesList.length,
                itemBuilder: (context, index) {
                  final quotes = quotesList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: smallPadding),
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
                                'Quote Number:',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                quotes.quoteNumber ?? 'N/A',
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
                                'Quote Date:',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                formatDate(quotes.invoiceDate),
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
                                formatDate(quotes.dueDate),
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
                                '${quotes.currencyText} ${quotes.total}',
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
                              Text(
                                (quotes.status != null && quotes.status!.isNotEmpty)
                                    ? quotes.status![0].toUpperCase() + quotes.status!.substring(1)
                                    : '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
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
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                children: [
                                  // Conditionally show the Edit icon based on status
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
                                                builder: (context) => UpdateQuoteScreen(quoteId: quotes.id)),
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
                                          Icons.link,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          copyQuoteUrl(quotes.url);
                                        },
                                      ),
                                      const Text(
                                        'Quote URL',
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
                                          Icons.delete_outline,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          mDeleteInvoiceDialog(quotes.id);
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
                                          mQuoteReminder(quotes.id);
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

  Future<bool> mDeleteInvoiceDialog(String? quoteId) async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Quote"),
        content: const Text("Do you really want to delete this quote?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // No
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              mQuoteDelete(quoteId);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    )) ?? false;
  }

  void copyQuoteUrl(String? url) {
    if (url != null) {
      Clipboard.setData(ClipboardData(text: url)).then((_) {
        CustomSnackBar.showSnackBar(
          context: context,
          message: 'Quote URL Copied!',
          color: kPrimaryColor,
        );
      });
    } else {
      // Show an error or handle the case when referralLink is null
      CustomSnackBar.showSnackBar(
        context: context,
        message: 'Quote URL is not available!',
        color: Colors.red,
      );
    }
  }

}
