import 'package:flutter/services.dart';

class MyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final RegExp regExp = RegExp(r'^[a-zA-Z0-9_\-\u0600-\u06FF ]*$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    } else {
      // If the entered text doesn't match the allowed pattern, keep the old value.
      return oldValue;
    }
  }
}
