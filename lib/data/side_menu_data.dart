import 'package:archiving_flutter_project/models/dto/side_menu/menu_model.dart';
import 'package:archiving_flutter_project/models/dto/side_menu/sub_menu_model.dart';
import 'package:archiving_flutter_project/screens/categories_screens/categories_screen.dart';
import 'package:archiving_flutter_project/screens/department_screens/department_screen.dart';
import 'package:archiving_flutter_project/screens/error_page.dart';
import 'package:archiving_flutter_project/screens/file_screens/file_list_screen.dart';
import 'package:archiving_flutter_project/screens/file_screens/files_view_screen.dart';
import 'package:archiving_flutter_project/screens/file_screens/search_file_screen.dart';
import 'package:archiving_flutter_project/screens/home_page.dart';
import 'package:archiving_flutter_project/screens/user_screen/add_user_permisons.dart';
import 'package:archiving_flutter_project/screens/user_screen/user_screen.dart';
import 'package:archiving_flutter_project/utils/constants/user_types_constant/user_types_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../screens/actions_screens/action_screen.dart';
import '../screens/actions_screens/daily_reminders.dart';
import '../screens/change_password_screen.dart';
import '../screens/file_screens/add_file_screen.dart';
import '../screens/reports/dashboard_screen.dart';
import '../screens/user_screen/user_category_screen.dart';
import '../screens/workflow/work_flow_screen.dart';

