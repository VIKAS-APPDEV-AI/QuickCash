import 'package:carousel_slider/carousel_slider.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:quickcash/Screens/CardsScreen/Add_Card.dart';
import 'package:quickcash/Screens/CardsScreen/CardListScreen/cards_list_screen.dart';
import 'package:quickcash/Screens/CardsScreen/PhysicalCardScreen.dart' as physicalCard;
import 'package:quickcash/Screens/CardsScreen/RequestPhysicalCard.dart';
import 'package:quickcash/Screens/CardsScreen/addCardModel/addCardApi.dart';
import 'package:quickcash/Screens/CardsScreen/cardListModel/cardListApi.dart';
import 'package:quickcash/Screens/CardsScreen/cardListModel/cardListModel.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/model/currencyApiModel/Model/currencyModel.dart';
import 'package:quickcash/model/currencyApiModel/Services/currencyApi.dart';
import 'package:quickcash/util/AnimatedContainerWidget.dart';
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
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
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
          offset: Offset(_animation.value, 0), // Horizontal movement
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
  List<CardListsData> cardsListData = [];
  int _currentCardIndex = 0;

  bool isLoading = false;
  String? errorMessage;

  void _mSetPinBottomSheet(BuildContext context, String cardName,
      String cardNumber, int oldPassword) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 450,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pin Change',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: kPrimaryColor),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Card Name: $cardName',
                      style:
                          const TextStyle(fontSize: 16, color: kPrimaryColor)),
                ],
              ),
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Card Number: $cardNumber',
                      style:
                          const TextStyle(fontSize: 16, color: kPrimaryColor)),
                ],
              ),
              const SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Old Password: $oldPassword',
                      style:
                          const TextStyle(fontSize: 16, color: kPrimaryColor)),
                ],
              ),
              const SizedBox(height: 35),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'New PIN',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 55),
                child: ElevatedButton(
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
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
        errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Virtual Cards",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(
              child: SpinKitWaveSpinner(color: kPrimaryColor, size: 75),
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
                        decoration: const BoxDecoration(
                          color: kPrimaryColor,
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
                                  ? const Center(
                                      child: Text(
                                        'No Cards Available',
                                        style: TextStyle(
                                            fontSize: 18, color: kPrimaryColor),
                                      ),
                                    )
                                  : AnimatedContainerWidget(
                                    duration: const Duration(milliseconds: 1000),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20.0),
                                                child: CardItem(card: card),
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
                            label: 'Set/Reset\nPIN',
                            onTap: () {
                              if (cardsListData.isNotEmpty) {
                                final currentCard =
                                    cardsListData[_currentCardIndex];
                                _mSetPinBottomSheet(
                                  context,
                                  currentCard.cardHolderName!,
                                  currentCard.cardNumber!,
                                  currentCard.cardPin!,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('No card available to set PIN')),
                                );
                              }
                            },
                          ),
                        ),
                        AnimatedContainerWidget(
                          child: _buildButton(
                            icon: Icons.ac_unit,
                            label: 'Freeze\nCard',
                            onTap: () {
                              print('Freeze Card tapped');
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
                              print('Transaction Limits tapped');
                            },
                          ),
                        ),
                        AnimatedContainerWidget(

                          child: _buildButton(
                            icon: Icons.credit_card,
                            label: 'Manage\nCard',
                            onTap: () {
                               if (AuthManager.getKycStatus() == "completed"){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CardsListScreen()),
                          );
                        }else{
                          CustomSnackBar.showSnackBar(context: context, message: "Your KYC is not completed", color: kPrimaryColor);
                        }
                            },
                          ),
                        ),
                      ],
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
                                        margin: const EdgeInsets.only(left: 16.0),
                                        child: Image.asset(
                                            'assets/images/PhysicalCard.png')),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: SizedBox(
                                  width: 250,
                                  height: 54,
                                  child: AnimatedContainerWidget(
                                    fadeCurve: Easing.standardDecelerate,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(context, CupertinoPageRoute(builder: (context) => RequestPhysicalCard(onCardAdded: () {  },),));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor,
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 16.0),
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: kPrimaryColor,
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
            style: const TextStyle(
              fontSize: 13.0,
              color: Colors.black87,
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
                const Text(
                  'Add Card',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: kPrimaryColor),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Add card details here in order to save your card",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor),
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
              cursorColor: kPrimaryColor,
              onSaved: (value) {},
              readOnly: false,
              style: const TextStyle(color: kPrimaryColor),
              decoration: InputDecoration(
                labelText: "Your Name",
                labelStyle: const TextStyle(color: kPrimaryColor, fontSize: 16),
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
                    border: Border.all(color: kPrimaryColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedCurrency ?? "Select Currency",
                          style: const TextStyle(
                              color: kPrimaryColor, fontSize: 16)),
                      const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 45),
            const SizedBox(height: defaultPadding),
            if (isLoading)
              const SpinKitWaveSpinner(color: kPrimaryColor, size: 75),
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

  const CardItem({super.key, required this.card});

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  bool isFront = true;
  bool showFullNumber = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFront = !isFront;
          showFullNumber = false;
        });
      },
      child: isFront ? _buildCardFront() : _buildCardBack(),
    );
  }

  Widget _buildCardFront() {
    return Container(
      width: double.infinity,
      height: 250.0,
      padding: const EdgeInsets.all(smallPadding),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 0),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/tr.jpg'),
          fit: BoxFit.cover,
          opacity: 0.8,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 55,
            left: defaultPadding,
            child: Image.asset('assets/icons/chip.png'),
          ),
          Positioned(
            top: 115,
            left: defaultPadding,
            child: Text(
              _formatCardNumber(widget.card.cardNumber!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'OCRA',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: defaultPadding,
            left: defaultPadding,
            child: Text(
              widget.card.cardHolderName!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: defaultPadding,
            right: defaultPadding,
            child: Text(
              'valid thru ${widget.card.cardValidity!}',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'RobotoMono',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 25,
            child: widget.card.currency?.toUpperCase() == 'EUR'
                ? getEuFlagWidget()
                : CountryFlag.fromCountryCode(
                    width: 35,
                    height: 35,
                    widget.card.currency?.substring(0, 2) ?? "US",
                    shape: const Circle(),
                  ),
          ),
          // Positioned(
          //   top: 50,
          //   right: 25,
          //   child: widget.card.currency?.toUpperCase() == 'EUR'
          //       ? physicalCard.getEuFlagWidget() // Using PhysicalCardScreen's version
          //       : CountryFlag.fromCountryCode(
          //           width: 35,
          //           height: 35,
          //           widget.card.currency?.substring(0, 2) ?? "US",
          //           shape: const Circle(),
          //         ),
          // ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showFullNumber = !showFullNumber;
                });
              },
              child: const Icon(
                Icons.info,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: double.infinity,
      height: 250.0,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/tr.jpg'),
          fit: BoxFit.cover,
          opacity: 0.8,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              color: Colors.black,
            ),
          ),
          Positioned(
            top: 110,
            left: 20,
            right: 20,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.yellow, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      widget.card.cardCVV!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCardNumber(String cardNumber) {
    String cleanedNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (!showFullNumber) {
      if (cleanedNumber.length >= 14) {
        return '${cleanedNumber.substring(0, 4)} **** **** ${cleanedNumber.substring(12)}';
      }
      return cleanedNumber;
    }

    String formattedNumber = '';
    for (int i = 0; i < cleanedNumber.length; i += 4) {
      int end = i + 4;
      if (end <= cleanedNumber.length) {
        formattedNumber += cleanedNumber.substring(i, end);
      } else {
        formattedNumber += cleanedNumber.substring(i);
      }
      if (end < cleanedNumber.length) {
        formattedNumber += ' ';
      }
    }
    return formattedNumber;
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