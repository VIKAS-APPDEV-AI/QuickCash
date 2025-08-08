import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationModel/NotificationsModel.dart';
import 'package:quickcash/util/apiConstants.dart';
import 'package:quickcash/util/auth_manager.dart';



class NotificationService {
  Future<List<NotificationModel>> getUserNotifications() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/notification/user-all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final List<dynamic> notificationJson = data['data'] ?? [];
      return notificationJson
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  }
}