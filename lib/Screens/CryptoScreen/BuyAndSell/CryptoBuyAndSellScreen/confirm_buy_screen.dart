import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/CryptoBuyAndSellScreen/cryptoSellModel/cryptoSellModel/cryptoSellApi.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/CryptoBuyAndSellScreen/cryptoSellModel/cryptoSellModel/cryptoSellModel.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/TransactionSuccessScreen/transactionSuccessScreen.dart';
import 'package:quickcash/Screens/CryptoScreen/WalletAddress/walletAddress_screen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../../../../util/customSnackBar.dart';
import 'cryptoBuyModel/cryptoBuyAddModel/cryptoBuyAddApi.dart';
import 'cryptoBuyModel/cryptoBuyAddModel/cryptoBuyAddModel.dart';
import 'cryptoBuyModel/cryptoTransactionGetDetails/cryptoTransactionGetDetailsApi.dart';
import 'cryptoBuyModel/requestWalletAddressModel/requestWalletAddressApi.dart';
import 'cryptoBuyModel/requestWalletAddressModel/requestWalletAddressModel.dart';
import 'cryptoBuyModel/walletAddressModel/walletAddressApi.dart';

class ConfirmBuyScreen extends StatefulWidget {
  final String? mCryptoAmount;
  final String? mCurrency;
  final String? mCoinName;
  final double? mFees;
  final double? mExchangeFees;
  final String? mYouGetAmount;
  final double? mEstimateRates;
  final String? mCryptoType;

  const ConfirmBuyScreen({
    super.key,
    this.mCryptoAmount,
    this.mCurrency,
    this.mCoinName,
    this.mFees,
    this.mExchangeFees,
    this.mYouGetAmount,
    this.mEstimateRates,
    this.mCryptoType,
  });

  @override
  State<ConfirmBuyScreen> createState() => _ConfirmBuyScreenState();
}

class _ConfirmBuyScreenState extends State<ConfirmBuyScreen> {
  final CryptoBuyWalletAddressApi _cryptoBuyWalletAddressApi =
      CryptoBuyWalletAddressApi();
  final CryptoBuyAddApi _cryptoBuyAddApi = CryptoBuyAddApi();
  final CryptoTransactionGetDetailsApi _cryptoTransactionGetDetailsApi =
      CryptoTransactionGetDetailsApi();
  final RequestWalletAddressApi _requestWalletAddressApi =
      RequestWalletAddressApi();
  final CryptoSellAddApi _cryptoSellAddApi = CryptoSellAddApi();

  final TextEditingController walletAddress = TextEditingController();

  String? selectedTransferType;
  bool isCryptoBuy = true;
  bool isLoading = false;
  bool isWalletAddressRequest = false;
  bool isUpdateLoading = false;

  String? mAmount;
  String? mCurrency;
  String? mCoin;
  double? mFees;
  double? mExchangeFees;
  double? mTotalFees;
  String? mGetAmount;
  double? mEstimateRate;
  double? mTotalAmount;
  double? mTotalCryptoSellAmount;
  String? mCryptoSellAddTransactionId;

  @override
  void initState() {
    print("Debug - initState called");
    mSetData();
    if (widget.mCryptoType == "Crypto Buy") {
      print("Debug - Crypto Buy detected, calling mWalletAddress");
      mWalletAddress();
      isCryptoBuy = true;
    } else {
      print("Debug - Crypto Sell detected");
      isCryptoBuy = false;
    }
    super.initState();
  }

