import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/BuyAndSellScreen/model/buyAndSellListApi.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/BuyAndSellScreen/model/buyAndSellListModel.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/CryptoBuyAndSellScreen/crypto_sell_exchange_screen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/customSnackBar.dart';

import '../../../../util/auth_manager.dart';

class BuyAndSellScreen extends StatefulWidget {
  const BuyAndSellScreen({super.key});

  @override
  State<BuyAndSellScreen> createState() => _BuyAndSellScreenState();
}

class _BuyAndSellScreenState extends State<BuyAndSellScreen> {
  final CryptoListApi _cryptoListApi = CryptoListApi();
  List<CryptoListsData> cryptoTransactions = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    mCryptoTransactionsList();
  }

  Future<void> mCryptoTransactionsList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _cryptoListApi.cryptoListApi();

      if (response.cryptoList != null && response.cryptoList!.isNotEmpty) {
        setState(() {
          cryptoTransactions = response.cryptoList!;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Crypto List';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'rejected':
      case 'declined':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : Colors.grey.shade600;
    }
  }

  String formatDate(String? dateTime) {
    if (dateTime == null) {
      return 'Date not available';
    }
    try {
      DateTime date = DateTime.parse(dateTime);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String getCurrencySymbol(String currencyCode) {
    if (currencyCode == "AWG") return 'ƒ';
    var format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.currencySymbol;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).brightness == Brightness.dark
      //       ? Colors.grey.shade800
      //       : Colors.white,
      //   iconTheme: IconThemeData(
      //     color: Theme.of(context).brightness == Brightness.dark
      //         ? Colors.white
      //         : Colors.black,
      //   ),
      //   title: Text(
      //     "Buy / Sell Exchange",
      //     style: TextStyle(
      //       color: Theme.of(context).brightness == Brightness.dark
      //           ? Colors.white
      //           : Colors.black,
      //       fontSize: isSmallScreen ? 16 : 20,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   elevation: 0,
      // ),
      body: Column(
        children: [
          SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: isSmallScreen ? 140 : 170,
                  height: isSmallScreen ? 40 : 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (AuthManager.getKycStatus() == "completed") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CryptoBuyAnsSellScreen(),
                          ),
                        );
                      } else {
                        CustomSnackBar.showSnackBar(
                          context: context,
                          message: "Your KYC is not completed",
                          color: Theme.of(context).extension<AppColors>()!.primary,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 12 : 16,
                        horizontal: isSmallScreen ? 8 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'Buy / Sell / Swap',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 13 : 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? defaultPadding / 2 : defaultPadding),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
          Expanded(
            child: isLoading
                ? Center(
                    child: SpinKitWaveSpinner(
                      color: Theme.of(context).extension<AppColors>()!.primary,
                      size: isSmallScreen ? 60 : 75,
                    ),
                  )
                : cryptoTransactions.isNotEmpty
                    ? ListView.builder(
                        itemCount: cryptoTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = cryptoTransactions[index];
                          return Card(
                            elevation: 4.0,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            margin: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 6 : 8,
                              horizontal: isSmallScreen ? 12 : 20,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Coin: ${transaction.coinName?.split('_')[0] ?? 'N/A'}",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      ClipOval(
                                        child: Image.network(
                                          _getImageForCoin(transaction.coinName?.split('_')[0] ?? ''),
                                          width: isSmallScreen ? 32 : 40,
                                          height: isSmallScreen ? 32 : 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Image.asset(
                                            'assets/icons/default.png',
                                            width: isSmallScreen ? 32 : 40,
                                            height: isSmallScreen ? 32 : 40,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Date:",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        formatDate(transaction.date),
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white70
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Payment Type:",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        transaction.paymentType ?? "N/A",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white70
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "No Of Coins:",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        transaction.noOfCoin ?? "N/A",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white70
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Side:",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        transaction.side != null
                                            ? transaction.side![0].toUpperCase() + transaction.side!.substring(1)
                                            : "N/A",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white70
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Amount:",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        transaction.noOfCoin != null
                                            ? '${getCurrencySymbol(transaction.currencyType ?? 'USD')} ${(double.tryParse(transaction.amount?.toString() ?? '0.00')?.toStringAsFixed(2) ?? '0.00')}'
                                            : '0.00',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white70
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Status:",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      FilledButton.tonal(
                                        onPressed: () {},
                                        style: ButtonStyle(
                                          backgroundColor: WidgetStateProperty.all(_getStatusColor(transaction.status ?? 'unknown')),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          padding: WidgetStateProperty.all(
                                            EdgeInsets.symmetric(
                                              horizontal: isSmallScreen ? 8 : 12,
                                              vertical: isSmallScreen ? 4 : 6,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          (transaction.status?.isNotEmpty ?? false)
                                              ? transaction.status![0].toUpperCase() + transaction.status!.substring(1).toLowerCase()
                                              : "N/A",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isSmallScreen ? 14 : 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isSmallScreen ? 4 : 8),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          "No Crypto Available.",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

String _getImageForCoin(String coin) {
  switch (coin) {
    case "BTC":
      return 'https://assets.coincap.io/assets/icons/btc@2x.png';
    case "BCH":
      return 'https://assets.coincap.io/assets/icons/bch@2x.png';
    case "BNB":
      return 'https://assets.coincap.io/assets/icons/bnb@2x.png';
    case "ADA":
      return 'https://assets.coincap.io/assets/icons/ada@2x.png';
    case "SOL":
      return 'https://assets.coincap.io/assets/icons/sol@2x.png';
    case "DOGE":
      return 'https://assets.coincap.io/assets/icons/doge@2x.png';
    case "LTC":
      return 'https://assets.coincap.io/assets/icons/ltc@2x.png';
    case "ETH":
      return 'https://assets.coincap.io/assets/icons/eth@2x.png';
    case "SHIB":
      return 'https://assets.coincap.io/assets/icons/shib@2x.png';
    default:
      return 'assets/icons/default.png';
  }
}