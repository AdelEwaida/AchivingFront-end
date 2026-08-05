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
  String? workflowActive;
  String? docTrackingActive;
  String? userRole;
  String? openedFromLink;
  final Map<int, GlobalKey> _submenuArrowKeys = {};

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
    packageInfo = await PackageInfo.fromPlatform();

    await SetupController().cacheSetupFlags(storage);

    workflowActive = await storage.read(key: StorageKeys.workflowActive) ??
        await storage.read(key: StorageKeys.bolActive);
    docTrackingActive =
        await storage.read(key: StorageKeys.docTrackingActive) ?? '0';
    if (workflowActive == null) {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }
    userRole = await storage.read(key: "roles");
    openedFromLink = await storage.read(key: "openedFromLink");

    if (userRole != null) {
      menuList = getMenus(
        _locale,
        userRole!,
        workflowActive!,
        docTrackingActive!,
      );
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
      workflowActive: workflowActive ?? "0",
      docTrackingActive: docTrackingActive ?? "0",
      openedFromLink: openedFromLink ?? "0",
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
    final arrowKey = _submenuArrowKeys.putIfAbsent(
        index, () => GlobalKey(debugLabel: 'submenu_arrow_$index'));
    return MenuItemWidget(
      menu: menuItem,
      arrowKey: arrowKey,
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
        if (menuItem.isParent) {
          setState(() {
            closeAllMenus(index);
            menuItem.isOpened = true;
            selectedMenuIndex = index;
          });
          _openSubMenuPopup(menuItem, index);
          return;
        }

        setState(() {
          closeAllMenus(index);
          selectedMenuIndex = index;
          screenProvider.setPage1(menuItem.pageNumber);
        });
        if (closeDrawerOnTap) {
          Navigator.of(context).maybePop();
        }
      },
      onArrowTap: () async {
        if (!menuItem.isParent) return;
        setState(() {
          closeAllMenus(index);
          menuItem.isOpened = true;
          selectedMenuIndex = index;
        });
        await _openSubMenuPopup(menuItem, index);
      },
    );
  }

  Future<void> _openSubMenuPopup(
    MenuModel menu,
    int parentIndex,
  ) async {
    if (!menu.isParent || menu.subMenuList.isEmpty) {
      return;
    }

    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) {
      return;
    }

    final arrowContext = _submenuArrowKeys[parentIndex]?.currentContext;
    final arrowRenderBox = arrowContext?.findRenderObject() as RenderBox?;
    if (arrowRenderBox == null) {
      return;
    }

    final arrowGlobalOffset = arrowRenderBox.localToGlobal(Offset.zero);
    final arrowSize = arrowRenderBox.size;
    final selectedIndex = await showMenu<int>(
      context: context,
      color: secondary,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFFFFB300).withOpacity(0.95),
          width: 0.8,
        ),
      ),
      position: RelativeRect.fromLTRB(
        arrowGlobalOffset.dx - 8,
        arrowGlobalOffset.dy + arrowSize.height + 6,
        overlay.size.width - (arrowGlobalOffset.dx + arrowSize.width),
        overlay.size.height - (arrowGlobalOffset.dy + arrowSize.height),
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
