import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/utils/constants/routes_constant.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
class LogoutTab extends StatefulWidget {
  final bool isCollapse;
  const LogoutTab({super.key, required this.isCollapse});

  @override
  State<LogoutTab> createState() => _LogoutTabState();
}

class _LogoutTabState extends State<LogoutTab> {
  double width = 0;
  double height = 0;
  bool isHovered = false;
  late AppLocalizations locale;
  double fontSize = 0;
  Color selectedColor = const Color.fromARGB(255, 14, 1, 1).withOpacity(0.3);
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  @override
  void didChangeDependencies() {
    locale = AppLocalizations.of(context)!;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    final isDesktop = Responsive.isDesktop(context);

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
    if (widget.isCollapse) {
      return Tooltip(
        message: locale.logout,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: confirmDialog,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: getActiveColor(),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.logout_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: confirmDialog,
      child: Container(
        decoration: BoxDecoration(
          color: getActiveColor(),
          borderRadius: BorderRadius.circular(8),
        ),
        width: menuWidth(isDesktop),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                size: isDesktop ? width * 0.011 : width * 0.05,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                locale.logout,
                style: TextStyle(
                  fontSize: isDesktop ? fontSize : width * 0.04,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
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
