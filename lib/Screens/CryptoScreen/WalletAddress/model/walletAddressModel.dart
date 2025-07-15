
class WalletAddressListsData {
  final String? coin;
  final String? noOfCoins;
  final String? walletAddress;

  WalletAddressListsData({
    this.coin,
    this.noOfCoins,
    this.walletAddress,
  });

  factory WalletAddressListsData.fromJson(Map<String, dynamic> json) {
    return WalletAddressListsData(
      coin: json['coin'] as String?,
      noOfCoins: json['noOfCoins'] as String?,
      walletAddress: json['walletAddress'] as String?,
    );
  }
}

class WalletAddressResponse {
  final List<WalletAddressListsData>? walletAddressList;

  WalletAddressResponse({
    this.walletAddressList,
  });

  factory WalletAddressResponse.fromJson(Map<String, dynamic> json) {
    return WalletAddressResponse(
      walletAddressList: (json['data'] as List<dynamic>? )
          ?.map((item) => WalletAddressListsData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
