import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkUtils {
  // Check if there's an active internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Handle API response errors
  static String handleApiError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please check your API key.';
      case 403:
        return 'Forbidden. You do not have access to this resource.';
      case 404:
        return 'Resource not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred: ${response.statusCode}';
    }
  }

  // Format API error message
  static String formatErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is HttpException) {
      return 'Could not find the requested data. Please try again.';
    } else if (error is FormatException) {
      return 'Bad response format. Please try again later.';
    } else {
      return error.toString();
    }
  }
}
