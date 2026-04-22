import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomToastMessage {
  /// ==============================
  /// 🔹 Base Method (General)
  /// ==============================
  static Future<bool?> _show({
    required String msg,
    Toast? toastLength,
    int timeInSecForIosWeb = 1,
    double? fontSize,
    String? fontAsset,
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    bool webShowClose = false,
    dynamic webBgColor,
    dynamic webPosition,
  }) {
    // Only cancel on native platforms, not on web
    if (!kIsWeb) {
      try {
        Fluttertoast.cancel();
      } catch (e) {
        // Ignore cancel errors on platforms that don't support it
        debugPrint("Toast cancel error: $e");
      }
    }

    return Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      timeInSecForIosWeb: timeInSecForIosWeb,
      fontSize: fontSize,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      webShowClose: webShowClose,
      webBgColor: webBgColor,
      webPosition: webPosition,
    );
  }

  /// ==============================
  /// ✅ Success
  /// ==============================
  static Future<bool?> success(
    BuildContext context,
    String msg, {
    Toast? toastLength,
    int timeInSecForIosWeb = 2,
    double? fontSize,
    String? fontAsset,
    ToastGravity? gravity = ToastGravity.TOP,
    Color? backgroundColor = Colors.green,
    Color? textColor = Colors.white,
    bool webShowClose = false,
    dynamic webBgColor = "linear-gradient(to right, #00b09b, #96c93d)",
    dynamic webPosition = "center",
  }) {
    return _show(
      msg: msg,
      toastLength: toastLength,
      timeInSecForIosWeb: timeInSecForIosWeb,
      fontSize: fontSize,
      fontAsset: fontAsset,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      webShowClose: webShowClose,
      webBgColor: webBgColor,
      webPosition: webPosition,
    );
  }

  /// ==============================
  /// ❌ Error
  /// ==============================
  static Future<bool?> error(
    BuildContext context,
    String msg, {
    Toast? toastLength,
    int timeInSecForIosWeb = 2,
    double? fontSize,
    String? fontAsset,
    ToastGravity? gravity = ToastGravity.TOP,
    Color? backgroundColor = Colors.red,
    Color? textColor = Colors.white,
    bool webShowClose = false,
    dynamic webBgColor = "linear-gradient(to right, #ff416c, #ff4b2b)",
    dynamic webPosition = "right",
  }) {
    return _show(
      msg: msg,
      toastLength: toastLength,
      timeInSecForIosWeb: timeInSecForIosWeb,
      fontSize: fontSize,
      fontAsset: fontAsset,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      webShowClose: webShowClose,
      webBgColor: webBgColor,
      webPosition: webPosition,
    );
  }

  /// ==============================
  /// ⚠️ Warning
  /// ==============================
  static Future<bool?> warning(
    BuildContext context,
    String msg, {
    Toast? toastLength,
    int timeInSecForIosWeb = 2,
    double? fontSize,
    String? fontAsset,
    ToastGravity? gravity = ToastGravity.TOP,
    Color? backgroundColor = Colors.orange,
    Color? textColor = Colors.white,
    bool webShowClose = false,
    dynamic webBgColor = "linear-gradient(to right, #f7971e, #ffd200)",
    dynamic webPosition = "center",
  }) {
    return _show(
      msg: msg,
      toastLength: toastLength,
      timeInSecForIosWeb: timeInSecForIosWeb,
      fontSize: fontSize,
      fontAsset: fontAsset,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      webShowClose: webShowClose,
      webBgColor: webBgColor,
      webPosition: webPosition,
    );
  }

  /// ==============================
  /// ℹ️ Info
  /// ==============================
  static Future<bool?> info(
    BuildContext context,
    String msg, {
    Toast? toastLength,
    int timeInSecForIosWeb = 2,
    double? fontSize,
    String? fontAsset,
    ToastGravity? gravity = ToastGravity.TOP,
    Color? backgroundColor = Colors.blue,
    Color? textColor = Colors.white,
    bool webShowClose = false,
    dynamic webBgColor = "linear-gradient(to right, #2193b0, #6dd5ed)",
    dynamic webPosition = "right",
  }) {
    return _show(
      msg: msg,
      toastLength: toastLength,
      timeInSecForIosWeb: timeInSecForIosWeb,
      fontSize: fontSize,
      fontAsset: fontAsset,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      webShowClose: webShowClose,
      webBgColor: webBgColor,
      webPosition: webPosition,
    );
  }
}
