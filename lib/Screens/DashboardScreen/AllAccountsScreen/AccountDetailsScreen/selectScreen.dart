import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'package:quickcash/Screens/NotificationsScreen.dart/NotificationScreen.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/model/currencyApiModel/Model/currencyModel.dart';
import 'package:quickcash/model/currencyApiModel/Services/currencyApi.dart';
import 'package:quickcash/util/auth_manager.dart';
import 'package:quickcash/util/currency_utils.dart';
import 'package:quickcash/util/customSnackBar.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectCurrencyScreen extends StatefulWidget {
  const SelectCurrencyScreen({super.key});

  @override
  State<SelectCurrencyScreen> createState() => _SelectCurrencyScreenState();
}

class _SelectCurrencyScreenState extends State<SelectCurrencyScreen> {
  List<CurrencyListsData>? currencyList;
  CurrencyListsData? selectedCurrency;
  String userId = AuthManager.getUserId();
  bool isLoading = false;
  bool isNewsLoading = false;
  List<dynamic> newsArticles = [];

  // Theme gradient for AppBar
  static const themeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 6, 6, 6), // Dark neo-banking color
      Color(0xFF8A2BE2), // Gradient transition
      Color(0x00000000), // Transparent fade// Transparent fade
    ],
    stops: [0.0, 0.7, 1.0],
  );

  @override
  void initState() {
    super.initState();
    fetchCurrencies();
    fetchCurrencyNews();
  }

  // Fetch currency list from API
  Future<void> fetchCurrencies() async {
    setState(() => isLoading = true);
    final currencyApi = CurrencyApi();

    try {
      final response = await currencyApi.currencyApi();
      setState(() {
        currencyList = response.currencyList ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching currencies: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error fetching currencies"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Add currency via API
  Future<void> addCurrency() async {
    if (selectedCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a currency", style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse("https://quickcash.oyefin.com/api/v1/account/add");
    final headers = {
      'Authorization': 'Bearer ${AuthManager.getToken()}',
      'Content-Type': 'application/json',
    };
    final body = {
      "user": userId,
      "currency": selectedCurrency!.currencyCode,
      "amount": "0",
    };

    try {
      final response =
          await http.post(url, headers: headers, body: json.encode(body));
      setState(() => isLoading = false);

      final responseData = json.decode(response.body);

      if (responseData['status'] == 201) {
        CustomSnackBar.showSnackBar(
          context: context,
          message: responseData['message'] ?? 'Currency Added Successfully!',
          color: Colors.green,
        );
        Navigator.pop(context, selectedCurrency);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Failed to add currency: ${responseData['message'] ?? 'Unknown error'}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error adding currency: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Fetch currency-related news from NewsAPI
  Future<void> fetchCurrencyNews() async {
    setState(() => isNewsLoading = true);

    // Replace with your actual NewsAPI key
    const apiKey =
        '6c41a5cc7ebe4221a238471104f4a5b5'; // Get from https://newsapi.org/
    final url = Uri.parse(
      'https://newsapi.org/v2/everything?q=currency${selectedCurrency != null ? "+${selectedCurrency!.currencyCode}" : ""}&apiKey=$apiKey',
    );

    try {
      final response = await http.get(url);
      setState(() => isNewsLoading = false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          newsArticles = data['articles']?.take(5).toList() ?? [];
        });
      } else {
        print("Failed to fetch news: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to load news"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() => isNewsLoading = false);
      print("Error fetching news: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error loading news"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          "Select Currency",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.bell_fill,
              color: AppColors.light.white,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => NotificationScreen(),
                  ));
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: Icon(
              CupertinoIcons.headphones,
              color: AppColors.light.white,
            ),
            onPressed: () {
              print('Support tapped');
            },
            tooltip: 'Support',
          ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 6, 6, 6), // Dark neo-banking color
                Color(0xFF8A2BE2), // Gradient transition
                Color(0x00000000), // Transparent fade
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    Colors.grey[900]!, // Dark grey for dark mode
                    Colors.black, // Even darker towards bottom
                  ]
                : [
                    Colors.white, // Light mode top
                    Color(0xFFF5F5F5), // Light grey bottom
                  ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  "Choose Your Currency",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.light.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                        color: AppColors.light.primary,
                      ))
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.light.primary, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CurrencyListsData>(
                            hint: const Text(
                              "Select Currency",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                            value: selectedCurrency,
                            isExpanded: true,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.light.primary,
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            items: currencyList?.map((currency) {
                                  return DropdownMenuItem<CurrencyListsData>(
                                    value: currency,
                                    child: Row(
                                      children: [
                                        Text(
                                          '${currency.currencyCode}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "(${getCurrencySymbol(currency.currencyCode)})",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList() ??
                                [],
                            onChanged: (newValue) {
                              setState(() {
                                selectedCurrency = newValue;
                                fetchCurrencyNews();
                              });
                            },
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 30),
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : addCurrency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors
                          .light.primary, // Solid purple for visibility
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black26,
                    ).copyWith(
                      overlayColor: WidgetStateProperty.all(
                          Colors.white.withOpacity(0.2)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Add Currency",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Latest Currency News",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                         color: isDarkMode ? Colors.white : AppColors.light.primary
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: isDarkMode ? Colors.white : AppColors.light.primary
                      ),
                      onPressed: fetchCurrencyNews,
                      tooltip: 'Refresh News',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: isNewsLoading
                    ? Center(
                        child: CircularProgressIndicator(
                        color: AppColors.light.primary,
                      ))
                    : newsArticles.isEmpty
                        ? const Center(
                            child: Text(
                              "No news available",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: newsArticles.length,
                            itemBuilder: (context, index) {
                              final article = newsArticles[index];
                              return FadeInUp(
                                duration:
                                    Duration(milliseconds: 900 + index * 100),
                                child: Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  elevation: 3,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                        color: AppColors.light.primary,
                                        width: 1.5),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () async {
                                      final url = article['url'];
                                      if (url != null &&
                                          await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(
                                          Uri.parse(url),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text("Unable to open article"),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: article['urlToImage'] != null
                                                ? Image.network(
                                                    article['urlToImage'],
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Container(
                                                      width: 80,
                                                      height: 80,
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  article['title'] ??
                                                      'No Title',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  article['description'] ??
                                                      'No Description',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  article['source']?['name'] ??
                                                      'Unknown Source',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.light.primary,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
