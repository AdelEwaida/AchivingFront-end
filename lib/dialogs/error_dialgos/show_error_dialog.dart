import 'package:archiving_flutter_project/utils/constants/routes_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../utils/constants/colors.dart';

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: widget.color,
                  radius: 35,
                  child: Icon(
                    widget.icon,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: height * 0.015),
                Text(
                  widget.errorTitle,
                  style: TextStyle(
                    fontSize: height * 0.025,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height * 0.025,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     const SizedBox(width: 10),
            //     SizedBox(height: height * 0.07),
            //   ],
            // ),
            // if (showDetails)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.errorDetails,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: height * 0.018,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[900],
                  ),
                ),
                SizedBox(
                  height: height * 0.025,
                ),
                MaterialButton(
                  color: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () async {
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
                  child: Text(
                    widget.isItemStatusScreen == true
                        ? _locale.cancel
                        : _locale.ok,
                    style: const TextStyle(color: Colors.white),
                  ),
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
