import 'package:intl/intl.dart';

class DateFormatter {
  // Format date string from API (YYYY-MM-DD) to a more readable format
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Unknown';
    }
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }
  
  // Calculate age from date of birth
  static int calculateAge(String? dateOfBirth) {
    if (dateOfBirth == null || dateOfBirth.isEmpty) {
      return 0;
    }
    
    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final today = DateTime.now();
      
      int age = today.year - birthDate.year;
      
      // Adjust age if birthday hasn't occurred yet this year
      if (today.month < birthDate.month || 
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      
      return age;
    } catch (e) {
      return 0;
    }
  }
  
  // Format date range (for competition seasons)
  static String formatDateRange(String? startDate, String? endDate) {
    if (startDate == null || endDate == null || 
        startDate.isEmpty || endDate.isEmpty) {
      return 'Unknown period';
    }
    
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      
      final startFormatted = DateFormat('MMM d, yyyy').format(start);
      final endFormatted = DateFormat('MMM d, yyyy').format(end);
      
      return '$startFormatted - $endFormatted';
    } catch (e) {
      return '$startDate - $endDate'; // Return original strings if parsing fails
    }
  }
}
