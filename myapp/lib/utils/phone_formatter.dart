/// Utility class for formatting phone numbers to E.164 format
class PhoneFormatter {
  /// Format phone number to E.164 format
  /// E.164 format: +[country code][number]
  /// Example: "55555555" -> "+12345555555" (assuming US country code)
  static String formatToE164(String phoneNumber, {String defaultCountryCode = '+216'}) {
    // Remove all non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // If already starts with +, return as is (assuming it's already formatted)
    if (phoneNumber.trim().startsWith('+')) {
      return phoneNumber.trim();
    }
    
    // If starts with country code digits (like 1 for US), add +
    if (digitsOnly.startsWith('1') && digitsOnly.length == 11) {
      return '+$digitsOnly';
    }
    
    // If 10 digits (US/Canada format), add default country code
    if (digitsOnly.length == 10) {
      return '$defaultCountryCode$digitsOnly';
    }
    
    // If 11 digits and starts with 1, add +
    if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      return '+$digitsOnly';
    }
    
    // For other lengths, try to add default country code
    // This handles cases like 8-digit local numbers
    if (digitsOnly.length < 10) {
      // Assume it's a local number, add country code
      return '$defaultCountryCode$digitsOnly';
    }
    
    // If already 11+ digits, assume it includes country code
    if (digitsOnly.length >= 11) {
      return '+$digitsOnly';
    }
    
    // Default: add country code
    return '$defaultCountryCode$digitsOnly';
  }
  
  /// Validate if phone number is in valid format
  static bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;
    
    // Remove all non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Must start with + and have at least 7 digits after country code (E.164 allows 7-15)
    if (cleaned.startsWith('+')) {
      String digits = cleaned.substring(1);
      return digits.length >= 7 && digits.length <= 15;
    }
    
    // If no +, check if it's a valid length (7-15 digits, we'll add country code)
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 7 && digitsOnly.length <= 15;
  }
  
  /// Get country code from phone number
  static String? getCountryCode(String phoneNumber) {
    if (phoneNumber.startsWith('+')) {
      // Extract country code (usually 1-3 digits)
      String withoutPlus = phoneNumber.substring(1);
      if (withoutPlus.startsWith('1')) return '+1'; // US/Canada
      if (withoutPlus.startsWith('33')) return '+33'; // France
      if (withoutPlus.startsWith('212')) return '+212'; // Morocco
      // Add more as needed
    }
    return '+216'; // Default to Tunisia
  }
}

