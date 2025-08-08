class NotificationModel {
  final String id;
  final String user;
  final String title;
  final List<String> tags;
  final String attachment;
  final String message;
  final String notifyFrom;
  final String notifyType;
  final bool read;
  final String createdAt;
  final List<UserDetails> userDetails;

  NotificationModel({
    required this.id,
    required this.user,
    required this.title,
    required this.tags,
    required this.attachment,
    required this.message,
    required this.notifyFrom,
    required this.notifyType,
    required this.read,
    required this.createdAt,
    required this.userDetails,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      title: json['title'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      attachment: json['attachment'] ?? '',
      message: json['message'] ?? '',
      notifyFrom: json['notifyFrom'] ?? '',
      notifyType: json['notifyType'] ?? '',
      read: json['read'] ?? false,
      createdAt: json['createdAt'] ?? '',
      userDetails: (json['userDetails'] as List<dynamic>?)
              ?.map((item) => UserDetails.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class UserDetails {
  final String name;

  UserDetails({required this.name});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      name: json['name'] ?? '',
    );
  }
}