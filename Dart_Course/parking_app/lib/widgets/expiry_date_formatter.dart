import 'package:flutter/services.dart';

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    // Remove all non-digit characters
    String digitsOnly = newText.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 4 digits (MMYY)
    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }
    
    // Format as MM/YY
    String formatted = '';
    if (digitsOnly.isNotEmpty) {
      if (digitsOnly.length == 1) {
        formatted = digitsOnly;
      } else if (digitsOnly.length == 2) {
        formatted = digitsOnly;
      } else if (digitsOnly.length == 3) {
        formatted = '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2)}';
      } else if (digitsOnly.length == 4) {
        formatted = '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2)}';
      }
    }
    
    // Calculate cursor position
    int cursorPosition = formatted.length;
    if (newValue.selection.baseOffset < newText.length) {
      final originalCursorPos = newValue.selection.baseOffset;
      int digitsBeforeCursor = 0;
      
      for (int i = 0; i < originalCursorPos && i < newText.length; i++) {
        if (RegExp(r'\d').hasMatch(newText[i])) {
          digitsBeforeCursor++;
        }
      }
      
      if (digitsBeforeCursor <= 2) {
        cursorPosition = digitsBeforeCursor;
      } else {
        cursorPosition = digitsBeforeCursor + 1; // +1 for the slash
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class ExpiryDateValidator {
  static bool isValidExpiryDate(String expiryDate) {
    // Remove non-digits
    final digitsOnly = expiryDate.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length != 4) {
      return false;
    }
    
    final month = int.tryParse(digitsOnly.substring(0, 2));
    final year = int.tryParse(digitsOnly.substring(2, 4));
    
    if (month == null || year == null) {
      return false;
    }
    
    // Check month validity
    if (month < 1 || month > 12) {
      return false;
    }
    
    // Check if the card has expired
    final now = DateTime.now();
    final currentYear = now.year % 100; // Get last 2 digits of current year
    final currentMonth = now.month;
    
    if (year < currentYear) {
      return false;
    }
    
    if (year == currentYear && month < currentMonth) {
      return false;
    }
    
    return true;
  }
  
  static String? getExpiryError(String expiryDate) {
    final digitsOnly = expiryDate.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.isEmpty) {
      return 'Expiry date is required';
    }
    
    if (digitsOnly.length < 4) {
      return 'Enter MM/YY format';
    }
    
    final month = int.tryParse(digitsOnly.substring(0, 2));
    final year = int.tryParse(digitsOnly.substring(2, 4));
    
    if (month == null || year == null) {
      return 'Invalid expiry date';
    }
    
    if (month < 1 || month > 12) {
      return 'Invalid month';
    }
    
    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;
    
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }
    
    return null;
  }
  
  static Map<String, String> parseExpiryDate(String expiryDate) {
    final digitsOnly = expiryDate.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length == 4) {
      return {
        'month': digitsOnly.substring(0, 2),
        'year': '20${digitsOnly.substring(2, 4)}',
      };
    }
    
    return {'month': '', 'year': ''};
  }
}
