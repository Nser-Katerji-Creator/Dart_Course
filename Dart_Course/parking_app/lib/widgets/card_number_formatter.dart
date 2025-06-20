import 'package:flutter/services.dart';

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    // Remove all non-digit characters
    String digitsOnly = newText.replaceAll(RegExp(r'\D'), '');
    
    // Limit to 19 digits (longest card number)
    if (digitsOnly.length > 19) {
      digitsOnly = digitsOnly.substring(0, 19);
    }
    
    // Format with spaces every 4 digits
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += digitsOnly[i];
    }
    
    // Calculate cursor position
    int cursorPosition = formatted.length;
    if (newValue.selection.baseOffset < newText.length) {
      // User is editing in the middle, try to maintain relative cursor position
      final originalCursorPos = newValue.selection.baseOffset;
      int spacesBeforeCursor = 0;
      int digitsBeforeCursor = 0;
      
      for (int i = 0; i < originalCursorPos && i < newText.length; i++) {
        if (RegExp(r'\d').hasMatch(newText[i])) {
          digitsBeforeCursor++;
        }
      }
      
      // Count spaces that should be before this many digits
      spacesBeforeCursor = (digitsBeforeCursor - 1) ~/ 4;
      if (digitsBeforeCursor > 0) {
        cursorPosition = digitsBeforeCursor + spacesBeforeCursor;
      } else {
        cursorPosition = 0;
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class CardNumberValidator {
  static bool isValidCardNumber(String cardNumber) {
    // Remove spaces and non-digits
    final digitsOnly = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    // Check length
    if (digitsOnly.length < 13 || digitsOnly.length > 19) {
      return false;
    }
    
    // Luhn algorithm
    return _luhnCheck(digitsOnly);
  }
  
  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool isEven = false;
    
    // Process digits from right to left
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      
      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit = digit ~/ 10 + digit % 10;
        }
      }
      
      sum += digit;
      isEven = !isEven;
    }
    
    return sum % 10 == 0;
  }
  
  static String getCardType(String cardNumber) {
    final digitsOnly = cardNumber.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.startsWith('4')) {
      return 'Visa';
    } else if (RegExp(r'^5[1-5]').hasMatch(digitsOnly) || 
               RegExp(r'^2[2-7]').hasMatch(digitsOnly)) {
      return 'Mastercard';
    } else if (RegExp(r'^3[47]').hasMatch(digitsOnly)) {
      return 'American Express';
    } else if (RegExp(r'^6(?:011|5)').hasMatch(digitsOnly)) {
      return 'Discover';
    } else if (RegExp(r'^35').hasMatch(digitsOnly)) {
      return 'JCB';
    } else if (RegExp(r'^3[068]').hasMatch(digitsOnly)) {
      return 'Diners Club';
    } else if (RegExp(r'^(5018|5020|5038|6304|6759|6761|6762|6763)').hasMatch(digitsOnly)) {
      return 'Maestro';
    }
    
    return 'Unknown';
  }
}
