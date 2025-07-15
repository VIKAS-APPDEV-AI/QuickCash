import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/BuyAndSellScreen/cryptoBuyModel/cryptoBuyApi.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/BuyAndSellScreen/cryptoBuyModel/cryptoBuyModel.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/BuyAndSellScreen/cryptoSellFetchCoinDataModel/cryptoSellFetchCoinApi.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/BuyAndSellScreen/cryptoSellFetchCoinPriceModel/cryptoSellFetchCoinPriceApi.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/BuyAndSellScreen/cryptoSellFetchCoinPriceModel/cryptoSellFetchCoinPriceModel.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/model/currencyApiModel/Model/currencyModel.dart';
import 'package:quickcash/model/currencyApiModel/Services/currencyApi.dart';
import 'package:quickcash/util/currency_utils.dart';
import 'package:quickcash/util/customSnackBar.dart';
import 'confirm_buy_screen.dart';

// Binance API Service
class BinanceApi {
  // Fetch current price for a specific symbol (e.g., "BTCUSDT")
  Future<Map<String, dynamic>> fetchCurrentPrice(String symbol) async {
    final response = await http.get(
      Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=$symbol'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch price for $symbol');
    }
  }

  // Fetch 24-hour price change percentage for a specific symbol
  Future<Map<String, dynamic>> fetch24HrPriceChange(String symbol) async {
    final response = await http.get(
      Uri.parse('https://api.binance.com/api/v3/ticker/24hr?symbol=$symbol'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch 24hr price change for $symbol');
    }
  }

  // Fetch prices for multiple symbols
  Future<List<Map<String, dynamic>>> fetchMultiplePrices(
      List<String> symbols) async {
    final response = await http.get(
      Uri.parse('https://api.binance.com/api/v3/ticker/price'),
    );

    if (response.statusCode == 200) {
      List<dynamic> allPrices = jsonDecode(response.body);
      return allPrices
          .where((price) => symbols.contains(price['symbol']))
          .map((price) => price as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception('Failed to fetch multiple prices');
    }
  }
}

// Custom Indicator for dynamic border radius
class CustomTabIndicator extends Decoration {
  final int selectedIndex;

  CustomTabIndicator({required this.selectedIndex});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter(selectedIndex: selectedIndex);
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  final int selectedIndex;

  _CustomTabIndicatorPainter({required this.selectedIndex});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = Offset(offset.dx, (configuration.size!.height - 40) / 2) &
        Size(configuration.size!.width, 40);
    final Paint paint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;

    final RRect rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: selectedIndex == 0
          ? const Radius.circular(20.0)
          : const Radius.circular(8.0),
      bottomLeft: selectedIndex == 0
          ? const Radius.circular(20.0)
          : const Radius.circular(8.0),
      topRight: selectedIndex == 1
          ? const Radius.circular(20.0)
          : const Radius.circular(8.0),
      bottomRight: selectedIndex == 1
          ? const Radius.circular(20.0)
          : const Radius.circular(8.0),
    );

    canvas.drawShadow(
      Path()..addRRect(rrect),
      Colors.black.withOpacity(0.2),
      3.0,
      true,
    );

    canvas.drawRRect(rrect, paint);
  }
}

// Main Screen with updated bottom modal sheet
class CryptoBuyAnsSellScreen extends StatefulWidget {
  const CryptoBuyAnsSellScreen({super.key});

  @override
  State<CryptoBuyAnsSellScreen> createState() => _CryptoBuyAnsSellScreenState();
}

