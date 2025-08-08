import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:quickcash/Screens/CardsScreen/CardListScreen/cards_list_screen.dart';
import 'package:quickcash/Screens/CardsScreen/FreezeCard/API/FreezeCardAPI.dart';
import 'package:quickcash/Screens/CardsScreen/FreezeCard/Model/freezeCardModel.dart';
import 'package:quickcash/Screens/CardsScreen/LoadCard/API/FeeTypeAPI.dart';
import 'package:quickcash/Screens/CardsScreen/LoadCard/API/LoadCardApi.dart';
import 'package:quickcash/Screens/CardsScreen/LoadCard/SuccessScreen.dart';
import 'package:quickcash/Screens/CardsScreen/RequestPhysicalCard.dart';
import 'package:quickcash/Screens/CardsScreen/addCardModel/addCardApi.dart';
import 'package:quickcash/Screens/CardsScreen/cardListModel/cardListApi.dart';
import 'package:quickcash/Screens/CardsScreen/cardListModel/cardListModel.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListApi.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListModel.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/PayRecipientsScree/exchangeCurrencyModel/CurrencyExchangeModel.dart';
import 'package:quickcash/Screens/DashboardScreen/SendMoneyScreen/PayRecipientsScree/exchangeCurrencyModel/NewCurrencyExchangeAPI.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/model/currencyApiModel/Model/currencyModel.dart';
import 'package:quickcash/model/currencyApiModel/Services/currencyApi.dart';
import 'package:quickcash/util/AnimatedContainerWidget.dart';
import 'package:quickcash/util/apiConstants.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/util/currency_utils.dart';
import 'package:quickcash/util/customSnackBar.dart';

