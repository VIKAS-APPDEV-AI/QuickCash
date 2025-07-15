import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quickcash/Screens/ReferAndEarnScreen/refer_and_earn_screen.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
      Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReferAndEarnScreen()),
          );
      },
      child: Container(
        height: 180,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage(
              'assets/images/referAndEarn.png',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black26,
              BlendMode.dstATop,
            ),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900.withOpacity(0.9),
              Colors.purple.shade600.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Invite and Earn With QuickCash!',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Receive interesting incentives and deals as a reward for your recommendation!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 40),
                        // SizedBox(
                        //   width: 190, // Set desired width
                        //   height: 40,
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       // Could navigate to a specific feature
                        //     },
                        //     style: ElevatedButton.styleFrom(
                        //       foregroundColor: Colors.blue.shade900,
                        //       backgroundColor: Colors.white,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(20),
                        //       ),
                        //       padding: const EdgeInsets.symmetric(
                        //         horizontal: 20,
                        //         vertical: 10,
                        //       ),
                        //     ),
                        //     child: const Text(
                        //       'Get Started',
                        //       style: TextStyle(
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 45.0),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white),
                      child: ClipOval(
                        child: Lottie.asset(
                          'assets/lottie/Arrow.json', // Replace with your Lottie file path
                          fit: BoxFit.contain,
                          repeat: true, // Set to false if you want it to play once
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
