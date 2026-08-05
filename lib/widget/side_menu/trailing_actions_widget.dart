import 'package:archiving_flutter_project/utils/constants/user_types_constant/user_types_constant.dart';
import 'package:archiving_flutter_project/widget/notification_icon_widget.dart';
import 'package:archiving_flutter_project/widget/side_menu/glass_action_button.dart';
import 'package:archiving_flutter_project/widget/side_menu/language_selector.dart';
import 'package:archiving_flutter_project/widget/side_menu/logout_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrailingActions extends StatelessWidget {
  final String userRole;
  final String workflowActive;
  final String docTrackingActive;
  final String openedFromLink;

  final VoidCallback onExportExcel;

  const TrailingActions({
    super.key,
    required this.userRole,
    required this.workflowActive,
    required this.docTrackingActive,
    this.openedFromLink = "0",
    required this.onExportExcel,
  });

  static const double actionGap = 6;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;
    final String normalizedRole = userRole.trim().toUpperCase();
    final bool isAdmin = normalizedRole == USERTYPEADMIN;
    final bool hideLogoutAndLang =
        normalizedRole == NORMALUSER && openedFromLink == "true";
    final bool showNotifications =
        workflowActive == "1" || docTrackingActive == "1";

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hideLogoutAndLang) ...[
            const LogoutTab(isCollapse: true),
            const SizedBox(width: actionGap),
            const LanguageSelector(),
            const SizedBox(width: actionGap),
          ],
          if (isAdmin)
            GlassActionButton(
              tooltip: locale.importFromExcel,
              icon: Icons.upload_file_rounded,
              iconColor: const Color(0xFFFFF176),
              onPressed: onExportExcel,
            ),
          if (isAdmin && showNotifications) const SizedBox(width: actionGap),
          if (showNotifications) NotificationIcon(),
        ],
      ),
    );
  }
}
