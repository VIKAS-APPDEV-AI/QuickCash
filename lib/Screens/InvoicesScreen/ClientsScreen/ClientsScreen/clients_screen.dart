import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/InvoicesScreen/ClientsScreen/AddClientsFormScreen/add_clients_form_screen.dart';
import 'package:quickcash/Screens/InvoicesScreen/ClientsScreen/ClientsScreen/deleteClientModel/deleteClientApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/ClientsScreen/ClientsScreen/model/clientsApi.dart';
import 'package:quickcash/Screens/InvoicesScreen/ClientsScreen/ClientsScreen/model/clientsModel.dart';
import 'package:quickcash/Screens/InvoicesScreen/ClientsScreen/EditClientsFormScreen/edit_clients_form_screen.dart';
import 'package:quickcash/Screens/InvoicesScreen/ClientsScreen/ViewClientsScreen/view_clients_screen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/customSnackBar.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {

  final DeleteClientApi _deleteClientApi = DeleteClientApi();
  final ClientsApi _clientsApi = ClientsApi();
  List<ClientsData> clientsData = [];

  bool isLoading = false;
  String? errorMessage;


  @override
  void initState() {
    super.initState();
    mClientsApi();
  }


  Future<void> mClientsApi() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try{
      final response = await _clientsApi.clientsApi();
      
      if(response.clientsList !=null && response.clientsList!.isNotEmpty){
        setState(() {
          clientsData = response.clientsList!;
          isLoading = false;
        });
      }else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Clients List';
        });
      }
      
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
    return DateFormat('yyyy-MM-dd').format(date);
  }


  // Delete Client Api ---
  Future<void> mDeleteClient(String? clientId) async{
    try{
      final response = await _deleteClientApi.deleteClientApi(clientId!);

      if(response.message == "Client Data has been deleted successfully"){
        setState(() {
          mClientsApi();
          Navigator.of(context).pop(true);
          CustomSnackBar.showSnackBar(context: context, message: response.message!, color: kGreenColor);
        });

      }else{
        setState(() {
          Navigator.of(context).pop(true);
          CustomSnackBar.showSnackBar(context: context, message: "We are facing some issue", color: kGreenColor);
        });
      }

    }catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
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
          "Clients",
          style: TextStyle(color: Colors.transparent),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /*Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        cursorColor: kPrimaryColor,

                        onSaved: (value){

                        },

                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(defaultPadding),
                            borderSide: const BorderSide(),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          hintText: "Search",
                          hintStyle: const TextStyle(color: kPrimaryColor),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(defaultPadding),
                            child: Icon(Icons.search),
                          ),
                        ),
                      ),
                  ),*/

                  const SizedBox(width: defaultPadding,),

                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddClientsFormScreen()),
                      );
                    },
                    child: const Icon(Icons.add,color: kPrimaryColor,),
                  ),
                ],
              ),

              const SizedBox(height: largePadding,),

              isLoading ? const Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
              ) : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: clientsData.length,
                itemBuilder: (context, index) {
                  final clientsList = clientsData[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: defaultPadding), // Add spacing
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Created Date:', style: TextStyle(color: Colors.white, fontSize: 16),),
                              Text(formatDate(clientsList.date), style: const TextStyle(color: Colors.white, fontSize: 16),),
                            ],
                          ),

                          const SizedBox(height: smallPadding,),
                          const Divider(color: kPrimaryLightColor,),
                          const SizedBox(height: smallPadding,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Client Name:',style: TextStyle(color: Colors.white, fontSize: 16),),
                              Text('${clientsList.firstName} ${clientsList.lastName}',style: const TextStyle(color: Colors.white, fontSize: 16),),
                            ],
                          ),

                          const SizedBox(height: smallPadding,),
                          const Divider(color: kPrimaryLightColor,),
                          const SizedBox(height: smallPadding,),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Expanded(child: Text("Action:",style: TextStyle(color: Colors.white, fontSize: 16))),

                              IconButton(
                                icon: const Icon(Icons.remove_red_eye,color: Colors.white,),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ViewClientsScreen(clientsID: clientsList.id)),
                                  );

                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white,),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => EditClientsFormScreen(clientsID: clientsList.id)),
                                  );
                                },
                              ),
                              IconButton(
                                icon:  const Icon(Icons.delete, color: Colors.white,),
                                onPressed: () {
                                  _showDeleteClientDialog(clientsList.id);
                                },
                              ),
                            ],
                          ),
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

  Future<bool> _showDeleteClientDialog(String? id) async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Client"),
        content: const Text("Do you really want to delete this client data?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // No
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              mDeleteClient(id);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    )) ?? false;
  }

}