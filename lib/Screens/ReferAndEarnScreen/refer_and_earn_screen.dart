import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickcash/Screens/ReferAndEarnScreen/model/referAndEarnApi.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/customSnackBar.dart';
import 'package:share_plus/share_plus.dart';
import '../../util/apiConstants.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  final ReferAndEarnApi _referAndEarnApi = ReferAndEarnApi();
  String? referralLink;
  bool isLoading = false;
  String? errorMessage;

  void _copyReferralLink() {
    if (referralLink != null) {
      Clipboard.setData(ClipboardData(text: referralLink!)).then((_) {
        CustomSnackBar.showSnackBar(
          context: context,
          message: 'Referral link copied to clipboard!',
          color: kPrimaryColor,
        );
      });
    } else {
      CustomSnackBar.showSnackBar(
        context: context,
        message: 'Referral link is not available!',
        color: Colors.red,
      );
    }
  }

  // Updated function to share the referral link using share_plus
  void _shareReferralLink(String platform) {
    if (referralLink != null) {
      Share.share(
        'Check out this awesome app! Use my referral link to join: $referralLink',
        subject: 'Join using my referral link!',
      );
    } else {
      CustomSnackBar.showSnackBar(
        context: context,
        message: 'Referral link is not available!',
        color: Colors.red,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    mReferralAndEarn();
  }

  Future<void> mReferralAndEarn() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _referAndEarnApi.referralAndEarnApi();
      print('API Response: ${response.referralCode}'); // Debug print

      if (response.referralCode != null && response.referralCode!.isNotEmpty) {
        setState(() {
          referralLink = '${ApiConstants.baseReferralCodeUrl}${response.referralCode}';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Referral code is unavailable';
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching referral code: $error'); // Debug print
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load referral link: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: kWhiteColor),
        title: const Text(
          "Refer & Earn",
          style: TextStyle(color: kWhiteColor),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: defaultPadding),
                          Card(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/tr.jpg',
                                    fit: BoxFit.cover,
                                    height: 270,
                                    width: double.infinity,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(defaultPadding),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Refer Your Friends And Get Rewards",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        "Tell your friends about TITA. Copy and paste the referral URL provided below to as many people as possible. Receive interesting incentives and deals as a reward for your recommendation!",
                                        style: TextStyle(color: Colors.white, fontSize: 14),
                                      ),
                                      const SizedBox(height: defaultPadding),
                                      Container(
                                        height: 60,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              referralLink ?? (errorMessage ?? 'Loading referral link...'),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              softWrap: false,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: <Widget>[
                                          IconButton(
                                            icon: const Icon(Icons.copy, color: Colors.white),
                                            onPressed: _copyReferralLink,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          const Text(
                            "How Does it Work?",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                              "All you have to do is develop campaigns, distribute them, and you'll be able to profit from our lucrative trading platform in no time. Discover how to:"),
                          const SizedBox(height: defaultPadding),
                          const Text(
                            '1. Get Your Link',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                            child: Text(
                              'Sign up for the platform, begin trading, and receive the above-mentioned referral link.',
                            ),
                          ),
                          const SizedBox(height: defaultPadding),
                          const Text(
                            '2. Share Your Link',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                            child: Text(
                              'Distribute the generated link to the specified number of sources.',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '3. Earn When They Trade',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bottom section for sharing
                Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  color: Colors.grey[200], // Background color similar to the image
                  child: Column(
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Container(
                      //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      //       decoration: BoxDecoration(
                      //         border: Border.all(color: Colors.grey),
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       child: Row(
                      //         children: [
                      //           Text(
                      //             'INVITE CODE: ${referralLink?.split('/').last ?? 'N/A'}',
                      //             style: const TextStyle(fontWeight: FontWeight.bold),
                      //           ),
                      //           const SizedBox(width: 8),
                      //           IconButton(
                      //             icon: const Icon(Icons.copy, size: 20),
                      //             onPressed: _copyReferralLink,
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // WhatsApp Button
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.green), // WhatsApp icon
                            onPressed: () => _shareReferralLink('WhatsApp'),
                          ),
                          const SizedBox(width: 16),
                          // Telegram Button
                          IconButton(
                            icon: const Icon(Icons.send), // Telegram icon
                            onPressed: () => _shareReferralLink('Telegram'),
                          ),
                          const SizedBox(width: 16),
                          // Email Button
                          IconButton(
                            icon: const Icon(Icons.email), // Email icon
                            onPressed: () => _shareReferralLink('Email'),
                          ),
                          const SizedBox(width: 16),
                          // More Options Button
                          IconButton(
                            icon: const Icon(Icons.share_outlined), // More options icon
                            onPressed: () => _shareReferralLink('More'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _shareReferralLink('Invite'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: kPrimaryColor),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'INVITE NOW',
                          style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 30,)
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}