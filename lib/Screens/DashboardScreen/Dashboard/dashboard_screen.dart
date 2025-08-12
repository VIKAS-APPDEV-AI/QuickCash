import 'package:carousel_slider/carousel_slider.dart';
import 'package:country_flags/country_flags.dart';
import 'package:excel/excel.dart' as excel_;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/CryptoBuyAndSellScreen/crypto_sell_exchange_screen.dart';
import 'package:quickcash/Screens/CryptoScreen/WalletAddress/model/walletAddressModel.dart';
import 'package:quickcash/Screens/CryptoScreen/WalletAddress/walletAddress_screen.dart';
import 'package:quickcash/Screens/CryptoScreen/utils/CryptoImageUtils.dart';
import 'package:quickcash/Screens/DashboardScreen/AddMoneyScreen/add_money_screen.dart';
import 'package:quickcash/Screens/DashboardScreen/AllAccountsScreen/allAccountsScreen.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListModel.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/DashboardBanner.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/KycStatusWidgets/KycStatusWidgets.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/ThemeToggle.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/TransactionList/transactionListModel.dart';
import 'package:quickcash/Screens/DashboardScreen/DashboardProvider/DashboardProvider.dart';
import 'package:quickcash/Screens/DashboardScreen/ExchangeScreen/exchangeMoneyScreen/exchange_money_screen.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/send_money_screen.dart';
import 'package:quickcash/Screens/HomeScreen/ViewAllTransactionScreen.dart';
import 'package:quickcash/Screens/LoginScreen/login_screen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/DashboardTicketScreen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/tickets_screen.dart';
import 'package:quickcash/Screens/TransactionScreen/TransactionDetailsScreen/transaction_details_screen.dart';
import 'package:quickcash/components/background.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/util/customSnackBar.dart';
import 'package:quickcash/util/file_export_utils.dart';
import 'package:quickcash/utils/themeProvider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import '../../CryptoScreen/BuyAndSell/BuyAndSellScreen/model/buyAndSellListModel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideFromLeftAnimation;
  late Animation<Offset> _slideFromRightAnimation;

  bool _hasShownTokenDialog = false;
  bool _hasReloadedAfterLogin = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideFromLeftAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideFromRightAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialState(context);
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleInitialState(BuildContext context) async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    if (provider.isTokenExpired && !_hasShownTokenDialog) {
      setState(() => _hasShownTokenDialog = true);
      await mTokenExpireDialog(context).then((value) {
        provider.isTokenExpired = false;
        provider.notifyListeners();
        setState(() => _hasShownTokenDialog = false);
      });
    } else if (AuthManager.isLoggedIn() &&
        AuthManager.isFreshLogin() &&
        !_hasReloadedAfterLogin) {
      setState(() => _hasReloadedAfterLogin = true);
      await provider.reloadAfterLogin().then((_) {
        AuthManager.clearFreshLogin();
        provider.notifyListeners();
      }).catchError((e) {
        print("Error in reloadAfterLogin: $e");
      }).whenComplete(() {
        setState(() => _hasReloadedAfterLogin = false);
      });
    }
  }

  String _formatDate(String? dateTime) {
    if (dateTime == null) return 'Date not available';
    DateTime date = DateTime.parse(dateTime);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _getCurrencySymbol(String? currencyCode) {
    if (currencyCode == null || currencyCode.isEmpty) {
      return NumberFormat.simpleCurrency(name: 'USD').currencySymbol;
    }
    final cryptoCurrencies = {
      'BTC',
      'BCH',
      'BNB',
      'ADA',
      'SOL',
      'DOGE',
      'LTC',
      'ETH',
      'SHIB'
    };
    if (cryptoCurrencies.contains(currencyCode.toUpperCase())) {
      return currencyCode.toUpperCase();
    }
    return NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
  }

  Future<bool> mTokenExpireDialog(BuildContext context) async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    return (await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          barrierColor: Theme.of(context).extension<AppColors>()!.primary,
          builder: (context) => AlertDialog(
            title: const Text("Login Again"),
            content: const Text("Token has been expired, Please Login Again!"),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  AuthManager.logout();
                  provider.resetState();
                  Navigator.of(context).pop(true);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: Text("OK",
                    style: TextStyle(
                        color:
                            Theme.of(context).extension<AppColors>()!.primary)),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> _downloadExcel(
      BuildContext context, DashboardProvider provider) async {
    try {
      List<TransactionListDetails> transactions = [];
      
      if (provider.selectedCardType == "fiat") {
        transactions = provider.transactionList.take(4).toList();
      } else if (provider.selectedCardType == "crypto") {
        // Convert crypto transactions to TransactionListDetails format
        transactions = provider.cryptoListData.take(4).map((crypto) {
          return TransactionListDetails(
            transactionId: crypto.coinName?.split('_')[0],
            transactionDate: crypto.date,
            transactionType: crypto.paymentType,
            amount: double.tryParse(crypto.amount?.toString() ?? '0.0'),
            balance: double.tryParse(crypto.noOfCoin ?? '0.0'),
            transactionStatus: crypto.status,
            fromCurrency: crypto.currencyType,
          );
        }).toList();
      }

      final fileName = "dashboard_transactions_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      final filePath = await FileExportUtils.createEnhancedExcelFile(
        transactions: transactions,
        fileName: fileName,
        title: "Dashboard Transaction Report",
      );
      
      await OpenFile.open(filePath);
      CustomSnackBar.showSnackBar(
          context: context,
          message: "Excel downloaded and opened successfully",
          color: Colors.green);
    } catch (e) {
      CustomSnackBar.showSnackBar(
          context: context,
          message: "Failed to download Excel: $e",
          color: Colors.red);
    }
  }

  Future<void> _downloadPDF(
      BuildContext context, DashboardProvider provider) async {
    try {
      List<TransactionListDetails> transactions = [];
      
      if (provider.selectedCardType == "fiat") {
        transactions = provider.transactionList.take(4).toList();
      } else if (provider.selectedCardType == "crypto") {
        // Convert crypto transactions to TransactionListDetails format
        transactions = provider.cryptoListData.take(4).map((crypto) {
          return TransactionListDetails(
            transactionId: crypto.coinName?.split('_')[0],
            transactionDate: crypto.date,
            transactionType: crypto.paymentType,
            amount: double.tryParse(crypto.amount?.toString() ?? '0.0'),
            balance: double.tryParse(crypto.noOfCoin ?? '0.0'),
            transactionStatus: crypto.status,
            fromCurrency: crypto.currencyType,
          );
        }).toList();
      }

      final fileName = "dashboard_transactions_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final filePath = await FileExportUtils.createEnhancedPDFFile(
        transactions: transactions,
        fileName: fileName,
        title: "Dashboard Transaction Report",
      );
      
      await OpenFile.open(filePath);
      CustomSnackBar.showSnackBar(
          context: context,
          message: "PDF downloaded and opened successfully",
          color: Colors.green);
    } catch (e) {
      CustomSnackBar.showSnackBar(
          context: context,
          message: "Failed to download PDF: $e",
          color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>();
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        try {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DashboardTicketScreen()),
                );
              },
              backgroundColor:
                  Theme.of(context).extension<AppColors>()!.primary,
              child: const Icon(Icons.chat, color: Colors.white),
              tooltip: 'Open Chat',
            ),
            body: RefreshIndicator(
              onRefresh: provider.refreshData,
              child: Background(
                child: SingleChildScrollView(
                  child: provider.isLoading
                      ? _buildSkeletonLoading(context)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 25),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: CheckKycStatus(),
                            ),
                            const SizedBox(height: 0),
                            if (AuthManager.getKycStatus() == "completed") ...[
                              SlideTransition(
                                position: _slideFromLeftAnimation,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Welcome ',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${AuthManager.getUserName() ?? 'User'}!',
                                        style: TextStyle(
                                          fontSize: 23,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .extension<AppColors>()!
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SlideTransition(
                                position: _slideFromRightAnimation,
                                child: provider.selectedCardType == "fiat"
                                    ? _buildFiatSection(context, provider)
                                    : provider.selectedCardType == "crypto"
                                        ? _buildCryptoSection(context, provider)
                                        : provider.selectedCardType == "card"
                                            ? _buildCardSection(
                                                context, provider)
                                            : _buildSavingsSection(
                                                context, provider),
                              ),
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: _buildActionButtons(context, provider),
                              ),
                              const SizedBox(height: largePadding),
                              SlideTransition(
                                position: _slideFromLeftAnimation,
                                child:
                                    _buildTransactionSection(context, provider),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          );
        } catch (e, stack) {
          print('Error in Dashboard build: $e\n$stack');
          return const Center(
              child: Text('Something went wrong. Please try again.'));
        }
      },
    );
  }

  Widget _buildSkeletonLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 50,
            width: double.infinity,
            color: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 30,
              width: 200,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(15),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                Container(
                  height: 20,
                  width: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Container(
                  height: 168,
                  width: 340,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Container(
                  height: 5,
                  width: 50,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (index) => Container(
                  width: 50,
                  height: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          _buildSkeletonTransactionSection(context),
        ],
      ),
    );
  }

  Widget _buildFiatSection(BuildContext context, DashboardProvider provider) {
    if (provider.isTokenExpired &&
        provider.accountsListData.isEmpty &&
        provider.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await mTokenExpireDialog(context).then((value) {
          if (value == true) {
            provider.resetState();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        });
      });
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideFromRightAnimation,
        child: Container(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(15),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('FIAT',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .extension<AppColors>()!
                              .primary)),
                  InkWell(
                    onTap: () {
                      provider.setSelectedCardType("crypto");
                      setState(() {});
                    },
                    hoverColor: Theme.of(context)
                        .extension<AppColors>()!
                        .primary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.currency_exchange_outlined,
                        color:
                            Theme.of(context).extension<AppColors>()!.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (provider.isLoading)
                _buildSkeletonFiatCard(context)
              else if (provider.accountsListData.isEmpty &&
                  provider.errorMessage != null &&
                  provider.isTokenExpired == true)
                Center(
                    child: Text(provider.errorMessage!,
                        style: const TextStyle(color: Colors.red)))
              else
                Column(
                  children: [
                    HeroMode(
                      enabled: false,
                      child: CarouselSlider.builder(
                        itemCount: provider.accountsListData.length + 1,
                        options: CarouselOptions(
                          height: 168,
                          autoPlay: false,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) =>
                              provider.updateFiatPage(index),
                        ),
                        itemBuilder: (context, index, realIndex) {
                          if (index == provider.accountsListData.length) {
                            return _buildAddCurrencyCard(context);
                          }
                          final account = provider.accountsListData[index];
                          final isSelected =
                              provider.selectedCardType == "fiat" &&
                                  provider.selectedFiatIndex == index;
                          return _buildFiatCard(
                              context, provider, account, index, isSelected);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedSmoothIndicator(
                      activeIndex: provider.currentFiatPage,
                      count: provider.accountsListData.length,
                      effect: ExpandingDotsEffect(
                          activeDotColor:
                              Theme.of(context).extension<AppColors>()!.primary,
                          dotHeight: 5,
                          dotWidth: 5),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonFiatCard(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 5,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultPadding)),
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 20,
                    color: Colors.white,
                  ),
                  Container(
                    width: 100,
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 20,
                    color: Colors.white,
                  ),
                  Container(
                    width: 80,
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCryptoSection(BuildContext context, DashboardProvider provider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideFromRightAnimation,
        child: Container(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(15),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CRYPTO',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .extension<AppColors>()!
                              .primary)),
                  InkWell(
                    onTap: () {
                      provider.setSelectedCardType("fiat");
                      setState(() {});
                    },
                    hoverColor: Theme.of(context)
                        .extension<AppColors>()!
                        .primary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.currency_exchange_outlined,
                        color:
                            Theme.of(context).extension<AppColors>()!.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (provider.isLoading)
                _buildSkeletonCryptoCard(context)
              else if (provider.walletAddressList.isEmpty &&
                  provider.errorMessage != null &&
                  !provider.isTokenExpired)
                Center(
                    child: Text(provider.errorMessage!,
                        style: const TextStyle(color: Colors.red)))
              else if (provider.walletAddressList.isNotEmpty)
                Column(
                  children: [
                    HeroMode(
                      enabled: false,
                      child: CarouselSlider.builder(
                        itemCount: provider.walletAddressList.length + 1,
                        options: CarouselOptions(
                          height: 130,
                          autoPlay: false,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) =>
                              provider.updateCryptoPage(index),
                        ),
                        itemBuilder: (context, index, realIndex) {
                          if (index == provider.walletAddressList.length) {
                            return _buildAddCryptoCard(context);
                          }
                          final wallet = provider.walletAddressList[index];
                          final isSelected =
                              provider.selectedCardType == "crypto" &&
                                  provider.selectedCryptoIndex == index;
                          return _buildCryptoCard(
                              context, provider, wallet, index, isSelected);
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    AnimatedSmoothIndicator(
                      activeIndex: provider.currentCryptoPage,
                      count: provider.walletAddressList.length,
                      effect: ExpandingDotsEffect(
                          activeDotColor:
                              Theme.of(context).extension<AppColors>()!.primary,
                          dotHeight: 5,
                          dotWidth: 5),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCryptoCard(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 5,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultPadding)),
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 20,
                    color: Colors.white,
                  ),
                  Container(
                    width: 80,
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection(BuildContext context, DashboardProvider provider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(15),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Text('CARD',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).extension<AppColors>()!.primary)),
            SizedBox(height: 10),
            Center(
                child: Text('Card section not implemented yet.',
                    style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsSection(
      BuildContext context, DashboardProvider provider) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(15),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Text('SAVINGS',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).extension<AppColors>()!.primary)),
            SizedBox(height: 10),
            Center(
                child: Text('Savings section not implemented yet.',
                    style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, DashboardProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Colors.white,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: provider.selectedCardType == "crypto"
            ? _buildCryptoActions(context)
            : _buildFiatActions(context, provider),
      ),
    );
  }

  Widget _buildTransactionSection(
      BuildContext context, DashboardProvider provider) {
    return SlideTransition(
      position: _slideFromLeftAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(opacity: _fadeAnimation, child: const HomeBanner()),
          Card(
            color: Colors.white.withOpacity(0.9),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                  color: Theme.of(context)
                      .extension<AppColors>()!
                      .primary
                      .withOpacity(0.3),
                  width: 1),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.01,
            ),
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.02),
                    child: Text(
                      'Download Transaction List -',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color:
                            Theme.of(context).extension<AppColors>()!.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.01),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.download,
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .primary,
                            size: MediaQuery.of(context).size.width * 0.06,
                          ),
                          onPressed: () => _downloadExcel(context, provider),
                          tooltip: 'Download Excel',
                        ),
                        const SizedBox(width: 0),
                        IconButton(
                          icon: Icon(
                            Icons.picture_as_pdf,
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .primary,
                            size: MediaQuery.of(context).size.width * 0.06,
                          ),
                          onPressed: () => _downloadPDF(context, provider),
                          tooltip: 'Download PDF',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.01,
            ),
            child: Card(
              color: Colors.white.withOpacity(0.9),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                    color: Theme.of(context)
                        .extension<AppColors>()!
                        .primary
                        .withOpacity(0.3),
                    width: 1),
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.25,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.01,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: constraints.maxWidth * 0.05,
                                    vertical: constraints.maxHeight * 0.1,
                                  ),
                                  child: Text(
                                    "Recent Transaction -",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .extension<AppColors>()!
                                          .primary,
                                      fontSize: constraints.maxWidth * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: constraints.maxWidth * 0.05,
                                  ),
                                  child: Text(
                                    'Showing recent transaction for the selected Card',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: constraints.maxWidth * 0.03,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Container(
                          //   width: 1,
                          //   height: constraints.maxHeight * 0.6,
                          //   color: AppColors.light.hint,
                          //   margin: EdgeInsets.symmetric(
                          //       horizontal: constraints.maxWidth * 0.02),
                          // ),
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: constraints.maxWidth * 0.02),
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        const ViewAllTransaction(),
                                  ),
                                ),
                                hoverColor: Colors.grey.withOpacity(0.3),
                                splashColor: Colors.white.withOpacity(0.5),
                                highlightColor: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                child: Card(
                                  color: Theme.of(context)
                                      .extension<AppColors>()!
                                      .primary,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: constraints.maxWidth * 0.03,
                                      vertical: constraints.maxHeight * 0.2,
                                    ),
                                    child: Text(
                                      'View All',
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth * 0.035,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: smallPadding),
          if (provider.isTransactionLoading)
            _buildSkeletonTransactionSection(context)
          else if (provider.selectedCardType == "crypto") ...[
            if (provider.errorMessage != null && !provider.isTokenExpired)
              SizedBox(
                height: 190,
                child: Card(
                  color: Theme.of(context).extension<AppColors>()!.primary,
                  elevation: 4,
                  child: Center(
                      child: Text(provider.errorMessage!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16))),
                ),
              )
            else if (provider.filteredCryptoTransactions.isEmpty)
              SizedBox(
                height: 140,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Card(
                    color: Theme.of(context).extension<AppColors>()!.primary,
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset('assets/lottie/NoTransactions.json',
                                height: 100),
                            const SizedBox(width: 10),
                            const Text("You haven’t made any transactions yet",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Column(
                children: provider.filteredCryptoTransactions
                    .take(4)
                    .map((transaction) =>
                        _buildCryptoTransactionCard(context, transaction))
                    .toList(),
              ),
          ] else ...[
            if (provider.errorTransactionMessage != null &&
                !provider.isTokenExpired)
              SizedBox(
                height: 140,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Card(
                    color: Theme.of(context).extension<AppColors>()!.primary,
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset('assets/lottie/NoTransactions.json',
                                height: 87),
                            const SizedBox(width: 10),
                            const Text("You haven’t made any transactions yet",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (provider.transactionList.isEmpty)
              SizedBox(
                height: 140,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Card(
                    color: Theme.of(context).extension<AppColors>()!.primary,
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset('assets/lottie/NoTransactions.json',
                                height: 100),
                            const SizedBox(width: 10),
                            const Text("You haven’t made any transactions yet",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Column(
                children: provider.transactionList
                    .take(4)
                    .map((transaction) =>
                        _buildTransactionCard(context, transaction, provider))
                    .toList(),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeletonTransactionSection(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            height: 100,
            width: double.infinity,
            color: Colors.white,
          ),
          Card(
            color: Colors.white.withOpacity(0.9),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                  color: Theme.of(context)
                      .extension<AppColors>()!
                      .primary
                      .withOpacity(0.3),
                  width: 1),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.01,
            ),
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    color: Colors.white,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 30,
                        height: 30,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.01,
            ),
            child: Card(
              color: Colors.white.withOpacity(0.9),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                    color: Theme.of(context)
                        .extension<AppColors>()!
                        .primary
                        .withOpacity(0.3),
                    width: 1),
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.width * 0.25,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.01,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 200,
                              height: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.black,
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          width: 80,
                          height: 40,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: smallPadding),
          Column(
            children: List.generate(
              3,
              (index) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 100,
                              height: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 80,
                            height: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 80,
                            height: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCurrencyCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          CupertinoPageRoute(builder: (context) => const AllAccountsScreen())),
      child: Card(
        elevation: 5,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultPadding)),
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.add_circle_outline,
                      size: 35,
                      color: Theme.of(context).extension<AppColors>()!.primary),
                  Text('Add Currency',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .extension<AppColors>()!
                              .primary)),
                ],
              ),
              SizedBox(height: largePadding),
              Text('XXXXXXXX',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).extension<AppColors>()!.primary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddCryptoCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => const WalletAddressScreen())),
      child: Card(
        elevation: 5,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultPadding)),
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.add_circle_outline,
                      size: 35,
                      color: Theme.of(context).extension<AppColors>()!.primary),
                  Text('Add Crypto',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .extension<AppColors>()!
                              .primary)),
                ],
              ),
              SizedBox(height: largePadding),
              Text('XXXXXXXX',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).extension<AppColors>()!.primary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiatCard(BuildContext context, DashboardProvider provider,
      AccountsListsData account, int index, bool isSelected) {
    String getCountryCode(String? country, String? currency) {
      if (country != null &&
          country.length == 2 &&
          RegExp(r'^[A-Z]{2}$').hasMatch(country)) {
        return country.toUpperCase();
      }
      switch (currency?.toUpperCase()) {
        case 'EUR':
          return 'DE';
        case 'USD':
          return 'US';
        case 'GBP':
          return 'GB';
        default:
          return 'US';
      }
    }

    return GestureDetector(
      onTap: () => provider.selectFiatCard(index, account),
      child: Card(
        elevation: 5,
        color: provider.selectedCardType == "fiat" &&
                provider.selectedFiatIndex == index
            ? Theme.of(context).extension<AppColors>()!.primary
            : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultPadding)),
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (account.currency?.toUpperCase() == 'EUR')
                    getEuFlagWidget()
                  else
                    CountryFlag.fromCountryCode(
                      width: 35,
                      height: 35,
                      getCountryCode(account.country, account.currency),
                      shape: const Circle(),
                    ),
                  Text(
                    _getCurrencySymbol(account.currency),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context)
                                .extension<AppColors>()!
                                .primary),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${account.currency}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context)
                                .extension<AppColors>()!
                                .primary),
                  ),
                  Text(
                    "${account.iban}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context)
                                .extension<AppColors>()!
                                .primary),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Balance",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context)
                                .extension<AppColors>()!
                                .primary),
                  ),
                  Row(
                    children: [
                      Text(
                        _getCurrencySymbol(account.currency),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                      ),
                      Text(
                        account.amount != null && account.amount! < 0
                            ? "0.0000"
                            : "${account.amount?.toStringAsFixed(3)}",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCryptoCard(BuildContext context, DashboardProvider provider,
      WalletAddressListsData wallet, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => provider.selectCryptoCard(index),
      child: Card(
        elevation: 5,
        color: provider.selectedCardType == "crypto" &&
                provider.selectedCryptoIndex == index
            ? Color(0xFF9fce63)
            : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultPadding)),
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: ImageUtils.getImageForTransferType(
                          wallet.coin!.split('_')[0]),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(
                        color:
                            Theme.of(context).extension<AppColors>()!.primary,
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  Text(
                    wallet.coin!.split('_')[0],
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context)
                                .extension<AppColors>()!
                                .primary),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Balance",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context)
                                .extension<AppColors>()!
                                .primary),
                  ),
                  Text(
                    wallet.noOfCoins!,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context)
                                .extension<AppColors>()!
                                .primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCryptoActions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        const SizedBox(height: smallPadding),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth > 600 ? 140 : screenWidth * 0.36,
              child: FloatingActionButton.extended(
                heroTag: 'Crypto_buy_Sell',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CryptoBuyAnsSellScreen())),
                label: const Text('Buy/SELL/Swap',
                    style: TextStyle(color: Colors.white, fontSize: 12 )),
                icon: const Icon(Icons.send, color: Colors.white),
                backgroundColor:
                    Theme.of(context).extension<AppColors>()!.primary,
              ),
            ),
            const SizedBox(width: 15),
            SizedBox(
              width: screenWidth > 600 ? 140 : screenWidth * 0.40,
              child: FloatingActionButton.extended(
                heroTag: 'crypto_wallet_address',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WalletAddressScreen())),
                label: const Text('WALLET ADDRESS',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                icon: const Icon(Icons.send, color: Colors.white),
                backgroundColor:
                    Theme.of(context).extension<AppColors>()!.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiatActions(BuildContext context, DashboardProvider provider) {
    return SlideTransition(
      position: _slideFromRightAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 10),
          _buildActionButton(
            context,
            label: 'Add Money',
            icon: Icons.add,
            heroTag: 'fiat_add_Money',
            onPressed: () {
              if (provider.amountExchange == null ||
                  provider.selectedCardType != "fiat") {
                CustomSnackBar.showSnackBar(
                  context: context,
                  message: "Please select a currency from the FIAT section",
                  color: Colors.red,
                );
                return;
              }
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => AddMoneyScreen(
                    accountName: provider.accountName ?? 'N/A',
                    accountId: provider.accountIdExchange ?? '',
                    country: provider.countryExchange ?? '',
                    currency: provider.currencyExchange ?? '',
                    iban: provider.ibanExchange ?? '',
                    status: provider.statusExchange,
                    amount: provider.amountExchange ?? 0.0,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            context,
            label: 'Exchange Money',
            icon: Icons.currency_exchange,
            heroTag: 'fiat_exchange',
            onPressed: () {
              if (provider.amountExchange == null ||
                  provider.selectedCardType != "fiat") {
                CustomSnackBar.showSnackBar(
                  context: context,
                  message:
                      "Exchange Money Can't Work Right Now Because Fiat Data Is Null",
                  color: Colors.red,
                );
                return;
              }
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ExchangeMoneyScreen(
                    accountId: provider.accountIdExchange,
                    country: provider.countryExchange,
                    currency: provider.currencyExchange,
                    iban: provider.ibanExchange,
                    status: provider.statusExchange,
                    amount: provider.amountExchange,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            context,
            label: 'Send Money',
            icon: Icons.send,
            heroTag: 'Fiat_sendMoney',
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const SendMoneyScreen(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            context,
            label: 'All Account',
            icon: Icons.account_balance_wallet,
            heroTag: 'fiat_All_Accounts',
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const AllAccountsScreen(),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required String label,
      required IconData icon,
      required String heroTag,
      required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 80,
        margin: const EdgeInsets.symmetric(vertical: 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Theme.of(context).extension<AppColors>()!.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context,
      TransactionListDetails transaction, DashboardProvider provider) {
    String currencySymbol = _getCurrencySymbolForBalance(transaction);
    String amountDisplay = _getAmountDisplay(transaction);
    Color amountColor = _getAmountColor(transaction);
    String formattedDate = _formatDate(transaction.transactionDate);

    String? extraType = transaction.extraType?.toLowerCase();
    String transType = transaction.transactionType?.toLowerCase() ?? '';
    String fullType = "$extraType-$transType";

    IconData? transactionIcon;
    Color iconColor = Colors.grey;

    switch (fullType) {
      case 'credit-add money':
        transactionIcon = Icons.arrow_forward;
        iconColor = Colors.green;
        break;
      case 'debit-wallet to card':
        transactionIcon = Icons.arrow_back;
        iconColor = Colors.red;
        break;
      case 'credit-exchange':
        transactionIcon = Icons.sync;
        iconColor = Colors.green;
        break;
      case 'debit-crypto':
        transactionIcon = Icons.arrow_back;
        iconColor = Colors.red;
        break;
      case 'credit-crypto':
        transactionIcon = Icons.arrow_back;
        iconColor = Colors.red;
        break;
      case 'debit-exchange':
        transactionIcon = Icons.sync;
        iconColor = Colors.red;
        break;
      case 'debit-beneficiary transfer money':
        transactionIcon = Icons.sync;
        iconColor = Colors.red;
        break;
      case 'debit-external transfer':
        transactionIcon = Icons.sync;
        iconColor = Colors.red;
        break;
      default:
        transactionIcon = Icons.help_outline;
        iconColor = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TransactionDetailPage(transactionId: transaction.trxId ?? ''),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  transactionIcon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trans Id - ${transaction.transactionId ?? 'N/A'}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountDisplay,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                    child: Text(
                      '$currencySymbol ${transaction.balance?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        transaction.transactionStatus == 'succeeded' ||
                                transaction.transactionStatus == 'Complete' ||
                                transaction.transactionStatus == 'Success'
                            ? Icons.check_circle
                            : transaction.transactionStatus == 'pending'
                                ? Icons.info
                                : Icons.cancel,
                        color: transaction.transactionStatus == 'succeeded' ||
                                transaction.transactionStatus == 'Complete' ||
                                transaction.transactionStatus == 'Success'
                            ? Colors.green
                            : transaction.transactionStatus == 'pending'
                                ? Colors.orange
                                : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        transaction.transactionStatus == 'succeeded' ||
                                transaction.transactionStatus == 'Complete' ||
                                transaction.transactionStatus == 'Success'
                            ? 'Success'
                            : transaction.transactionStatus == 'pending'
                                ? 'Pending'
                                : 'Failed',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: transaction.transactionStatus == 'succeeded' ||
                                  transaction.transactionStatus == 'Complete' ||
                                  transaction.transactionStatus == 'Success'
                              ? Colors.green
                              : transaction.transactionStatus == 'pending'
                                  ? Colors.orange
                                  : Colors.red,
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
    );
  }

  Widget _buildCryptoTransactionCard(
      BuildContext context, CryptoListsData transaction) {
    String formattedDate = _formatDate(transaction.date);
    String currencySymbol = _getCurrencySymbol(transaction.currencyType);
    Color statusColor = _getStatusColor(transaction.status ?? "pending");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: ImageUtils.getImageForTransferType(
                            transaction.coinName!.split('_')[0]),
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(
                          color:
                              Theme.of(context).extension<AppColors>()!.primary,
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            transaction.side?.toLowerCase() == 'buy'
                                ? "Buy"
                                : "Sell",
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        Text(formattedDate,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                Text(
                    "$currencySymbol${double.tryParse(transaction.amount?.toString() ?? '0.00')?.toStringAsFixed(2) ?? '0.00'}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text("No of Coins:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).extension<AppColors>()!.black)),
                Text(transaction.noOfCoin ?? "N/A",
                    style:  TextStyle(fontSize: 16, color: Theme.of(context).extension<AppColors>()!.black,)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4))
      ],
      border: Border.all(color: Colors.grey.shade300, width: 1),
    );
  }

  String _getAmountDisplay(TransactionListDetails transaction) {
    String transType = transaction.transactionType?.toLowerCase() ?? '';
    String extraType = transaction.extraType?.toLowerCase() ?? '';
    String info = transaction.info?.toLowerCase() ?? '';
    String currencySymbol = _getCurrencySymbol(transaction.fromCurrency);

    double displayAmount = transaction.amount ?? 0.0;
    double fees = transaction.fees ?? 0.0;
    double billAmount = fees + displayAmount;

    if (transType == 'Add money' && extraType == 'credit') {
      return "+${_getCurrencySymbol(transaction.to_currency)}${transaction.conversionAmounttext ?? '0.00'}";
    } else if (info == 'crypto sell transaction') {
      return "+$currencySymbol${transaction.amount?.toStringAsFixed(2)}";
    } else if (transType == 'crypto' ||
        (extraType == 'credit' &&
            _isCryptoCurrency(transaction.fromCurrency))) {
      return "-${_getCurrencySymbol(transaction.to_currency)}${billAmount.toStringAsFixed(2)}";
    } else if (extraType == 'credit') {
      return "+${transaction.conversionAmounttext ?? '0.00'}";
    } else if (transType == 'external transfer' && extraType == 'debit') {
      return "-$currencySymbol${billAmount.toStringAsFixed(2)}";
    } else if (transType == 'beneficiary transfer money') {
      return "-$currencySymbol${billAmount.toStringAsFixed(2)}";
    } else if (transType == 'exchange' && extraType == 'debit') {
      return "-$currencySymbol${billAmount.toStringAsFixed(2)}";
    } else if (info == 'Crypto buy Transaction') {
      return "-$currencySymbol${billAmount.toStringAsFixed(2)}";
    } else if (transType == 'wallet to card') {
      return "-$currencySymbol${displayAmount.toStringAsFixed(2)}";
    }
    return "$currencySymbol${displayAmount.toStringAsFixed(2)}";
  }

  Color _getAmountColor(TransactionListDetails transaction) {
    String transType = transaction.transactionType?.toLowerCase() ?? '';
    String extraType = transaction.extraType?.toLowerCase() ?? '';
    String info = transaction.info?.toLowerCase() ?? '';

    if (info == 'crypto sell transaction') {
      return Colors.green;
    } else if (extraType == 'credit') {
      return Colors.green;
    } else if (extraType == 'debit' ||
        transType == 'crypto' ||
        _isCryptoCurrency(transaction.fromCurrency)) {
      return Colors.red;
    }
    return Colors.green;
  }

  bool _isCryptoCurrency(String? currencyCode) {
    if (currencyCode == null || currencyCode.isEmpty) return false;
    final cryptoCurrencies = {
      'BTC',
      'BCH',
      'BNB',
      'ADA',
      'SOL',
      'DOGE',
      'LTC',
      'ETH',
      'SHIB'
    };
    return cryptoCurrencies.contains(currencyCode.toUpperCase());
  }

  String _getCurrencySymbolForBalance(TransactionListDetails transaction) {
    String transType = transaction.transactionType?.toLowerCase() ?? '';
    String extraType = transaction.extraType?.toLowerCase() ?? '';
    String info = transaction.info?.toLowerCase() ?? '';

    if (extraType == 'credit' &&
        transType == 'crypto' &&
        info == 'crypto sell transaction') {
      return _getCurrencySymbol(transaction.fromCurrency);
    } else if (extraType == 'credit' &&
        (transType == 'Add Money' ||
            transType == 'exchange' ||
            transType == 'crypto')) {
      return _getCurrencySymbol(transaction.to_currency);
    } else if (extraType == 'debit' ||
        transType == 'crypto' ||
        _isCryptoCurrency(transaction.fromCurrency)) {
      return _getCurrencySymbol(transaction.fromCurrency);
    }
    return _getCurrencySymbol(transaction.fromCurrency);
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
        return Theme.of(context).extension<AppColors>()!.primary;
    }
  }

  Widget getEuFlagWidget() {
    return Container(
      width: 35,
      height: 35,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: AssetImage('assets/images/EuroFlag.png'), fit: BoxFit.cover),
      ),
    );
  }
}

class GaugeContainer extends StatelessWidget {
  final Widget child;
  const GaugeContainer({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        width: 210,
        height: 112,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 4))
          ],
        ),
        child: child,
      );
}

class GaugeWidget extends StatelessWidget {
  final String label;
  final double currentAmount;
  final double totalAmount;
  final Color color;
  final IconData icon;

  const GaugeWidget({
    super.key,
    required this.label,
    required this.currentAmount,
    required this.totalAmount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (currentAmount / totalAmount).clamp(0.0, 1.0);
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
            size: const Size(100, 120),
            painter: GaugePainter(percentage: percentage, color: color)),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: largePadding),
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 0),
            Text(label,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            Text('\$${currentAmount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ],
    );
  }
}

class GaugePainter extends CustomPainter {
  final double percentage;
  final Color color;

  GaugePainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40.0;
    final Paint progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40.0;

    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.width / 2),
        pi,
        pi,
        false,
        backgroundPaint);
    canvas.drawArc(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.width / 2),
        pi,
        pi * percentage,
        false,
        progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
