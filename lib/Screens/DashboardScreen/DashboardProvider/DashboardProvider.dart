import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/BuyAndSellScreen/model/buyAndSellListApi.dart';
import 'package:quickcash/Screens/CryptoScreen/WalletAddress/model/walletAddressApi.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListApi.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountListTransactionApi.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/AccountsList/accountsListModel.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/RevenueList/revenueListApi.dart';
import 'package:quickcash/Screens/DashboardScreen/Dashboard/TransactionList/transactionListApi.dart';
import 'package:quickcash/Screens/KYCScreen/KYCStatusModel/kycStatusApi.dart';
import 'package:quickcash/util/auth_manager.dart';
import '../Dashboard/TransactionList/transactionListModel.dart';
import 'package:quickcash/Screens/CryptoScreen/WalletAddress/model/walletAddressModel.dart';
import 'package:quickcash/Screens/CryptoScreen/BuyAndSell/BuyAndSellScreen/model/buyAndSellListModel.dart';

class DashboardProvider extends ChangeNotifier {
  final WalletAddressApi _walletAddressApi = WalletAddressApi();
  final TransactionListApi _transactionListApi = TransactionListApi();
  final AccountsListApi _accountsListApi = AccountsListApi();
  final CryptoListApi _cryptoListApi = CryptoListApi();
  final AccountListTransactionApi _accountListTransactionApi =
      AccountListTransactionApi();
  final RevenueListApi _revenueListApi = RevenueListApi();
  final KycStatusApi _kycStatusApi = KycStatusApi();

  bool isTokenExpired = false;

  List<WalletAddressListsData> walletAddressList = [];
  List<AccountsListsData> accountsListData = [];
  List<CryptoListsData> cryptoListData = [];
  List<TransactionListDetails> transactionList = [];

  int _selectedFiatIndex = -1; // Default to no fiat selection
  int _selectedCryptoIndex = -1; // Default to no crypto selection
  int _currentFiatPage = 0;
  int _currentCryptoPage = 0;
  String? _selectedCardType = "fiat"; // Changed to "fiat" to match segmented control

  bool isLoading = false;
  bool isTransactionLoading = false;
  String? errorTransactionMessage;
  String? errorMessage;

  double? creditAmount;
  double? debitAmount;
  double? investingAmount;
  double? earningAmount;

  String? accountIdExchange;
  String? accountName;
  String? countryExchange;
  String? currencyExchange;
  String? ibanExchange;
  bool? statusExchange;
  double? amountExchange;
  String? mKycDocumentStatus;

  int get selectedFiatIndex => _selectedFiatIndex;
  int get selectedCryptoIndex => _selectedCryptoIndex;
  int get currentFiatPage => _currentFiatPage;
  int get currentCryptoPage => _currentCryptoPage;
  String? get selectedCardType => _selectedCardType;

  DashboardProvider() {
    initializeData();
  }

  // Add this method to update selectedCardType
  void setSelectedCardType(String type) {
    _selectedCardType = type;
    // Reset indices when switching sections to ensure proper behavior
    if (type != "fiat") {
      _selectedFiatIndex = -1;
    }
    if (type != "crypto") {
      _selectedCryptoIndex = -1;
    }
    notifyListeners();
  }

  Future<void> initializeData() async {
    await AuthManager.init();
    if (AuthManager.getKycStatus() == "completed") {
      isLoading = true;
      notifyListeners();
      await Future.wait([
        fetchAccounts(),
        fetchCryptoAccounts(),
        fetchRevenueList(),
        fetchTransactionList(),
        fetchWalletAddresses(),
      ]);
      _restoreSelectedAccount();
      isLoading = false;
      notifyListeners();
    }
    await fetchKycStatus();
    if (AuthManager.isFreshLogin()) {
      notifyListeners(); // Ensure UI updates after fresh login
    }
  }

  // Reset all state to initial values
  void resetState() {
    isTokenExpired = false;
    walletAddressList = [];
    accountsListData = [];
    cryptoListData = [];
    transactionList = [];
    _selectedFiatIndex = -1;
    _selectedCryptoIndex = -1;
    _currentFiatPage = 0;
    _currentCryptoPage = 0;
    _selectedCardType = "fiat"; // Reset to "fiat"
    isLoading = false;
    isTransactionLoading = false;
    errorTransactionMessage = null;
    errorMessage = null;
    creditAmount = null;
    debitAmount = null;
    investingAmount = null;
    earningAmount = null;
    accountIdExchange = null;
    accountName = null;
    countryExchange = null;
    currencyExchange = null;
    ibanExchange = null;
    statusExchange = null;
    amountExchange = null;
    mKycDocumentStatus = null;
    notifyListeners();
  }

