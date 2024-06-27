import 'package:archiving_flutter_project/utils/constants/routes_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ErrorDialog extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String errorDetails;
  final String errorTitle;
  final int statusCode;
  final Function()? customOnPressed;

  final bool? isItemStatusScreen;
  const ErrorDialog(
      {Key? key,
      required this.icon,
      required this.errorDetails,
      this.isItemStatusScreen,
      this.customOnPressed,
      required this.errorTitle,
      required this.color,
      required this.statusCode})
      : super(key: key);

  @override
  State<ErrorDialog> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {
  bool showDetails = false;

  late AppLocalizations _locale;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: width * 0.35,
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.icon,
                  color: widget.color,
                  size: height * 0.05,
                ),
                SizedBox(width: width * 0.01),
                Flexible(
                  child: Text(
                    widget.errorTitle,
                    style: TextStyle(
                      fontSize: height * 0.025,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: height * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 10),
                SizedBox(height: height * 0.07),
              ],
            ),
            // if (showDetails)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.errorDetails,
                    style: TextStyle(
                      fontSize: height * 0.015,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(
                  width: width * 0.2,
                ),
                MaterialButton(
                  onPressed: () async {
                    print(
                        "widget.statusCodewidget.statusCode ${widget.statusCode}");
                    if (widget.isItemStatusScreen == true &&
                        widget.customOnPressed != null) {
                      widget.customOnPressed!();
                    } else {
                      if (widget.statusCode == 401 ||
                          widget.statusCode == 417) {
                        if (kIsWeb) {
                          // context.read<TabsProvider>().emptyAll();
                          GoRouter.of(context).go(loginScreenRoute);
                        } else {
                          // context.read<TabsProvider>().emptyAll();
                          Navigator.pushReplacementNamed(
                              context, loginScreenRoute);
                        }
                      } else {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  child: Text(widget.isItemStatusScreen == true
                      ? _locale.cancel
                      : _locale.ok),
                ),
                Visibility(
                  visible: widget.statusCode == 402,
                  child: MaterialButton(
                    onPressed: () async {
                      Navigator.pop(context, false);
                    },
                    child: Text(_locale.no),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
