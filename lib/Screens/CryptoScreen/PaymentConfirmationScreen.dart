import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/TransactionSuccessScreen/transactionSuccessScreen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/customSnackBar.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final String? mAmount;
  final String? mCurrency;
  final String? mCoin;
  final double? mFees;
  final double? mExchangeFees;
  final String? mGetAmount;
  final double? mEstimateRate;
  final String? mCryptoType;
  final double? mTotalAmount;
  final double? mTotalCryptoSellAmount;
  final String? transferType;
  final String? walletAddress;

  const PaymentConfirmationScreen({
    super.key,
    this.mAmount,
    this.mCurrency,
    this.mCoin,
    this.mFees,
    this.mExchangeFees,
    this.mGetAmount,
    this.mEstimateRate,
    this.mCryptoType,
    this.mTotalAmount,
    this.mTotalCryptoSellAmount,
    this.transferType,
    this.walletAddress,
  });

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  late Timer _timer;
  int _startSeconds = 10 * 60; // 10 minutes in seconds
  int _remainingSeconds = 10 * 60;
  bool isTimerExpired = false;
  bool isConfirmed = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
          isTimerExpired = true;
          CustomSnackBar.showSnackBar(
            context: context,
            message: "Time expired! Please restart the process.",
            color: Colors.red,
          );
          Navigator.pop(context);
        }
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _confirmPayment() async {
    if (!isProcessing) {
      setState(() => isProcessing = true);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => isProcessing = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionSuccessScreen(
            totalAmount: widget.mTotalAmount,
            currency: widget.mCurrency,
            coinName: widget.mCoin,
            gettingCoin: widget.mCryptoType == "Crypto Sell"
                ? widget.mTotalCryptoSellAmount?.toStringAsFixed(2)
                : widget.mGetAmount,
            mCryptoType: widget.mCryptoType,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dynamicPadding = screenWidth * 0.04;
    final dynamicFontSize = screenWidth * 0.045;

    double progress = _remainingSeconds / _startSeconds;

    return Scaffold(
      body: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).extension<AppColors>()!.primary, Color.fromARGB(255, 30, 29, 30)],
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
                      icon: Icon(Icons.arrow_back,
                          color: Colors.white, size: dynamicFontSize * 1.2),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "STEP 2 OF 3",
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
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        _buildStepIndicator(screenWidth),
                        SizedBox(height: screenHeight * 0.03),
                        _buildTimerAndProgress(progress),
                        SizedBox(height: screenHeight * 0.03),
                        Center(
                          child: Text(
                            "${widget.mCryptoType == 'Crypto Buy' ? 'BUY Details' : 'Confirm SELL'}",
                            style: TextStyle(
                              fontSize: dynamicFontSize * 1.2,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).extension<AppColors>()!.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        widget.mCryptoType == "Crypto Buy"
                            ? _buildCryptoBuyDetails(screenWidth, screenHeight)
                            : _buildCryptoSellDetails(
                                screenWidth, screenHeight),
                        SizedBox(height: screenHeight * 0.02),
                        _buildConfirmationCheckbox(screenWidth),
                        SizedBox(height: screenHeight * 0.03),
                        _buildActionButtons(screenWidth, screenHeight),
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
        _buildStepCircle("1", "Details", false, circleSize),
        Container(width: lineWidth, height: 2, color: Colors.grey[400]),
        _buildStepCircle("2", "Confirm", true, circleSize),
        Container(width: lineWidth, height: 2, color: Colors.grey[400]),
        _buildStepCircle("3", "Complete", false, circleSize),
      ],
    );
  }

  Widget _buildStepCircle(
      String number, String label, bool isActive, double size) {
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

  Widget _buildTimerAndProgress(double progress) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Center(
          child: Text(
            'Time Remaining: ${_formatTime(_remainingSeconds)}',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: _remainingSeconds > 0 ? Theme.of(context).extension<AppColors>()!.primary : Colors.red,
            ),
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Center(
          child: SizedBox(
            width: screenWidth * 0.8,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).extension<AppColors>()!.primary),
              minHeight: screenWidth * 0.025,
              borderRadius: BorderRadius.circular(screenWidth * 0.0125),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCryptoBuyDetails(double screenWidth, double screenHeight) {
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
              _buildDetailRow("Amount:",
                  "${widget.mAmount ?? ''} ${widget.mCurrency}", screenWidth),
              const Divider(color: Color(0xA66F35A5), height: 1),
              _buildDetailRow(
                  "Crypto Fees:",
                  "${(widget.mFees ?? 0.0).toStringAsFixed(1)} ${widget.mCurrency}",
                  screenWidth),
              const Divider(color: Color(0xA66F35A5), height: 1),
              if (widget.mExchangeFees != 0) ...[
                _buildDetailRow(
                    "Exchange Fees:",
                    "${(widget.mExchangeFees ?? 0.0).toStringAsFixed(1)} ${widget.mCurrency}",
                    screenWidth),
                const Divider(color: Color(0xA66F35A5), height: 1),
              ],
              _buildDetailRow(
                  "Total Fees:",
                  "${((widget.mFees ?? 0.0) + (widget.mExchangeFees ?? 0.0)).toStringAsFixed(1)} ${widget.mCurrency}",
                  screenWidth),
              const Divider(color: Color(0xA66F35A5), height: 1),
              _buildDetailRow(
                  "Total Amount:",
                  "${widget.mTotalAmount?.toStringAsFixed(1) ?? '0.00'} ${widget.mCurrency}",
                  screenWidth),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                  height: 1,
                  width: screenWidth * 0.6,
                  color: Color(0xA66F35A5)),
              Material(
                elevation: 4.0,
                shape: const CircleBorder(),
                child: Container(
                  width: screenWidth * 0.09,
                  height: screenWidth * 0.09,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child:  Center(
                      child: Icon(Icons.arrow_downward,
                          size: 20, color: Theme.of(context).extension<AppColors>()!.primary)),
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
              Center(
                  child: Text("You will get",
                      style: TextStyle(
                          color: Theme.of(context).extension<AppColors>()!.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045))),
              SizedBox(height: screenWidth * 0.04),
              Text('${widget.mGetAmount ?? '0.0'} ${widget.mCoin}',
                  style: TextStyle(
                      color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.045)),
              const Divider(color: Color(0xA66F35A5), height: 1),
              Text(
                  "1 ${widget.mCurrency} = ${widget.mEstimateRate?.toString() ?? '0.0'} ${widget.mCoin}",
                  style: TextStyle(
                      color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.035)),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.03),
        _buildTransferTypeDisplay(screenWidth),
        SizedBox(height: screenHeight * 0.02),
        _buildWalletAddressDisplay(screenWidth),
      ],
    );
  }

  Widget _buildCryptoSellDetails(double screenWidth, double screenHeight) {
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
              _buildDetailRow("No of Coins:",
                  "${widget.mAmount ?? ''} ${widget.mCoin}", screenWidth),
              const Divider(color: Color(0xA66F35A5), height: 1),
              _buildDetailRow(
                  "Crypto Fees:",
                  "${(widget.mFees ?? 0.0).toStringAsFixed(2)} ${widget.mCurrency}",
                  screenWidth),
              const Divider(color: Color(0xA66F35A5), height: 1),
              if (widget.mExchangeFees != 0) ...[
                _buildDetailRow(
                    "Exchange Fees:",
                    "${(widget.mExchangeFees ?? 0.0).toStringAsFixed(2)} ${widget.mCurrency}",
                    screenWidth),
                const Divider(color: Color(0xA66F35A5), height: 1),
              ],
              _buildDetailRow(
                  "Total Fees:",
                  "${((widget.mFees ?? 0.0) + (widget.mExchangeFees ?? 0.0)).toStringAsFixed(2)} ${widget.mCurrency}",
                  screenWidth),
              const Divider(color: Color(0xA66F35A5), height: 1),
              _buildDetailRow(
                  "Amount for ${widget.mAmount ?? ''} ${widget.mCoin}:",
                  "${widget.mGetAmount ?? '0.00'} ${widget.mCurrency}",
                  screenWidth),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                  height: 1,
                  width: screenWidth * 0.6,
                  color: Color(0xA66F35A5)),
              Material(
                elevation: 4.0,
                shape: const CircleBorder(),
                child: Container(
                  width: screenWidth * 0.09,
                  height: screenWidth * 0.09,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child:  Center(
                      child: Icon(Icons.arrow_downward,
                          size: 20, color: Theme.of(context).extension<AppColors>()!.primary)),
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
              Center(
                  child: Text("You will get",
                      style: TextStyle(
                          color: Theme.of(context).extension<AppColors>()!.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045))),
              SizedBox(height: screenWidth * 0.04),
              Text("Total Amount = Amount - Fees",
                  style: TextStyle(
                      color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.035)),
              SizedBox(height: screenHeight * 0.01),
              Text(
                  "${widget.mCurrency} ${widget.mTotalCryptoSellAmount?.toStringAsFixed(2) ?? '0.00'}",
                  style: TextStyle(
                      color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.045)),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.03),
        _buildTransferTypeDisplay(screenWidth),
        SizedBox(height: screenHeight * 0.02),
        _buildWalletAddressDisplay(screenWidth),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).extension<AppColors>()!.primary,
                  fontSize: screenWidth * 0.04)),
          Text(value,
              style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).extension<AppColors>()!.primary)),
        ],
      ),
    );
  }

  Widget _buildTransferTypeDisplay(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Transfer Type",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).extension<AppColors>()!.primary,
                fontSize: screenWidth * 0.045)),
        SizedBox(height: screenWidth * 0.02),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, vertical: screenWidth * 0.03),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(screenWidth * 0.025),
            color: Colors.white,
          ),
          child: Text(
            widget.transferType ?? "Bank Transfer",
            style:
                TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.04),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletAddressDisplay(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Wallet Address",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).extension<AppColors>()!.primary,
                fontSize: screenWidth * 0.045)),
        SizedBox(height: screenWidth * 0.02),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(screenWidth * 0.025),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04, vertical: screenWidth * 0.03),
            child: Text(
              widget.walletAddress ?? "Not available",
              style: TextStyle(
                  color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.04),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationCheckbox(double screenWidth) {
    return Row(
      children: [
        Checkbox(
          value: isConfirmed,
          onChanged: isTimerExpired
              ? null
              : (value) {
                  setState(() {
                    isConfirmed = value ?? false;
                  });
                },
          activeColor: Theme.of(context).extension<AppColors>()!.primary,
          checkColor: Colors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: Text(
            "I confirm the payment details are correct",
            style:
                TextStyle(color: Theme.of(context).extension<AppColors>()!.primary, fontSize: screenWidth * 0.04),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(double screenWidth, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.025)),
              elevation: 0,
            ),
            child: Text(
              "BACK",
              style: TextStyle(
                  color: Theme.of(context).extension<AppColors>()!.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.04),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.04),
        Expanded(
          child: ElevatedButton(
            onPressed: (isConfirmed && !isProcessing && !isTimerExpired)
                ? () => _confirmPayment()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.025)),
              elevation: 4,
            ),
            child: isProcessing
                ? const SpinKitThreeBounce(color: Colors.white, size: 18.0)
                : Text(
                    widget.mCryptoType == "Crypto Buy"
                        ? "CONFIRM & BUY"
                        : "CONFIRM & SELL",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04),
                  ),
          ),
        ),
      ],
    );
  }
}