import 'package:archiving_flutter_project/data/side_menu_data.dart';
import 'package:archiving_flutter_project/models/dto/side_menu/menu_model.dart';
import 'package:archiving_flutter_project/models/dto/side_menu/sub_menu_model.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/service/controller/work_flow_controllers/setup_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/storage_keys.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../dialogs/issues_excel/import_excel_dialog.dart';
import 'menu_item_widget.dart';
import 'menu_section.dart';
import 'trailing_actions_widget.dart';

class SideMenu extends StatefulWidget {
  final String? name;
  const SideMenu({super.key, this.name});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  double width = 0;
  int selectedMenuHover = -1;
  int selectedSubMenuHover = -1;
  int selectedMenuIndex = -1;
  int selectedSubMenuIndex = -1;
  int selectedSubMenuParentIndex = -1;

  late AppLocalizations _locale;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  PackageInfo? packageInfo;
  late ScreenContentProvider screenProvider;
  List<MenuModel> menuList = [];
  String? active;
  String? userRole;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
    packageInfo = await PackageInfo.fromPlatform();

    final setup = await SetupController().getSetup();
    if (setup != null) {
      await storage.write(
        key: StorageKeys.bolActive,
        value: setup.bolActive.toString(),
      );
    } else {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }

    active = await storage.read(key: StorageKeys.bolActive);
    userRole = await storage.read(key: "roles");

    if (userRole != null && active != null) {
      menuList = getMenus(_locale, userRole!, active!);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    final bool isDesktop = Responsive.isDesktop(context);
    screenProvider = context.read<ScreenContentProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(7, 8, 7, 8),
      decoration: BoxDecoration(
        color: secondary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  child: MenuSection(
                    width: width,
                    menuList: menuList,
                    logoPath: "assets/images/logo-white.png",
                    itemBuilder: (menu, index) {
                      final menuItem = menuList[index];
                      return _buildMenuItem(menuItem, index);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                _buildTrailingActions(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildTrailingActions(),
                ),
                const SizedBox(height: 12),
                Image.asset(
                  "assets/images/logo-white.png",
                  width: width * 0.32,
                  alignment: Alignment.centerLeft,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < menuList.length; i++) ...[
                        _buildMenuItem(menuList[i], i, closeDrawerOnTap: true),
                        if (i != menuList.length - 1) const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTrailingActions() {
    return TrailingActions(
      userRole: userRole ?? "-1",
      active: active ?? "0",
      onExportExcel: () {
        showDialog(
          context: context,
          builder: (context) => ImportExcelDialog(),
        );
      },
    );
  }

  Widget _buildMenuItem(
    MenuModel menuItem,
    int index, {
    bool closeDrawerOnTap = false,
  }) {
    return MenuItemWidget(
      menu: menuItem,
      isSelected: selectedMenuIndex == index,
      isOpened: menuItem.isOpened,
      isHovered: selectedMenuHover == index,
      onHover: () {
        setState(() => selectedMenuHover = index);
      },
      onExit: () {
        setState(() => selectedMenuHover = -1);
      },
      onTap: () {
        if (!menuItem.isParent) {
          setState(() {
            closeAllMenus(index);
            selectedMenuIndex = index;
            screenProvider.setPage1(menuItem.pageNumber);
          });
          if (closeDrawerOnTap) {
            Navigator.of(context).maybePop();
          }
        }
      },
      onTapDown: (details) async {
        if (!menuItem.isParent) return;
        setState(() {
          closeAllMenus(index);
          menuItem.isOpened = true;
          selectedMenuIndex = index;
        });
        await _openSubMenuPopup(menuItem, index, details);
      },
    );
  }

  Future<void> _openSubMenuPopup(
    MenuModel menu,
    int parentIndex,
    TapDownDetails details,
  ) async {
    if (!menu.isParent || menu.subMenuList.isEmpty) {
      return;
    }

    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) {
      return;
    }

    final selectedIndex = await showMenu<int>(
      context: context,
      color: secondary,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white.withOpacity(0.15),
          width: 0.8,
        ),
      ),
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy + 24,
        overlay.size.width - details.globalPosition.dx,
        overlay.size.height - details.globalPosition.dy,
      ),
      items: [
        for (int i = 0; i < menu.subMenuList.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Text(
              menu.subMenuList[i].title,
              style: TextStyle(
                color: getActiveSubColor(i, parentIndex),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );

    if (selectedIndex == null) {
      setState(() {
        menuList[parentIndex].isOpened = false;
      });
      return;
    }

    final SubMenuModel selectedSub = menu.subMenuList[selectedIndex];
    setState(() {
      selectedSubMenuParentIndex = parentIndex;
      selectedSubMenuIndex = selectedIndex;
      menuList[parentIndex].isOpened = false;
      screenProvider.setPage1(selectedSub.pageNumber);
    });
  }

  void closeAllMenus(int index) {
    for (int i = 0; i < menuList.length; i++) {
      if (i != index) {
        menuList[i].isOpened = false;
      }
    }
  }

  Color getActiveColor(int index) {
    if (selectedMenuIndex == index) {
      return const Color.fromARGB(255, 169, 168, 168).withOpacity(0.3);
    }
    return selectedMenuHover == index
        ? Colors.grey.withOpacity(0.3)
        : Colors.transparent;
  }

  Color? getActiveSubColor(int subMenuIndex, int parentIndex) {
    if ((selectedSubMenuIndex == subMenuIndex &&
            selectedSubMenuParentIndex == parentIndex) ||
        selectedSubMenuHover == subMenuIndex) {
      return textSecondary;
    }
    return Colors.white.withOpacity(0.85);
  }
}
