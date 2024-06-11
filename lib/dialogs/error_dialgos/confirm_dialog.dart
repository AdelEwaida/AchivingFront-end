import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomConfirmDialog extends StatefulWidget {
  final String? confirmText;
  final String? cancelText;
  final String confirmMessage;
  //  void Function()? onDelete;

  const CustomConfirmDialog({
    super.key,
    this.confirmText,
    this.cancelText,
    required this.confirmMessage,
    //    this.onDelete,
  });

  @override
  State createState() => _CustomConfirmDialogState();
}

class _CustomConfirmDialogState extends State<CustomConfirmDialog> {
  late AppLocalizations _local;
  final FocusNode _foucasNode = FocusNode();
  @override
  void didChangeDependencies() {
    _local = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _foucasNode.dispose();
    super.dispose();
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _foucasNode.requestFocus();
    final dialogWidth = MediaQuery.of(context).size.width;
    final dialogHeight = MediaQuery.of(context).size.height;
    // String confirmText;
    // String cancelText;
    //final String confirmMessage;
    // void Function()? onDelete;

    return RawKeyboardListener(
      onKey: _handleKey,
      focusNode: _foucasNode,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: dialogWidth * 0.35,
          height: dialogHeight * 0.38,
          child: Column(
            children: [
              Material(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: const Color(0xFF515c6f),
                child: SizedBox(
                  height: dialogHeight * 0.13,
                  width: double.infinity,
                  child: const Icon(
                    Icons.report_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.confirmMessage,
                        style: TextStyle(fontSize: dialogHeight * 0.03),
                        textAlign: TextAlign.center,
                      ),
                      //  SizedBox(height: dialogHeight * 0.08),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            child: Text(widget.confirmText ?? _local.ok),
                          ),

                          // ElevatedButton(
                          //   onPressed: () {
                          //     Navigator.pop(context, true);
                          //   },
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: const Color(0xFF515c6f),
                          //     padding: const EdgeInsets.symmetric(
                          //       vertical: 16,
                          //       horizontal: 32,
                          //     ),
                          //     textStyle: const TextStyle(fontSize: 18),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(30),
                          //     ),
                          //   ),
                          //   child: Text(
                          //     widget.confirmText ?? "Ok",
                          //     style: TextStyle(
                          //         fontSize: MediaQuery.of(context).size.height *
                          //             0.025,
                          //         fontWeight: FontWeight.w600),
                          //   ),
                          // ),

                          SizedBox(width: dialogWidth * 0.02),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            child: Text(widget.cancelText ?? _local.cancel),
                          ),
                          // TextButton(
                          //   onPressed: () {
                          //     Navigator.pop(context, false);
                          //   },
                          //   style: TextButton.styleFrom(
                          //     padding: const EdgeInsets.symmetric(
                          //       vertical: 16,
                          //       horizontal: 32,
                          //     ),
                          //     textStyle: const TextStyle(fontSize: 18),
                          //   ),
                          //   child: Text(
                          //     widget.cancelText ?? "Cancel",
                          //     style: TextStyle(
                          //         fontSize: MediaQuery.of(context).size.height *
                          //             0.025,
                          //         fontWeight: FontWeight.w600),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
