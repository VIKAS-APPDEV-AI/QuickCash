// add_money_screen.dart
import 'package:flutter/material.dart';
import 'package:quickcash/Screens/DashboardScreen/AddMoneyScreen/Add_Money_Provider.dart/Add_Money_Screen_Logic.dart';
import 'package:quickcash/Screens/DashboardScreen/AddMoneyScreen/Add_Money_Provider.dart/Add_Money_Screen_UI.dart';


class AddMoneyScreen extends StatelessWidget {
  final String? accountId;
  final String? accountName;
  final String? country;
  final String? currency;
  final String? iban;
  final bool? status;
  final double? amount;

  const AddMoneyScreen({
    super.key,
    this.accountId,
    this.country,
    this.currency,
    this.iban,
    this.status,
    this.amount,
    this.accountName,
  });

  @override
  Widget build(BuildContext context) {
    final logic = AddMoneyScreenLogic(
      accountId: accountId,
      accountName: accountName,
      country: country,
      currency: currency,
      iban: iban,
      status: status,
      amount: amount,
    );
    
    return AddMoneyScreenUI(logic: logic);
  }
}