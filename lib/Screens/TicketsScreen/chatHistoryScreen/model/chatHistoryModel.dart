import 'package:quickcash/Screens/TicketsScreen/chatHistoryScreen/chat_history_screen.dart';

class ChatHistoryResponse {
  final String? status;
  final List<ChatDetail>? chatDetails;

  ChatHistoryResponse({this.status, this.chatDetails});

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      status: json['status']?.toString(),
      chatDetails: (json['data'] as List<dynamic>?)
          ?.map((item) => ChatDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChatDetail {
  final String? id;
  final String? user;
  final String? from;
  final String? to;
  final String? message;
  final String? createdAt;
  final List<ChatMessage>? chat;

  ChatDetail({
    this.id,
    this.user,
    this.from,
    this.to,
    this.message,
    this.createdAt,
    this.chat,
  });

  factory ChatDetail.fromJson(Map<String, dynamic> json) {
    var chatList = (json['chat'] as List<dynamic>?)
        ?.map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();

    return ChatDetail(
      id: json['_id']?.toString(),
      user: json['user']?.toString(),
      from: json['from']?.toString(),
      to: json['to']?.toString(),
      message: json['message']?.toString(),
      createdAt: json['createdAt']?.toString(),
      chat: chatList,
    );
  }
}