  Future<void> mSetData() async {
    print("Debug - mSetData called");
    mAmount = widget.mCryptoAmount;
    mCurrency = widget.mCurrency;
    mCoin = widget.mCoinName;
    mFees = widget.mFees ?? 0.0;
    mExchangeFees = widget.mExchangeFees ?? 0.0;
    mGetAmount = widget.mYouGetAmount;
    mEstimateRate = widget.mEstimateRates;

    print("Crypto Fees in Confirm: $mFees");
    print("Exchange Fees in Confirm: $mExchangeFees");

    mTotalFees = (mFees ?? 0.0) + (mExchangeFees ?? 0.0);
    print("Debug - mTotalFees calculated: $mTotalFees");

    double amountValue =
        (mAmount != null) ? double.tryParse(mAmount!) ?? 0.0 : 0.0;

    if (widget.mCryptoType == "Crypto Buy") {
      mTotalAmount = amountValue + (mTotalFees ?? 0.0);
      print("Debug - Crypto Buy - mTotalAmount: $mTotalAmount");
    } else {
      mTotalAmount = amountValue;
      print("Debug - Crypto Sell - mTotalAmount: $mTotalAmount");
    }

    double getAmountValue =
        (mGetAmount != null) ? double.tryParse(mGetAmount!) ?? 0.0 : 0.0;
    mTotalCryptoSellAmount = getAmountValue - (mTotalFees ?? 0.0);
    print("Debug - mTotalCryptoSellAmount before adjustment: $mTotalCryptoSellAmount");

    if (mTotalCryptoSellAmount! < 0) {
      mTotalCryptoSellAmount = 0.0;
      print("Debug - mTotalCryptoSellAmount adjusted to 0.0 (was negative)");
    }

    setState(() {});
  }

  Future<void> mWalletAddress() async {
    print("Debug - mWalletAddress called");
    setState(() => isLoading = true);
    try {
      String coinName = '${mCoin}_TEST';
      final response = await _cryptoBuyWalletAddressApi
          .cryptoBuyWalletAddressApi(coinName, AuthManager.getUserEmail());
      if (response.message == "Response") {
        setState(() {
          walletAddress.text = response.data.addresses.first.address;
          isLoading = false;
        });
      } else if (response.message ==
          "Wallet Address is not available please request wallet address") {
        CustomSnackBar.showSnackBar(
            context: context,
            message:
                "Wallet Address is not available please request wallet address",
            color: kPrimaryColor);
      } else {
        setState(() {
          isLoading = false;
          CustomSnackBar.showSnackBar(
              context: context,
              message: "We are facing some issue!",
              color: kPrimaryColor);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isWalletAddressRequest = true;
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Wallet Address not found",
            color: kPrimaryColor);
      });
    }
  }

