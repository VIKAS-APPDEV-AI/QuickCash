import 'package:flutter/material.dart';
import 'package:quickcash/components/background.dart';

class InvoiceTemplatesScreen extends StatefulWidget {
  const InvoiceTemplatesScreen({super.key});

  @override
  State<InvoiceTemplatesScreen> createState() => _InvoiceTemplatesScreenState();
}

class _InvoiceTemplatesScreenState extends State<InvoiceTemplatesScreen> {

  @override
  Widget build(BuildContext context) {
    return const Background(
      child: SafeArea(
        child: Column(
          children: [
            // You can add more widgets below this Row if needed
            Expanded(
              child: Center(
                child:
                Text('Invoice Templates Screen'), // Placeholder for main content
              ),
            ),
          ],
        ),
      ),
    );
  }

}