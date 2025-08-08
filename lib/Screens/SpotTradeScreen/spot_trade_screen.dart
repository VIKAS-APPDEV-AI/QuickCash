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
  State<SpotTradeScreen> createState() => _SpotTradeScreenState();
}

class _SpotTradeScreenState extends State<SpotTradeScreen> {
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

  void initializeChannel() {
    channel = IOWebSocketChannel.connect(
        'wss://stream.binance.com:9443/ws/$selectedCoin@ticker');
    streamListener();
  }

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
    channel.sink.close();
    super.dispose();
  }

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
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Theme.of(context).extension<AppColors>()!.primary,
          );
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackBar(
          context: context,
          message: 'Something went wrong',
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Theme.of(context).extension<AppColors>()!.primary,
        );
      });
    }
  }

  String formatTimestamp(int? timestamp) {
    if (timestamp == null) {
      return 'Time not available';
    }
    try {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateFormat('hh:mm:ss a').format(dateTime);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final primaryColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Theme.of(context).extension<AppColors>()!.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coin selection dropdown
                    GestureDetector(
                      onTap: () => _showTransferTypeDropDown(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade600
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.black54
                                  : Colors.black.withOpacity(0.1),
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
                                      _getImageForTransferType(selectedTransferType!),
                                      height: isSmallScreen ? 24 : 30,
                                      width: isSmallScreen ? 24 : 30,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.broken_image,
                                          color: Colors.red,
                                          size: isSmallScreen ? 20 : 24,
                                        );
                                      },
                                    ),
                                  ),
                                SizedBox(width: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                                Text(
                                  selectedTransferType != null
                                      ? '$selectedTransferType$mAccountCurrency'
                                      : 'Coin',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: isSmallScreen ? 13 : 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: primaryColor,
                              size: isSmallScreen ? 20 : 24,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? smallPadding / 2 : smallPadding),

                    // Combined chart and trading controls section
                    Column(
                      children: [
                        // Trading View Chart
                        Container(
                          height: context.tradingViewWidgetHeight * (isSmallScreen ? 0.8 : 1.0),
                          padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black54
                                    : Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: context.smallTopPad,
                            child: TradingViewWidgetHtml(
                              cryptoName: mTradingViewCoin!,
                              currency: mTradingViewCurrency!,
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? smallPadding / 2 : smallPadding),

                        // Trading controls
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black54
                                    : Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "Spot",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: isSmallScreen ? 15 : 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? smallPadding / 2 : smallPadding),
                              Divider(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade300,
                              ),
                              SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),

                              // Order type buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: isSmallScreen ? 90 : 100,
                                    height: isSmallScreen ? 40 : 45,
                                    child: FloatingActionButton.extended(
                                      onPressed: () {},
                                      label: Text(
                                        'Limit',
                                        style: TextStyle(
                                           color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                          fontSize: isSmallScreen ? 13 : 15,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      backgroundColor: primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                                  SizedBox(
                                    width: isSmallScreen ? 90 : 100,
                                    height: isSmallScreen ? 40 : 45,
                                    child: FloatingActionButton.extended(
                                      onPressed: () {},
                                      label: Text(
                                        'Market',
                                        style: TextStyle(
                                           color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                          fontSize: isSmallScreen ? 13 : 15,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      backgroundColor: primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                                  SizedBox(
                                    width: isSmallScreen ? 100 : 110,
                                    height: isSmallScreen ? 40 : 45,
                                    child: FloatingActionButton.extended(
                                      onPressed: () {},
                                      label: Text(
                                        'Stop Limit',
                                         style: TextStyle(
                                           color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                          fontSize: isSmallScreen ? 13 : 15,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      backgroundColor: primaryColor,
                                    ),
                                  ),
                                ],
                              ),

                              // Balance
                              SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                              Container(
                                width: double.infinity,
                                height: isSmallScreen ? 45 : 55,
                                padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.black54
                                          : Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "$mAccountCurrency Balance",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 13 : 15,
                                      ),
                                    ),
                                    Text(
                                      "${mAccountBalance ?? '0.00'} $mAccountCurrency",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 13 : 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Price
                              SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                              Container(
                                width: double.infinity,
                                height: isSmallScreen ? 45 : 55,
                                padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.black54
                                          : Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Price",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 13 : 15,
                                      ),
                                    ),
                                    Text(
                                      "${mTwentyFourHourChange ?? '0.00'} $mAccountCurrency",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 13 : 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // No of coins
                              SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                              Container(
                                width: double.infinity,
                                height: isSmallScreen ? 45 : 55,
                                padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.black54
                                          : Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "No of Coins",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 13 : 15,
                                      ),
                                    ),
                                    Text(
                                      mTradingViewCoin ?? "BTC",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 13 : 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Range slider
                              SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.black54
                                          : Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Amount Range",
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 6 : 8),
                                    Row(
                                      children: [
                                        Text(
                                          "0%",
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 11 : 12,
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: SliderTheme(
                                            data: SliderTheme.of(context).copyWith(
                                              activeTrackColor: primaryColor,
                                              inactiveTrackColor: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.grey.shade600
                                                  : Colors.grey.shade300,
                                              thumbColor: primaryColor,
                                              overlayColor: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white.withOpacity(0.2)
                                                  : Colors.black.withOpacity(0.1),
                                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
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
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: isSmallScreen ? 6 : 8),
                                        Text(
                                          "100%",
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 11 : 12,
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Center(
                                      child: Text(
                                        "${sliderValue.toInt()}%",
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 11 : 12,
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Total Balance
                              SizedBox(height: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                              Container(
                                width: double.infinity,
                                height: isSmallScreen ? 45 : 55,
                                padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.black54
                                          : Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total",
                                       style: TextStyle(
                                           color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                          fontSize: isSmallScreen ? 13 : 15,
                                          fontWeight: FontWeight.bold
                                        ),
                                    ),
                                    Text(
                                      "${mAccountBalance ?? '214.5093297443351'} $mAccountCurrency",
                                      style: TextStyle(
                                           color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                          fontSize: isSmallScreen ? 13 : 15,
                                          fontWeight: FontWeight.bold
                                        ),
                                    ),
                                  ],
                                ),
                              ),

                              // Buy/Sell buttons
                              SizedBox(height: isSmallScreen ? 25 : 35),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(width: isSmallScreen ? largePadding / 2 : largePadding),
                                  SizedBox(
                                    width: isSmallScreen ? 110 : 130,
                                    height: isSmallScreen ? 40 : 45,
                                    child: FloatingActionButton.extended(
                                      onPressed: () {},
                                      label: Text(
                                        'Buy',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isSmallScreen ? 13 : 15,
                                        ),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                  SizedBox(width: isSmallScreen ? defaultPadding / 2 : defaultPadding),
                                  SizedBox(
                                    width: isSmallScreen ? 110 : 130,
                                    height: isSmallScreen ? 40 : 45,
                                    child: FloatingActionButton.extended(
                                      onPressed: () {},
                                      label: Text(
                                        'Sell',
                                         style: TextStyle(
                                           color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                          fontSize: isSmallScreen ? 13 : 15,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      backgroundColor: primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: isSmallScreen ? largePadding / 2 : largePadding),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isSmallScreen ? smallPadding / 2 : smallPadding),

                    // Market data section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade600
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black54
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "24h Change",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 3 : 5),
                          Text(
                            "${mTwentyFourHourChange ?? '0'} ${mTwentyFourHourPercentage ?? '0'}%",
                            style: TextStyle(
                              color: double.tryParse(mTwentyFourHourPercentage ?? '0') != null &&
                                      double.tryParse(mTwentyFourHourPercentage ?? '0')! < 0
                                  ? Colors.red
                                  : Colors.green,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? smallPadding / 2 : smallPadding),
                          Divider(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade600
                                : Colors.grey.shade300,
                          ),
                          Text(
                            "24h High",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 3 : 5),
                          Text(
                            "${mTwentyFourHourHigh ?? '0'}",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? smallPadding / 2 : smallPadding),
                          Divider(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade600
                                : Colors.grey.shade300,
                          ),
                          Text(
                            "24h Low",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 3 : 5),
                          Text(
                            "${mTwentyFourHourLow ?? '0'}",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? smallPadding / 2 : smallPadding),
                          Divider(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade600
                                : Colors.grey.shade300,
                          ),
                          Text(
                            "24h Volume",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 3 : 5),
                          Text(
                            "${mTwentyFourHourVolume ?? '0'}",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? smallPadding / 2 : smallPadding),
                          Divider(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade600
                                : Colors.grey.shade300,
                          ),
                          Text(
                            "24h Volume(USDT)",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 3 : 5),
                          Text(
                            "${mTwentyFourHourVolumeUSDT ?? '0'}",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? largePadding / 2 : largePadding),

                    // Recent trades section
                    Container(
                      width: double.infinity,
                      height: isSmallScreen ? 350 : 418,
                      padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade600
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black54
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recent Trades",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: isSmallScreen ? 15 : 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? smallPadding / 2 : smallPadding),
                          SizedBox(
                            height: isSmallScreen ? 300 : 350,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: recentTrades.length,
                              itemBuilder: (context, index) {
                                final trade = recentTrades[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: isSmallScreen ? smallPadding / 2 : smallPadding),
                                  padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade900
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Price ($mAccountCurrency):",
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: isSmallScreen ? 13 : 15,
                                            ),
                                          ),
                                          Text(
                                            "${trade.price ?? '0'}",
                                            style: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white70
                                                  : Colors.grey.shade600,
                                              fontSize: isSmallScreen ? 13 : 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isSmallScreen ? smallPadding / 2 : smallPadding),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Qty (BTC):",
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: isSmallScreen ? 13 : 15,
                                            ),
                                          ),
                                          Text(
                                            "${trade.qty ?? '0'}",
                                            style: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white70
                                                  : Colors.grey.shade600,
                                              fontSize: isSmallScreen ? 13 : 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isSmallScreen ? smallPadding / 2 : smallPadding),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Time:",
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: isSmallScreen ? 13 : 15,
                                            ),
                                          ),
                                          Text(
                                            formatTimestamp(trade.time),
                                            style: TextStyle(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white70
                                                  : Colors.grey.shade600,
                                              fontSize: isSmallScreen ? 13 : 15,
                                            ),
                                          ),
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
        return 'assets/icons/default.png';
    }
  }

  void _showTransferTypeDropDown(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ListView(
          padding: EdgeInsets.all(isSmallScreen ? defaultPadding / 1.5 : defaultPadding),
          children: [
            SizedBox(height: isSmallScreen ? 20 : 25),
            _buildTransferOptions(
              'BTC',
              'https://assets.coincap.io/assets/icons/btc@2x.png',
              isSmallScreen,
            ),
            _buildTransferOptions(
              'BNB',
              'https://assets.coincap.io/assets/icons/bnb@2x.png',
              isSmallScreen,
            ),
            _buildTransferOptions(
              'ADA',
              'https://assets.coincap.io/assets/icons/ada@2x.png',
              isSmallScreen,
            ),
            _buildTransferOptions(
              'SOL',
              'https://assets.coincap.io/assets/icons/sol@2x.png',
              isSmallScreen,
            ),
            _buildTransferOptions(
              'DOGE',
              'https://assets.coincap.io/assets/icons/doge@2x.png',
              isSmallScreen,
            ),
            _buildTransferOptions(
              'LTC',
              'https://assets.coincap.io/assets/icons/ltc@2x.png',
              isSmallScreen,
            ),
            _buildTransferOptions(
              'ETH',
              'https://assets.coincap.io/assets/icons/eth@2x.png',
              isSmallScreen,
            ),
            _buildTransferOptions(
              'SHIB',
              'https://assets.coincap.io/assets/icons/shib@2x.png',
              isSmallScreen,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransferOptions(String type, String logoPath, bool isSmallScreen) {
    final primaryColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Theme.of(context).extension<AppColors>()!.primary;

    return ListTile(
      title: Row(
        children: [
          ClipOval(
            child: Image.network(
              logoPath,
              height: isSmallScreen ? 24 : 30,
              width: isSmallScreen ? 24 : 30,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.broken_image,
                  color: Colors.red,
                  size: isSmallScreen ? 20 : 24,
                );
              },
            ),
          ),
          SizedBox(width: isSmallScreen ? defaultPadding / 2 : defaultPadding),
          Text(
            '$type$mAccountCurrency',
            style: TextStyle(
              color: primaryColor,
              fontSize: isSmallScreen ? 13 : 15,
              fontWeight: FontWeight.bold,
            ),
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
}