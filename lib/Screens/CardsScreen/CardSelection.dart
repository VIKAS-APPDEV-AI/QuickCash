import 'package:flutter/material.dart';
import 'package:quickcash/Screens/CardsScreen/Add_Card.dart';
import 'package:quickcash/Screens/CardsScreen/PhysicalCardConfirmation.dart';
import 'package:quickcash/Screens/CardsScreen/PhysicalCardScreen.dart';
import 'package:quickcash/Screens/CardsScreen/RequestPhysicalCard.dart';
import 'package:quickcash/Screens/CardsScreen/card_screen.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/KycStatusWidgets/KycStatusWidgets.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/AnimatedContainerWidget.dart';
import 'package:quickcash/util/auth_manager.dart'; // Import AuthManager for KYC status
import 'package:quickcash/Screens/KYCScreen/kycHomeScreen.dart'; // Import for navigation

class CardSelectionScreen extends StatefulWidget {
  const CardSelectionScreen({super.key});

  @override
  State<CardSelectionScreen> createState() => _CardSelectionScreenState();
}

class _CardSelectionScreenState extends State<CardSelectionScreen> {
  String? kycStatus;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchKycStatus();
  }

  Future<void> _fetchKycStatus() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      // Simulate fetching KYC status (replace with actual async call if needed)
      String status = AuthManager.getKycStatus();
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

    // Responsive padding
    final padding = isSmallScreen ? 12.0 : isTablet ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: kWhiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                )
              : errorMessage != null
                  ? _buildErrorWidget()
                  : _buildContentBasedOnKycStatus(kycStatus ?? 'Pending', context),
        ),
      ),
    );
  }

  // Method to determine content based on KYC status
  Widget _buildContentBasedOnKycStatus(String kycStatus, BuildContext context) {
    switch (kycStatus.toLowerCase()) {
      case "pending":
        return  CheckKycStatus(); // Show KYC pending widget
      case "processed":
        return _buildProcessedWidget(context); // Show processed widget
      case "declined":
        return _buildDeclinedWidget(context); // Show declined widget
      case "completed":
        return _buildCardSelectionContent(context); // Show full card selection UI
      default:
        return CheckKycStatus(); // Default to KYC pending widget
    }
  }

  // Error widget when KYC status fetch fails
  Widget _buildErrorWidget() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final fontSize = isSmallScreen ? 14.0 : 16.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 60,
        ),
        const SizedBox(height: 20),
        Text(
          errorMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: fontSize,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 24 : 32,
              vertical: isSmallScreen ? 12 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            ),
          ),
          onPressed: _fetchKycStatus,
          child: Text(
            'Retry',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        ),
      ],
    );
  }

  // Full Card Selection UI for "completed" status
  Widget _buildCardSelectionContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1200;

    final titleFontSize = isSmallScreen ? 20.0 : isTablet ? 22.0 : 24.0;
    final spacing = isSmallScreen ? 8.0 : isTablet ? 12.0 : 16.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: spacing * 1.25),
          AnimatedContainerWidget(
            child: Center(
              child: Text(
                "Pick your Cards",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: spacing * 0.625),
          AnimatedContainerWidget(
            slideBegin: const Offset(2.0, 1.0),
            child: Divider(
              color: Colors.black26,
              thickness: isSmallScreen ? 1 : 1.5,
            ),
          ),
          SizedBox(height: spacing),
          AnimatedContainerWidget(
            slideBegin: const Offset(1.0, 1.0),
            child: _buildCardSection(
              context: context,
              imagePath: "assets/images/card.png",
              icon: Icons.credit_card,
              title: "Physical Card",
              description:
                  "Choose your card design or personalize it, and get it delivered to your doorstep.",
              buttonText: "Customizable",
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
                            builder: (context) => const DeliveryProcessingScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: spacing),
          AnimatedContainerWidget(
            slideCurve: Curves.linear,
            child: _buildCardSection(
              context: context,
              imagePath: "assets/images/VirtualCard.png",
              icon: Icons.credit_card_outlined,
              title: "Virtual Card",
              description:
                  "Get free virtual cards instantly, with disposable options for extra online security.",
              buttonText: "Extra Secure",
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
          ),
        ],
      ),
    );
  }

  // Widget for "Processed" status
  Widget _buildProcessedWidget(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1200;

    final imageWidth = isSmallScreen ? 200.0 : isTablet ? 230.0 : 260.0;
    final imageHeight = isSmallScreen ? 120.0 : isTablet ? 135.0 : 150.0;
    final fontSize = isSmallScreen ? 14.0 : isTablet ? 15.0 : 16.0;
    final spacing = isSmallScreen ? 15.0 : isTablet ? 18.0 : 20.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              // BoxShadow(
              //   color: Colors.black.withOpacity(0.1),
              //   spreadRadius: 2,
              //   blurRadius: 8,
              //   offset: const Offset(0, 4),
              // ),
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
          'Your details have been submitted. An admin will approve your KYC after review.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: fontSize,
            height: 1.5,
          ),
        ),
        SizedBox(height: spacing),
        OutlinedButton(
          onPressed: _fetchKycStatus,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: kPrimaryColor, width: 2),
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
              color: kPrimaryColor,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Widget for "Declined" status
  Widget _buildDeclinedWidget(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1200;

    final imageWidth = isSmallScreen ? 200.0 : isTablet ? 230.0 : 260.0;
    final imageHeight = isSmallScreen ? 120.0 : isTablet ? 135.0 : 150.0;
    final fontSize = isSmallScreen ? 14.0 : isTablet ? 15.0 : 16.0;
    final buttonFontSize = isSmallScreen ? 14.0 : isTablet ? 15.0 : 16.0;
    final spacing = isSmallScreen ? 15.0 : isTablet ? 18.0 : 20.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
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
              fit: BoxFit.cover,
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
          ),
        ),
        SizedBox(height: spacing * 1.75),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 24 : 32,
              vertical: isSmallScreen ? 12 : 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            ),
            elevation: 5,
            shadowColor: kPrimaryColor.withOpacity(0.3),
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
              fontSize: buttonFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build the card sections
  Widget _buildCardSection({
    required BuildContext context,
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

    final cardHeight = isSmallScreen ? 110.0 : isTablet ? 115.0 : 120.0;
    final imageSize = isSmallScreen ? 36.0 : isTablet ? 38.0 : 40.0;
    final titleFontSize = isSmallScreen ? 16.0 : isTablet ? 17.0 : 18.0;
    final descriptionFontSize = isSmallScreen ? 12.0 : isTablet ? 13.0 : 14.0;
    final iconSize = isSmallScreen ? 14.0 : isTablet ? 15.0 : 16.0;
    final padding = isSmallScreen ? 12.0 : isTablet ? 14.0 : 16.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: cardHeight,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kPrimaryColor,
              kPrimaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(isSmallScreen ? 0.3 : 0.4),
              spreadRadius: isSmallScreen ? 1 : 2,
              blurRadius: isSmallScreen ? 4 : 5,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                imagePath,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
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
                  SizedBox(height: padding / 4),
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
              color: Colors.white.withOpacity(0.9),
              size: iconSize,
            ),
          ],
        ),
      ),
    );
  }
}