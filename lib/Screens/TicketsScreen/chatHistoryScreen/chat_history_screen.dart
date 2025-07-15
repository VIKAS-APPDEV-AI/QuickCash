import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/TicketsScreen/chatHistoryScreen/replyModel/chatReplyApi.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'model/chatHistoryApi.dart';

class ChatMessage {
  final String? from;
  final String? to;
  final String? message;
  final String? createdAt;
  final String? user;

  ChatMessage({
    this.from,
    this.to,
    this.message,
    this.createdAt,
    this.user,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      from: json['from']?.toString(),
      to: json['to']?.toString(),
      message: json['message']?.toString(),
      createdAt: json['createdAt']?.toString(),
      user: json['user']?.toString(),
    );
  }
}

class ChatHistoryScreen extends StatefulWidget {
  final String? mID;
  final String? mChatStatus;
  const ChatHistoryScreen({super.key, required this.mID, required this.mChatStatus});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> with SingleTickerProviderStateMixin {
  final ChatReplyApi _chatReplyApi = ChatReplyApi();
  final ChatHistoryApi _chatHistoryApi = ChatHistoryApi();
  List<ChatMessage> messages = [];
  bool isLoading = false;
  bool isFetchingNewMessage = false; // Flag for showing dots during polling
  String? errorMessage;
  String? chatStatus;
  late Timer _pollingTimer;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController; // For animated dots

  @override
  void initState() {
    super.initState();
    mChatHistory("No");
    chatStatus = widget.mChatStatus;
    _startPolling();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(); // Repeat animation for dots
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      mChatHistory("Yes");
    });
  }

  Future<void> mChatHistory(String s) async {
    setState(() {
      if (s == "No") {
        isLoading = true;
        errorMessage = null;
      } else {
        isFetchingNewMessage = true; // Show dots during polling
        errorMessage = null;
      }
    });

    try {
      final response = await _chatHistoryApi.chatHistoryApi(widget.mID);
      if (response.chatDetails != null && response.chatDetails!.isNotEmpty) {
        List<ChatMessage> tempMessages = [];
        for (var chatDetail in response.chatDetails!) {
          if (chatDetail.chat != null && chatDetail.chat!.isNotEmpty) {
            tempMessages.addAll(chatDetail.chat!);
          }
        }
        setState(() {
          if (tempMessages.length > messages.length) {
            messages = tempMessages;
            _scrollToBottom();
          }
          isLoading = false;
          isFetchingNewMessage = false; // Hide dots after fetch
        });
      } else {
        setState(() {
          isLoading = false;
          isFetchingNewMessage = false;
          errorMessage = 'No Chat Details';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isFetchingNewMessage = false;
        errorMessage = error.toString();
      });
    }
  }

  Future<void> sendTicketReply() async {
    setState(() {
      isFetchingNewMessage = true; // Show dots while sending
    });

    try {
      final response = await _chatReplyApi.replyTicket(
        support: widget.mID!,
        user: AuthManager.getUserId(),
        message: _controller.text,
        from: 'User',
        to: 'Admin',
        attachment: null,
      );

      if (response.message == "Success") {
        setState(() {
          messages.add(ChatMessage(
            from: 'User',
            to: 'Admin',
            message: _controller.text,
            createdAt: DateTime.now().toIso8601String(),
            user: AuthManager.getUserId(),
          ));
          _controller.clear();
          _scrollToBottom();
          isFetchingNewMessage = false; // Hide dots after success
        });
      } else {
        setState(() {
          isFetchingNewMessage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'We are facing some issue!')),
        );
      }
    } catch (error) {
      setState(() {
        isFetchingNewMessage = false;
        errorMessage = error.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $error')),
      );
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      sendTicketReply();
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('h:mm a - dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _refreshChatHistory() async {
    await mChatHistory("No");
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    _scrollController.dispose();
    _controller.dispose();
    _animationController.dispose(); // Dispose animation controller
    super.dispose();
  }

  Widget _buildTypingIndicator() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        int dotCount = (_animationController.value * 3).toInt() + 1;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '.' * dotCount,
                style: const TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Chat History', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshChatHistory,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(child: Text(errorMessage!))
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length + (isFetchingNewMessage ? 1 : 0), // Add extra item for dots
                          itemBuilder: (context, index) {
                            if (isFetchingNewMessage && index == messages.length) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: _buildTypingIndicator(), // Show animated dots
                              );
                            }
                            final message = messages[index];
                            bool isAdminMessage = message.from == "Admin";
                            return Align(
                              alignment: isAdminMessage
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isAdminMessage
                                      ? Colors.blue[100]
                                      : Colors.green[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isAdminMessage) ...[
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: kPurpleColor,
                                        child: Text(
                                          (message.from?.isNotEmpty ?? false)
                                              ? message.from![0]
                                              : 'N/A',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: isAdminMessage
                                            ? CrossAxisAlignment.start
                                            : CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            message.message ?? "",
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            formatDate(message.createdAt ?? ""),
                                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isAdminMessage) ...[
                                      const SizedBox(width: 10),
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: kGreenColor,
                                        child: Text(
                                          (message.from?.isNotEmpty ?? false)
                                              ? message.from![0]
                                              : 'N/A',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: chatStatus == "open"
                ? Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _controller,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.none,
                          cursorColor: kPrimaryColor,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(defaultPadding),
                              borderSide: const BorderSide(),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            hintText: "Type a message...",
                            labelStyle: const TextStyle(color: kPrimaryColor),
                            hintStyle: const TextStyle(color: kPrimaryColor),
                          ),
                          maxLines: 4,
                          minLines: 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      FloatingActionButton(
                        onPressed: _sendMessage,
                        backgroundColor: kPrimaryColor,
                        child: const Icon(Icons.send, color: kWhiteColor),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}