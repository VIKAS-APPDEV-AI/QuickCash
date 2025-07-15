import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/model/currencyApiModel/Model/currencyModel.dart';
import 'package:quickcash/model/currencyApiModel/Services/currencyApi.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:http/http.dart' as http;
import 'package:quickcash/util/customSnackBar.dart';

class SelectCurrencyScreen extends StatefulWidget {
  const SelectCurrencyScreen({Key? key}) : super(key: key);

  @override
  _SelectCurrencyScreenState createState() => _SelectCurrencyScreenState();
}

class _SelectCurrencyScreenState extends State<SelectCurrencyScreen> {
  List<CurrencyListsData>? currencyList;
  CurrencyListsData? selectedCurrency;
  String UserId = AuthManager.getUserId();

  @override
  void initState() {
    super.initState();
    fetchCurrencies();
  }

  // Fetch Currency List from API
  Future<void> fetchCurrencies() async {
    final currencyApi = CurrencyApi();

    try {
      final response = await currencyApi.currencyApi();
      print(response); // Print the response to debug
      setState(() {
        currencyList = response.currencyList ?? [];
      });
    } catch (e) {
      print("Error fetching currencies: $e");
    }
  }

  // Add Currency API Call
  Future<void> addCurrency() async {
    if (selectedCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a currency")),
      );
      return;
    }

    final url = Uri.parse("https://quickcash.oyefin.com/api/v1/account/add");

    final Map<String, String> headers = {
      'Authorization': 'Bearer ${AuthManager.getToken()}',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      "user": UserId,
      "currency": selectedCurrency!.currencyCode,
      "amount": "0"
    };

    try {
      final response =
          await http.post(url, headers: headers, body: json.encode(body));

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final Map<String, dynamic> responseData = json.decode(response.body);


       if (responseData['status'] == 201) {
      CustomSnackBar.showSnackBar(
        context: context,
        message: responseData['message'] ?? 'Currency Added Successfully!',
        color: kGreenColor,
      );

      Navigator.pop(context, selectedCurrency);
      return; // Stop further execution
    }// If the status code is NOT 201, show the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add currency: ${response.body}")),
      );
    } catch (e) {
      print("Error adding currency: $e");
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("An error occurred: $e")),
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Currency")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select a Currency:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            DropdownButton<CurrencyListsData>(
              hint: Text("Select Currency"),
              value: selectedCurrency,
              isExpanded: true,
              items: currencyList?.map((CurrencyListsData currency) {
                    return DropdownMenuItem<CurrencyListsData>(
                      value: currency,
                      child: Text("${currency.currencyCode}"),
                    );
                  }).toList() ??
                  [],
              onChanged: (CurrencyListsData? newValue) {
                setState(() {
                  selectedCurrency = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addCurrency,
              child: Text("Add Currency"),
            ),
          ],
        ),
      ),
    );
  }
}
