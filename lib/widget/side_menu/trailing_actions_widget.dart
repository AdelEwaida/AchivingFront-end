import 'package:archiving_flutter_project/widget/notification_icon_widget.dart';
import 'package:archiving_flutter_project/widget/side_menu/glass_action_button.dart';
import 'package:archiving_flutter_project/widget/side_menu/language_selector.dart';
import 'package:archiving_flutter_project/widget/side_menu/logout_tab.dart';
import 'package:archiving_flutter_project/utils/constants/user_types_constant/user_types_constant.dart';
import 'package:flutter/material.dart';

class TrailingActions extends StatelessWidget {
  final String userRole;
  final String active;

  final VoidCallback onExportExcel;

  const TrailingActions({
    super.key,
    required this.userRole,
    required this.active,
    required this.onExportExcel,
  });

  static const double actionGap = 6;

  @override
  Widget build(BuildContext context) {
    final String normalizedRole = userRole.trim().toUpperCase();
    final bool isAdmin = normalizedRole == USERTYPEADMIN;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LogoutTab(isCollapse: true),
          const SizedBox(width: actionGap),
          const LanguageSelector(),
          const SizedBox(width: actionGap),
          if (isAdmin)
            GlassActionButton(
                tooltip: 'Export Excel',
                icon: Icons.upload_file_rounded,
                iconColor: const Color(0xFFFFF176),
                onPressed: onExportExcel),
          if (isAdmin && active == "1") const SizedBox(width: actionGap),
          if (active == "1") NotificationIcon(),
        ],
      ),
    );
  }
}
