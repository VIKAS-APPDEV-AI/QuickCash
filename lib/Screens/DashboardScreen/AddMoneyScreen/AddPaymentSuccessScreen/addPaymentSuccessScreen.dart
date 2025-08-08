import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quickcash/components/background.dart';
import 'package:quickcash/constants.dart';
import '../../../HomeScreen/home_screen.dart';

class AddPaymentSuccessScreen extends StatefulWidget {
  final String? transactionId;
  final String? amount;
  const AddPaymentSuccessScreen({super.key, this.transactionId, this.amount});

  @override
  State<AddPaymentSuccessScreen> createState() =>
      _AddPaymentSuccessScreenState();
}

class _AddPaymentSuccessScreenState extends State<AddPaymentSuccessScreen> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Trigger the animation after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isVisible = true;
      });
    });
  }

  Future<bool> _onWillPop() async {
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Background(
        child: Stack(
          children: [
            // Confetti animation
            Lottie.asset(
              'assets/lottie/confetti.json',
              repeat: true, // Loop the animation
            ),
            // Animated central message box with fade and scale
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _isVisible ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                transform: Matrix4.identity()..scale(_isVisible ? 1.0 : 0.5),
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 100),
                      Image.asset(
                        "assets/images/tick.png",
                        fit: BoxFit.contain,
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: largePadding),
                      Text(
                        "Transaction Successful",
                        style: TextStyle(
                          color:
                              Theme.of(context).extension<AppColors>()!.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: smallPadding),
                      Text(
                        'Successfully paid ${widget.amount}',
                        maxLines: 3,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      const SizedBox(height: 75),
                      Card(
                        elevation: 1.0,
                        color: isDarkMode
                            ? const Color.fromARGB(166, 252, 251, 253)
                            : const Color(0xA66F35A5),
                        margin: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 0),
                        child: Padding(
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Transaction Id',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode
                                          ? const Color.fromARGB(
                                              255, 15, 15, 15)
                                          : Colors.grey[100],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: Text(
                                      '${widget.transactionId}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .extension<AppColors>()!
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: defaultPadding),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode
                                          ? const Color.fromARGB(
                                              255, 15, 15, 15)
                                          : Colors.grey[100],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 6,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'Success',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 50,
                          child: FloatingActionButton.extended(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            },
                            label: const Text(
                              'Home',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            backgroundColor: Theme.of(context)
                                .extension<AppColors>()!
                                .primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
