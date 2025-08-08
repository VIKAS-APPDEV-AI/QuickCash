import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:quickcash/Screens/CardsScreen/CardSelection.dart';

class FinPayWelcomeScreen extends StatefulWidget {
  const FinPayWelcomeScreen({super.key});

  @override
  State<FinPayWelcomeScreen> createState() => _FinPayWelcomeScreenState();
}

class _FinPayWelcomeScreenState extends State<FinPayWelcomeScreen>
    with TickerProviderStateMixin {
  // Changed to TickerProviderStateMixin
  late AnimationController _controller;
  late AnimationController _arrowController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _arrowBounceAnimation;
  late List<Animation<Offset>> _cardSlideAnimations;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize main controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Initialize arrow controller
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Initialize fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Initialize card slide animations
    _cardSlideAnimations = List.generate(3, (index) {
      return Tween<Offset>(
        begin: Offset(-1.0 - index * 0.2, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.2 + index * 0.1,
            0.7 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    // Initialize text slide animation
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Initialize arrow bounce animation
    _arrowBounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _arrowController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _controller.forward();
    _arrowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  Widget buildCard({
    required String name,
    required String number,
    double angle = 0,
    double xOffset = 0,
    double marginTop = 0,
    String? flagAsset,
    required Animation<Offset> slideAnimation,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = screenWidth * 0.85;
        final cardHeight = screenWidth * 0.5;
        final fontScale = screenWidth / 375;

        return SlideTransition(
          position: slideAnimation,
          child: Transform.translate(
            offset: Offset(xOffset * fontScale, marginTop * fontScale),
            child: Transform.rotate(
              angle: angle,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20 * fontScale),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6F35A5),
                      Color(0x00000000),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(20 * fontScale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/chip.png',
                            width: 30 * fontScale,
                            height: 30 * fontScale,
                          ),
                          const Spacer(),
                          if (flagAsset != null)
                            Image.asset(
                              flagAsset,
                              width: 28 * fontScale,
                              height: 20 * fontScale,
                            ),
                        ],
                      ),
                      SizedBox(height: 20 * fontScale),
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22 * fontScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10 * fontScale),
                      Text(
                        number,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18 * fontScale,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBouncyArrow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final fontScale = screenWidth / 375;

        return SlideTransition(
          position: _textSlideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: AnimatedBuilder(
              animation: _arrowBounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_arrowBounceAnimation.value, 0),
                  child: child,
                );
              },
              child: InkWell(
                onTap: (){
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => CardSelectionScreen(),));
                },
                child: Container(
                  width: 60 * fontScale,
                  height: 60 * fontScale,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.blue,
                    size: 30 * fontScale,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontScale = screenWidth / 375;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/c.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),

            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.0 * fontScale,
                  vertical: 50 * fontScale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30 * fontScale),

                    // Card Stack
                    SizedBox(
                      height: screenWidth * 0.75,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          buildCard(
                            name: "EUR CARD",
                            number: "**** **** 1435",
                            angle: -5 * pi / 180,
                            xOffset: -20,
                            marginTop: 40,
                            flagAsset: 'assets/icons/euro.png',
                            slideAnimation: _cardSlideAnimations[0],
                          ),
                          buildCard(
                            name: "INR CARD",
                            number: "**** **** 7223",
                            angle: 0,
                            xOffset: 0,
                            marginTop: 20,
                            flagAsset: 'assets/icons/ind.png',
                            slideAnimation: _cardSlideAnimations[1],
                          ),
                          buildCard(
                            name: "AUD CARD",
                            number: "**** **** 9988",
                            angle: 6 * pi / 180,
                            xOffset: 20,
                            marginTop: 0,
                            flagAsset: 'assets/icons/aust.png',
                            slideAnimation: _cardSlideAnimations[2],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          "Managing your Card is about to get a lot better.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22 * fontScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30 * fontScale),

                    _buildBouncyArrow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
