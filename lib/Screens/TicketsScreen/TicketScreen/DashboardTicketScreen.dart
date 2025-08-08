import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/HomeScreen/home_screen.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/Screens/TicketsScreen/CreateTicketScreen/createTicketApi.dart';
import 'package:quickcash/Screens/TicketsScreen/CreateTicketScreen/createTicketModel.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/model/ticketScreenApi.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/model/ticketScreenModel.dart';
import 'package:quickcash/Screens/TicketsScreen/chatHistoryScreen/chat_history_screen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';

class DashboardTicketScreen extends StatefulWidget {
  const DashboardTicketScreen({super.key});

  @override
  State<DashboardTicketScreen> createState() => _DashboardTicketScreenState();
}

class _DashboardTicketScreenState extends State<DashboardTicketScreen>
    with SingleTickerProviderStateMixin {
  final TicketListApi _ticketListApi = TicketListApi();
  List<TicketListsData> ticketHistory = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false; // Safeguard for initialization

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller and animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _isInitialized = true; // Mark as initialized
    _animationController.forward();
    mTicketHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> mTicketHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _ticketListApi.ticketListApi();

      if (response.ticketList != null && response.ticketList!.isNotEmpty) {
        setState(() {
          ticketHistory = response.ticketList!;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Tickets Available';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  String formatDate(String? dateTime) {
    if (dateTime == null) {
      return 'Date not available';
    }
    DateTime date = DateTime.parse(dateTime);
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(
              //     context,
              //     CupertinoPageRoute(
              //       builder: (context) => HomeScreen(),
              //     ));
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF6B46C1),
                Color(0xFF2A1B3D),
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
        ),
        title: const Text(
          "Customer Support",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              CupertinoIcons.bell_fill,
              size: 26,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => NotificationScreen(),
                ),
              );
            },
            tooltip: 'Notifications',
          ),
          // IconButton(
          //   icon: const Icon(CupertinoIcons.headphones, size: 26),
          //   onPressed: () {
          //     print('Support tapped');
          //   },
          //   tooltip: 'Support',
          // ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isInitialized // Only build FadeTransition if initialized
          ? FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 220,
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1A1A2E),
                              Color(0xFF6B46C1),
                              Color(0xFF2A1B3D),
                            ], // Customize your gradient
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            showCreateTicketDialog(context, mTicketHistory);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Create New Ticket',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  Expanded(
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary,
                            ),
                          )
                        : errorMessage != null
                            ? Center(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: mTicketHistory,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: ticketHistory.length,
                                  itemBuilder: (context, index) {
                                    final ticket = ticketHistory[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: Card(
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFF1A1A2E),
                                                Color(0xFF6B46C1),
                                                Color(0xFF2A1B3D),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Ticket ID:",
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${ticket.ticketId}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                    color: Colors.white24,
                                                    height: 20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Created At:",
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      formatDate(ticket.date),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                    color: Colors.white24,
                                                    height: 20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Subject:",
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        "${ticket.subject}",
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                    color: Colors.white24,
                                                    height: 20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Message:",
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        "${ticket.message}",
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                    color: Colors.white24,
                                                    height: 20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Status:",
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                            color:
                                                                Colors.green),
                                                      ),
                                                      child: Text(
                                                        "${ticket.status?.isNotEmpty == true ? ticket.status![0].toUpperCase() + ticket.status!.substring(1) : 'Unknown'}",
                                                        style: const TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),
                                                Center(
                                                  child: SizedBox(
                                                    width: 150,
                                                    height: 45,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.white,
                                                        foregroundColor: Theme
                                                                .of(context)
                                                            .extension<
                                                                AppColors>()!
                                                            .primary,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        elevation: 3,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                ChatHistoryScreen(
                                                              mID: ticket.id,
                                                              mChatStatus:
                                                                  ticket.status,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                        'View Details',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

Future<void> showCreateTicketDialog(
    BuildContext context, VoidCallback onTicketCreated) async {
  showDialog(
    context: context,
    barrierDismissible: false,
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

class _CreateTicketScreenState extends State<CreateTicketScreen>
    with SingleTickerProviderStateMixin {
  final CreateTicketApi _createTicketApi = CreateTicketApi();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isInitialized = false; // Safeguard for initialization

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller and animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _isInitialized = true; // Mark as initialized
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> mCreateTicket() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        final request = CreateTicketRequest(
          cardStatus: "Pending",
          subject: subjectController.text,
          userId: AuthManager.getUserId(),
          message: messageController.text,
        );

        final response = await _createTicketApi.createTicket(request);

        if (response.message == "support ticket has been added !!!") {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(response.message ?? 'Ticket Created Successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            Navigator.pop(context);
            isLoading = false;
          });
          widget.onTicketCreated();
        } else {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message ?? 'We are facing some issue!'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            Navigator.pop(context);
            isLoading = false;
          });
        }
      } catch (error) {
        setState(() {
          isLoading = false;
          errorMessage = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized // Only build ScaleTransition if initialized
        ? ScaleTransition(
            scale: _scaleAnimation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
              title: const Text(
                'Create New Ticket',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              content: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: subjectController,
                          keyboardType: TextInputType.text,
                          cursorColor:
                              Theme.of(context).extension<AppColors>()!.primary,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .background,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .background,
                                width: 2,
                              ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Subject is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: messageController,
                          keyboardType: TextInputType.text,
                          cursorColor:
                              Theme.of(context).extension<AppColors>()!.primary,
                          textInputAction: TextInputAction.none,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Message',
                            labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .background,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .extension<AppColors>()!
                                    .background,
                                width: 2,
                              ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          maxLines: 6,
                          minLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Message is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: defaultPadding),
                        if (isLoading)
                          CircularProgressIndicator(
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .primary,
                          ),
                        if (errorMessage != null)
                          Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : mCreateTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).extension<AppColors>()!.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child:  Text(
                    'Submit Ticket',
                    style: TextStyle(
                      color: Theme.of(context).extension<AppColors>()!.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
