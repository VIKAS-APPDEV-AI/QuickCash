import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quickcash/Screens/CardsScreen/Add_Card.dart';
import 'package:quickcash/Screens/CardsScreen/PhysicalCardConfirmation.dart';
import 'package:quickcash/Screens/CardsScreen/RequestPhysicalCard.dart';
import 'package:quickcash/Screens/CardsScreen/card_screen.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/KycStatusWidgets/KycStatusWidgets.dart';
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/Screens/TicketsScreen/TicketScreen/DashboardTicketScreen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/AnimatedContainerWidget.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/Screens/KYCScreen/kycHomeScreen.dart';

class CardSelectionScreen extends StatefulWidget {
  const CardSelectionScreen({super.key});

  @override
  State<CardSelectionScreen> createState() => _CardSelectionScreenState();
}

class _CardSelectionScreenState extends State<CardSelectionScreen>
    with TickerProviderStateMixin {
  String? kycStatus;
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Initialize fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Initialize slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Start animations and fetch KYC status after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      _fetchKycStatus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchKycStatus() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final status = AuthManager.getKycStatus();
      setState(() {
        kycStatus = status;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch KYC status. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1200;
    final padding = isSmallScreen
        ? 12.0
        : isTablet
            ? 16.0
            : 20.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 6, 6, 6),
                Color(0xFF8A2BE2),
                Color(0x00000000),
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
        ),
          actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.bell_fill),
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Card Selection',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
       
      ),
      body: Container(
        height: double.infinity, // Ensure full height
        width: double.infinity, // Ensure full width
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context)
                  .extension<AppColors>()!
                  .primary
                  .withOpacity(0.5),
              Colors.white,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).extension<AppColors>()!.primary,
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: errorMessage != null
                          ? _buildErrorWidget()
                          : _buildContentBasedOnKycStatus(
                              kycStatus ?? 'Pending'),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildContentBasedOnKycStatus(String kycStatus) {
    switch (kycStatus.toLowerCase()) {
      case 'pending':
        return  CheckKycStatus();
      case 'processed':
        return _buildProcessedWidget();
      case 'declined':
        return _buildDeclinedWidget();
      case 'completed':
        return _buildCardSelectionContent();
      default:
        return  CheckKycStatus();
    }
  }

  Widget _buildErrorWidget() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final fontSize = isSmallScreen ? 16.0 : 18.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.1),
          ),
          child: const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          errorMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 24 : 32,
              vertical: isSmallScreen ? 12 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            ),
            elevation: 5,
            shadowColor: Theme.of(context)
                .extension<AppColors>()!
                .primary
                .withOpacity(0.3),
          ),
          onPressed: _fetchKycStatus,
          child: Text(
            'Retry',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessedWidget() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1200;
    final imageWidth = isSmallScreen
        ? 200.0
        : isTablet
            ? 230.0
            : 260.0;
    final imageHeight = isSmallScreen
        ? 120.0
        : isTablet
            ? 135.0
            : 150.0;
    final fontSize = isSmallScreen
        ? 16.0
        : isTablet
            ? 17.0
            : 18.0;
    final spacing = isSmallScreen
        ? 15.0
        : isTablet
            ? 18.0
            : 20.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .extension<AppColors>()!
                    .primary
                    .withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/PendingApproval.jpg',
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: spacing),
        Text(
          'Your details are under review. An admin will approve your KYC soon.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: fontSize,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: spacing),
        OutlinedButton(
          onPressed: _fetchKycStatus,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Theme.of(context).extension<AppColors>()!.primary,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20 : 24,
              vertical: isSmallScreen ? 10 : 12,
            ),
          ),
          child: Text(
            'Refresh Status',
            style: TextStyle(
              color: Theme.of(context).extension<AppColors>()!.primary,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeclinedWidget() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1200;
    final imageWidth = isSmallScreen
        ? 200.0
        : isTablet
            ? 230.0
            : 260.0;
    final imageHeight = isSmallScreen
        ? 120.0
        : isTablet
            ? 135.0
            : 150.0;
    final fontSize = isSmallScreen
        ? 16.0
        : isTablet
            ? 17.0
            : 18.0;
    final spacing = isSmallScreen
        ? 15.0
        : isTablet
            ? 18.0
            : 20.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .extension<AppColors>()!
                    .primary
                    .withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/Rejected.jpg',
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: spacing),
        Text(
          'Your KYC was declined. Please resubmit your details for verification.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: fontSize,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: spacing * 1.75),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).extension<AppColors>()!.primary,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 24 : 32,
              vertical: isSmallScreen ? 12 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            ),
            elevation: 5,
            shadowColor: Theme.of(context)
                .extension<AppColors>()!
                .primary
                .withOpacity(0.3),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KycHomeScreen()),
            );
          },
          child: Text(
            'Apply Again',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardSelectionContent() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1200;
    final titleFontSize = isSmallScreen
        ? 22.0
        : isTablet
            ? 24.0
            : 26.0;
    final spacing = isSmallScreen
        ? 12.0
        : isTablet
            ? 16.0
            : 20.0;
    final dropdownFontSize = isSmallScreen
        ? 14.0
        : isTablet
            ? 15.0
            : 16.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: spacing * 2),
          AnimatedContainerWidget(
            child: Text(
              'Choose Your Card',
              style: TextStyle(
                color: Theme.of(context).extension<AppColors>()!.primary,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing),
          AnimatedContainerWidget(
            slideBegin: const Offset(0.0, 0.5),
            child: Divider(
              color: Theme.of(context)
                  .extension<AppColors>()!
                  .primary
                  .withOpacity(0.3),
              thickness: 2,
              indent: spacing * 2,
              endIndent: spacing * 2,
            ),
          ),
          SizedBox(height: spacing),
          _buildCardSection(
            imagePath: 'assets/images/card.png',
            icon: Icons.credit_card,
            title: 'Physical Card',
            description:
                'Personalize your card design and have it delivered to your doorstep with ease.',
            buttonText: 'Customizable',
            isButton: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RequestPhysicalCard(
                    onCardAdded: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DeliveryProcessingScreen(),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          SizedBox(height: spacing),
          _buildCardSection(
            imagePath: 'assets/images/VirtualCard.png',
            icon: Icons.credit_card_outlined,
            title: 'Virtual Card',
            description:
                'Instantly create secure virtual cards for safe online transactions.',
            buttonText: 'Extra Secure',
            isButton: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCardScreen(
                    onCardAdded: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CardsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 40),
          AnimatedContainerWidget(
            slideBegin: const Offset(0.0, 0.5),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: spacing),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .extension<AppColors>()!
                        .primary
                        .withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                leading: Icon(
                  Icons.info,
                  color: Theme.of(context).extension<AppColors>()!.primary,
                  size: isSmallScreen ? 20 : 24,
                ),
                title: Text(
                  'How to Add a Card',
                  style: TextStyle(
                    color: Theme.of(context).extension<AppColors>()!.primary,
                    fontSize: dropdownFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                iconColor: Theme.of(context).extension<AppColors>()!.primary,
                backgroundColor: Colors.white,
                collapsedBackgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                childrenPadding: EdgeInsets.all(spacing),
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: dropdownFontSize * 0.9,
                        height: 1.6,
                      ),
                      children: const [
                        TextSpan(text: '• '),
                        TextSpan(
                          text: 'Virtual Card',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextSpan(
                          text:
                              ': A virtual card that exists only online. It provides secure online commerce, transfers, and payments without issuing a physical card\n\n',
                          style: TextStyle(fontSize: 13),
                        ),
                        TextSpan(text: '• '),
                        TextSpan(
                          text: 'Physical Card',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextSpan(
                          text:
                              ': Access your funds globally without all the costs and time. Your Physical card will arrive anywhere from 3-5 business days.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
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

  Widget _buildCardSection({
    required String imagePath,
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required bool isButton,
    VoidCallback? onTap,
  }) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1200;
    final cardHeight = isSmallScreen
        ? 120.0
        : isTablet
            ? 130.0
            : 140.0;
    final imageSize = isSmallScreen
        ? 40.0
        : isTablet
            ? 44.0
            : 48.0;
    final titleFontSize = isSmallScreen
        ? 18.0
        : isTablet
            ? 20.0
            : 22.0;
    final descriptionFontSize = isSmallScreen
        ? 14.0
        : isTablet
            ? 15.0
            : 16.0;
    final padding = isSmallScreen
        ? 12.0
        : isTablet
            ? 16.0
            : 20.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: double.infinity,
        height: cardHeight,
        margin: EdgeInsets.symmetric(horizontal: padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context)
                  .extension<AppColors>()!
                  .primary
                  .withOpacity(0.9),
              Theme.of(context)
                  .extension<AppColors>()!
                  .primary
                  .withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .extension<AppColors>()!
                  .primary
                  .withOpacity(isSmallScreen ? 0.3 : 0.4),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      imagePath,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: padding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: padding / 2),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: descriptionFontSize,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: isSmallScreen ? 16 : 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
