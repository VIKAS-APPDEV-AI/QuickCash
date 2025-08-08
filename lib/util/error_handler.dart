// lib/utils/error_handler.dart
String getFriendlyErrorMessage(dynamic error) {
  final errorStr = error.toString();

  if (errorStr.contains("SocketException")) {
    return "No internet connection. Please check your network.";
  } else if (errorStr.contains("TimeoutException")) {
    return "Connection timeout. Please try again later.";
  } else if (errorStr.contains("DioError")) {
    return "Server is not responding. Try again shortly.";
  } else {
    return "Unexpected error occurred. Please try again.";
  }
}