// Floating Icon Widget
class FloatingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const FloatingIcon({
    required this.icon,
    required this.color,
    required this.size,
    super.key,
  });

  @override
  State<FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<FloatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: Icon(
            widget.icon,
            color: widget.color,
            size: widget.size,
          ),
        );
      },
    );
  }
}

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardListApi _cardListApi = CardListApi();
  final AccountsListApi _accountsListApi = AccountsListApi();
  final LoadCardApi _loadCardApi = LoadCardApi();
  final ToggleFreezeCardApi _toggleFreezeCardApi = ToggleFreezeCardApi();
  List<CardListsData> cardsListData = [];
  Map<String, bool> cardFreezeStatus = {};
  int _currentCardIndex = 0;

  bool isLoading = false;
  String? errorMessage;

  void _loadDataBottomSheet(BuildContext context, String cardName,
      String cardNumber, int oldPassword, String cardCurrency, String cardId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return _LoadCardBottomSheet(
          cardName: cardName,
          cardNumber: cardNumber,
          cardPin: oldPassword,
          cardCurrency: cardCurrency,
          cardId: cardId,
          accountsListApi: _accountsListApi,
          loadCardApi: _loadCardApi,
        );
      },
    );
  }

  void _showFreezeConfirmationDialog(BuildContext context, String cardId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.white,
        title: Text(
          'Confirm Action',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).extension<AppColors>()!.primary,
            fontSize: 20,
          ),
        ),
        content: Text(
          cardFreezeStatus[cardId] ?? false
              ? 'Are you sure you want to unfreeze this card?'
              : 'Are you sure you want to freeze this card? Once frozen, the card cannot be used for 24 hours.',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _freezeCard(cardId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 3,
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}

  Future<void> _freezeCard(String cardId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response =
          await _toggleFreezeCardApi.toggleFreezeCardApi(cardId: cardId);
      final freezeResponse = FreezeCardResponse.fromJson(response);

      if (freezeResponse.status == 200 || freezeResponse.status == 201) {
        setState(() {
          cardFreezeStatus[cardId] = freezeResponse.data?.isFrozen ?? false;
          isLoading = false;
        });
        String actionMessage = cardFreezeStatus[cardId]!
            ? 'Card frozen successfully'
            : 'Card unfrozen successfully';
        CustomSnackBar.showSnackBar(
          context: context,
          message: freezeResponse.message.isNotEmpty
              ? freezeResponse.message
              : actionMessage,
          color: Colors.green,
        );
        await mCardList();
      } else {
        setState(() {
          isLoading = false;
          errorMessage = freezeResponse.message.isNotEmpty
              ? freezeResponse.message
              : 'Failed to toggle card freeze/unfreeze';
        });
        print(errorMessage);
        CustomSnackBar.showSnackBar(
          context: context,
          message: errorMessage!,
          color: Colors.red,
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error toggling card status: $error';
      });
      print(errorMessage);
      CustomSnackBar.showSnackBar(
        context: context,
        message: errorMessage!,
        color: Colors.red,
      );
    }
  }

  void _showTransactionLimitBottomSheet(BuildContext context, String cardId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return _TransactionLimitBottomSheet(cardId: cardId);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    cardFreezeStatus = {};
    mCardList();
  }

  Future<void> mCardList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _cardListApi.cardListApi();

      if (response.cardList != null && response.cardList!.isNotEmpty) {
        setState(() {
          cardsListData = response.cardList!;
          for (var card in cardsListData) {
            cardFreezeStatus[card.cardId!] = card.isFrozen ?? false;
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Card Found';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching card list: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Virtual Cards",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: mCardList,
        color: Theme.of(context).extension<AppColors>()!.primary,
        backgroundColor: Colors.white,
        child: isLoading
            ? Center(
                child: SpinKitWaveSpinner(
                    color: Theme.of(context).extension<AppColors>()!.primary,
                    size: 75),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 160,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .primary,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(defaultPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: defaultPadding),
                                const SizedBox(height: 0.0),
                                cardsListData.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No Cards Available',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .extension<AppColors>()!
                                                  .primary),
                                        ),
                                      )
                                    : AnimatedContainerWidget(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        slideCurve: Easing.linear,
                                        child: CarouselSlider(
                                          options: CarouselOptions(
                                            height: 250.0,
                                            enlargeCenterPage: true,
                                            autoPlay: false,
                                            aspectRatio: 16 / 9,
                                            viewportFraction: 0.8,
                                            initialPage: 0,
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                _currentCardIndex = index;
                                              });
                                            },
                                          ),
                                          items: cardsListData.map((card) {
                                            return Builder(
                                              builder: (BuildContext context) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 20.0),
                                                  child: CardItem(
                                                    card: card,
                                                    isFrozen: cardFreezeStatus[
                                                            card.cardId!] ??
                                                        false,
                                                  ),
                                                );
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AnimatedContainerWidget(
                            slideBegin: const Offset(2.0, 0.0),
                            duration: const Duration(milliseconds: 950),
                            child: _buildButton(
                              icon: Icons.lock,
                              label: 'Load\nCard',
                              onTap: () {
                                if (cardsListData.isNotEmpty) {
                                  final currentCard =
                                      cardsListData[_currentCardIndex];
                                  final isCardFrozen =
                                      cardFreezeStatus[currentCard.cardId!] ??
                                          false;
                                  if (!isCardFrozen) {
                                    _loadDataBottomSheet(
                                      context,
                                      currentCard.cardHolderName!,
                                      currentCard.cardNumber!,
                                      currentCard.cardPin!,
                                      currentCard.currency!,
                                      currentCard.cardId!,
                                    );
                                  } else {
                                    CustomSnackBar.showSnackBar(
                                      context: context,
                                      message:
                                          'This card is frozen and cannot be loaded',
                                      color: Colors.red,
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('No card available to load')),
                                  );
                                }
                              },
                            ),
                          ),
                          AnimatedContainerWidget(
                            child: _buildButton(
                              icon: Icons.ac_unit,
                              label: cardsListData.isNotEmpty
                                  ? (cardFreezeStatus[
                                              cardsListData[_currentCardIndex]
                                                  .cardId!] ??
                                          false)
                                      ? 'Unfreeze\nCard'
                                      : 'Freeze\nCard'
                                  : 'Freeze\nCard',
                              onTap: () {
                                if (cardsListData.isNotEmpty) {
                                  final currentCard =
                                      cardsListData[_currentCardIndex];
                                  if (currentCard.cardId == null) {
                                    CustomSnackBar.showSnackBar(
                                      context: context,
                                      message: 'Card ID is missing',
                                      color: Colors.red,
                                    );
                                    return;
                                  }
                                  _showFreezeConfirmationDialog(
                                      context, currentCard.cardId!);
                                } else {
                                  CustomSnackBar.showSnackBar(
                                    context: context,
                                    message: 'No card available to freeze',
                                    color: Colors.red,
                                  );
                                }
                              },
                            ),
                          ),
                          AnimatedContainerWidget(
                            slideBegin: const Offset(2.0, 0.0),
                            duration: const Duration(milliseconds: 950),
                            child: _buildButton(
                              icon: Icons.settings,
                              label: 'Transaction\nLimits',
                              onTap: () {
                                if (cardsListData.isNotEmpty) {
                                  final currentCard =
                                      cardsListData[_currentCardIndex];

                                  if (currentCard.cardId == null) {
                                    CustomSnackBar.showSnackBar(
                                      context: context,
                                      message: 'Card ID is missing',
                                      color: Colors.red,
                                    );
                                    return;
                                  }

                                  final isCardFrozen =
                                      cardFreezeStatus[currentCard.cardId!] ??
                                          false;
                                  if (isCardFrozen) {
                                    CustomSnackBar.showSnackBar(
                                      context: context,
                                      message:
                                          'This card is frozen and cannot have transaction limits set',
                                      color: Colors.red,
                                    );
                                    return;
                                  }

                                  _showTransactionLimitBottomSheet(
                                      context, currentCard.cardId!);
                                } else {
                                  CustomSnackBar.showSnackBar(
                                    context: context,
                                    message: 'No card available to set limits',
                                    color: Colors.red,
                                  );
                                }
                              },
                            ),
                          ),
                          AnimatedContainerWidget(
                            child: _buildButton(
                              icon: Icons.credit_card,
                              label: 'Manage\nCard',
                              onTap: () {
                                if (AuthManager.getKycStatus() == "completed") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CardsListScreen()),
                                  );
                                } else {
                                  CustomSnackBar.showSnackBar(
                                      context: context,
                                      message: "Your KYC is not completed",
                                      color: Theme.of(context)
                                          .extension<AppColors>()!
                                          .primary);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (cardsListData.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding,
                          vertical: defaultPadding * 0.5,
                        ),
                        child: AnimatedContainerWidget(
                          duration: const Duration(milliseconds: 500),
                          slideCurve: Curves.easeInOut,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate responsive font sizes and padding
                              final double screenWidth =
                                  MediaQuery.of(context).size.width;
                              final double fontScale = screenWidth < 360
                                  ? 0.9
                                  : screenWidth > 600
                                      ? 1.2
                                      : 1.0;
                              final double cardPadding =
                                  screenWidth < 360 ? 12.0 : 20.0;
                              final double iconSize = screenWidth < 360
                                  ? 16.0
                                  : screenWidth > 600
                                      ? 24.0
                                      : 18.0;

                              return Card(
                                elevation: 0, // Flat for transparency
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .extension<AppColors>()!
                                        .primary
                                        .withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                ),
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: min(screenWidth * 0.95,
                                        600), // Cap max width for large screens
                                    minWidth:
                                        280, // Ensure minimum width for small screens
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(
                                        0.1), // Glassmorphism effect
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 5,
                                          sigmaY: 5), // Frosted glass effect
                                      child: Padding(
                                        padding: EdgeInsets.all(cardPadding),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Card Details',
                                                  style: TextStyle(
                                                    fontSize: 18 * fontScale,
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black87,
                                                    letterSpacing: 0.8,
                                                    fontFamily: 'Roboto',
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(
                                                  Icons.credit_card_outlined,
                                                  color: Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Theme.of(context)
                                                      .extension<AppColors>()!
                                                      .primary,
                                                  size: 22 * fontScale,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: cardPadding * 0.8),
                                            Wrap(
                                              spacing: cardPadding,
                                              runSpacing: cardPadding * 0.8,
                                              alignment:
                                                  WrapAlignment.spaceBetween,
                                              children: [
                                                _buildDetailItem(
                                                  icon: Icons
                                                      .account_balance_wallet_outlined,
                                                  label: 'Balance',
                                                  value:
                                                      '${cardsListData[_currentCardIndex].currency} ${cardsListData[_currentCardIndex].balance?.toStringAsFixed(2) ?? '0.00'}',
                                                  fontScale: fontScale,
                                                  iconSize: iconSize,
                                                ),
                                                _buildDetailItem(
                                                  icon: Icons.today_outlined,
                                                  label: 'Daily Limit',
                                                  value:
                                                      '${cardsListData[_currentCardIndex].currency} ${cardsListData[_currentCardIndex].dailyLimit?.toStringAsFixed(2) ?? '0.00'}',
                                                  fontScale: fontScale,
                                                  iconSize: iconSize,
                                                ),
                                                _buildDetailItem(
                                                  icon: Icons
                                                      .calendar_month_outlined,
                                                  label: 'Monthly Limit',
                                                  value:
                                                      '${cardsListData[_currentCardIndex].currency} ${cardsListData[_currentCardIndex].monthlyLimit?.toStringAsFixed(2) ?? '0.00'}',
                                                  fontScale: fontScale,
                                                  iconSize: iconSize,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 30.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Card(
                        color: Colors.white70,
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AnimatedContainerWidget(
                                slideCurve: Easing.standard,
                                child: Text(
                                  'Physical Card',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              AnimatedContainerWidget(
                                fadeCurve: Easing.standard,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildBulletPoint(
                                              'Make easy payments without having to carry cash'),
                                          _buildBulletPoint(
                                              'Make easy withdrawals from anywhere in the world'),
                                          _buildBulletPoint(
                                              'Make travelling and shopping easy and fun with just one swipe'),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 120.0,
                                        margin:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Image.asset(
                                            'assets/images/PhysicalCard.png'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: SizedBox(
                                    width: 250,
                                    height: 54,
                                    child: AnimatedContainerWidget(
                                      fadeCurve: Easing.standardDecelerate,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  RequestPhysicalCard(
                                                      onCardAdded: () {}),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .extension<AppColors>()!
                                              .primary,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Request Physical Card',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 8.0),
                                            FloatingIcon(
                                              icon: Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48.0),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required double fontScale,
    required double iconSize,
  }) {
    return AnimatedContainerWidget(
      duration: const Duration(milliseconds: 300),
      slideCurve: Curves.easeInOut,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 150, // Limit width to prevent overflow on small screens
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context)
                      .extension<AppColors>()!
                      .primary
                      .withOpacity(0.6),
                  size: iconSize,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13 * fontScale,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15 * fontScale,
                color: Theme.of(context).extension<AppColors>()!.primary,
                fontWeight: FontWeight.w700,
                fontFamily: 'Roboto',
              ),
              overflow: TextOverflow.ellipsis, // Handle long text gracefully
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      splashColor:
          Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.3),
      highlightColor:
          Theme.of(context).extension<AppColors>()!.primary.withOpacity(0.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).extension<AppColors>()!.primary,
            ),
            child: Icon(
              icon,
              size: 30.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.0,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void mAddCardBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddCardBottomSheet(
          onCardAdded: mCardList,
        );
      },
    );
  }
}

class _LoadCardBottomSheet extends StatefulWidget {
  final String cardName;
  final String cardNumber;
  final int cardPin;
  final String cardCurrency;
  final String cardId;
  final AccountsListApi accountsListApi;
  final LoadCardApi loadCardApi;

  const _LoadCardBottomSheet({
    required this.cardName,
    required this.cardNumber,
    required this.cardPin,
    required this.cardCurrency,
    required this.cardId,
    required this.accountsListApi,
    required this.loadCardApi,
  });

  @override
  State<_LoadCardBottomSheet> createState() => _LoadCardBottomSheetState();
}

class _LoadCardBottomSheetState extends State<_LoadCardBottomSheet> {
  final FeeTypeApi _feeTypeApi = FeeTypeApi();
  double depositFeePercent = 0.0;

  String? selectedCurrency;
  String? selectedAccountId;
  List<AccountsListsData> accountsList = [];
  double availableBalance = 0.0;
  double amount = 0.0;
  double fee = 0.0;
  double conversionAmount = 0.0;
  bool isLoading = false;
  String? errorMessage;
  final TextEditingController _amountController = TextEditingController();
  final ExchangeCurrencyApiNew _exchangeCurrencyApi = ExchangeCurrencyApiNew();

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
    _amountController.addListener(_updateConversion);
    _fetchDepositFee();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchDepositFee() async {
    try {
      final feePercent = await _feeTypeApi.getDepositFeePercent();
      setState(() {
        depositFeePercent = feePercent;
        _updateConversion();
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Fee fetch error: $e';
      });
    }
  }

  Future<void> _fetchAccounts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await widget.accountsListApi.accountsListApi();
      if (response.accountsList != null && response.accountsList!.isNotEmpty) {
        setState(() {
          accountsList = response.accountsList!;
          selectedCurrency = accountsList.first.currency;
          selectedAccountId = accountsList.first.accountId;
          availableBalance = accountsList.first.amount ?? 0.0;
          isLoading = false;
          _updateConversion();
        });
      } else {
        setState(() {
          errorMessage = 'No accounts available';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  Future<double> _getConversionRate(String from, String to) async {
    try {
      final request = ExchangeCurrencyRequestnew(
        fromCurrency: from,
        toCurrency: to,
        amount: 1.0,
      );
      final response =
          await _exchangeCurrencyApi.exchangeCurrencyApiNew(request);
      return response.result?.convertedAmount ?? 1.0;
    } catch (e) {
      setState(() {
        errorMessage = 'Conversion error: $e';
      });
      return 1.0;
    }
  }

  Future<void> _updateConversion() async {
    if (_amountController.text.isNotEmpty && selectedCurrency != null) {
      final inputAmount = double.tryParse(_amountController.text) ?? 0.0;
      final rate =
          await _getConversionRate(selectedCurrency!, widget.cardCurrency);
      final feeAmount = inputAmount * depositFeePercent / 100;
      final converted = inputAmount * rate;

      setState(() {
        amount = inputAmount;
        fee = feeAmount;
        conversionAmount = converted;
      });
    } else {
      setState(() {
        amount = 0.0;
        fee = 0.0;
        conversionAmount = 0.0;
      });
    }
  }

  Future<void> _loadCard() async {
    if (amount <= 0 || selectedCurrency == null || selectedAccountId == null) {
      CustomSnackBar.showSnackBar(
          context: context,
          message: "Please enter a valid amount and select an account",
          color: Colors.red);
      return;
    }

    if (amount > availableBalance) {
      CustomSnackBar.showSnackBar(
          context: context, message: "Insufficient balance", color: Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await widget.loadCardApi.loadCardApi(
        amount: amount,
        fee: fee,
        sourceAccountId: selectedAccountId!,
        cardId: widget.cardId,
        fromCurrency: selectedCurrency!,
        toCurrency: widget.cardCurrency,
        conversionAmount: conversionAmount,
      );

      if (response['transaction']?['info'] == "Wallet to Card Balance Load") {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(response: response),
          ),
        );
      } else {
        CustomSnackBar.showSnackBar(
          context: context,
          message: "Failed: ${response['message'] ?? 'Unknown error'}",
          color: Colors.red,
        );
      }
    } catch (e) {
      CustomSnackBar.showSnackBar(
        context: context,
        message: "Load error: $e",
        color: Colors.red,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 10,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context)
                  .extension<AppColors>()!
                  .primary
                  .withOpacity(0.9),
              Colors.black
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Wallet Balance',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: selectedCurrency,
                        items: accountsList.map((account) {
                          return DropdownMenuItem<String>(
                            value: account.currency,
                            child: Text(
                              "${account.currency}",
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedCurrency = newValue;
                            final selected = accountsList.firstWhere(
                                (account) => account.currency == newValue);
                            selectedAccountId = selected.accountId;
                            availableBalance = selected.amount ?? 0.0;
                            _updateConversion();
                          });
                        },
                        dropdownColor: Colors.black87,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Enter Amount',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Available Balance: ${selectedCurrency ?? ''} ${availableBalance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoCard(
                  'Deposit Fee (${depositFeePercent.toStringAsFixed(0)}%)',
                  '${selectedCurrency ?? ''} ${fee.toStringAsFixed(2)}',
                  Icons.percent,
                ),
                _buildInfoCard(
                  'Entered Amount',
                  '${selectedCurrency ?? ''} ${amount.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
                _buildInfoCard(
                  'Conversion Amount',
                  '${widget.cardCurrency} ${conversionAmount.toStringAsFixed(2)}',
                  Icons.swap_horiz,
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _loadCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor:
                          Theme.of(context).extension<AppColors>()!.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'ADD BALANCE',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionLimitBottomSheet extends StatefulWidget {
  final String cardId;

  const _TransactionLimitBottomSheet({required this.cardId});

  @override
  State<_TransactionLimitBottomSheet> createState() =>
      _TransactionLimitBottomSheetState();
}

class _TransactionLimitBottomSheetState
    extends State<_TransactionLimitBottomSheet> {
  final TextEditingController _dailyLimitController = TextEditingController();
  final TextEditingController _monthlyLimitController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _updateTransactionLimit() async {
    final dailyInput = _dailyLimitController.text.trim();
    final monthlyInput = _monthlyLimitController.text.trim();

    if (dailyInput.isEmpty || monthlyInput.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both daily and monthly limits';
      });
      return;
    }

    final dailyAmount = double.tryParse(dailyInput);
    final monthlyAmount = double.tryParse(monthlyInput);

    if (dailyAmount == null || monthlyAmount == null) {
      setState(() {
        _errorMessage = 'Please enter valid numeric amounts for both limits';
      });
      return;
    }

    if (dailyAmount <= 0 || monthlyAmount <= 0) {
      setState(() {
        _errorMessage = 'Amounts must be greater than zero';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url =
          Uri.parse('${ApiConstants.baseUrl}/card/limit/${widget.cardId}');
      final token = AuthManager.getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final body = jsonEncode({
        'dailyLimit': dailyAmount.toStringAsFixed(2),
        'monthlyLimit': monthlyAmount.toStringAsFixed(2),
      });

      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        CustomSnackBar.showSnackBar(
          context: context,
          message: responseData['message'] ?? 'Transaction limits updated',
          color: Colors.green,
        );
        Navigator.pop(context);
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          _errorMessage =
              'Failed to update limits: ${responseData['message'] ?? 'Unknown error'}';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error updating limits: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _dailyLimitController.dispose();
    _monthlyLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: defaultPadding,
        right: defaultPadding,
        top: 10,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context)
                  .extension<AppColors>()!
                  .primary
                  .withOpacity(0.9),
              Colors.black
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Set Transaction Limits',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _dailyLimitController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Daily Transaction Limit',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _monthlyLimitController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Monthly Transaction Limit',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateTransactionLimit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor:
                            Theme.of(context).extension<AppColors>()!.primary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? SpinKitWaveSpinner(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary,
                              size: 24)
                          : const Text(
                              'Update Limits',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddCardBottomSheet extends StatefulWidget {
  final VoidCallback onCardAdded;
  const AddCardBottomSheet({super.key, required this.onCardAdded});

  @override
  State<AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<AddCardBottomSheet> {
  final AddCardApi _addCardApi = AddCardApi();
  final CurrencyApi _currencyApi = CurrencyApi();

  String? selectedCurrency;
  List<CurrencyListsData> currency = [];
  TextEditingController name = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    mGetCurrency();
  }

  Future<void> mGetCurrency() async {
    final response = await _currencyApi.currencyApi();
    if (response.currencyList != null && response.currencyList!.isNotEmpty) {
      currency = response.currencyList!;
    }
  }

  Future<void> mAddCard() async {
    if (selectedCurrency != null) {
      if (name.text.isNotEmpty) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });

        try {
          final response = await _addCardApi.addCardApi(
              AuthManager.getUserId(), name.text, selectedCurrency.toString());

          if (response.message == "Card is added Successfully!!!") {
            setState(() {
              isLoading = false;
              name.clear();
              Navigator.pop(context);
              errorMessage = null;
            });
            widget.onCardAdded();
          } else if (response.message ==
              "Same Currency Account is already added in our record") {
            setState(() {
              isLoading = false;
              errorMessage =
                  'Same Currency Account is already added in our record';
            });
          } else {
            setState(() {
              isLoading = false;
              errorMessage = 'We are facing some issue!';
            });
          }
        } catch (error) {
          setState(() {
            isLoading = false;
            errorMessage = error.toString();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Card',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).extension<AppColors>()!.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: Theme.of(context).extension<AppColors>()!.primary),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Add card details here in order to save your card",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).extension<AppColors>()!.primary),
            ),
            Card(
              child: Container(
                width: double.infinity,
                height: 200.0,
                padding: const EdgeInsets.all(smallPadding),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 25,
                      left: defaultPadding,
                      child: Image.asset('assets/icons/chip.png'),
                    ),
                    const Positioned(
                      top: 75,
                      left: 75,
                      child: Text(
                        "••••    ••••    ••••    ••••",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OCRA',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: defaultPadding,
                      left: defaultPadding,
                      child: Text(
                        name.text.isEmpty ? "Your Name Here" : name.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 38,
                      right: defaultPadding,
                      child: Text(
                        "valid thru",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      right: 25,
                      child: selectedCurrency?.toUpperCase() == 'EUR'
                          ? getEuFlagWidget()
                          : CountryFlag.fromCountryCode(
                              width: 35,
                              height: 35,
                              selectedCurrency?.substring(0, 2) ?? "US",
                              shape: const Circle(),
                            ),
                    ),
                    const Positioned(
                      bottom: defaultPadding,
                      right: 35,
                      child: Text(
                        '••/••',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 45),
            TextFormField(
              controller: name,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              cursorColor: Theme.of(context).extension<AppColors>()!.primary,
              onSaved: (value) {},
              readOnly: false,
              style: TextStyle(
                  color: Theme.of(context).extension<AppColors>()!.primary),
              decoration: InputDecoration(
                labelText: "Your Name",
                labelStyle: TextStyle(
                    color: Theme.of(context).extension<AppColors>()!.primary,
                    fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(),
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: defaultPadding),
            GestureDetector(
              onTap: () {
                if (currency.isNotEmpty) {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  Offset offset = renderBox.localToGlobal(Offset.zero);

                  showMenu<String>(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      offset.dx,
                      offset.dy + renderBox.size.height,
                      offset.dx + renderBox.size.width,
                      0.0,
                    ),
                    items: currency.map((CurrencyListsData currencyItem) {
                      return PopupMenuItem<String>(
                        value: currencyItem.currencyCode,
                        child: Text(currencyItem.currencyCode!),
                      );
                    }).toList(),
                  ).then((String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedCurrency = newValue;
                      });
                    }
                  });
                }
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            Theme.of(context).extension<AppColors>()!.primary),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedCurrency ?? "Select Currency",
                          style: TextStyle(
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary,
                              fontSize: 16)),
                      Icon(Icons.arrow_drop_down,
                          color: Theme.of(context)
                              .extension<AppColors>()!
                              .primary),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 45),
            if (isLoading)
              SpinKitWaveSpinner(
                  color: Theme.of(context).extension<AppColors>()!.primary,
                  size: 75),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 55),
              child: ElevatedButton(
                onPressed: isLoading ? null : mAddCard,
                child: const Text('Submit',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 45),
          ],
        ),
      ),
    );
  }
}

class CardItem extends StatefulWidget {
  final CardListsData card;
  final bool isFrozen;

  const CardItem({super.key, required this.card, required this.isFrozen});

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (!widget.isFrozen) {
      if (showFront) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      showFront = !showFront;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.isFrozen,
      child: GestureDetector(
        onTap: _flipCard,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            double angle = _animation.value * pi;
            final isBackVisible = _animation.value >= 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: isBackVisible
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(pi),
                      child: _buildCardBack(),
                    )
                  : _buildCardFront(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isFrozen ? Colors.grey : Colors.indigo,
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: const AssetImage('assets/images/tr.jpg'),
          fit: BoxFit.cover,
          opacity: widget.isFrozen ? 0.5 : 0.85,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Opacity(
        opacity: widget.isFrozen ? 0.5 : 1.0,
        child: Stack(
          children: [
            Positioned(
              top: 50,
              left: 20,
              child: Image.asset('assets/icons/chip.png', height: 40),
            ),
            Positioned(
              top: 110,
              left: 20,
              child: Text(
                _formatCardNumber(widget.card.cardNumber ?? ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'OCRA',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Text(
                widget.card.cardHolderName ?? 'No Name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Text(
                'valid thru ${widget.card.cardValidity ?? ''}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: widget.card.currency?.toUpperCase() == 'EUR'
                  ? getEuFlagWidget()
                  : CountryFlag.fromCountryCode(
                      widget.card.currency?.substring(0, 2) ?? 'US',
                      width: 40,
                      height: 30,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    bool _isCvvVisible = false;

    void _showOtpVerificationDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Verify Phone to View CVV",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "To view the CVV, please verify your phone number with an OTP sent to your registered number.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(
                    color: Theme.of(context).extension<AppColors>()!.primary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).extension<AppColors>()!.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  _isCvvVisible = true;
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                "Verify",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: widget.isFrozen ? Colors.grey[300] : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: const AssetImage('assets/images/tr.jpg'),
          fit: BoxFit.cover,
          opacity: widget.isFrozen ? 0.5 : 0.8,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Container(
            height: 50,
            color: Colors.black87,
            margin: const EdgeInsets.symmetric(horizontal: 0),
          ),
          const SizedBox(height: 30),
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.only(right: 16),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.yellowAccent, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _isCvvVisible ? (widget.card.cardCVV ?? '***') : '***',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isCvvVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: () {
                    if (!_isCvvVisible) {
                      _showOtpVerificationDialog();
                    } else {
                      setState(() {
                        _isCvvVisible = false;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCardNumber(String number) {
    final cleaned = number.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 16) return number;
    return '${cleaned.substring(0, 4)} **** **** ${cleaned.substring(12)}';
  }
}

class CardData {
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String iconPath;
  final String oldPassword;

  CardData(this.cardNumber, this.cardHolder, this.expiryDate, this.iconPath,
      this.oldPassword);
}
