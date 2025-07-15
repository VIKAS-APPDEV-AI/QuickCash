import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/TicketsScreen/CreateTicketScreen/createTicketApi.dart';
import 'package:quickcash/Screens/TicketsScreen/CreateTicketScreen/createTicketModel.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/model/ticketScreenApi.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/model/ticketScreenModel.dart';
import 'package:quickcash/Screens/TicketsScreen/chatHistoryScreen/chat_history_screen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {

  final TicketListApi _ticketListApi = TicketListApi();
  List<TicketListsData> ticketHistory = [];

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    mTicketHistory();
  }

  Future<void> mTicketHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try{
      final response = await _ticketListApi.ticketListApi();

      if(response.ticketList !=null && response.ticketList!.isNotEmpty){
        setState(() {
          ticketHistory = response.ticketList!;
          isLoading = false;
        });
      }else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Statement List';
        });
      }

    } catch (error) {
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
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.transparent),
        title: const Text("Tickets", style: TextStyle(color: Colors.transparent),),
      ),
      body: Column(
        children: [
          const SizedBox(height: 0),

          // Create Ticket Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Pass mTicketHistory method as callback to showCreateTicketDialog
                showCreateTicketDialog(context, mTicketHistory);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Create Ticket', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ),

          const SizedBox(height: defaultPadding),
          Expanded(
            child:  isLoading ? const Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            ) : SingleChildScrollView(
              child: Column(
                children: ticketHistory.map((ticketsData) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: kPrimaryColor,
                    child: ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: defaultPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Ticket ID:", style: TextStyle(color: Colors.white, fontSize: 16)),
                              Text("${ticketsData.ticketId}", style: const TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Created At:", style: TextStyle(color: Colors.white, fontSize: 16)),
                              Text(formatDate(ticketsData.date), style: const TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Subject:", style: TextStyle(color: Colors.white, fontSize: 16)),
                              Text("${ticketsData.subject}", style: const TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Message:", style: TextStyle(color: Colors.white, fontSize: 16)),
                              Text("${ticketsData.message}", style: const TextStyle(color: Colors.white, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Status:", style: TextStyle(color: Colors.white, fontSize: 16)),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white, width: 1),
                                ),
                                child: Text(
                                  "${ticketsData.status}".isNotEmpty
                                      ? "${ticketsData.status?[0].toUpperCase()}${ticketsData.status?.substring(1)}"
                                      : "",  // Capitalize first letter and keep the rest as is
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),

                          // View Button
                          const SizedBox(height: 35),
                          Center(
                            child: SizedBox(
                              width: 150,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ChatHistoryScreen(mID: ticketsData.id,mChatStatus: ticketsData.status,)),
                                  );
                                },
                                child: const Text('View', style: TextStyle(color: kPrimaryColor, fontSize: 16)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Function to show the dialog with barrierDismissible set to false
Future<void> showCreateTicketDialog(BuildContext context, VoidCallback onTicketCreated) async {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing the dialog by tapping outside
    builder: (BuildContext context) {
      return CreateTicketScreen(
        onTicketCreated: onTicketCreated,
      );
    },
  );
}

class CreateTicketScreen extends StatefulWidget {
  final VoidCallback onTicketCreated;
  const CreateTicketScreen({super.key, required this.onTicketCreated});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();

}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final CreateTicketApi _createTicketApi = CreateTicketApi();

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;


  @override
  void initState() {
    super.initState();
    mCreateTicket();
  }

  Future<void> mCreateTicket() async{
   if(_formKey.currentState!.validate()){
     setState(() {
       isLoading = true;
       errorMessage = null;
     });

     try{
       final request = CreateTicketRequest(cardStatus: "Pending", subject: subjectController.text, userId: AuthManager.getUserId(), message: messageController.text);

       final response = await _createTicketApi.createTicket(request);

       if(response.message == "support ticket has been added !!!"){
         setState(() {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(response.message ?? 'Ticket Created Successfully')),
           );
           Navigator.pop(context);
           isLoading = false;
         });
         widget.onTicketCreated();
       }else{
         setState(() {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(response.message ?? 'We are facing some issue!')),
           );
           Navigator.pop(context);
           isLoading = false;
         });
       }
     }catch (error) {
       setState(() {
         isLoading = false;
         errorMessage = error.toString();
       });
     }
   }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Ticket'),
      content: SizedBox(
        width: 350, // Set your desired width here
        height: 400, // Set your desired height here
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: subjectController,
                  keyboardType: TextInputType.text,
                  cursorColor: kPrimaryColor,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    labelStyle: const TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                    fillColor: Colors.transparent,
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Subject is required';
                    }
                    return null; // Validation passed
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: messageController,
                  keyboardType: TextInputType.text,
                  cursorColor: kPrimaryColor,
                  textInputAction: TextInputAction.none,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    labelStyle: const TextStyle(color: kPrimaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(),
                    ),
                    fillColor: Colors.transparent,
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  maxLines: 10,
                  minLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Message is required';
                    }
                    return null; // Validation passed
                  },
                ),

                const SizedBox(height: defaultPadding),
                if (isLoading) const CircularProgressIndicator(color: kPrimaryColor,), // Show loading indicator
                if (errorMessage != null) // Show error message if there's an error
                  Text(errorMessage!, style: const TextStyle(color: Colors.red)),

              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : mCreateTicket,
          child: const Text('Post Ticket'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}


