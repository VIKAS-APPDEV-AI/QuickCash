import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcash/Screens/SpotTradeScreen/recentsTradeModel/recentTradeApi.dart';
import 'package:quickcash/Screens/SpotTradeScreen/recentsTradeModel/recentTradeModel.dart';
import 'package:quickcash/Screens/SpotTradeScreen/tradingView/crypto_name_data_source.dart';
import 'package:quickcash/Screens/SpotTradeScreen/tradingView/trading_view_html.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/core/extension/context_extension.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/util/customSnackBar.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

class SpotTradeScreen extends StatefulWidget {
  const SpotTradeScreen({super.key});

  @override
  State<SpotTradeScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<SpotTradeScreen> {
  late IOWebSocketChannel channel;
  final RecentTradeApi _recentTradeApi = RecentTradeApi();
  List<TradeDetail> recentTrades = [];

  String? selectedTransferType;
  double sliderValue = 25;

  String? mAccountBalance = '';
  String? mAccountCurrency = '';

  bool isLoading = false;

  String selectedCoin = 'btcusdt';
  String? mTwentyFourHourChange = '0';
  String? mTwentyFourHourPercentage = '0';
  String? mTwentyFourHourHigh = '0';
  String? mTwentyFourHourLow = '0';
  String? mTwentyFourHourVolume = '0';
  String? mTwentyFourHourVolumeUSDT = '0';
  String? mTradingViewCurrency;
  String? mTradingViewCoin = 'BTC';

  @override
  void initState() {
    mAccountCurrency = AuthManager.getCurrency();
    mAccountBalance = AuthManager.getBalance();
    mRecentTradeDetails();
    initializeChannel();

    if (mAccountCurrency == "EUR") {
      mTradingViewCurrency = 'EUR';
    } else {
      mTradingViewCurrency = 'USD';
    }

    super.initState();
  }

  // Initialize the WebSocket channel with the selected coin
  void initializeChannel() {
    // Close the previous channel if it exists
    channel = IOWebSocketChannel.connect(
        'wss://stream.binance.com:9443/ws/$selectedCoin@ticker');
    streamListener();
  }

  // Listen to the incoming WebSocket stream and update the price
  void streamListener() {
    channel.stream.listen((message) {
      Map getData = jsonDecode(message);
      setState(() {
        mTwentyFourHourChange = getData['c'];
        mTwentyFourHourPercentage = getData['P'];
        mTwentyFourHourHigh = getData['h'];
        mTwentyFourHourLow = getData['l'];
        mTwentyFourHourVolume = getData['v'];
        mTwentyFourHourVolumeUSDT = getData['q'];
      });
    });
  }

  @override
  void dispose() {
    // Close the channel when the widget is disposed
    channel.sink.close();
    super.dispose();
  }

  // Recent Trade Api ******
  Future<void> mRecentTradeDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _recentTradeApi.recentTradeApi();

      if (response.tradeDetails != null && response.tradeDetails!.isNotEmpty) {
        setState(() {
          isLoading = false;
          recentTrades = response.tradeDetails!;
        });
      } else {
        setState(() {
          isLoading = false;
          CustomSnackBar.showSnackBar(
              context: context,
              message: 'We are facing some issue.',
              color: kPrimaryColor);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackBar(
            context: context,
            message: 'Something went wrong',
            color: kPrimaryColor);
      });
    }
  }

// Function to format the timestamp
  String formatTimestamp(int? timestamp) {
    if (timestamp == null) {
      return 'Time not available';
    }
    // Convert the timestamp to DateTime
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

    // Format the DateTime to a readable time format (hh:mm:ss a)
    return DateFormat('hh:mm:ss a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   iconTheme: const IconThemeData(color: Colors.transparent),
      //   title: const Text(
      //     "Spot Trade",
      //     style: TextStyle(color: Colors.transparent),
      //   ),
      // ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: kPrimaryColor,
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: smallPadding),
              GestureDetector(
                onTap: () => _showTransferTypeDropDown(context),
                child: Container(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (selectedTransferType != null)
                            ClipOval(
                              child: Image.network(
                                _getImageForTransferType(
                                    selectedTransferType!),
                                height: 30,
                                width: 30,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image,
                                      color: Colors.red);
                                },
                              ),
                            ),
                          const SizedBox(width: defaultPadding),
                          Text(
                            selectedTransferType != null
                                ? '$selectedTransferType$mAccountCurrency'
                                : 'Coin',
                            style: const TextStyle(
                                color: kPrimaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down,
                          color: kPrimaryColor),
                    ],
                  ),
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
                    const Text("24h Change",
                        style: TextStyle(color: kPurpleColor)),
                    const SizedBox(height: 5),
                    Text(
                        "$mTwentyFourHourChange  $mTwentyFourHourPercentage%",
                        style: TextStyle(
                            color: double.tryParse(
                                mTwentyFourHourPercentage!) !=
                                null &&
                                double.tryParse(
                                    mTwentyFourHourPercentage!)! <
                                    0
                                ? kRedColor
                                : kGreenColor,
                            fontSize: 16)),
                    const SizedBox(height: smallPadding),
                    const Divider(color: kPrimaryLightColor),
                    const Text("24h High",
                        style: TextStyle(color: kPurpleColor)),
                    const SizedBox(height: 5),
                    Text("$mTwentyFourHourHigh",
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: smallPadding),
                    const Divider(color: kPrimaryLightColor),
                    const Text("24h Low",
                        style: TextStyle(color: kPurpleColor)),
                    const SizedBox(height: 5),
                    Text("$mTwentyFourHourLow",
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: smallPadding),
                    const Divider(color: kPrimaryLightColor),
                    const Text("24h Volume",
                        style: TextStyle(color: kPurpleColor)),
                    const SizedBox(height: 5),
                    Text("$mTwentyFourHourVolume",
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: smallPadding),
                    const Divider(color: kPrimaryLightColor),
                    const Text("24h Volume(USDT)",
                        style: TextStyle(color: kPurpleColor)),
                    const SizedBox(height: 5),
                    Text("$mTwentyFourHourVolumeUSDT",
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: largePadding),
              Container(
                width: double.infinity,
                height: 418,
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
                    const Text("Recent Trades",
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: smallPadding),
                    // Wrap ListView in a Container or SizedBox with a defined height
                    SizedBox(
                      height: 350, // Adjust this height as needed
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: recentTrades.length,
                        itemBuilder: (context, index) {
                          final trade = recentTrades[index];
                          return Container(
                            margin: const EdgeInsets.only(
                                bottom: smallPadding),
                            padding: const EdgeInsets.all(defaultPadding),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: kPurpleColor, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Price ($mAccountCurrency):",
                                        style: const TextStyle(
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.bold)),
                                    Text("${trade.price}",
                                        style: const TextStyle(
                                            color: kPrimaryColor)),
                                  ],
                                ),
                                const SizedBox(height: smallPadding),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Qty (BTC):",
                                        style: TextStyle(
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.bold)),
                                    Text("${trade.qty}",
                                        style: const TextStyle(
                                            color: kPrimaryColor)),
                                  ],
                                ),
                                const SizedBox(height: smallPadding),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Time:",
                                        style: TextStyle(
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.bold)),
                                    Text(formatTimestamp(trade.time),
                                        style: const TextStyle(
                                            color: kPrimaryColor)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: smallPadding,
              ),
              Container(
                height: context.tradingViewWidgetHeight,
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
                child: Padding(
                  padding: context.smallTopPad,
                  child: TradingViewWidgetHtml(
                    cryptoName: CryptoNameDataSource.binanceSourceEuro(
                      mTradingViewCoin!.toString(),
                      mTradingViewCurrency!,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: smallPadding,
              ),
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
                      child: Text("Spot",
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(
                      height: smallPadding,
                    ),
                    const Divider(
                      color: kPurpleColor,
                    ),
                    const SizedBox(
                      height: defaultPadding,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 45,
                          child: FloatingActionButton.extended(
                            onPressed: () {},
                            label: const Text(
                              'Limit',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                            backgroundColor: kPrimaryColor,
                          ),
                        ),
                        const SizedBox(width: defaultPadding),
                        SizedBox(
                          width: 100,
                          height: 45,
                          child: FloatingActionButton.extended(
                            onPressed: () {},
                            label: const Text(
                              'Market',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                            backgroundColor: kPrimaryColor,
                          ),
                        ),
                        const SizedBox(width: defaultPadding),
                        SizedBox(
                          width: 110,
                          height: 45,
                          child: FloatingActionButton.extended(
                            onPressed: () {
                              // Add your onPressed code here!
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CardsListScreen()),
                              );*/
                            },
                            label: const Text(
                              'Stop Limit',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                            backgroundColor: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),

                    // Balance
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    Container(
                      width: double.infinity,
                      height: 55.0,
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
                      // Replace with your desired color
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$mAccountCurrency Balance",
                            style: const TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Text(
                            "$mAccountBalance $mAccountCurrency",
                            style: const TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),

                    // Price
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    Container(
                      width: double.infinity,
                      height: 55.0,
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kPurpleColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Price",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Text(
                            "$mTwentyFourHourChange  $mAccountCurrency",
                            style: const TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),

                    // No of coins
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    Container(
                      width: double.infinity,
                      height: 55.0,
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kPurpleColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "No of Coins",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Text(
                            "BTC",
                            style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),

                    // Range
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
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
                          const Text(
                            "Amount Range",
                            style: TextStyle(
                                fontSize: 16,
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text("0%",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold)),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: kPurpleColor,
                                    inactiveTrackColor:
                                    kPrimaryLightColor,
                                    thumbColor: kPrimaryColor,
                                    overlayColor:
                                    Colors.black.withOpacity(0.1),
                                    thumbShape:
                                    const RoundSliderThumbShape(
                                        enabledThumbRadius: 10),
                                    trackHeight: 4.0,
                                  ),
                                  child: Slider(
                                    value: sliderValue,
                                    min: 0,
                                    max: 100,
                                    divisions: 100,
                                    onChanged: (value) {
                                      setState(() {
                                        sliderValue = value;
                                        // mSidePercentage(sliderValue);
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text("100%",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Center(
                            child: Text("${sliderValue.toInt()}%",
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),

                    // Total Balance
                    const SizedBox(
                      height: defaultPadding,
                    ),
                    Container(
                      width: double.infinity,
                      height: 55.0,
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
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
                      // Replace with your desired color
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          Text(
                            "214.5093297443351 USD",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),

                    //Buy And Sell Button
                    const SizedBox(
                      height: 35,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: largePadding,
                        ),
                        SizedBox(
                          width: 130,
                          height: 45,
                          child: FloatingActionButton.extended(
                            onPressed: () {},
                            label: const Text(
                              'Buy',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                            backgroundColor: kGreenColor,
                          ),
                        ),
                        const SizedBox(width: defaultPadding),
                        SizedBox(
                          width: 130,
                          height: 45,
                          child: FloatingActionButton.extended(
                            onPressed: () {
                              // Add your onPressed code here!
                              /*Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CardsListScreen()),
                              );*/
                            },
                            label: const Text(
                              'Sell',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                            backgroundColor: kRedColor,
                          ),
                        ),
                        const SizedBox(
                          width: largePadding,
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

  void _showTransferTypeDropDown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: [
            const SizedBox(height: 25),
            _buildTransferOptions(
                'BTC', 'https://assets.coincap.io/assets/icons/btc@2x.png'),
            _buildTransferOptions(
                'BNB', 'https://assets.coincap.io/assets/icons/bnb@2x.png'),
            _buildTransferOptions(
                'ADA', 'https://assets.coincap.io/assets/icons/ada@2x.png'),
            _buildTransferOptions(
                'SOL', 'https://assets.coincap.io/assets/icons/sol@2x.png'),
            _buildTransferOptions(
                'DOGE', 'https://assets.coincap.io/assets/icons/doge@2x.png'),
            _buildTransferOptions(
                'LTC', 'https://assets.coincap.io/assets/icons/ltc@2x.png'),
            _buildTransferOptions(
                'ETH', 'https://assets.coincap.io/assets/icons/eth@2x.png'),
            _buildTransferOptions(
                'SHIB', 'https://assets.coincap.io/assets/icons/shib@2x.png'),
          ],
        );
      },
    );
  }

  Widget _buildTransferOptions(String type, String logoPath) {
    return ListTile(
      title: Row(
        children: [
          ClipOval(
            child: Image.network(logoPath, height: 30),
          ),
          const SizedBox(width: defaultPadding),
          Text(
            '$type$mAccountCurrency',
            style: const TextStyle(
                color: kPrimaryColor,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
      onTap: () {
        setState(() {
          selectedTransferType = type;
          mTradingViewCoin = type;
          mRecentTradeDetails();
          setState(() {
            if (mAccountCurrency == "EUR") {
              String coin = '${selectedTransferType!.toLowerCase()}eur';
              selectedCoin = coin;
              channel.sink.close();
              initializeChannel();
            } else {
              String coin = '${selectedTransferType!.toLowerCase()}usdt';
              selectedCoin = coin;
              channel.sink.close();
              initializeChannel();
            }
          });
        });
        Navigator.pop(context);
      },
    );
  }

/*Future<void> mSidePercentage(double sliderValue) async {
    print('SliderValue: $sliderValue');
    print('24 Hour Change: $mTwentyFourHourChange');

    // Convert the string to double using tryParse for mTwentyFourHourChange
    double? mTwentyFourHourChangeDouble = double.tryParse(mTwentyFourHourChange!);

    if (mTwentyFourHourChangeDouble == null) {
      print('Invalid 24 Hour Change value');
      return;
    }

    // Convert the string to double using tryParse for mAccountBalance
    double? mBalance = double.tryParse(mAccountBalance!);

    if (mBalance != null) {
      // Calculate the percentage of mAccountBalance based on sliderValue
      double percentage = (mBalance * sliderValue) / 100;
      print('Percentage of Account Balance: $percentage');

      // Check if percentage is non-zero to avoid division by zero
      if (percentage != 0) {
        double result = mTwentyFourHourChangeDouble / percentage;
        print('Result of dividing 24 Hour Change by percentage: $result');
      } else {
        print('Percentage is zero, cannot divide by zero');
      }
    } else {
      print('Invalid Account Balance');
    }
  }*/
}