  // Call this after login to reset and reload data
  Future<void> reloadAfterLogin() async {
    print("reloadAfterLogin: Starting reset and reload"); // Debug
    resetState();
    await initializeData();
    if (AuthManager.isFreshLogin()) {
      print("reloadAfterLogin: Clearing fresh login flag"); // Debug
      AuthManager.clearFreshLogin();
    }
    print("reloadAfterLogin: Completed"); // Debug
  }

  List<CryptoListsData> get filteredCryptoTransactions {
    if (_selectedCardType != "crypto" ||
        _selectedCryptoIndex < 0 ||
        _selectedCryptoIndex >= walletAddressList.length) {
      return cryptoListData;
    }
    String selectedCoin = walletAddressList[_selectedCryptoIndex]
        .coin!
        .split('_')[0]
        .toUpperCase();
    return cryptoListData
        .where((transaction) =>
            transaction.coinName?.toUpperCase().split('_')[0] == selectedCoin)
        .toList();
  }

  Future<void> fetchWalletAddresses() async {
    try {
      final response = await _walletAddressApi.walletAddressApi();
      walletAddressList = response.walletAddressList ?? [];
      errorMessage =
          walletAddressList.isEmpty ? "No Wallet Addresses Found" : null;
      isTokenExpired = false;
    } catch (error) {
      if (error is DioException && error.response?.statusCode == 403) {
        isTokenExpired = true;
        errorMessage = "Token has been expired / Missing Token";
      } else {
        errorMessage = error.toString();
      }
    }
    notifyListeners();
  }

  Future<void> fetchKycStatus() async {
    try {
      final response = await _kycStatusApi.kycStatusApi();
      if (response.message == "kyc data are fetched Successfully") {
        await AuthManager.saveKycStatus(
            response.kycStatusDetails!.first.kycStatus!);
        await AuthManager.saveKycId(response.kycStatusDetails!.first.kycId!);
        await AuthManager.saveKycDocFront(
            response.kycStatusDetails!.first.documentPhotoFront!);
        mKycDocumentStatus =
            response.kycStatusDetails!.first.documentPhotoFront;
      }
      isTokenExpired = false;
    } catch (error) {
      if (error is DioException && error.response?.statusCode == 403) {
        isTokenExpired = true;
        errorMessage = "Token has been expired / Missing Token";
      } else {
        errorMessage = error.toString();
      }
    }
    notifyListeners();
  }

  Future<void> fetchAccounts() async {
    try {
      final response = await _accountsListApi.accountsListApi();
      accountsListData = response.accountsList ?? [];
      errorMessage = accountsListData.isEmpty ? 'No Account Found' : null;
      isTokenExpired = false;
    } catch (error) {
      if (error is DioException && error.response?.statusCode == 403) {
        isTokenExpired = true;
        errorMessage = "Token has been expired / Missing Token";
      } else {
        errorMessage = error.toString();
        isTokenExpired = true;
      }
    }
    notifyListeners();
  }

  Future<void> fetchCryptoAccounts() async {
    try {
      final response = await _cryptoListApi.cryptoListApi();
      cryptoListData = response.cryptoList ?? [];
      errorMessage = cryptoListData.isEmpty ? 'No Data' : null;
      isTokenExpired = false;
    } catch (error) {
      if (error is DioException && error.response?.statusCode == 403) {
        isTokenExpired = true;
        errorMessage = "Token has been expired / Missing Token";
      } else {
        errorMessage = error.toString();
        isTokenExpired = true;
      }
    }
    notifyListeners();
  }

  Future<void> fetchTransactionList() async {
    isTransactionLoading = true;
    notifyListeners();
    try {
      final response = await _transactionListApi.transactionListApi();
      transactionList = response.transactionList ?? [];
      errorTransactionMessage =
          transactionList.isEmpty ? 'No Transaction List' : null;
      isTokenExpired = false;
    } catch (error) {
      if (error is DioException && error.response?.statusCode == 403) {
        isTokenExpired = true;
        errorTransactionMessage = "Token has been expired / Missing Token";
      } else {
        errorTransactionMessage = error.toString();
      }
    }
    isTransactionLoading = false;
    notifyListeners();
  }

