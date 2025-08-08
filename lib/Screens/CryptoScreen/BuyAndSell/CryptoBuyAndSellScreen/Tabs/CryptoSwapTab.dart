import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/BuyAndSellScreen/cryptoSellFetchCoinDataModel/cryptoSellFetchCoinApi.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/CryptoBuyAndSellScreen/CryptoSwap/CryptoSwapAPI/SwapApiService.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/CryptoBuyAndSellScreen/CryptoSwap/Widgets/SuccessScreen.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/CryptoBuyAndSellScreen/crypto_sell_exchange_screen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/model/currencyApiModel/Services/currencyApi.dart';
import 'package:quickcash/util/auth_manager.dart';

class CryptoSwapTab extends StatefulWidget {
  const CryptoSwapTab({super.key});

  @override
  State<CryptoSwapTab> createState() => _CryptoSwapTabState();
}

class _CryptoSwapTabState extends State<CryptoSwapTab>
    with AutomaticKeepAliveClientMixin {
  final CryptoApiService _apiService = CryptoApiService();
  final BinanceApi _binanceApi = BinanceApi();
  final CryptoSellFetchCoinDataApi _cryptoSellFetchCoinDataApi =
      CryptoSellFetchCoinDataApi();

  final TextEditingController mAmount = TextEditingController();
  final TextEditingController mYouGet = TextEditingController();
  Timer? _debounceTimer;
  Timer? _priceUpdateTimer;

  bool isDataLoaded = false;
  bool isLoading = false;
  String? selectedCoinType;
  String? selectedCoinToReceive;
  String? mCryptoSellCoinAvailable = "0.00";
  String? _errorMessage;
  String? _conversionRate = "0";
  double? mLivePrice;
  double? mPriceChangePercentage;
  Map<String, Map<String, dynamic>> allCryptoPrices = {};
  List<Map<String, String>> swapCoins = [];
  List<String> cryptoList = [];
  String? coinName;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await mGetSwapCoins();
      setState(() {
        isDataLoaded = true;
        if (swapCoins.isNotEmpty) {
          cryptoList = swapCoins.map((coin) => '${coin['coin']}USDT').toList();
          selectedCoinType = swapCoins[0]['coin'];
          selectedCoinToReceive = swapCoins.length > 1
              ? swapCoins[1]['coin']
              : swapCoins[0]['coin'];
        } else {
          _errorMessage = 'No swap coins available';
        }
      });
      if (swapCoins.isNotEmpty) {
        await Future.wait([
          mCryptoSellFetchCoinData(),
          fetchLivePrice(),
          fetchAllCryptoPrices(),
        ]);
        _priceUpdateTimer =
            Timer.periodic(const Duration(seconds: 120), (timer) {
          fetchLivePrice();
          fetchAllCryptoPrices();
        });
      }
    } catch (e) {
      setState(() {
        isDataLoaded = true;
        _errorMessage = 'Initialization failed: $e';
      });
      CustomSnackBar.showSnackBar(
        context: context,
        message: 'Initialization failed: $e',
        color: Colors.red,
      );
    }
  }

  @override
  void dispose() {
    mAmount.dispose();
    mYouGet.dispose();
    _debounceTimer?.cancel();
    _priceUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> mGetSwapCoins() async {
    try {
      final coins = await _apiService.fetchSwapCoins();
      setState(() {
        swapCoins = coins;
      });
    } catch (e) {
      setState(() {
        swapCoins = [];
        _errorMessage = 'Error fetching swap coins: $e';
      });
      CustomSnackBar.showSnackBar(
        context: context,
        message: 'Error fetching swap coins: $e',
        color: Colors.red,
      );
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
        message: 'Failed to fetch live price: $e',
        color: Colors.red,
      );
    }
  }

  Future<void> fetchAllCryptoPrices() async {
    try {
      final prices = await _binanceApi.fetchMultiplePrices(cryptoList);
      Map<String, Map<String, dynamic>> updatedPrices = {};

      for (var price in prices) {
        String coin = price['symbol'].replaceAll('USDT', '');
        updatedPrices[coin] = {'price': double.tryParse(price['price']) ?? 0.0};
      }

      for (var symbol in cryptoList) {
        final changeData = await _binanceApi.fetch24HrPriceChange(symbol);
        String coin = symbol.replaceAll('USDT', '');
        updatedPrices[coin]!['change'] =
            double.tryParse(changeData['priceChangePercent']) ?? 0.0;
      }

      setState(() {
        allCryptoPrices = updatedPrices;
      });
    } catch (e) {
      setState(() {
        allCryptoPrices = {};
      });
      CustomSnackBar.showSnackBar(
        context: context,
        message: 'Failed to fetch all crypto prices: $e',
        color: Colors.red,
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
          mCryptoSellCoinAvailable =
              double.tryParse(response.data)?.toStringAsFixed(2) ?? "0.00";
        });
      } else {
        setState(() {
          mCryptoSellCoinAvailable = "0.00";
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        mCryptoSellCoinAvailable = "0.00";
        CustomSnackBar.showSnackBar(
            context: context, message: "No coins found", color: Theme.of(context).extension<AppColors>()!.primary);
      });
    }
  }

  Future<void> mConvertCoin() async {
    if (mAmount.text.isEmpty ||
        selectedCoinType == null ||
        selectedCoinToReceive == null) {
      setState(() {
        isLoading = false;
        mYouGet.text = "0";
        _conversionRate = "0";
        _errorMessage = 'Please select both coins and enter an amount';
      });
      CustomSnackBar.showSnackBar(
        context: context,
        message: 'Please fill all required fields',
        color: Colors.red,
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      double enteredAmount = double.tryParse(mAmount.text) ?? 0;
      double availableCoins =
          double.tryParse(mCryptoSellCoinAvailable ?? "0") ?? 0;

      if (enteredAmount > availableCoins) {
        setState(() {
          isLoading = false;
          mYouGet.text = "0";
          _conversionRate = "0";
          _errorMessage = 'Insufficient balance';
        });
        CustomSnackBar.showSnackBar(
          context: context,
          message: 'Insufficient balance',
          color: Colors.red,
        );
        return;
      }

      if (enteredAmount <= 0) {
        setState(() {
          isLoading = false;
          mYouGet.text = "0";
          _conversionRate = "0";
          _errorMessage = 'Amount must be greater than 0';
        });
        CustomSnackBar.showSnackBar(
          context: context,
          message: 'Amount must be greater than 0',
          color: Colors.red,
        );
        return;
      }

      final response = await _apiService.convertCoin(
        fromCoin: selectedCoinType!,
        toCoin: selectedCoinToReceive!,
        amount: enteredAmount,
      );

      print('mConvertCoin response: $response');

      setState(() {
        isLoading = false;
        mYouGet.text =
            double.tryParse(response['coinsAdded']?.toString() ?? "0")
                    ?.toStringAsFixed(8) ??
                "0";
        _conversionRate =
            double.tryParse(response['rate'])?.toStringAsFixed(8) ?? "0";
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        mYouGet.text = "0";
        _conversionRate = "0";
        _errorMessage = e.toString().contains('Too many requests')
            ? 'Too many requests, please try again later'
            : 'Failed to convert coin: $e';
      });
      CustomSnackBar.showSnackBar(
        context: context,
        message: e.toString().contains('Too many requests')
            ? 'Too many requests, please try again later'
            : (e.toString().contains('token')
                ? 'Please log in again'
                : 'Conversion failed: $e'),
        color: Colors.red,
      );
    }
  }

  Future<void> mUpdateSwap() async {
    if (mAmount.text.isEmpty ||
        selectedCoinType == null ||
        selectedCoinToReceive == null ||
        mYouGet.text.isEmpty ||
        mYouGet.text == "0") {
      setState(() {
        isLoading = false;
        _errorMessage = 'Please complete the conversion first';
      });
      CustomSnackBar.showSnackBar(
        context: context,
        message: 'Please complete the conversion first',
        color: Colors.red,
      );
      return;
    }

    setState(() => isLoading = true);
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final userId = await AuthManager.getUserId();
        final response = await _apiService.updateSwap(
          userId: userId,
          fromCoin: '${selectedCoinType}_TEST',
          toCoin: '${selectedCoinToReceive}_TEST',
          coinsDeducted:
              double.tryParse(mAmount.text)?.toStringAsFixed(2) ?? "0.00",
          coinsAdded:
              double.tryParse(mYouGet.text)?.toStringAsFixed(8) ?? "0.00000000",
        );

        print('mUpdateSwap response: $response');
        print('Response success type: ${response['success'].runtimeType}');

        // Fix: Check success value safely
        if (response['success'].toString().toLowerCase() == 'true') {
          setState(() {
            isLoading = false;
            mCryptoSellCoinAvailable = double.tryParse(response['data']
                                ['updatedBalances']['${selectedCoinType}_TEST']
                            ?.toString() ??
                        "0")
                    ?.toStringAsFixed(2) ??
                "0.00";
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SuccessScreen(
                fromCoin: '${selectedCoinType}_TEST',
                toCoin: '${selectedCoinToReceive}_TEST',
                coinsDeducted:
                    double.tryParse(mAmount.text)?.toStringAsFixed(2) ?? "0.00",
                coinsAdded: double.tryParse(mYouGet.text)?.toStringAsFixed(8) ??
                    "0.00000000",
              ),
            ),
          );
          return;
        } else {
          throw Exception(
              'Swap update failed: ${response['message'] ?? 'Invalid response'}');
        }
      } catch (e) {
        print('mUpdateSwap error: $e');
        if (e.toString().contains('429')) {
          retryCount++;
          if (retryCount >= maxRetries) {
            setState(() {
              isLoading = false;
              _errorMessage = 'Too many requests, please try again later';
            });
            CustomSnackBar.showSnackBar(
              context: context,
              message: 'Too many requests, please try again later',
              color: Colors.red,
            );
            return;
          }
          await Future.delayed(Duration(seconds: 1 << retryCount));
          continue;
        } else if (e.toString().contains('401') ||
            e.toString().contains('403')) {
          setState(() {
            isLoading = false;
            _errorMessage = 'Authentication failed: Please log in again';
          });
          CustomSnackBar.showSnackBar(
            context: context,
            message: 'Authentication failed: Please log in again',
            color: Colors.red,
          );
          return;
        } else if (e.toString().contains('400')) {
          setState(() {
            isLoading = false;
            _errorMessage = 'Invalid swap details provided';
          });
          CustomSnackBar.showSnackBar(
            context: context,
            message: 'Invalid swap details: Please check your inputs',
            color: Colors.red,
          );
          return;
        }

        setState(() {
          isLoading = false;
          _errorMessage = 'Swap failed: $e';
        });
        CustomSnackBar.showSnackBar(
          context: context,
          message: 'Swap failed: $e',
          color: Colors.red,
        );
        return;
      }
    }
  }

  void _showConfirmSwapDialog() {
    bool isConfirmed = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'Confirm Swap Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'From Coin: ${selectedCoinType ?? "N/A"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'To Coin: ${selectedCoinToReceive ?? "N/A"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coins Deducted: ${double.tryParse(mAmount.text)?.toStringAsFixed(2) ?? "0.00"} $selectedCoinType',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coins Added: ${double.tryParse(mYouGet.text)?.toStringAsFixed(8) ?? "0.00000000"} $selectedCoinToReceive',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: isConfirmed,
                          onChanged: (bool? value) {
                            setStateDialog(() {
                              isConfirmed = value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'I confirm the above swap details are correct.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isConfirmed ? Theme.of(context).extension<AppColors>()!.primary : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isConfirmed
                      ? () {
                          Navigator.of(context).pop();
                          mUpdateSwap();
                        }
                      : null,
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onAmountChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        _errorMessage = null;
        if (value.isNotEmpty) {
          double enteredAmount = double.tryParse(value) ?? 0;
          double availableCoins =
              double.tryParse(mCryptoSellCoinAvailable ?? "0") ?? 0;
          if (enteredAmount > availableCoins) {
            _errorMessage = 'Insufficient balance';
            mYouGet.text = "0";
            _conversionRate = "0";
          } else if (enteredAmount <= 0) {
            _errorMessage = 'Amount must be greater than 0';
            mYouGet.text = "0";
            _conversionRate = "0";
          } else if (selectedCoinType != null &&
              selectedCoinToReceive != null) {
            mConvertCoin();
          }
        } else {
          mYouGet.text = "0";
          _conversionRate = "0";
        }
      });
    });
  }

  String _getImageForTransferType(String transferType) {
    final coinData = swapCoins.firstWhere(
      (coin) => coin['coin'] == transferType,
      orElse: () => {'logoName': 'default'},
    );
    final logoName = coinData['logoName'] ?? 'default';

    const Map<String, String> coinImages = {
      'sol': 'https://assets.coincap.io/assets/icons/sol@2x.png',
      'ada': 'https://assets.coincap.io/assets/icons/ada@2x.png',
      'bch': 'https://assets.coincap.io/assets/icons/bch@2x.png',
      'doge': 'https://assets.coincap.io/assets/icons/doge@2x.png',
      'btc': 'https://assets.coincap.io/assets/icons/btc@2x.png',
      'bnb': 'https://assets.coincap.io/assets/icons/bnb@2x.png',
      'ltc': 'https://assets.coincap.io/assets/icons/ltc@2x.png',
      'eth': 'https://assets.coincap.io/assets/icons/eth@2x.png',
      'shib': 'https://assets.coincap.io/assets/icons/shib@2x.png',
      'default': 'assets/icons/default.png',
    };
    return coinImages[logoName] ?? 'assets/icons/default.png';
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
              color: Theme.of(context).extension<AppColors>()!.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Spend Section
                  Container(
                    padding: const EdgeInsets.only(
                        top: 25, bottom: 10, left: 15, right: 15),
                    decoration:  BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      color: Theme.of(context).extension<AppColors>()!.primary,
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
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'Spend',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                                    cursorColor: Colors.white,
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
                                    onChanged: _onAmountChanged,
                                  ),
                                ),
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
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
                                        _conversionRate = "0";
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
                                            selectedCoinType ?? 'SOL'),
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
                                        items: swapCoins
                                            .map<DropdownMenuItem<String>>(
                                                (coin) {
                                          return DropdownMenuItem<String>(
                                            value: coin['coin'],
                                            child: Text(
                                              coin['coin']!,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue == null) return;
                                          setState(() {
                                            selectedCoinType = newValue;
                                            if (selectedCoinToReceive ==
                                                newValue) {
                                              selectedCoinToReceive =
                                                  swapCoins.firstWhere(
                                                (coin) =>
                                                    coin['coin'] != newValue,
                                                orElse: () => swapCoins[0],
                                              )['coin'];
                                            }
                                            mCryptoSellFetchCoinData();
                                            fetchLivePrice();
                                            if (mAmount.text.isNotEmpty) {
                                              mConvertCoin();
                                            } else {
                                              mYouGet.text = "0";
                                              _conversionRate = "0";
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
                  // Receive Section
                  Container(
                    padding:
                        const EdgeInsets.only(bottom: 25, left: 15, right: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).extension<AppColors>()!.primary,
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
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                                  decoration:  InputDecoration(
                                    fillColor: Theme.of(context).extension<AppColors>()!.primary,
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
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    mYouGet.clear();
                                    setState(() {
                                      _conversionRate = "0";
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
                                          selectedCoinToReceive ?? 'ADA'),
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
                                      value: selectedCoinToReceive,
                                      dropdownColor: Colors.grey[900],
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: Colors.grey),
                                      underline: const SizedBox(),
                                      items: swapCoins
                                          .where((coin) =>
                                              coin['coin'] != selectedCoinType)
                                          .map<DropdownMenuItem<String>>(
                                              (coin) {
                                        return DropdownMenuItem<String>(
                                          value: coin['coin'],
                                          child: Text(
                                            coin['coin']!,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue == null) return;
                                        setState(() {
                                          selectedCoinToReceive = newValue;
                                          if (mAmount.text.isNotEmpty) {
                                            mConvertCoin();
                                          } else {
                                            mYouGet.text = "0";
                                            _conversionRate = "0";
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
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available Balance:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white),
                        ),
                        Text(
                          selectedCoinType != null
                              ? '${mCryptoSellCoinAvailable ?? "0.00"} $selectedCoinType'
                              : 'Select a coin',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _conversionRate != null &&
                                  _conversionRate != "0" &&
                                  selectedCoinType != null &&
                                  selectedCoinToReceive != null
                              ? '$selectedCoinType → $selectedCoinToReceive Rate:'
                              : 'N/A',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white),
                        ),
                        Text(
                          _conversionRate != null && _conversionRate != "0"
                              ? ' ${double.tryParse(_conversionRate!)?.toStringAsFixed(8) ?? "N/A"}'
                              : 'N/A',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white),
                        ),
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
                  backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: isLoading ||
                        mAmount.text.isEmpty ||
                        selectedCoinType == null ||
                        selectedCoinToReceive == null ||
                        _errorMessage != null
                    ? null
                    : () {
                        _showConfirmSwapDialog();
                      },
                child: isLoading
                    ? const SpinKitWaveSpinner(color: Colors.white, size: 30)
                    : const Text('Proceed',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              color: const Color(0xFFdfad52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cryptocurrency Prices',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white30),
                    if (allCryptoPrices.isEmpty && isDataLoaded)
                       Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: SpinKitWaveSpinner(
                              color: Theme.of(context).extension<AppColors>()!.primary, size: 30),
                        ),
                      )
                    else if (allCryptoPrices.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Unable to fetch cryptocurrency prices. Please try again later.',
                          style:
                              TextStyle(color: Colors.redAccent, fontSize: 14),
                        ),
                      )
                    else
                      ...allCryptoPrices.entries.map((entry) {
                        String coin = entry.key;
                        double price = entry.value['price'] ?? 0.0;
                        double change = entry.value['change'] ?? 0.0;
                        bool isSelected = coin == selectedCoinType;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
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
                                              const Icon(Icons.broken_image,
                                                  color: Colors.red, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    coin,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
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
                                          : Colors.white,
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
                      }),
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
}
