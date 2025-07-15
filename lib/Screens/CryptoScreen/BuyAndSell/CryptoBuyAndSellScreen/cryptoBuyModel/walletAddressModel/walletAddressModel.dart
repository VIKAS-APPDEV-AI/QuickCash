class CryptoBuyWalletAddressResponse {
  final int status;
  final String message;
  final WalletData data;

  // Constructor
  CryptoBuyWalletAddressResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  // Factory method to create a CryptoBuyWalletAddressResponse from JSON
  factory CryptoBuyWalletAddressResponse.fromJson(Map<String, dynamic> json) {
    return CryptoBuyWalletAddressResponse(
      status: json['status'],
      message: json['message'],
      data: WalletData.fromJson(json['data']),
    );
  }

  // Method to convert CryptoBuyWalletAddressResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class WalletData {
  final List<WalletAddress> addresses;

  // Constructor
  WalletData({required this.addresses});

  // Factory method to create WalletData from JSON
  factory WalletData.fromJson(Map<String, dynamic> json) {
    var addressesList = json['addresses'] as List;
    List<WalletAddress> addressObjs = addressesList
        .map((addressJson) => WalletAddress.fromJson(addressJson))
        .toList();
    return WalletData(addresses: addressObjs);
  }

  // Method to convert WalletData to JSON
  Map<String, dynamic> toJson() {
    return {
      'addresses': addresses.map((address) => address.toJson()).toList(),
    };
  }
}

class WalletAddress {
  final String assetId;
  final String address;
  final String description;
  final String tag;
  final String type;
  final String legacyAddress;
  final String enterpriseAddress;
  final int bip44AddressIndex;
  final bool userDefined;

  // Constructor
  WalletAddress({
    required this.assetId,
    required this.address,
    required this.description,
    required this.tag,
    required this.type,
    required this.legacyAddress,
    required this.enterpriseAddress,
    required this.bip44AddressIndex,
    required this.userDefined,
  });

  // Factory method to create WalletAddress from JSON
  factory WalletAddress.fromJson(Map<String, dynamic> json) {
    return WalletAddress(
      assetId: json['assetId'],
      address: json['address'],
      description: json['description'] ?? '',
      tag: json['tag'] ?? '',
      type: json['type'],
      legacyAddress: json['legacyAddress'] ?? '',
      enterpriseAddress: json['enterpriseAddress'] ?? '',
      bip44AddressIndex: json['bip44AddressIndex'],
      userDefined: json['userDefined'],
    );
  }

  // Method to convert WalletAddress to JSON
  Map<String, dynamic> toJson() {
    return {
      'assetId': assetId,
      'address': address,
      'description': description,
      'tag': tag,
      'type': type,
      'legacyAddress': legacyAddress,
      'enterpriseAddress': enterpriseAddress,
      'bip44AddressIndex': bip44AddressIndex,
      'userDefined': userDefined,
    };
  }
}
