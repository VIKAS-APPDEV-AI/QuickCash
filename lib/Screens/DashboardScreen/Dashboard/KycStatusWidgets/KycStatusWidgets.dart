import 'package:flutter/material.dart';
import 'package:quickcash/Screens/KYCScreen/kycHomeScreen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';

class CheckKycStatus extends StatelessWidget {
  // Callback to refresh KYC status
  Future<void> _refreshKycStatus() async {
    // Simulate a network call or refresh logic (replace with actual logic)
    await Future.delayed(Duration(seconds: 1));
    // Add actual logic to fetch updated KYC status from AuthManager or a server here
  }

  @override
  Widget build(BuildContext context) {
    String kycStatus = AuthManager.getKycStatus();
    Widget? kycWidget = _buildKycStatusWidget(kycStatus, context);

    if (kycWidget == null) {
      return SizedBox.shrink(); // Hide widget if no valid KYC status
    }

    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Card(
        elevation: 4.0,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        child: RefreshIndicator(
          onRefresh: _refreshKycStatus, // Triggered when user pulls to refresh
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Ensures scrolling is always enabled
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                children: [
                  const SizedBox(height: largePadding),
                  kycWidget,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildKycStatusWidget(String kycStatus, BuildContext context) {
    switch (kycStatus) {
      case "Pending":
        return KycPendingWidget();
      case "Processed":
        return KycApprovalPendingWidget();
      case "Declined":
        return KycDeclinedWidget();
      case "completed":
        return null; // Hide widget completely when KYC is completed
      default:
        return KycPendingWidget();
    }
  }
}

// KYC Pending Widget
class KycPendingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImage('assets/images/KycPending.jpg'),
        const SizedBox(height: largePadding),
        _buildText('KYC is Pending', fontSize: 26, isBold: true),
        _buildText('Click here to complete the KYC', color: Colors.grey),
        const SizedBox(height: 35),
        _buildKycButton(context),
      ],
    );
  }

  Widget _buildKycButton(BuildContext context) {
    return _buildButton(context, 'Click Now');
  }
}

// KYC Approval Pending Widget
class KycApprovalPendingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImage('assets/images/PendingApproval.jpg'),
        const SizedBox(height: largePadding),
        _buildText(
          'Your details are submitted, Admin will approve after reviewing your KYC details!',
          color: Colors.grey,
        ),
        const SizedBox(height: largePadding),
      ],
    );
  }
}

// KYC Declined Widget
class KycDeclinedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImage('assets/images/Rejected.jpg'),
        const SizedBox(height: largePadding),
        _buildText(
          'Your KYC was rejected. Please apply for Re-KYC!',
          color: Colors.grey,
        ),
        const SizedBox(height: 35),
        _buildButton(context, 'Apply Again'),
      ],
    );
  }
}

// Utility Functions
Widget _buildImage(String imagePath) {
  return Center(
    child: Image.asset(imagePath, width: 260, height: 150),
  );
}

Widget _buildText(String text,
    {double fontSize = 16, bool isBold = false, Color color = Colors.black}) {
  return Center(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color,
      ),
    ),
  );
}

Widget _buildButton(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 50),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KycHomeScreen()),
        );
      },
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
    ),
  );
}