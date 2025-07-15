import 'package:flutter/material.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/PaymentQRCodeScreen/paymentQrCodeScreen.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/SettingsScreen/settings_screen.dart';
import 'package:quickcash/Screens/InvoicesScreen/Settings/TaxScreen/taxScreen.dart';

List<String> titles = <String>[
  'General Settings',
  'Tax',
  'Payment QR Code'
];


class SettingsMainScreen extends StatefulWidget{
  const SettingsMainScreen({super.key});

  @override
  State<SettingsMainScreen> createState() => _SettingsMainScreenState();
}

class _SettingsMainScreenState extends State<SettingsMainScreen>{

  @override
  Widget build(BuildContext context){
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    colorScheme.primary.withOpacity(0.05);
    colorScheme.primary.withOpacity(0.15);
    const int tabsCount = 3;

    return DefaultTabController(
      initialIndex: 0,
        length: tabsCount,
        child: Scaffold(
          body: Column(
            children: [
              Padding(padding: const EdgeInsets.only(top: 0.0),
              child: TabBar(
                isScrollable: true,
                  tabs: <Widget> [
                    Tab(text: titles[0],),
                    Tab(text: titles[1],),
                    Tab(text: titles[2],),
                  ]
              ),
              ),
              const Expanded(
                  child: TabBarView(
                      children: <Widget> [
                        SettingsScreen(),
                        TaxScreen(),
                        PaymentQRCodeScreen(),
                      ]))
            ],
          ),
        )
    );
  }
}