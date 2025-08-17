import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/utils/constants/routes_constant.dart';
import 'package:archiving_flutter_project/utils/constants/user_types_constant/user_types_constant.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:flutter/foundation.dart';
import 'dart:html' as html;

import '../../providers/screen_content_provider.dart';

// ignore: must_be_immutable
class LogoutTab extends StatefulWidget {
  bool isCollapse;
  LogoutTab({super.key, required this.isCollapse});

  @override
  State<LogoutTab> createState() => _LogoutTabState();
}

class _LogoutTabState extends State<LogoutTab> {
  double width = 0;
  double height = 0;
  bool isHovered = false;
  late AppLocalizations locale;
  double fontSize = 0;
  bool isDesktop = false;
  Color selectedColor = const Color.fromARGB(255, 14, 1, 1).withOpacity(0.3);
  FlutterSecureStorage storage = FlutterSecureStorage();
  @override
  void didChangeDependencies() {
    locale = AppLocalizations.of(context)!;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);

    bool isTablet = Responsive.isTablet(context);
    fontSize = width * 0.008;

    return MouseRegion(
      onEnter: (event) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          isHovered = false;
        });
      },
      child: logoutTab(isDesktop, isTablet),
    );
  }

  Widget logoutTab(bool isDesktop, bool isTablet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        InkWell(
          onTap: () async {
            confirmDialog();

            //   tabsProvider.deleteAllTabsExceptFirst();
          },
          child: Container(
            decoration: BoxDecoration(
              color: getActiveColor(),
              borderRadius: BorderRadius.circular(5),
            ),
            width: menuWidth(isDesktop),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.logout,
                      size: isDesktop ? width * 0.011 : width * 0.05,
                      color: Colors.white),
                  !widget.isCollapse
                      ? const SizedBox(
                          width: 5,
                        )
                      : Container(),
                  !widget.isCollapse
                      ? Text(
                          locale.logout,
                          style: TextStyle(
                              fontSize: isDesktop ? fontSize : width * 0.04,
                              color: Colors.white),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  confirmDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomConfirmDialog(confirmMessage: locale.areYouSureToLogOut);
      },
    ).then((value) async {
      if (value) {
        storage.deleteAll();
        await storage.delete(key: "jwt").then((value) async {
          await storage.delete(key: "roles").then((value) {
            // context.read<ScreenContentProvider>().setPage1(-1);

            GoRouter.of(context).go(loginScreenRoute);

            // menuList = getMenus(_locale, value!);
            // setState(() {});
          });
          // context.read<ScreenContentProvider>().setPage1(0);
        });
        await storage.delete(key: "roles").then((value) {
          // context.read<ScreenContentProvider>().setPage1(-1);

          GoRouter.of(context).go(loginScreenRoute);
        });
        // });
      }
    });
  }

  getActiveColor() {
    return isHovered ? selectedColor : const Color.fromARGB(0, 0, 0, 0);
  }

  double menuWidth(bool isDesktop) {
    if (isDesktop) {
      return !widget.isCollapse ? width * 0.122 : 35;
    } else {
      return width * 0.55;
    }
  }
}