  Future<void> fetchAccountListTransaction(
      String accountId, String currency) async {
    isTransactionLoading = true;
    notifyListeners();
    try {
      final response = await _accountListTransactionApi.accountListTransaction(
          accountId, currency, AuthManager.getUserId());
      transactionList = response.transactionList ?? [];
      errorTransactionMessage =
          transactionList.isEmpty ? 'No Transaction List' : null;
      isTokenExpired = false;
    } catch (error) {
      if (error is DioException && error.response?.statusCode == 403) {
        isTokenExpired = true;
        errorTransactionMessage = "Token has been expired / Missing Token";
      } else {
        errorTransactionMessage = error.toString();
      }
    }
    isTransactionLoading = false;
    notifyListeners();
  }

  Future<void> fetchRevenueList() async {
    try {
      final response = await _revenueListApi.revenueListApi();
      creditAmount = response.creditAmount ?? 0.0;
      debitAmount = response.debitAmount ?? 0.0;
      investingAmount = response.investingAmount ?? 0.0;
      earningAmount = response.earningAmount ?? 0.0;
      isTokenExpired = false;
    } catch (error) {
      if (error is DioException && error.response?.statusCode == 403) {
        isTokenExpired = true;
        errorMessage = "Token has been expired / Missing Token";
      } else {
        errorMessage = error.toString();
      }
    }
    notifyListeners();
  }

  void selectFiatCard(int index, AccountsListsData data) {
    if (index >= 0 && index < accountsListData.length) {
      _selectedFiatIndex = index;
      _selectedCryptoIndex = -1;
      _selectedCardType = "fiat";
      accountName = data.Accountname;
      accountIdExchange = data.accountId;
      countryExchange = data.country;
      currencyExchange = data.currency;
      ibanExchange = data.iban;
      statusExchange = data.status;
      amountExchange = data.amount;
      AuthManager.saveCurrency(data.currency!);
      AuthManager.saveAccountBalance(data.amount.toString());
      AuthManager.saveSelectedAccountId(data.accountId!);
      fetchAccountListTransaction(data.accountId!, data.currency!);
      notifyListeners();
    }
  }

  void selectCryptoCard(int index) {
    if (index >= 0 && index < walletAddressList.length) {
      _selectedCryptoIndex = index;
      _selectedFiatIndex = -1;
      _selectedCardType = "crypto";
      AuthManager.saveSelectedAccountId('');
      notifyListeners();
    }
  }

  void updateFiatPage(int index) {
    _currentFiatPage = index;
    notifyListeners();
  }

  void updateCryptoPage(int index) {
    _currentCryptoPage = index;
    notifyListeners();
  }

  Future<void> refreshData() async {
    isLoading = true;
    notifyListeners();
    await Future.wait([
      fetchAccounts(),
      fetchCryptoAccounts(),
      fetchRevenueList(),
      fetchTransactionList(),
      fetchWalletAddresses(),
    ]);
    _restoreSelectedAccount();
    isLoading = false;
    notifyListeners();
  }

  void _restoreSelectedAccount() {
    if (accountsListData.isNotEmpty) {
      final savedAccountId = AuthManager.getSelectedAccountId();
      if (savedAccountId.isNotEmpty) {
        final accountIndex = accountsListData
            .indexWhere((account) => account.accountId == savedAccountId);
        if (accountIndex != -1) {
          selectFiatCard(accountIndex, accountsListData[accountIndex]);
          _currentFiatPage = accountIndex;
          return;
        }
      }
      final usdIndex =
          accountsListData.indexWhere((account) => account.currency == "USD");
      if (usdIndex != -1) {
        selectFiatCard(usdIndex, accountsListData[usdIndex]);
        _currentFiatPage = usdIndex;
      } else if (accountsListData.isNotEmpty) {
        selectFiatCard(0, accountsListData[0]);
        _currentFiatPage = 0;
      }
    }
    if (_selectedCardType != "fiat" && walletAddressList.isNotEmpty) {
      selectCryptoCard(0);
      _currentCryptoPage = 0;
    } else if (_selectedCardType == "") {
      _selectedFiatIndex = -1;
      _selectedCryptoIndex = -1;
      _selectedCardType = "fiat"; // Changed to "fiat"
      _currentFiatPage = 0;
      _currentCryptoPage = 0;
    }
  }
}