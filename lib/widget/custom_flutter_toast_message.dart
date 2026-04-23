import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/constants/key.dart';

class CustomToastMessage {
  /// ==============================
  /// 🔹 Base Method (Internal UI)
  /// ==============================
  static Future<bool?> _show({
    required BuildContext context,
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
    IconData icon = Icons.info,
  }) {
    final overlayState = navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint("❌ No Overlay found");
      return Future.value(false);
    }

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return _AnimatedToast(
          msg: msg,
          bgColor: backgroundColor ?? Colors.black87,
          textColor: textColor ?? Colors.white,
          icon: icon,
        );
      },
    );

    overlayState.insert(overlayEntry);

    Future.delayed(Duration(seconds: timeInSecForIosWeb), () {
      overlayEntry.remove();
    });

    return Future.value(true);
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
      context: context,
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
      icon: Icons.check_circle,
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
      context: context,
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
      icon: Icons.error,
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
      context: context,
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
      icon: Icons.warning,
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
      context: context,
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
      icon: Icons.info,
    );
  }
}

/// ==============================
/// 🎨 UI Widget
/// ==============================
class _AnimatedToast extends StatefulWidget {
  final String msg;
  final Color bgColor;
  final Color textColor;
  final IconData icon;

  const _AnimatedToast({
    required this.msg,
    required this.bgColor,
    required this.textColor,
    required this.icon,
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offsetAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 70,
      left: 0,
      right: 0,
      child: Center(
        // 🔥 هذا المهم (توسيط)
        child: SlideTransition(
          position: offsetAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 300, // 🔥 ما يكبر كثير
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: widget.bgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: IntrinsicWidth(
                // 🔥 حسب المحتوى
                child: Row(
                  mainAxisSize: MainAxisSize.min, // 🔥 مهم
                  children: [
                    Icon(widget.icon, color: widget.textColor, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.msg,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
