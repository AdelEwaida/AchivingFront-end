import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If user is deleting characters
    if (oldValue.text.length > newValue.text.length) {
      // Get the deleted character index
      final int deletedIndex = oldValue.text.length - 1;
      // If the deleted character is a hyphen, delete the previous digit as well
      if (oldValue.text[deletedIndex] == '-') {
        return TextEditingValue(
          text: newValue.text.substring(0, deletedIndex - 1) +
              newValue.text.substring(deletedIndex),
          selection: TextSelection.collapsed(offset: deletedIndex - 1),
        );
      }
    }

    // Formatting logic for typing new characters
    final RegExp phoneRegex = RegExp(r'(\d{1,3})(\d{1,3})?(\d{1,4})?');
    final StringBuffer newText = StringBuffer();
    for (int i = 0; i < newValue.text.length; i += 1) {
      newText.write(newValue.text[i]);
      if (i == 2 || i == 5 || i == 9 || i == 12 || i == 14) {
        if (newValue.text.length == 14) {
          // Add hyphen after 3rd, 6th, 10th and 13th digit if the 14th digit is being entered
          newText.write('-');
        } else if (i != newValue.text.length - 1) {
          // Add hyphen after 3rd, 6th, 10th and 13th digit for subsequent characters
          newText.write('-');
        }
      }
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
