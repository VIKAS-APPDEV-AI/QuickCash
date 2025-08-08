import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/constants.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> response;

  const PaymentSuccessScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final transaction = response['transaction'] as Map<String, dynamic>? ?? {};
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    // Extract relevant fields from response
    final cardBalance = response['cardBalance']?.toStringAsFixed(2) ?? '0.00';
    final accountBalance = response['accountBalance']?.toStringAsFixed(2) ?? '0.00';
    final amount = transaction['amount']?.toStringAsFixed(2) ?? '0.00';
    final amountText = transaction['amountText'] ?? 'N/A';
    final fee = transaction['fee']?.toStringAsFixed(2) ?? '0.00';
    final conversionAmount = transaction['conversionAmount']?.toStringAsFixed(2) ?? '0.00';
    final conversionAmountText = transaction['conversionAmountText'] ?? 'N/A';
    final fromCurrency = transaction['from_currency'] ?? 'N/A';
    final toCurrency = transaction['to_currency'] ?? 'N/A';
    final transactionId = transaction['trx'] ?? 'N/A';
    final createdAt = transaction['createdAt'] != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(transaction['createdAt']))
        : 'N/A';

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
        title: Text(
          'Payment Successful',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 16 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lottie Animation
              Lottie.asset(
                'assets/lottie/Success.json',
                height: isSmallScreen ? 120 : 150,
                width: isSmallScreen ? 120 : 150,
                repeat: true,
              ),
              SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
              Text(
                'Card Loaded Successfully!',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).extension<AppColors>()!.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? defaultPadding : defaultPadding * 2),
              // Transaction Details Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade600
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Transaction ID', transactionId, context),
                      _buildDetailRow('Amount', amountText, context),
                      _buildDetailRow('Fee', '$fee $fromCurrency', context),
                      _buildDetailRow('Conversion Amount', conversionAmountText, context),
                      _buildDetailRow('From Currency', fromCurrency, context),
                      _buildDetailRow('To Currency', toCurrency, context),
                      _buildDetailRow('Card Balance', '$cardBalance $toCurrency', context),
                      _buildDetailRow('Account Balance', '$accountBalance $fromCurrency', context),
                      _buildDetailRow('Date & Time', createdAt, context),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? defaultPadding : defaultPadding * 2),
              // Back Button
              SizedBox(
                width: isSmallScreen ? 160 : 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 12 : 16,
                      horizontal: isSmallScreen ? 8 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'Back to Cards',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4.0 : 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}