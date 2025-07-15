import 'package:flutter/material.dart';
import 'package:quickcash/Screens/UserProfileScreen/LoginHistoryScreen/model/loginHistoryApi.dart';
import 'package:quickcash/Screens/UserProfileScreen/LoginHistoryScreen/model/loginHistoryModel.dart';
import 'package:quickcash/constants.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

class LoginHistoryScreen extends StatefulWidget {
  const LoginHistoryScreen({super.key});

  @override
  State<LoginHistoryScreen> createState() => _LoginHistoryScreen();
}

class _LoginHistoryScreen extends State<LoginHistoryScreen> {
  final LoginHistoryApi _loginHistoryApi = LoginHistoryApi();

  List<LoginHistoryListDetails> loginHistoryData = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    mLoginHistoryList();
  }

  Future<void> mLoginHistoryList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _loginHistoryApi.loginHistoryListApi();

      if (response.loginHistoryList != null && response.loginHistoryList!.isNotEmpty) {
        setState(() {
          loginHistoryData = response.loginHistoryList!;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No accounts found.';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  // Function to get ordinal suffix for the day
  String getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

// Function to format the date
  String formatDate(String? dateTime) {
    if (dateTime == null) {
      return 'Date not available'; // Fallback text if dateTime is null
    }
    DateTime date = DateTime.parse(dateTime);

    // Get the ordinal suffix for the day
    String ordinalDay = getOrdinalSuffix(date.day);

    // Format the date and time
    String formattedDate = DateFormat('MMMM d, yyyy, h:mm:ss a').format(date);

    // Replace the day (without the suffix) with the day including the ordinal suffix
    formattedDate = formattedDate.replaceFirst('${date.day}', ordinalDay);

    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16.0), // Adjust the height as needed
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
          if (errorMessage != null)
            Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red))),
          if (!isLoading && errorMessage == null && loginHistoryData.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: loginHistoryData.length,
                itemBuilder: (context, index) {
                  final history = loginHistoryData[index];
                  return Card(
                    color: kPrimaryColor, // Change this to your desired color
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Format and display the date
                          Text(
                            'Date: ${formatDate(history.date)}',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Device: ${history.device}',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'OS: ${history.os}',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'IP Address: ${history.ipAddress}',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