List<MenuModel> getMenus(AppLocalizations locale, String type) {
  List<MenuModel> menus = type == USERTYPEADMIN
      ? [
          MenuModel(
            title: locale.dashboard,
            icon: Icons.dashboard,
            pageNumber: 0,
            isOpened: true,
            isParent: false,
            // route: mainScreenRoute,
            subMenuList: [],
          ),
          MenuModel(
            title: locale.dailyReminders,
            icon: Icons.dashboard,
            pageNumber: 1,
            isOpened: true,
            isParent: false,
            // route: mainScreenRoute,
            subMenuList: [],
          ),
          MenuModel(
              title: locale.systemSetup,
              icon: Icons.settings_input_antenna_rounded,
              isParent: true,
              pageNumber: 1,
              subMenuList: [
                SubMenuModel(
                  title: locale.listOfCategories,
                  pageNumber: 2,
                ),
                SubMenuModel(title: locale.listOfDepartment, pageNumber: 3),
                SubMenuModel(title: locale.listOfReminders, pageNumber: 4)
              ],
              isOpened: false),
          MenuModel(
              title: locale.documents,
              icon: Icons.document_scanner_rounded,
              isParent: true,
              pageNumber: 5,
              subMenuList: [
                SubMenuModel(title: locale.documentExplorer, pageNumber: 6),
                SubMenuModel(title: locale.addDocument, pageNumber: 7),
                SubMenuModel(title: locale.searchByContnet, pageNumber: 8),
                SubMenuModel(title: "work Flow", pageNumber: 9)
              ],
              isOpened: false),
          MenuModel(
              title: locale.users,
              icon: Icons.supervised_user_circle_sharp,
              isParent: false,
              pageNumber: 11,
              subMenuList: [
                // SubMenuModel(title: locale.addUser, pageNumber: 10),
                // SubMenuModel(title: locale.viewUser, pageNumber: 11),
              ],
              isOpened: false),
          MenuModel(
              title: locale.userCategories,
              icon: Icons.supervised_user_circle_sharp,
              isParent: true,
              pageNumber: 12,
              subMenuList: [
                SubMenuModel(title: locale.addUserCategories, pageNumber: 13),
                SubMenuModel(title: locale.viewUserCategories, pageNumber: 14),
              ],
              isOpened: false),
          MenuModel(
              title: locale.changePassword,
              icon: Icons.password_outlined,
              isParent: false,
              pageNumber: 15,
              isOpened: false,
              subMenuList: []),
        ]
      : type == USERTYPEMANEGER
          ? [
              // MenuModel(
              //   title: locale.dashboard,
              //   icon: Icons.dashboard,
              //   pageNumber: 0,
              //   isOpened: true,
              //   isParent: false,
              //   // route: mainScreenRoute,
              //   subMenuList: [],
              // ),
              MenuModel(
                title: locale.dailyReminders,
                icon: Icons.dashboard,
                pageNumber: 1,
                isOpened: true,
                isParent: false,
                // route: mainScreenRoute,
                subMenuList: [],
              ),
              MenuModel(
                  title: locale.listOfReminders,
                  icon: Icons.remember_me,
                  isParent: false,
                  pageNumber: 1,
                  subMenuList: [],
                  isOpened: false),
              MenuModel(
                  title: locale.documents,
                  icon: Icons.document_scanner_rounded,
                  isParent: true,
                  pageNumber: 5,
                  subMenuList: [
                    SubMenuModel(title: locale.documentExplorer, pageNumber: 6),
                    SubMenuModel(title: locale.addDocument, pageNumber: 7),
                    SubMenuModel(title: locale.searchByContnet, pageNumber: 8)
                  ],
                  isOpened: false),
              // MenuModel(
              //     title: locale.users,
              //     icon: Icons.supervised_user_circle_sharp,
              //     isParent: false,
              //     pageNumber: 11,
              //     subMenuList: [
              //       // SubMenuModel(title: locale.addUser, pageNumber: 10),
              //       // SubMenuModel(title: locale.viewUser, pageNumber: 11),
              //     ],
              //     isOpened: false),
              // MenuModel(
              //     title: locale.userCategories,
              //     icon: Icons.supervised_user_circle_sharp,
              //     isParent: true,
              //     pageNumber: 12,
              //     subMenuList: [
              //       SubMenuModel(
              //           title: locale.addUserCategories, pageNumber: 13),
              //       SubMenuModel(
              //           title: locale.viewUserCategories, pageNumber: 14),
              //     ],
              //     isOpened: false),
              MenuModel(
                  title: locale.changePassword,
                  icon: Icons.password_outlined,
                  isParent: false,
                  pageNumber: 15,
                  isOpened: false,
                  subMenuList: []),
            ]
          : [
              // MenuModel(
              //   title: locale.dashboard,
              //   icon: Icons.dashboard,
              //   pageNumber: 0,
              //   isOpened: true,
              //   isParent: false,
              //   // route: mainScreenRoute,
              //   subMenuList: [],
              // ),
              MenuModel(
                title: locale.dailyReminders,
                icon: Icons.dashboard,
                pageNumber: 1,
                isOpened: true,
                isParent: false,
                // route: mainScreenRoute,
                subMenuList: [],
              ),
              MenuModel(
                  title: locale.listOfReminders,
                  icon: Icons.remember_me,
                  isParent: false,
                  pageNumber: 4,
                  subMenuList: [],
                  isOpened: false),
              // MenuModel(
              //     title: locale.systemSetup,
              //     icon: Icons.settings_input_antenna_rounded,
              //     isParent: true,
              //     pageNumber: 1,
              //     subMenuList: [
              //       SubMenuModel(
              //         title: locale.listOfCategories,
              //         pageNumber: 2,
              //       ),
              //       SubMenuModel(title: locale.listOfDepartment, pageNumber: 3),
              //       SubMenuModel(title: locale.listOfReminders, pageNumber: 4)
              //     ],
              //     isOpened: false),
              MenuModel(
                  title: locale.documents,
                  icon: Icons.document_scanner_rounded,
                  isParent: true,
                  pageNumber: 5,
                  subMenuList: [
                    SubMenuModel(title: locale.documentExplorer, pageNumber: 6),
                    SubMenuModel(title: locale.addDocument, pageNumber: 7),
                    SubMenuModel(title: locale.searchByContnet, pageNumber: 8)
                  ],
                  isOpened: false),
              // MenuModel(
              //     title: locale.users,
              //     icon: Icons.supervised_user_circle_sharp,
              //     isParent: false,
              //     pageNumber: 11,
              //     subMenuList: [
              //       // SubMenuModel(title: locale.addUser, pageNumber: 10),
              //       // SubMenuModel(title: locale.viewUser, pageNumber: 11),
              //     ],
              //     isOpened: false),
              // MenuModel(
              //     title: locale.userCategories,
              //     icon: Icons.supervised_user_circle_sharp,
              //     isParent: true,
              //     pageNumber: 12,
              //     subMenuList: [
              //       SubMenuModel(
              //           title: locale.addUserCategories, pageNumber: 13),
              //       SubMenuModel(
              //           title: locale.viewUserCategories, pageNumber: 14),
              //     ],
              //     isOpened: false),
              MenuModel(
                  title: locale.changePassword,
                  icon: Icons.password_outlined,
                  isParent: false,
                  pageNumber: 15,
                  isOpened: false,
                  subMenuList: []),
            ];

  return menus;
}

Widget getScreenContent(int index) {
  switch (index) {
    case 0:
      return const DashboardScreen();
    case 1:
      return const DailyReminders();
    case 2:
      return const DealClassificationTreeScreen();
    case 3:
      return const DepartemntScreen();
    case 7:
      return const AddFileScreen();
    case 4:
      return const ActionScreen();
    case 6:
      return const FileListScreen();
    case 8:
      return const SearchFileScreen();
    case 11:
      return const UserScreen();
    case 14:
      return const UserCategoryScreen();
    case 13:
      return const AddUserPermisonsScreen();
    case 15:
      return const ChangePasswordScreen();
    case 17:
      return const FileListScreen();
    case 20:
      return const ErrorPage();
    case 9:
      return const WorkFlowScreen();

    // case 2:
    //   return UsersScreen();
  }
  return Container();
}

String getPageTitle(int index, AppLocalizations locale) {
  switch (index) {
    case 1:
      locale.dailyReminders;
  }
  return "";
}