  Future<void> mRequestWalletAddress() async {
    print("Debug - mRequestWalletAddress called");
    setState(() => isLoading = true);
    try {
      String coinName = '${mCoin}_TEST';
      final request = RequestWalletAddressRequest(
          userId: AuthManager.getUserId(), coinType: coinName);
      final response =
          await _requestWalletAddressApi.requestWalletAddressApi(request);
      if (response.message == "Wallet Address data is added !!!") {
        setState(() {
          isLoading = false;
          isWalletAddressRequest = false;
          walletAddress.text = response.data;
        });
      } else {
        setState(() {
          isLoading = false;
          CustomSnackBar.showSnackBar(
              context: context,
              message: "Please try after some time!",
              color: kPrimaryColor);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isWalletAddressRequest = true;
        CustomSnackBar.showSnackBar(
            context: context, message: "$error", color: kPrimaryColor);
      });
    }
  }

  Future<void> mCryptoSellAddApi() async {
    print("Debug - mCryptoSellAddApi called");
    setState(() => isUpdateLoading = true);
    print("Debug - isUpdateLoading set to true");

    if (mTotalCryptoSellAmount == null || mTotalCryptoSellAmount! <= 0) {
      print("Debug - mTotalCryptoSellAmount validation failed: $mTotalCryptoSellAmount");
      setState(() {
        isUpdateLoading = false;
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Payment can't be done with zero or negative amount",
            color: kRedColor);
      });
      return;
    }

    try {
      int? fees = mTotalFees?.toInt();
      print("Debug - Converted fees: $fees");
      print("Debug - mTotalFees type: ${mTotalFees.runtimeType}, value: $mTotalFees");
      if (fees == null || fees <= 0) {
        print("Debug - Warning: Fees is null or zero");
      }
      String coinType = '${mCoin}_TEST';
      print("Debug - coinType: $coinType");
      print("Debug - mCurrency: $mCurrency");
      print(mAmount);

      final request = CryptoSellRequest(
          userId: AuthManager.getUserId(),
          amount: mGetAmount!,
          coinType: coinType,
          currencyType: mCurrency ?? 'USD',
          fees: fees ?? 0,
          noOfCoins: mAmount!,
          side: "sell",
          status: "pending");
      print("Debug - CryptoSellRequest created: $request");
      print("Debug - CryptoSellRequest JSON: ${request.toJson()}");

      final response = await _cryptoSellAddApi.cryptoSellAddApi(request);
      print("Debug - API Response: ${response.message}");

      if (response.message == "Crypto Transactions Successfully updated!!!") {
        print("Debug - Transaction successful, calling mTransactionDetails");
        setState(() {
          isUpdateLoading = false;
          mTransactionDetails(response.data.id, "Crypto Sell");
        });
      } else {
        print("Debug - Transaction failed with message: ${response.message}");
        setState(() {
          isUpdateLoading = false;
          CustomSnackBar.showSnackBar(
              context: context,
              message: "We are facing some issue, Please try after some time",
              color: kPrimaryColor);
        });
      }
    } catch (error) {
      print("Debug - Error in mCryptoSellAddApi: $error");
      setState(() {
        isUpdateLoading = false;
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Something went wrong!",
            color: kPrimaryColor);
      });
    }
  }

  Future<void> mCryptoBuyAddApi() async {
    print("Debug - mCryptoBuyAddApi called");
    if (selectedTransferType != null) {
      if (walletAddress.text.isNotEmpty) {
        setState(() => isUpdateLoading = true);
        try {
          int amount = int.parse(mAmount!);
          int? fees = mTotalFees?.toInt();
          String coinType = '${mCoin}_TEST';
          final request = CryptoBuyAddRequest(
            userId: AuthManager.getUserId(),
            amount: amount,
            coinType: coinType,
            currencyType: mCurrency ?? '',
            fees: fees ?? 0,
            noOfCoins: mGetAmount!,
            paymentType: "Bank Transfer",
            side: "buy",
            status: "pending",
            walletAddress: walletAddress.text,
          );
          final response = await _cryptoBuyAddApi.cryptoBuyAddApi(request);
          if (response.message == "Crypto Transactions successfully !!!") {
            setState(() {
              isUpdateLoading = false;
              mCryptoSellAddTransactionId = response.data.id;
              mTransactionDetails(response.data.id, "Crypto Buy");
            });
          } else if (response.message == "All fields are mandatory") {
            setState(() {
              CustomSnackBar.showSnackBar(
                  context: context,
                  message: "All fields are mandatory",
                  color: kPrimaryColor);
              isUpdateLoading = false;
            });
          } else {
            setState(() => isUpdateLoading = false);
          }
        } catch (error) {
          setState(() {
            isUpdateLoading = false;
            CustomSnackBar.showSnackBar(
                context: context, message: "$error", color: kPrimaryColor);
          });
        }
      } else {
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Please Request Wallet Address!",
            color: kPrimaryColor);
      }
    } else {
      CustomSnackBar.showSnackBar(
          context: context,
          message: "Please Select Transfer Type!",
          color: kPrimaryColor);
    }
  }

  Future<void> mTransactionDetails(String id, String mCryptoType) async {
    print("Debug - mTransactionDetails called with id: $id, type: $mCryptoType");
    setState(() => isLoading = true);
    try {
      final response = await _cryptoTransactionGetDetailsApi
          .cryptoTransactionGetDetailsApiApi(id);
      if (response.message == "list are fetched Successfully") {
        setState(() {
          isLoading = false;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionSuccessScreen(
                totalAmount: mTotalAmount,
                currency: mCurrency,
                coinName: mCoin,
                gettingCoin: mCryptoType == "Crypto Sell"
                    ? mTotalCryptoSellAmount?.toStringAsFixed(2)
                    : mGetAmount,
                mCryptoType: mCryptoType,
              ),
            ),
          );
        });
      } else {
        setState(() {
          isLoading = false;
          CustomSnackBar.showSnackBar(
              context: context,
              message: "We are facing some issue!",
              color: kRedColor);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackBar(
            context: context, message: '$error', color: kRedColor);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Debug - build called, isLoading: $isLoading");
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("${widget.mCryptoType}",
            style: const TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kPrimaryColor))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: defaultPadding),
                    Text("Confirm ${widget.mCryptoType}",
                        style: const TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    const SizedBox(height: largePadding),
                    isCryptoBuy ? mCryptoBuy() : mCryptoSell(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget mCryptoBuy() {
    print("Debug - mCryptoBuy called");
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Amount:",
                        style: TextStyle(color: kPrimaryColor)),
                    Text("${mAmount ?? ''} $mCurrency",
                        style: const TextStyle(color: kPrimaryColor)),
                  ],
                ),
                const Divider(color: kPrimaryLightColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Crypto Fees:",
                        style: TextStyle(color: kPrimaryColor)),
                    Text("${mFees?.toStringAsFixed(2) ?? '0.00'} $mCurrency",
                        style: const TextStyle(color: kPrimaryColor)),
                  ],
                ),
                const Divider(color: kPrimaryLightColor),
                if (mExchangeFees != 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Exchange Fees:",
                          style: TextStyle(color: kPrimaryColor)),
                      Text(
                          "${mExchangeFees?.toStringAsFixed(2) ?? '0.00'} $mCurrency",
                          style: const TextStyle(color: kPrimaryColor)),
                    ],
                  ),
                  const Divider(color: kPrimaryLightColor),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Fees:",
                        style: TextStyle(color: kPrimaryColor)),
                    Text(
                        "${mTotalFees?.toStringAsFixed(2) ?? '0.00'} $mCurrency",
                        style: const TextStyle(color: kPrimaryColor)),
                  ],
                ),
                const Divider(color: kPrimaryLightColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Amount:",
                        style: TextStyle(color: kPrimaryColor)),
                    Text(
                        "${mTotalAmount?.toStringAsFixed(2) ?? '0.00'} $mCurrency",
                        style: const TextStyle(color: kPrimaryColor)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: smallPadding),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(height: 1, width: 250, color: kPrimaryLightColor),
                Material(
                  elevation: 4.0,
                  shape: const CircleBorder(),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: const Center(
                        child: Icon(Icons.arrow_downward,
                            size: 20, color: kPrimaryColor)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: smallPadding),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                    child: Text("You will get",
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold))),
                const SizedBox(height: defaultPadding),
                Text('${mGetAmount?.toString() ?? '0.0'} $mCoin',
                    style: const TextStyle(color: kPrimaryColor)),
                const Divider(color: kPrimaryLightColor),
                Text(
                    "1 $mCurrency = ${mEstimateRate?.toString() ?? '0.0'} $mCoin",
                    style: const TextStyle(color: kPrimaryColor)),
              ],
            ),
          ),
          const SizedBox(height: 45.0),
          GestureDetector(
            onTap: () => _showTransferTypeDropDown(context, true),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPrimaryColor)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (selectedTransferType != null)
                        const SizedBox(width: smallPadding),
                      Text(
                          selectedTransferType != null
                              ? '$selectedTransferType ${_getFlagForTransferType(selectedTransferType!)}'
                              : 'Transfer Type',
                          style: const TextStyle(
                              color: kPrimaryColor, fontSize: 16)),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25.0),
          TextFormField(
            controller: walletAddress,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            style: const TextStyle(color: kPrimaryColor),
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Wallet Address",
              labelStyle: const TextStyle(color: kPrimaryColor),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide()),
              filled: true,
              fillColor: Colors.white,
            ),
            minLines: 1,
            maxLines: 6,
          ),
          const SizedBox(height: largePadding),
          if (isWalletAddressRequest)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 220,
                  child: FloatingActionButton.extended(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WalletAddressScreen())),
                    backgroundColor: kPrimaryColor,
                    label: const Text('Request Wallet Address',
                        style: TextStyle(color: kWhiteColor, fontSize: 15)),
                  ),
                ),
              ],
            ),
          const SizedBox(height: defaultPadding),
          if (isUpdateLoading)
            const Center(
                child: CircularProgressIndicator(color: kPrimaryColor)),
          const SizedBox(height: 35.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: isUpdateLoading
                  ? null
                  : () {
                      print("Debug - Confirm & Buy button pressed");
                      mCryptoBuyAddApi();
                    },
              child: const Text('Confirm & Buy',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget mCryptoSell() {
    print("Debug - mCryptoSell called");
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("No of Coins:",
                        style: TextStyle(color: kPrimaryColor)),
                    Text("${mAmount ?? ''} $mCoin",
                        style: const TextStyle(color: kPrimaryColor)),
                  ],
                ),
                const Divider(color: kPrimaryLightColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Crypto Fees:",
                        style: TextStyle(color: kPrimaryColor)),
                    Text("${mFees?.toStringAsFixed(2) ?? '0.00'} $mCurrency",
                        style: const TextStyle(color: kPrimaryColor)),
                  ],
                ),
                const Divider(color: kPrimaryLightColor),
                if (mExchangeFees != 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Exchange Fees:",
                          style: TextStyle(color: kPrimaryColor)),
                      Text(
                          "${mExchangeFees?.toStringAsFixed(2) ?? '0.00'} $mCurrency",
                          style: const TextStyle(color: kPrimaryColor)),
                    ],
                  ),
                  const Divider(color: kPrimaryLightColor),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Fees:",
                        style: TextStyle(color: kPrimaryColor)),
                    Text(
                        "${mTotalFees?.toStringAsFixed(2) ?? '0.00'} $mCurrency",
                        style: const TextStyle(color: kPrimaryColor)),
                  ],
                ),
                const Divider(color: kPrimaryLightColor),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Amount for ${mAmount ?? ''} $mCoin = ${mGetAmount ?? ''} $mCurrency",
                        style: const TextStyle(color: kPrimaryColor)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: smallPadding),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(height: 1, width: 250, color: kPrimaryLightColor),
                Material(
                  elevation: 4.0,
                  shape: const CircleBorder(),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: const Center(
                        child: Icon(Icons.arrow_downward,
                            size: 20, color: kPrimaryColor)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: smallPadding),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(
                    child: Text("You will get",
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold))),
                const SizedBox(height: defaultPadding),
                const Text('Total Amount = Amount - Fees',
                    style: TextStyle(color: kPrimaryColor)),
                const SizedBox(height: smallPadding),
                Text(
                    "$mCurrency ${mTotalCryptoSellAmount?.toStringAsFixed(2) ?? '0.00'}",
                    style: const TextStyle(color: kPrimaryColor)),
              ],
            ),
          ),
          const SizedBox(height: defaultPadding),
          if (isUpdateLoading)
            const Center(
                child: CircularProgressIndicator(color: kPrimaryColor)),
          const SizedBox(height: 55.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: isUpdateLoading
                  ? null
                  : () {
                      print("Debug - Confirm & Sell button pressed");
                      mCryptoSellAddApi();
                    },
              child: const Text('Confirm & Sell',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransferTypeDropDown(BuildContext context, bool isTransfer) {
    print("Debug - _showTransferTypeDropDown called");
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => ListView(
        children: [
          const SizedBox(height: 25),
          _buildTransferOptions(
              'Bank Transfer', 'assets/icons/bank.png', isTransfer),
        ],
      ),
    );
  }

  Widget _buildTransferOptions(String type, String logoPath, bool isTransfer) {
    return ListTile(
      title: Row(
        children: [
          const SizedBox(width: defaultPadding),
          Image.asset(logoPath, height: 24, color: kPrimaryColor),
          const SizedBox(width: defaultPadding),
          Text(type, style: const TextStyle(color: kPrimaryColor)),
        ],
      ),
      onTap: () {
        setState(() {
          if (isTransfer) selectedTransferType = type;
        });
        Navigator.pop(context);
      },
    );
  }

  String _getFlagForTransferType(String transferType) {
    switch (transferType) {
      case "Bank Transfer":
        return '';
      default:
        return '';
    }
  }
}