class _CryptoBuyAnsSellScreenState extends State<CryptoBuyAnsSellScreen>
    with SingleTickerProviderStateMixin {
  final CurrencyApi _currencyApi = CurrencyApi();
  final CryptoBuyApi _cryptoBuyApi = CryptoBuyApi();
  final CryptoSellFetchCoinDataApi _cryptoSellFetchCoinDataApi =
      CryptoSellFetchCoinDataApi();
  final CryptoSellFetchCoinPriceApi _cryptoSellFetchCoinPriceApi =
      CryptoSellFetchCoinPriceApi();

  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          elevation: 0,
          title: const Text(
            "Crypto Exchange",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  backgroundColor: Colors.white,
                  builder: (BuildContext context) {
                    return Container(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedIndex == 0
                                  ? "How to Buy Crypto"
                                  : "How to Sell Crypto",
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.touch_app,
                                  color: kPrimaryColor,
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedIndex == 0
                                            ? "1. Enter Amount & Select Payment"
                                            : "1. Enter Amount & Choose Payment Method",
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedIndex == 0
                                            ? "Enter the amount, select the available payment method, and choose the payment account or bind the payment card."
                                            : "Enter the amount, select a payment method, and choose the account to receive the payment.",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.shopping_cart_checkout,
                                  color: kPrimaryColor,
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedIndex == 0
                                            ? "2. Confirm Order"
                                            : "2. Confirm Your Order",
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedIndex == 0
                                            ? "Confirmation of transaction detail information, including trading pair quotes, fees, and other explanatory tips."
                                            : "Review your transaction details, including trading pair quotes, fees, and any additional information before confirming.",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.currency_bitcoin,
                                  color: kPrimaryColor,
                                  size: 30,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedIndex == 0
                                            ? "3. Receive Crypto"
                                            : "3. Receive Cash",
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedIndex == 0
                                            ? "After successful payment, the purchased crypto will be deposited into your Spot or Funding Wallet."
                                            : "Once the payment is successful, the purchased digital currency will be deposited into your Spot Wallet.",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  "Close",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                  bottom: 15, left: 20, right: 20, top: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: kHintColor, width: 1.0),
                boxShadow: [
                  const BoxShadow(
                    color: kHintColor,
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: const BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20)),
                ),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                labelStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 16),
                labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                tabs: const [
                  Tab(text: 'Buy'),
                  Tab(text: 'Sell'),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: Text(
                          'Quickcash offers a user-friendly platform to purchase a \nvariety of cryptocurrencies.',
                          style: TextStyle(
                              fontSize: 13,
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold)))
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  CryptoBuyTab(),
                  CryptoSellTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CryptoBuyTab (Updated with Highlighting)
class CryptoBuyTab extends StatefulWidget {
  const CryptoBuyTab({super.key});

  @override
  State<CryptoBuyTab> createState() => _CryptoBuyTabState();
}

class _CryptoBuyTabState extends State<CryptoBuyTab>
    with AutomaticKeepAliveClientMixin {
  final CurrencyApi _currencyApi = CurrencyApi();
  final CryptoBuyApi _cryptoBuyApi = CryptoBuyApi();
  final BinanceApi _binanceApi = BinanceApi();

  final TextEditingController mAmount = TextEditingController();
  final TextEditingController mYouGet = TextEditingController();

  String? selectedCurrency;
  List<CurrencyListsData> currency = [];
  bool isDataLoaded = false;

  bool isLoading = false;
  String? selectedCoinType = 'DOGE';
  String? sideType = "buy";

  double? mEstimatedRate;
  double? fees;
  double? mCryptoFees;
  double? mExchangeFees;
  double? mLivePrice;
  double? mPriceChangePercentage;
  Map<String, Map<String, dynamic>> allCryptoPrices = {};
  Timer? _priceUpdateTimer;

  static const List<String> cryptoList = [
    'BTCUSDT',
    'BNBUSDT',
    'ADAUSDT',
    'SOLUSDT',
    'DOGEUSDT',
    'BCHUSDT'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    mGetCurrency().then((_) {
      setState(() => isDataLoaded = true);
      fetchLivePrice();
      fetchAllCryptoPrices();
      _priceUpdateTimer = Timer.periodic(Duration(seconds: 30), (timer) {
        fetchLivePrice();
        fetchAllCryptoPrices();
      });
    });
  }

  @override
  void dispose() {
    mAmount.dispose();
    mYouGet.dispose();
    _priceUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> mGetCurrency() async {
    final response = await _currencyApi.currencyApi();
    if (response.currencyList != null && response.currencyList!.isNotEmpty) {
     setState(() {
      currency = response.currencyList!;
      // Set default to "USD" if it exists, otherwise fallback to first currency
      selectedCurrency = currency.any((item) => item.currencyCode == 'USD')
          ? 'USD'
          : currency[0].currencyCode;
    });
    }
  }

  Future<void> fetchLivePrice() async {
    if (selectedCoinType == null) return;
    try {
      String symbol = "${selectedCoinType}USDT";
      final priceData = await _binanceApi.fetchCurrentPrice(symbol);
      final changeData = await _binanceApi.fetch24HrPriceChange(symbol);

      setState(() {
        mLivePrice = double.tryParse(priceData['price']) ?? 0.0;
        mPriceChangePercentage =
            double.tryParse(changeData['priceChangePercent']) ?? 0.0;
      });
    } catch (e) {
      setState(() {
        mLivePrice = 0.0;
        mPriceChangePercentage = 0.0;
      });
      CustomSnackBar.showSnackBar(
        context: context,
        message: "Failed to fetch live price",
        color: kPrimaryColor,
      );
    }
  }

  Future<void> fetchAllCryptoPrices() async {
    try {
      final prices = await _binanceApi.fetchMultiplePrices(cryptoList);
      Map<String, Map<String, dynamic>> updatedPrices = {};

      // Populate prices
      for (var price in prices) {
        String coin = price['symbol'].replaceAll('USDT', '');
        updatedPrices[coin] = {
          'price': double.tryParse(price['price']) ?? 0.0,
        };
      }

      // Fetch price change percentage for each symbol
      for (var symbol in cryptoList) {
        final changeData = await _binanceApi.fetch24HrPriceChange(symbol);
        String coin = symbol.replaceAll('USDT', '');
        updatedPrices[coin]!['change'] =
            double.tryParse(changeData['priceChangePercent']) ?? 0.0;
      }

      setState(() {
        allCryptoPrices = updatedPrices;
        print("All Crypto Prices (Buy Tab): $allCryptoPrices"); // Debugging
      });
    } catch (e) {
      setState(() {
        allCryptoPrices = {};
      });
      CustomSnackBar.showSnackBar(
        context: context,
        message: "Failed to fetch all crypto prices",
        color: kPrimaryColor,
      );
    }
  }

  Future<void> mCryptoBuyCalculation() async {
    if (mAmount.text.isEmpty ||
        selectedCoinType == null ||
        selectedCurrency == null) {
      setState(() {
        isLoading = false;
        mYouGet.text = '';
        mEstimatedRate = 0.0;
        fees = 0.0;
        mCryptoFees = 0.0;
        mExchangeFees = 0.0;
      });
      return;
    }
    setState(() => isLoading = true);
    try {
      int amount = int.parse(mAmount.text);
      final request = CryptoBuyRequest(
          amount: amount,
          coinType: selectedCoinType!,
          currencyType: selectedCurrency!,
          sideType: sideType!);
      final response = await _cryptoBuyApi.cryptoBuyApi(request);

      if (response.message == "Success") {
        setState(() {
          isLoading = false;
          mEstimatedRate = response.data.rate;
          mYouGet.text = response.data.numberofCoins.toString();
          fees = response.data.fees;
          mCryptoFees = response.data.cryptoFees ?? 0.0;
          mExchangeFees = response.data.exchangeFees ?? 0.0;
        });
      } else if (response.message ==
          "Make sure you have fill amount,currency and coin") {
        setState(() {
          isLoading = false;
          mEstimatedRate = 0.0;
          fees = 0.0;
          mCryptoFees = 0.0;
          mExchangeFees = 0.0;
        });
      } else {
        setState(() {
          isLoading = false;
          mEstimatedRate = 0.0;
          fees = 0.0;
          mCryptoFees = 0.0;
          mExchangeFees = 0.0;
          CustomSnackBar.showSnackBar(
              context: context,
              message: "We are facing some issue!",
              color: kPrimaryColor);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackBar(
            duration: Duration(seconds: 1),
            context: context,
            message: 'Please Enter Numeric Value',
            color: kPrimaryColor);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!isDataLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              color: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        top: 25, bottom: 10, left: 15, right: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        color: kPrimaryColor),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'Spend',
                              style: TextStyle( 
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 0.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: mAmount,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                    cursorColor: kWhiteColor,
                                    textAlign: TextAlign.start,
                                    decoration: const InputDecoration(
                                      fillColor: Colors.transparent,
                                      border: InputBorder.none,
                                      filled: true,
                                      hintText: 'Enter Amount',
                                      hintStyle: TextStyle(
                                          color: Colors.white38, fontSize: 18),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        if (selectedCurrency != null &&
                                            selectedCoinType != null &&
                                            mAmount.text.isNotEmpty) {
                                          mCryptoBuyCalculation();
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: kWhiteColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      mYouGet.clear();
                                      mAmount.clear();
                                    },
                                    icon: const Icon(Icons.clear,
                                        color: Colors.black, size: 12),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Row(
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: Text(
                                          getCurrencySymbol(selectedCurrency) ??
                                              '',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: DropdownButton<String>(
                                        value: selectedCurrency,
                                        dropdownColor: Colors.grey[900],
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: Colors.grey),
                                        underline: const SizedBox(),
                                        items: currency.map<
                                                DropdownMenuItem<String>>(
                                            (CurrencyListsData currencyItem) {
                                          return DropdownMenuItem<String>(
                                            value: currencyItem.currencyCode,
                                            child: Text(
                                              currencyItem.currencyCode!,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedCurrency = newValue;
                                            if (selectedCurrency != null &&
                                                selectedCoinType != null &&
                                                mAmount.text.isNotEmpty) {
                                              mCryptoBuyCalculation();
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(bottom: 25, left: 15, right: 15),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 10, left: 15),
                            child: Text(
                              'Receive',
                              style: TextStyle(
                                  color: kWhiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: mYouGet,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                  decoration: const InputDecoration(
                                    fillColor: kBlackColor,
                                    border: InputBorder.none,
                                    hintText: '0',
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  readOnly: true,
                                ),
                              ),
                              SizedBox(width: 15,),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: kWhiteColor,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    mYouGet.clear();
                                  },
                                  icon: const Icon(Icons.clear,
                                      color: Colors.black, size: 12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      _getImageForTransferType(
                                          selectedCoinType ?? 'BTC'),
                                      height: 20,
                                      width: 20,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image,
                                                  color: Colors.red, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: DropdownButton<String>(
                                      value: selectedCoinType,
                                      dropdownColor: Colors.grey[900],
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: Colors.grey),
                                      underline: const SizedBox(),
                                      items: <String>[
                                        'BTC',
                                        'BNB',
                                        'ADA',
                                        'SOL',
                                        'DOGE',
                                        'BCH',
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedCoinType = newValue;
                                          fetchLivePrice();
                                          if (selectedCurrency != null &&
                                              selectedCoinType != null &&
                                              mAmount.text.isNotEmpty) {
                                            mCryptoBuyCalculation();
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4.0,
              color: Colors.grey[500],
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Crypto Fees:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white)),
                        Text(
                            '${getCurrencySymbol(selectedCurrency) ?? ""} ${mCryptoFees?.toString() ?? '0.0'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white)),
                      ],
                    ),
                    if (mExchangeFees != null && mExchangeFees != 0) ...[
                      const SizedBox(height: smallPadding),
                      const Divider(color: Colors.white),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Exchange Fees:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white)),
                          Text(
                              '${getCurrencySymbol(selectedCurrency) ?? ""} ${mExchangeFees?.toString() ?? '0.0'}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white)),
                        ],
                      ),
                    ],
                    const SizedBox(height: smallPadding),
                    const Divider(color: Colors.white),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Estimated Rate:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white)),
                        Text(mEstimatedRate?.toString() ?? '0.0',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 0), // Reduced from 50 to 20
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: isLoading ||
                        mAmount.text.isEmpty ||
                        selectedCurrency == null ||
                        selectedCoinType == null
                    ? null
                    : () {
                        if (selectedCurrency == null) {
                          CustomSnackBar.showSnackBar(
                              context: context,
                              message: "Please Select Currency",
                              color: kPrimaryColor);
                        } else if (mAmount.text.isEmpty) {
                          CustomSnackBar.showSnackBar(
                              context: context,
                              message: "Please Enter Amount",
                              color: kPrimaryColor);
                        } else if (selectedCoinType == null) {
                          CustomSnackBar.showSnackBar(
                              context: context,
                              message: "Please Select Coin",
                              color: kPrimaryColor);
                        } else if (mAmount.text.isNotEmpty &&
                            selectedCurrency != null &&
                            selectedCoinType != null &&
                            mCryptoFees != null &&
                            mYouGet.text.isNotEmpty &&
                            mEstimatedRate != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfirmBuyScreen(
                                  mCryptoAmount: mAmount.text,
                                  mCurrency: selectedCurrency,
                                  mCoinName: selectedCoinType,
                                  mFees: mCryptoFees,
                                  mExchangeFees: mExchangeFees,
                                  mYouGetAmount: mYouGet.text,
                                  mEstimateRates: mEstimatedRate,
                                  mCryptoType: "Crypto Buy"),
                            ),
                          );
                        } else {
                          CustomSnackBar.showSnackBar(
                              context: context,
                              message: "Please Enter Valid Details.",
                              color: kPrimaryColor);
                        }
                      },
                child: isLoading
                    ? const SpinKitWaveSpinner(color: kWhiteColor, size: 30)
                    : const Text('Proceed',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            // Card(
            //   elevation: 4,
            //   color: Colors.black87,
            //   margin: const EdgeInsets.symmetric(horizontal: 0),
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(10),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Row(
            //           children: [
            //             ClipOval(
            //               child: Image.network(
            //                 _getImageForTransferType(selectedCoinType ?? 'BTC'),
            //                 height: 24,
            //                 width: 24,
            //                 errorBuilder: (context, error, stackTrace) =>
            //                     const Icon(Icons.broken_image,
            //                         color: Colors.red, size: 20),
            //               ),
            //             ),
            //             const SizedBox(width: 8),
            //             Text(
            //               selectedCoinType ?? 'BTC',
            //               style: const TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           ],
            //         ),
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.end,
            //           children: [
            //             Text(
            //               '\$${mLivePrice?.toStringAsFixed(2) ?? '0.00'}',
            //               style: const TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //             Text(
            //               '${mPriceChangePercentage?.toStringAsFixed(2) ?? '0.00'}%',
            //               style: TextStyle(
            //                 color: (mPriceChangePercentage ?? 0) >= 0
            //                     ? Colors.green
            //                     : Colors.red,
            //                 fontSize: 14,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              color: Color(0XFFdfad52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cryptocurrency Prices',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Divider(color: Colors.white30,),
                    // Show a loading indicator if prices are being fetched
                    if (allCryptoPrices.isEmpty && isDataLoaded)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SpinKitWaveSpinner(
                            color: kPrimaryColor,
                            size: 30,
                          ),
                        ),
                      )
                    // Show a message if no prices are available
                    else if (allCryptoPrices.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Unable to fetch cryptocurrency prices. Please try again later.',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                      )
                    // Display the list of cryptocurrency prices with highlighting
                    else
                      ...allCryptoPrices.entries.map((entry) {
                        String coin = entry.key;
                        double price = entry.value['price'] ?? 0.0;
                        double change = entry.value['change'] ?? 0.0;
                        bool isSelected = coin ==
                            selectedCoinType; // Check if this coin is selected
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors
                                    .transparent, // Highlight with white background if selected
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      _getImageForTransferType(coin),
                                      height: 20,
                                      width: 20,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.broken_image,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    coin,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors
                                              .white, // Adjust text color for contrast
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors
                                              .white, // Adjust text color for contrast
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${change.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: change >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getImageForTransferType(String transferType) {
    switch (transferType) {
      case "BTC":
        return 'https://assets.coincap.io/assets/icons/btc@2x.png';
      case "BNB":
        return 'https://assets.coincap.io/assets/icons/bnb@2x.png';
      case "ADA":
        return 'https://assets.coincap.io/assets/icons/ada@2x.png';
      case "SOL":
        return 'https://assets.coincap.io/assets/icons/sol@2x.png';
      case "DOGE":
        return 'https://assets.coincap.io/assets/icons/doge@2x.png';
      case "BCH":
        return 'https://assets.coincap.io/assets/icons/bch@2x.png';
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
}

// CryptoSellTab (Updated with Highlighting)
class CryptoSellTab extends StatefulWidget {
  const CryptoSellTab({super.key});

  @override
  State<CryptoSellTab> createState() => _CryptoSellTabState();
}

class _CryptoSellTabState extends State<CryptoSellTab>
    with AutomaticKeepAliveClientMixin {
  final CurrencyApi _currencyApi = CurrencyApi();
  final CryptoSellFetchCoinDataApi _cryptoSellFetchCoinDataApi =
      CryptoSellFetchCoinDataApi();
  final CryptoSellFetchCoinPriceApi _cryptoSellFetchCoinPriceApi =
      CryptoSellFetchCoinPriceApi();
  final BinanceApi _binanceApi = BinanceApi();

  final TextEditingController mAmount = TextEditingController();
  final TextEditingController mYouGet = TextEditingController();

  String? selectedCurrency;
  List<CurrencyListsData> currency = [];
  bool isDataLoaded = false;

  bool isLoading = false;
  String? selectedCoinType = 'DOGE';
  String? coinName;
  String? mCryptoSellCoinAvailable = "0.0";
  double? mSellCryptoFees;
  double? mSellExchangeFees;
  String? _errorMessage;
  double? mLivePrice;
  double? mPriceChangePercentage;
  Map<String, Map<String, dynamic>> allCryptoPrices = {};
  Timer? _priceUpdateTimer;

  static const List<String> cryptoList = [
    'BTCUSDT',
    'BNBUSDT',
    'ADAUSDT',
    'SOLUSDT',
    'DOGEUSDT',
    'BCHUSDT'
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    mGetCurrency().then((_) {
      setState(() => isDataLoaded = true);
      mCryptoSellFetchCoinData();
      fetchLivePrice();
      fetchAllCryptoPrices();
      _priceUpdateTimer = Timer.periodic(Duration(seconds: 30), (timer) {
        fetchLivePrice();
        fetchAllCryptoPrices();
      });
    });
  }

  @override
  void dispose() {
    mAmount.dispose();
    mYouGet.dispose();
    _priceUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> mGetCurrency() async {
    final response = await _currencyApi.currencyApi();
    if (response.currencyList != null && response.currencyList!.isNotEmpty) {
      setState(() {
      currency = response.currencyList!;
      // Set default to "USD" if it exists, otherwise fallback to first currency
      selectedCurrency = currency.any((item) => item.currencyCode == 'USD')
          ? 'USD'
          : currency[0].currencyCode;
    });
    }
  }

  Future<void> fetchLivePrice() async {
    if (selectedCoinType == null) return;
    try {
      String symbol = "${selectedCoinType}USDT";
      final priceData = await _binanceApi.fetchCurrentPrice(symbol);
      final changeData = await _binanceApi.fetch24HrPriceChange(symbol);

      setState(() {
        mLivePrice = double.tryParse(priceData['price']) ?? 0.0;
        mPriceChangePercentage =
            double.tryParse(changeData['priceChangePercent']) ?? 0.0;
      });
    } catch (e) {
      setState(() {
        mLivePrice = 0.0;
        mPriceChangePercentage = 0.0;
      });
      CustomSnackBar.showSnackBar(
        context: context,
        message: "Failed to fetch live price",
        color: kPrimaryColor,
      );
    }
  }

  Future<void> fetchAllCryptoPrices() async {
    try {
      final prices = await _binanceApi.fetchMultiplePrices(cryptoList);
      Map<String, Map<String, dynamic>> updatedPrices = {};

      // Populate prices
      for (var price in prices) {
        String coin = price['symbol'].replaceAll('USDT', '');
        updatedPrices[coin] = {
          'price': double.tryParse(price['price']) ?? 0.0,
        };
      }

      // Fetch price change percentage for each symbol
      for (var symbol in cryptoList) {
        final changeData = await _binanceApi.fetch24HrPriceChange(symbol);
        String coin = symbol.replaceAll('USDT', '');
        updatedPrices[coin]!['change'] =
            double.tryParse(changeData['priceChangePercent']) ?? 0.0;
      }

      setState(() {
        allCryptoPrices = updatedPrices;
        print("All Crypto Prices (Sell Tab): $allCryptoPrices"); // Debugging
      });
    } catch (e) {
      setState(() {
        allCryptoPrices = {};
      });
      CustomSnackBar.showSnackBar(
        context: context,
        message: "Failed to fetch all crypto prices",
        color: kPrimaryColor,
      );
    }
  }

  Future<void> mCryptoSellFetchCoinData() async {
    if (selectedCoinType == null) return;
    setState(() => isLoading = true);
    try {
      coinName = '${selectedCoinType}_TEST';
      final response = await _cryptoSellFetchCoinDataApi
          .cryptoSellFetchCoinDataApi(coinName!);
      if (response.message == "crypto coins are fetched Successfully") {
        setState(() {
          isLoading = false;
          mCryptoSellCoinAvailable = response.data;
        });
      } else {
        setState(() {
          mCryptoSellCoinAvailable = "0";
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        mCryptoSellCoinAvailable = "0";
        CustomSnackBar.showSnackBar(
            context: context,
            message: "No of Coins not found",
            color: kPrimaryColor);
      });
    }
  }

  Future<void> mCryptoSellFetchCoinPrice() async {
    if (mAmount.text.isEmpty ||
        selectedCoinType == null ||
        selectedCurrency == null) {
      setState(() {
        isLoading = false;
        mYouGet.text = "0";
        mSellCryptoFees = 0.0;
        mSellExchangeFees = 0.0;
      });
      return;
    }
    setState(() => isLoading = true);
    try {
      double availableCoins =
          double.tryParse(mCryptoSellCoinAvailable ?? "0") ?? 0;
      double enteredAmount = double.tryParse(mAmount.text) ?? 0;
      if (enteredAmount > availableCoins) {
        setState(() {
          isLoading = false;
          mYouGet.text = "0";
          mSellCryptoFees = 0.0;
          mSellExchangeFees = 0.0;
          _errorMessage = "Insufficient balance";
        });
        return;
      }
      final request = CryptoSellFetchCoinPriceRequest(
          coinType: selectedCoinType!,
          currencyType: selectedCurrency!,
          noOfCoins: mAmount.text);
      final response = await _cryptoSellFetchCoinPriceApi
          .cryptoSellFetchCoinPriceApi(request);
      if (response.message == "Success") {
        setState(() {
          isLoading = false;
          mSellCryptoFees = response.data.cryptoFees ?? 0.0;
          mSellExchangeFees = response.data.exchangeFees ?? 0.0;
          mYouGet.text = response.data.amount;
          _errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          mSellCryptoFees = 0.0;
          mSellExchangeFees = 0.0;
          mYouGet.text = "0";
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackBar(
            context: context,
            message: "Something went wrong!",
            color: kPrimaryColor);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!isDataLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              color: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        top: 25, bottom: 10, left: 15, right: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        color: kPrimaryColor),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'Spend',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 0.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: mAmount,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                    cursorColor: kWhiteColor,
                                    textAlign: TextAlign.start,
                                    decoration: const InputDecoration(
                                      fillColor: Colors.transparent,
                                      border: InputBorder.none,
                                      filled: true,
                                      hintText: 'Enter Amount',
                                      hintStyle: TextStyle(
                                          color: Colors.white38, fontSize: 18),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        _errorMessage = null;
                                        if (value.isNotEmpty) {
                                          double enteredAmount =
                                              double.tryParse(value) ?? 0;
                                          double availableCoins =
                                              double.tryParse(
                                                      mCryptoSellCoinAvailable ??
                                                          "0") ??
                                                  0;
                                          if (enteredAmount > availableCoins) {
                                            _errorMessage =
                                                "Insufficient balance";
                                          } else if (enteredAmount <= 0) {
                                            _errorMessage =
                                                "Amount must be greater than 0";
                                          } else if (selectedCurrency != null &&
                                              selectedCoinType != null) {
                                            mCryptoSellFetchCoinPrice();
                                          }
                                        } else {
                                          mYouGet.text = "0";
                                          mSellCryptoFees = 0.0;
                                          mSellExchangeFees = 0.0;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: kWhiteColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      mYouGet.clear();
                                      mAmount.clear();
                                      setState(() {
                                        _errorMessage = null;
                                        mSellCryptoFees = 0.0;
                                        mSellExchangeFees = 0.0;
                                      });
                                    },
                                    icon: const Icon(Icons.clear,
                                        color: Colors.black, size: 12),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Row(
                                  children: [
                                    ClipOval(
                                      child: Image.network(
                                        _getImageForTransferType(
                                            selectedCoinType ?? 'BTC'),
                                        height: 20,
                                        width: 20,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image,
                                                    color: Colors.red,
                                                    size: 10),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: DropdownButton<String>(
                                        value: selectedCoinType,
                                        dropdownColor: Colors.grey[900],
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: Colors.grey),
                                        underline: const SizedBox(),
                                        items: <String>[
                                          'BTC',
                                          'BNB',
                                          'ADA',
                                          'SOL',
                                          'DOGE',
                                          'BCH',
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedCoinType = newValue;
                                            if (selectedCoinType != null) {
                                              mCryptoSellFetchCoinData();
                                              fetchLivePrice();
                                              if (mAmount.text.isNotEmpty) {
                                                mCryptoSellFetchCoinPrice();
                                              }
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.only(bottom: 25, left: 15, right: 15),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 10, left: 15),
                            child: Text(
                              'Receive',
                              style: TextStyle(
                                  color: kWhiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: mYouGet,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                  decoration: const InputDecoration(
                                    fillColor: kBlackColor,
                                    border: InputBorder.none,
                                    hintText: '0',
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  readOnly: true,
                                ),
                              ),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: kWhiteColor,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    mYouGet.clear();
                                  },
                                  icon: const Icon(Icons.clear,
                                      color: Colors.black, size: 12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        getCurrencySymbol(selectedCurrency) ??
                                            '',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: DropdownButton<String>(
                                      value: selectedCurrency,
                                      dropdownColor: Colors.grey[900],
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: Colors.grey),
                                      underline: const SizedBox(),
                                      items: currency
                                          .map<DropdownMenuItem<String>>(
                                              (CurrencyListsData currencyItem) {
                                        return DropdownMenuItem<String>(
                                          value: currencyItem.currencyCode,
                                          child: Text(
                                            currencyItem.currencyCode!,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedCurrency = newValue;
                                          if (selectedCurrency != null &&
                                              selectedCoinType != null &&
                                              mAmount.text.isNotEmpty) {
                                            mCryptoSellFetchCoinPrice();
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
            const SizedBox(height: 20),
            Card(
              elevation: 4.0,
              color: Colors.grey[500],
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Coins Available:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white)),
                        Text(mCryptoSellCoinAvailable!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white)),
                      ],
                    ),
                    if (mSellExchangeFees != null &&
                        mSellExchangeFees != 0) ...[
                      const SizedBox(height: smallPadding),
                      const Divider(color: Colors.white),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Exchange Fees:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white)),
                          Text(
                              '${getCurrencySymbol(selectedCurrency) ?? ""} ${mSellExchangeFees?.toString() ?? '0.0'}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white)),
                        ],
                      ),
                    ],
                    const SizedBox(height: smallPadding),
                    const Divider(color: Colors.white),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Crypto Fees:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white)),
                        Text(
                            '${getCurrencySymbol(selectedCurrency) ?? ""} ${mSellCryptoFees?.toStringAsFixed(1) ?? '0.0'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: isLoading ||
                        mAmount.text.isEmpty ||
                        selectedCurrency == null ||
                        selectedCoinType == null ||
                        _errorMessage != null
                    ? null
                    : () {
                        if (selectedCoinType == null) {
                          CustomSnackBar.showSnackBar(
                              context: context,
                              message: "Please Select Coins",
                              color: kRedColor);
                          return;
                        }
                        if (mAmount.text.isEmpty) {
                          CustomSnackBar.showSnackBar(
                              context: context,
                              message: "Please Enter No of Coins",
                              color: kRedColor);
                          return;
                        }
                        if (selectedCurrency == null) {
                          CustomSnackBar.showSnackBar(
                              context: context,
                              message: "Please Select Currency",
                              color: kRedColor);
                          return;
                        }
                        double availableCoins =
                            double.tryParse(mCryptoSellCoinAvailable ?? "0") ??
                                0;
                        double enteredAmount =
                            double.tryParse(mAmount.text) ?? 0;
                        if (enteredAmount > availableCoins) {
                          CustomSnackBar.showSnackBar(
                              context: context,
                              message:
                                  "Insufficient balance to sell this amount of coins",
                              color: kRedColor);
                          return;
                        }
                        if (enteredAmount <= 0) {
                          CustomSnackBar.showSnackBar(
                              context: context,
                              message:
                                  "Please enter a valid amount greater than 0",
                              color: kRedColor);
                          return;
                        }
                        if (mAmount.text.isNotEmpty &&
                            selectedCurrency != null &&
                            selectedCoinType != null &&
                            mSellCryptoFees != null &&
                            mYouGet.text.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfirmBuyScreen(
                                mCryptoAmount: mAmount.text,
                                mCurrency: selectedCurrency,
                                mCoinName: selectedCoinType,
                                mFees: mSellCryptoFees,
                                mExchangeFees: mSellExchangeFees,
                                mYouGetAmount: mYouGet.text,
                                mEstimateRates: null,
                                mCryptoType: "Crypto Sell",
                              ),
                            ),
                          );
                        } else {
                          CustomSnackBar.showSnackBar(
                              context: context,
                              message: "Please Enter Valid Details",
                              color: kPrimaryColor);
                        }
                      },
                child: isLoading
                    ? const SpinKitWaveSpinner(color: kWhiteColor, size: 30)
                    : const Text('Proceed',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            // Card(
            //   elevation: 4,
            //   color: kPrimaryColor,
            //   margin: const EdgeInsets.symmetric(horizontal: 0),
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(10),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Row(
            //           children: [
            //             ClipOval(
            //               child: Image.network(
            //                 _getImageForTransferType(selectedCoinType ?? 'BTC'),
            //                 height: 24,
            //                 width: 24,
            //                 errorBuilder: (context, error, stackTrace) =>
            //                     const Icon(Icons.broken_image,
            //                         color: Colors.red, size: 20),
            //               ),
            //             ),
            //             const SizedBox(width: 8),
            //             Text(
            //               selectedCoinType ?? 'BTC',
            //               style: const TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           ],
            //         ),
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.end,
            //           children: [
            //             Text(
            //               '\$${mLivePrice?.toStringAsFixed(2) ?? '0.00'}',
            //               style: const TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //             Text(
            //               '${mPriceChangePercentage?.toStringAsFixed(2) ?? '0.00'}%',
            //               style: TextStyle(
            //                 color: (mPriceChangePercentage ?? 0) >= 0
            //                     ? Colors.green
            //                     : Colors.red,
            //                 fontSize: 14,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              color: Color(0XFFdfad52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cryptocurrency Prices',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.white30,),
                    // Show a loading indicator if prices are being fetched
                    if (allCryptoPrices.isEmpty && isDataLoaded)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SpinKitWaveSpinner(
                            color: kPrimaryColor,
                            size: 30,
                          ),
                        ),
                      )
                    // Show a message if no prices are available
                    else if (allCryptoPrices.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Unable to fetch cryptocurrency prices. Please try again later.',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                      )
                    // Display the list of cryptocurrency prices with highlighting
                    else
                      ...allCryptoPrices.entries.map((entry) {
                        String coin = entry.key;
                        double price = entry.value['price'] ?? 0.0;
                        double change = entry.value['change'] ?? 0.0;
                        bool isSelected = coin ==
                            selectedCoinType; // Check if this coin is selected
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors
                                    .transparent, // Highlight with white background if selected
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  ClipOval(
                                    child: Image.network(
                                      _getImageForTransferType(coin),
                                      height: 20,
                                      width: 20,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.broken_image,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    coin,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors
                                              .white, // Adjust text color for contrast
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors
                                              .white, // Adjust text color for contrast
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${change.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: change >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getImageForTransferType(String transferType) {
    switch (transferType) {
      case "BTC":
        return 'https://assets.coincap.io/assets/icons/btc@2x.png';
      case "BNB":
        return 'https://assets.coincap.io/assets/icons/bnb@2x.png';
      case "ADA":
        return 'https://assets.coincap.io/assets/icons/ada@2x.png';
      case "SOL":
        return 'https://assets.coincap.io/assets/icons/sol@2x.png';
      case "DOGE":
        return 'https://assets.coincap.io/assets/icons/doge@2x.png';
      case "BCH":
        return 'https://assets.coincap.io/assets/icons/bch@2x.png';
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
}
