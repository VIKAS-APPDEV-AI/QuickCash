
class ClientsData {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? date;

  ClientsData({
    this.id,
    this.firstName,
    this.lastName,
    this.date,
  });

  factory ClientsData.fromJson(Map<String, dynamic> json) {
    return ClientsData(

      id: json['_id'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      date: json['createdAt'] as String?,
    );
  }
}

class ClientsResponse {
  final List<ClientsData>? clientsList;

  ClientsResponse({
    this.clientsList,
  });

  factory ClientsResponse.fromJson(Map<String, dynamic> json) {
    return ClientsResponse(
      clientsList: (json['data'] as List<dynamic>? )
          ?.map((item) => ClientsData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
