import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/CryptoBuyAndSellScreen/cryptoSellModel/cryptoSellModel/cryptoSellApi.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/CryptoBuyAndSellScreen/cryptoSellModel/cryptoSellModel/cryptoSellModel.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/TransactionSuccessScreen/transactionSuccessScreen.dart';
import 'package:quickcash/Screens/CryptoScreen/PaymentConfirmationScreen.dart';
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
  final CryptoBuyWalletAddressApi _cryptoBuyWalletAddressApi = CryptoBuyWalletAddressApi();
  final CryptoBuyAddApi _cryptoBuyAddApi = CryptoBuyAddApi();
  final CryptoTransactionGetDetailsApi _cryptoTransactionGetDetailsApi = CryptoTransactionGetDetailsApi();
  final RequestWalletAddressApi _requestWalletAddressApi = RequestWalletAddressApi();
  final CryptoSellAddApi _cryptoSellAddApi = CryptoSellAddApi();

  final TextEditingController walletAddress = TextEditingController();

  String? selectedTransferType;
  bool isCryptoBuy = true;
  bool isLoading = false;
  bool isWalletAddressRequest = false;
  bool isUpdateLoading = false;
  bool isConfirmed = false;

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
    super.initState();
    mSetData();
    // Fetch wallet address for both Buy and Sell
    mWalletAddress().then((_) => setState(() {}));
    isCryptoBuy = widget.mCryptoType == "Crypto Buy";
  }

  Future<void> mSetData() async {
    mAmount = widget.mCryptoAmount;
    mCurrency = widget.mCurrency;
    mCoin = widget.mCoinName;
    mFees = widget.mFees ?? 0.0;
    mExchangeFees = widget.mExchangeFees ?? 0.0;
    mGetAmount = widget.mYouGetAmount;
    mEstimateRate = widget.mEstimateRates;

    mTotalFees = (mFees ?? 0.0) + (mExchangeFees ?? 0.0);
    double amountValue = (mAmount != null) ? double.tryParse(mAmount!) ?? 0.0 : 0.0;

    if (widget.mCryptoType == "Crypto Buy") {
      mTotalAmount = amountValue + (mTotalFees ?? 0.0);
    } else {
      mTotalAmount = amountValue;
    }

    double getAmountValue = (mGetAmount != null) ? double.tryParse(mGetAmount!) ?? 0.0 : 0.0;
    mTotalCryptoSellAmount = getAmountValue - (mTotalFees ?? 0.0);

    if (mTotalCryptoSellAmount! < 0) {
      mTotalCryptoSellAmount = 0.0;
    }

    setState(() {});
  }

  Future<void> mWalletAddress() async {
    setState(() => isLoading = true);
    try {
      String coinName = '${mCoin}_TEST';
      final response = await _cryptoBuyWalletAddressApi.cryptoBuyWalletAddressApi(coinName, AuthManager.getUserEmail());
      if (response.message == "Response") {
        setState(() {
          walletAddress.text = response.data.addresses.first.address;
          isLoading = false;
        });
      } else if (response.message == "Wallet Address is not available please request wallet address") {
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Wallet Address is not available please request wallet address",
            color: Theme.of(context).extension<AppColors>()!.primary);
      } else {
        setState(() {
          isLoading = false;
          CustomSnackBar.showSnackBar(
              context: context,
              message: "We are facing some issue!",
              color: Theme.of(context).extension<AppColors>()!.primary);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isWalletAddressRequest = true;
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Wallet Address not found",
            color: Theme.of(context).extension<AppColors>()!.primary);
      });
    }
  }

  Future<void> mRequestWalletAddress() async {
    setState(() => isLoading = true);
    try {
      String coinName = '${mCoin}_TEST';
      final request = RequestWalletAddressRequest(userId: AuthManager.getUserId(), coinType: coinName);
      final response = await _requestWalletAddressApi.requestWalletAddressApi(request);
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
              color: Theme.of(context).extension<AppColors>()!.primary);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isWalletAddressRequest = true;
        CustomSnackBar.showSnackBar(
            context: context, message: "$error", color: Theme.of(context).extension<AppColors>()!.primary);
      });
    }
  }

  Future<void> mCryptoSellAddApi() async {
    setState(() => isUpdateLoading = true);
    if (mTotalCryptoSellAmount == null || mTotalCryptoSellAmount! <= 0) {
      setState(() {
        isUpdateLoading = false;
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Payment can't be done with zero or negative amount",
            color: Colors.red);
      });
      return;
    }

    try {
      int? fees = mTotalFees?.toInt();
      String coinType = '${mCoin}_TEST';
      final request = CryptoSellRequest(
          userId: AuthManager.getUserId(),
          amount: mGetAmount!,
          coinType: coinType,
          currencyType: mCurrency ?? 'USD',
          fees: fees ?? 0,
          noOfCoins: mAmount!,
          side: "sell",
          status: "pending");
      final response = await _cryptoSellAddApi.cryptoSellAddApi(request);
      if (response.message == "Crypto Transactions Successfully updated!!!") {
        setState(() {
          isUpdateLoading = false;
          mTransactionDetails(response.data.id, "Crypto Sell");
        });
      } else {
        setState(() {
          isUpdateLoading = false;
          CustomSnackBar.showSnackBar(
              context: context,
              message: "We are facing some issue, Please try after some time",
              color: Theme.of(context).extension<AppColors>()!.primary);
        });
      }
    } catch (error) {
      setState(() {
        isUpdateLoading = false;
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Something went wrong!",
            color: Theme.of(context).extension<AppColors>()!.primary);
      });
    }
  }

  Future<void> mCryptoBuyAddApi() async {
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
                  color: Theme.of(context).extension<AppColors>()!.primary);
              isUpdateLoading = false;
            });
          } else {
            setState(() => isUpdateLoading = false);
          }
        } catch (error) {
          setState(() {
            isUpdateLoading = false;
            CustomSnackBar.showSnackBar(
                context: context, message: "$error", color: Theme.of(context).extension<AppColors>()!.primary);
          });
        }
      } else {
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Please Request Wallet Address!",
            color: Theme.of(context).extension<AppColors>()!.primary);
      }
    } else {
      CustomSnackBar.showSnackBar(
          context: context,
          message: "Please Select Transfer Type!",
          color: Theme.of(context).extension<AppColors>()!.primary);
    }
  }

  Future<void> mTransactionDetails(String id, String mCryptoType) async {
    setState(() => isLoading = true);
    try {
      final response = await _cryptoTransactionGetDetailsApi.cryptoTransactionGetDetailsApiApi(id);
      if (response.message == "list are fetched Successfully") {
        setState(() {
          isLoading = false;
          print("Wallet Address passed: ${walletAddress.text}"); // Debug print
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentConfirmationScreen(
                mAmount: mAmount,
                mCurrency: mCurrency,
                mCoin: mCoin,
                mFees: mFees,
                mExchangeFees: mExchangeFees,
                mGetAmount: mGetAmount,
                mEstimateRate: mEstimateRate,
                mCryptoType: mCryptoType,
                mTotalAmount: mTotalAmount,
                mTotalCryptoSellAmount: mTotalCryptoSellAmount,
                transferType: selectedTransferType ?? "Bank Transfer",
                walletAddress: walletAddress.text,
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
              color: Colors.red);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackBar(
            context: context, message: '$error', color: Colors.red);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dynamicPadding = screenWidth * 0.04;
    final dynamicFontSize = screenWidth * 0.045;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2A72), Color(0xFF8A2BE2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(dynamicPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: dynamicFontSize * 1.2),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "STEP 1 OF 3",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: dynamicFontSize,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(dynamicPadding),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: isLoading
                      ?  Center(child: CircularProgressIndicator(color: Theme.of(context).extension<AppColors>()!.primary))
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: screenHeight * 0.02),
                              _buildStepIndicator(screenWidth),
                              SizedBox(height: screenHeight * 0.03),
                              Center(
                                child: Text(
                                  "${isCryptoBuy ? 'Buy' : 'Sell'} Details",
                                  style: TextStyle(
                                    fontSize: dynamicFontSize * 1.2,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).extension<AppColors>()!.primary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.03),
                              isCryptoBuy ? mCryptoBuy(screenWidth, screenHeight) : mCryptoSell(screenWidth, screenHeight),
                              SizedBox(height: screenHeight * 0.02),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(double screenWidth) {
    final circleSize = screenWidth * 0.07;
    final lineWidth = screenWidth * 0.1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle("1", "Details", true, circleSize),
        Container(
          width: lineWidth,
          height: 2,
          color: Colors.grey[400],
        ),
        _buildStepCircle("2", "Confirm", false, circleSize),
        Container(
          width: lineWidth,
          height: 2,
          color: Colors.grey[400],
        ),
        _buildStepCircle("3", "Complete", false, circleSize),
      ],
    );
  }

  Widget _buildStepCircle(String number, String label, bool isActive, double size) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Theme.of(context).extension<AppColors>()!.primary : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.4,
              ),
            ),
          ),
        ),
        SizedBox(height: size * 0.1),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Theme.of(context).extension<AppColors>()!.primary : Colors.grey,
            fontSize: size * 0.3,
          ),
        ),
      ],
    );
  }

  Widget mCryptoBuy(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: screenWidth * 0.02,
                spreadRadius: screenWidth * 0.0025,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("Amount:", "${mAmount ?? ''} $mCurrency", screenWidth),
              const Divider(color: Color(0xA66F35A5), height: 1),
              _buildDetailRow("Crypto Fees:", "${mFees?.toStringAsFixed(1) ?? '0.00'} $mCurrency", screenWidth),
              const Divider(color: Color(0xA66F35A5), height: 1),
              if (mExchangeFees != 0) ...[
                _buildDetailRow("Exchange Fees:", "${mExchangeFees?.toStringAsFixed(2) ?? '0.00'} $mCurrency", screenWidth),
                const Divider(color: Color(0xA66F35A5), height: 1),
              ],
              _buildDetailRow("Total Fees:", "${mTotalFees?.toStringAsFixed(1) ?? '0.00'} $mCurrency", screenWidth),
              const Divider(color: Color(0xA66F35A5), height: 1),
              _buildDetailRow("Total Amount:", "${mTotalAmount?.toStringAsFixed(1) ?? '0.00'} $mCurrency", screenWidth),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(height: 1, width: screenWidth * 0.6, color: Color(0xA66F35A5)),
              Material(
                elevation: 4.0,
                shape: const CircleBorder(),
                child: Container(
                  width: screenWidth * 0.09,
                  height: screenWidth * 0.09,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child:  Center(child: Icon(Icons.arrow_downward, size: 20, color: Theme.of(context).extension<AppColors>()!.primary)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: screenWidth * 0.02,
                spreadRadius: screenWidth * 0.0025,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text("You will get", style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045))),
              SizedBox(height: screenWidth * 0.04),
              Text('${mGetAmount?.toString() ?? '0.0'} $mCoin', style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.045)),
              const Divider(color: Color(0xA66F35A5), height: 1),
              Text("1 $mCurrency = ${mEstimateRate?.toString() ?? '0.0'} $mCoin", style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.035)),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.03),
        _buildTransferTypeDropdown(screenWidth),
        SizedBox(height: screenHeight * 0.02),
        _buildWalletAddressField(screenWidth),
        SizedBox(height: screenHeight * 0.02),
        if (isWalletAddressRequest)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: screenWidth * 0.5,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (context) => WalletAddressScreen())),
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).extension<AppColors>()!.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025))),
                  child: Text('Request Wallet Address', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04)),
                ),
              ),
            ],
          ),
        SizedBox(height: screenHeight * 0.02),
        if (isUpdateLoading) Center(child: CircularProgressIndicator(color: Theme.of(context).extension<AppColors>()!.primary)),
        SizedBox(height: screenHeight * 0.02),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: SizedBox(
            width: screenWidth > 600 ? 140 : screenWidth * 0.40,
            child: ElevatedButton(
              onPressed: isUpdateLoading ? null : mCryptoBuyAddApi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025)),
              ),
              child: Text('Confirm & Buy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget mCryptoSell(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: screenWidth * 0.02,
                spreadRadius: screenWidth * 0.0025,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow("No of Coins:", "${mAmount ?? ''} $mCoin", screenWidth),
              const Divider(color: Color(0xA66F35A5), height: 1),
              _buildDetailRow("Crypto Fees:", "${mFees?.toStringAsFixed(2) ?? '0.00'} $mCurrency", screenWidth),
              const Divider(color: Color(0xA66F35A5), height: 1),
              if (mExchangeFees != 0) ...[
                _buildDetailRow("Exchange Fees:", "${mExchangeFees?.toStringAsFixed(2) ?? '0.00'} $mCurrency", screenWidth),
                const Divider(color: Color(0xA66F35A5), height: 1),
              ],
              _buildDetailRow("Total Fees:", "${mTotalFees?.toStringAsFixed(2) ?? '0.00'} $mCurrency", screenWidth),
              const Divider(color: Color(0xA66F35A5), height: 1),
              _buildDetailRow("Amount for ${mAmount ?? ''} $mCoin:", "${mGetAmount ?? ''} $mCurrency", screenWidth),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(height: 1, width: screenWidth * 0.6, color: Color(0xA66F35A5)),
              Material(
                elevation: 4.0,
                shape: const CircleBorder(),
                child: Container(
                  width: screenWidth * 0.09,
                  height: screenWidth * 0.09,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child:  Center(child: Icon(Icons.arrow_downward, size: 20, color: Theme.of(context).extension<AppColors>()!.primary)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: screenWidth * 0.02,
                spreadRadius: screenWidth * 0.0025,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: Text("You will get", style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045))),
              SizedBox(height: screenWidth * 0.04),
              Text("Total Amount = Amount - Fees", style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.035)),
              SizedBox(height: screenHeight * 0.01),
              Text("$mCurrency ${mTotalCryptoSellAmount?.toStringAsFixed(2) ?? '0.00'}", style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.045)),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.03),
        _buildTransferTypeDropdown(screenWidth),
        SizedBox(height: screenHeight * 0.02),
        _buildWalletAddressField(screenWidth),
        SizedBox(height: screenHeight * 0.02),
        if (isWalletAddressRequest)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: screenWidth * 0.5,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => Navigator.push(context, MaterialPageRoute(builder: (context) => WalletAddressScreen())),
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).extension<AppColors>()!.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025))),
                  child: Text('Request Wallet Address', style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04)),
                ),
              ),
            ],
          ),
        SizedBox(height: screenHeight * 0.02),
        if (isUpdateLoading) Center(child: CircularProgressIndicator(color: Theme.of(context).extension<AppColors>()!.primary)),
        SizedBox(height: screenHeight * 0.02),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: SizedBox(
              width: screenWidth > 600 ? 140 : screenWidth * 0.40,
            child: ElevatedButton(
              onPressed: isUpdateLoading ? null : mCryptoSellAddApi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.025)),
              ),
              child: Text('Confirm & Sell', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.04)),
          Text(value, style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w600, color: Theme.of(context).extension<AppColors>()!.primary)),
        ],
      ),
    );
  }

  Widget _buildTransferTypeDropdown(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Transfer Type", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.045)),
        SizedBox(height: screenWidth * 0.02),
        GestureDetector(
          onTap: () => _showTransferTypeDropDown(context, true),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.03),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(screenWidth * 0.025),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedTransferType ?? "Bank Transfer",
                  style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.04),
                ),
                Icon(Icons.arrow_drop_down, color: Theme.of(context).extension<AppColors>()!.primary, size: screenWidth * 0.05),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletAddressField(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Wallet Address", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.045)),
        SizedBox(height: screenWidth * 0.02),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(screenWidth * 0.025),
            color: Colors.white,
          ),
          child: TextFormField(
            controller: walletAddress,
            readOnly: true,
            style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.04),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.03),
              border: InputBorder.none,
            ),
            minLines: 1,
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  void _showTransferTypeDropDown(BuildContext context, bool isTransfer) {
    final screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.05)),
      ),
      builder: (BuildContext context) => Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: screenWidth * 0.1,
              height: 4,
              margin: EdgeInsets.only(bottom: screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Image.asset(
                'assets/icons/bank.png',
                height: screenWidth * 0.06,
                color: Theme.of(context).extension<AppColors>()!.primary,
              ),
              title: Text(
                'Bank Transfer',
                style: TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.04),
              ),
              onTap: () {
                setState(() {
                  if (isTransfer) selectedTransferType = 'Bank Transfer';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}