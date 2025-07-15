
class ViewClientsResponse {
  final String? firstName;
  final String? lastName;
  final String? email;
  final int? mobile;
  final String? country;
  final String? state;
  final String? city;
  final String? postalCode;
  final String? address;
  final String? notes;
  final String? lastUpdate;
  final String? profilePhoto;

  ViewClientsResponse({
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.country,
    this.state,
    this.city,
    this.postalCode,
    this.address,
    this.notes,
    this.lastUpdate,
    this.profilePhoto,
  });

  factory ViewClientsResponse.fromJson(Map<String, dynamic> json) {
    return ViewClientsResponse(
      firstName: json['data']?['firstName'] as String?,
      lastName: json['data']?['lastName'] as String?,
      email: json['data']?['email'] as String?,
      mobile: json['data']?['mobile'] as int?,
      country: json['data']?['country'] as String?,
      state: json['data']?['state'] as String?,
      city: json['data']?['city'] as String?,
      postalCode: json['data']?['postalCode'] as String?,
      address: json['data']?['address'] as String?,
      notes: json['data']?['notes'] as String?,
      lastUpdate: json['data']?['updatedAt'] as String?,
      profilePhoto: json['data']?['profilePhoto'] as String?,
    );
  }
}
