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
    switch (status) {
      case 'Completed':
      case 'completed':
        return Colors.green;
      case 'Rejected':
      case 'declined':
        return Colors.red;
      case 'Pending':
      case 'pending':
        return Colors.orange;
      default:
        return kPrimaryColor; // Default color if status is unknown
    }
  }

  // Function to format the date
  String formatDate(String? dateTime) {
    if (dateTime == null) {
      return 'Date not available'; // Fallback text if dateTime is null
    }
    DateTime date = DateTime.parse(dateTime);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String getCurrencySymbol(String currencyCode) {
    if (currencyCode == "AWG") return 'ƒ';
    var format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.currencySymbol;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   iconTheme: const IconThemeData(color: Colors.transparent),
      //   title: const Text(
      //     "Buy / Sell Exchange",
      //     style: TextStyle(color: Colors.transparent),
      //   ),
      // ),
      body: Column(
        children: [
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 130,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (AuthManager.getKycStatus() == "completed") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CryptoBuyAnsSellScreen()),
                        );
                      } else {
                        CustomSnackBar.showSnackBar(
                            context: context,
                            message: "Your KYC is not completed",
                            color: kPrimaryColor);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      )
                    ),
                    child: const Text('Buy / Sell',
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: defaultPadding),
              ],
            ),
          ),
          const SizedBox(height: defaultPadding),
          Expanded(
            child: isLoading
                ? const Center(
                    child: SpinKitWaveSpinner(color: kPrimaryColor, size: 75))
                : cryptoTransactions.isNotEmpty
                    ? ListView.builder(
                        itemCount: cryptoTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = cryptoTransactions[index];
                          return Card(
                            elevation: 4.0,
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            child: Padding(
                              padding: const EdgeInsets.all(defaultPadding),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Coin: ${transaction.coinName!.split('_')[0]}",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      ClipOval(
                                        child: Image.network(
                                          _getImageForCoin(transaction.coinName!
                                              .split('_')[0]),
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit
                                              .cover, // Ensure the image fills the circle
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: defaultPadding),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Date:",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          formatDate(transaction.date ?? "N/A"),
                                          style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: defaultPadding),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Payment Type:",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      Text(transaction.paymentType ?? "N/A",
                                          style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: defaultPadding),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("No Of Coins:",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      Text(transaction.noOfCoin ?? "N/A",
                                          style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: defaultPadding),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Side:",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          transaction.side![0].toUpperCase() +
                                              transaction.side!.substring(1),
                                          style: const TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: defaultPadding),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Amount:",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                        transaction.noOfCoin != null
                                            ? '${getCurrencySymbol(transaction.currencyType!)} ${(double.tryParse(transaction.amount?.toString() ?? '0.00')?.toStringAsFixed(2) ?? '0.00')}'
                                            : '0.00',
                                        style: const TextStyle(fontSize: 16),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: defaultPadding),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Status:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      FilledButton.tonal(
                                        onPressed: () {},
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  _getStatusColor(
                                                      transaction.status!)),
                                        ),
                                        child: Text(
                                          (transaction.status?.isNotEmpty ??
                                                  false)
                                              ? transaction.status![0]
                                                      .toUpperCase() +
                                                  transaction.status!
                                                      .substring(1)
                                              : "N/A",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(child: Text("No Crypto Available.")),
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
      return 'assets/icons/default.png'; // Default image if needed
  }
}
