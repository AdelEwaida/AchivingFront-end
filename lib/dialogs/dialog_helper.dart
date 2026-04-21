import 'package:flutter/material.dart';

class DialogHelper {
  static Future<T?> showAppDialog<T>({
    required BuildContext context,
    required Widget child,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => child,
    );
  }
}
