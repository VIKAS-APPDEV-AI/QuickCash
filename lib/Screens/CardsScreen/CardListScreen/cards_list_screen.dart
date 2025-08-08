import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:country_flags/country_flags.dart';
import 'package:quickcash/Screens/CardsScreen/CardListScreen/cardUpdateModel/cardUpdateApi.dart';
import 'package:quickcash/Screens/CardsScreen/CardListScreen/cardUpdateModel/cardUpdateModel.dart';
import 'package:quickcash/Screens/CardsScreen/CardListScreen/deleteCardModel/deleteCardApi.dart';
import 'package:quickcash/Screens/CardsScreen/cardListModel/cardListApi.dart';
import 'package:quickcash/Screens/CardsScreen/cardListModel/cardListModel.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/DashboardTicketScreen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/currency_utils.dart';
import 'package:quickcash/util/customSnackBar.dart';
import 'cardModel/cardApi.dart';

class CardsListScreen extends StatefulWidget {
  const CardsListScreen({super.key});

  @override
  State<CardsListScreen> createState() => _CardsListScreenState();
}

class _CardsListScreenState extends State<CardsListScreen>
    with SingleTickerProviderStateMixin {
  final CardListApi _cardListApi = CardListApi();
  final DeleteCardApi _deleteCardApi = DeleteCardApi();
  List<CardListsData> cardListData = [];
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
    _animationController!.forward();
    mCardList();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
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
          cardListData = response.cardList!;
          isLoading = false;
        });
        _animationController?.forward(from: 0);
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No Cards Found';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  Future<void> mDeleteCard(String? cardId) async {
    if (cardId == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Card ID is missing';
        CustomSnackBar.showSnackBar(
          context: context,
          message: 'Card ID is missing',
          color: Colors.red,
        );
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _deleteCardApi.deleteCardApi(cardId);
      if (response.message == "User Card Data has been deleted successfully") {
        setState(() {
          mCardList();
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Card deleted successfully!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          CustomSnackBar.showSnackBar(
            context: context,
            message: "We are facing some issue",
            color: Colors.red,
          );
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        CustomSnackBar.showSnackBar(
          context: context,
          message: error.toString(),
          color: Colors.red,
        );
      });
    }
  }

  String _formatCardNumber(String cardNumber) {
    if (cardNumber.isEmpty) return '**** **** **** ****';
    final length = cardNumber.length;
    if (length < 4) return '**** **** **** ${cardNumber.padLeft(4, '*')}';
    return '**** **** **** ${cardNumber.substring(length - 4)}';
  }

  Widget _buildCardFront(CardListsData card) {
    final isFrozen = card.status == false;
    final currency = card.currency ?? 'USD';

    return Container(
      width: double.infinity,
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFrozen
            ? Colors.grey
            : Theme.of(context).extension<AppColors>()!.primary,
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/tr.jpg'),
          fit: BoxFit.cover,
          opacity: 0.85,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 40,
            left: 20,
            child: Opacity(
              opacity: isFrozen ? 0.5 : 1.0,
              child: Image.asset(
                'assets/icons/chip.png',
                height: 40,
                width: 40,
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 20,
            child: Opacity(
              opacity: isFrozen ? 0.5 : 1.0,
              child: Text(
                _formatCardNumber(card.cardNumber ?? ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'OCRA',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Opacity(
              opacity: isFrozen ? 0.5 : 1.0,
              child: Text(
                card.cardHolderName ?? 'No Name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Opacity(
              opacity: isFrozen ? 0.5 : 1.0,
              child: Text(
                'valid thru ${card.cardValidity ?? ''}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Opacity(
              opacity: isFrozen ? 0.5 : 1.0,
              child: currency.toUpperCase() == 'EUR'
                  ? getEuFlagWidget()
                  : CountryFlag.fromCountryCode(
                      currency.substring(0, 2),
                      width: 40,
                      height: 30,
                    ),
            ),
          ),
          Positioned(
            top: 10,
            right: 70,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  onPressed: () {
                    if (card.cardId != null) {
                      mEditCardCardBottomSheet(context, card.cardId!);
                    } else {
                      CustomSnackBar.showSnackBar(
                        context: context,
                        message: 'Card ID is missing',
                        color: Colors.red,
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 20),
                  onPressed: () {
                    _showDeleteCardDialog(card.cardId);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode
        ? Colors.white
        : Theme.of(context).extension<AppColors>()!.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 20, 20, 20), // Primary color
                Color(0xFF8A2BE2), // Slightly lighter for gradient effect
                Color(0x00000000),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "My Cards",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.bell_fill),
            onPressed: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => NotificationScreen(),
                  ));
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.headphones),
            onPressed: () {
             Navigator.push(context, CupertinoPageRoute(builder: (context) => DashboardTicketScreen(),));
            },
            tooltip: 'Support',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading || _fadeAnimation == null
          ? Center(
              child: SpinKitWaveSpinner(
                color: Theme.of(context).extension<AppColors>()!.primary,
                size: 75,
                waveColor: Theme.of(context)
                    .extension<AppColors>()!
                    .primary
                    .withOpacity(0.5),
              ),
            )
          : RefreshIndicator(
              onRefresh: mCardList,
              color: Theme.of(context).extension<AppColors>()!.primary,
              child: FadeTransition(
                opacity: _fadeAnimation!,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 16),
                            ),
                          ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cardListData.length,
                          itemBuilder: (context, index) {
                            final card = cardListData[index];
                            String formattedDate = 'N/A';
                            if (card.cardValidity != null &&
                                card.cardValidity!.isNotEmpty) {
                              try {
                                // Parse MM/yy format (e.g., 12/30)
                                final dateFormat = DateFormat('MM/yy');
                                final parsedDate =
                                    dateFormat.parseStrict(card.cardValidity!);
                                // Format to desired output (MMM dd, yyyy)
                                formattedDate = DateFormat('MMM dd, yyyy')
                                    .format(parsedDate);
                              } catch (e) {
                                // Handle invalid date format gracefully
                                formattedDate = 'Invalid Date';
                              }
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCardFront(card),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  child: Text(
                                    'Added: $formattedDate',
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void mEditCardCardBottomSheet(BuildContext context, String cardId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: EditCardCardBottomSheet(getCardId: cardId),
        );
      },
    );
  }

  Future<bool> _showDeleteCardDialog(String? cardId) async {
    if (cardId == null) {
      CustomSnackBar.showSnackBar(
        context: context,
        message: 'Card ID is missing',
        color: Colors.red,
      );
      return false;
    }

    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Delete Card",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text("Are you sure you want to delete this card?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: Theme.of(context).extension<AppColors>()!.primary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  mDeleteCard(cardId);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }
}

class EditCardCardBottomSheet extends StatefulWidget {
  final String getCardId;
  const EditCardCardBottomSheet({super.key, required this.getCardId});

  @override
  State<EditCardCardBottomSheet> createState() => _EditCardBottomSheetState();
}

class _EditCardBottomSheetState extends State<EditCardCardBottomSheet>
    with SingleTickerProviderStateMixin {
  final CardApi _cardApi = CardApi();
  final CardUpdateApi _cardUpdateApi = CardUpdateApi();
  String selectedStatus = 'Card Status';
  List<String> status = ['Active', 'In Active'];
  TextEditingController cardHolderName = TextEditingController();
  TextEditingController cardNo = TextEditingController();
  TextEditingController cardCVV = TextEditingController();
  TextEditingController cardExpireDate = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool isLoading = false;
  String? errorMessage;
  bool _isCvvVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    mCard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    cardHolderName.dispose();
    cardNo.dispose();
    cardCVV.dispose();
    cardExpireDate.dispose();
    super.dispose();
  }

  Future<void> mCard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _cardApi.cardApi(widget.getCardId);
      if (response.card != null) {
        setState(() {
          isLoading = false;
          cardHolderName.text = response.card!.cardHolderName ?? '';
          cardNo.text = response.card!.cardNumber ?? '';
          cardCVV.text = response.card!.cardCVV ?? '';
          cardExpireDate.text = response.card!.cardValidity ?? '';
          selectedStatus = response.card!.status != null
              ? (response.card!.status! ? 'Active' : 'In Active')
              : 'Card Status';
        });
        _animationController.forward(from: 0);
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

  Future<bool> resolveCardStatus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return selectedStatus == 'Active';
  }

  Future<void> mUpdateCard() async {
    if (cardHolderName.text.isEmpty || cardCVV.text.isEmpty) {
      setState(() {
        errorMessage = 'Please fill all required fields';
        CustomSnackBar.showSnackBar(
          context: context,
          message: 'Please fill all required fields',
          color: Colors.red,
        );
      });
      return;
    }

    if (selectedStatus == 'Card Status') {
      setState(() {
        errorMessage = 'Please select a valid card status';
        CustomSnackBar.showSnackBar(
          context: context,
          message: 'Please select a valid card status',
          color: Colors.red,
        );
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      bool resolvedStatus = await resolveCardStatus();
      final request = CardUpdateRequest(
        cardStatus: resolvedStatus,
        cardName: cardHolderName.text,
        cardCVV: cardCVV.text,
      );

      final response =
          await _cardUpdateApi.cardUpdate(request, widget.getCardId);
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Card updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        CustomSnackBar.showSnackBar(
          context: context,
          message: error.toString(),
          color: Colors.red,
        );
      });
    }
  }

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
              // Add OTP verification logic here
              setState(() {
                _isCvvVisible =
                    true; // For demo; replace with actual OTP verification
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode
        ? Colors.white
        : Theme.of(context).extension<AppColors>()!.primary;

    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      child: isLoading
          ? Center(
              child: SpinKitWaveSpinner(
                color: Theme.of(context).extension<AppColors>()!.primary,
                size: 75,
                waveColor: Theme.of(context)
                    .extension<AppColors>()!
                    .primary
                    .withOpacity(0.5),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Card Details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .extension<AppColors>()!
                                .primary,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              color: Theme.of(context)
                                  .extension<AppColors>()!
                                  .primary,
                              size: 28),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              isDarkMode ? Colors.grey[900]! : Colors.white,
                              isDarkMode
                                  ? Colors.grey[900]!.withOpacity(0.9)
                                  : Colors.white.withOpacity(0.9),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: cardHolderName,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                cursorColor: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  labelText: "Cardholder Name",
                                  labelStyle: TextStyle(
                                      color: textColor.withOpacity(0.7)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .extension<AppColors>()!
                                            .primary,
                                        width: 2),
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: cardNo,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                cursorColor: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary,
                                readOnly: true,
                                style: TextStyle(
                                    color: textColor.withOpacity(0.6)),
                                decoration: InputDecoration(
                                  labelText: "Card Number",
                                  labelStyle: TextStyle(
                                      color: textColor.withOpacity(0.7)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: cardCVV,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                cursorColor: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary,
                                style: TextStyle(color: textColor),
                                obscureText: !_isCvvVisible,
                                decoration: InputDecoration(
                                  labelText: "CVV",
                                  labelStyle: TextStyle(
                                      color: textColor.withOpacity(0.7)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .extension<AppColors>()!
                                            .primary,
                                        width: 2),
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isCvvVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: textColor.withOpacity(0.7),
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
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: cardExpireDate,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                cursorColor: Theme.of(context)
                                    .extension<AppColors>()!
                                    .primary,
                                readOnly: true,
                                style: TextStyle(
                                    color: textColor.withOpacity(0.6)),
                                decoration: InputDecoration(
                                  labelText: "Expiry Date",
                                  labelStyle: TextStyle(
                                      color: textColor.withOpacity(0.7)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: selectedStatus,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  labelText: 'Card Status',
                                  labelStyle: TextStyle(
                                      color: textColor.withOpacity(0.7)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .extension<AppColors>()!
                                            .primary,
                                        width: 2),
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                ),
                                items: ['Card Status', 'Active', 'In Active']
                                    .map((String role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child: Text(
                                      role,
                                      style: TextStyle(color: textColor),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedStatus = newValue!;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              if (errorMessage != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 14),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              Center(
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : mUpdateCard,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .extension<AppColors>()!
                                        .primary,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ),
    );
  }
}
