// login_model.dart
class LoginHistoryList {
  LoginHistoryList();
}

class LoginHistoryListDetails {
  final String? date;
  final String? device;
  final String? os;
  final String? ipAddress;

  LoginHistoryListDetails({
    this.date,
    this.device,
    this.os,
    this.ipAddress,
  });

  factory LoginHistoryListDetails.fromJson(Map<String, dynamic> json) {
    return LoginHistoryListDetails(
      date: json['createdAt'] as String?,
      device: json['device'] as String?,
      os: json['OS'] as String?,
      ipAddress: json['ipAddress'] as String?,
    );
  }
}

class LoginHistoryResponse {
  final List<LoginHistoryListDetails>? loginHistoryList; // Change to List<BeneficiaryAccountListDetails>

  LoginHistoryResponse({
    this.loginHistoryList,
  });

  factory LoginHistoryResponse.fromJson(Map<String, dynamic> json) {
    return LoginHistoryResponse(
      loginHistoryList: (json['data'] as List<dynamic>?)
          ?.map((item) => LoginHistoryListDetails.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
