import 'package:archiving_flutter_project/data/side_menu_data.dart';
import 'package:archiving_flutter_project/models/dto/side_menu/menu_model.dart';
import 'package:archiving_flutter_project/providers/local_provider.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/language_widget/language_widget.dart';
import 'package:archiving_flutter_project/widget/side_menu/logout_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/dto/side_menu/sub_menu_model.dart';

class SideMenu extends StatefulWidget {
  String? name;
  SideMenu({super.key, this.name});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  double width = 0;
  double height = 0;

  Color shadowColor = Colors.grey.withOpacity(0.3);

  bool isEnteredCollapseIcon = false;
  double fontSize = 0;

  Color selectedColor =
      const Color.fromARGB(255, 169, 168, 168).withOpacity(0.3);

  int selectedMenuHover = -1;
  int selectedSubMenuHover = -1;
  int selectedMenuIndex = -1;
  int selectedSubMenuIndex = -1;
  int selectedSubMenuParentIndex = -1;

  bool isCollapsed = false;

  bool isDesktop = false;

  late AppLocalizations _locale;
  FlutterSecureStorage storage = FlutterSecureStorage();

  late ScreenContentProvider screenProvider;
  int openedMenuIndex = -1;
  List<MenuModel> menuList = [];

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    storage.read(key: "roles").then((value) {
      print("vaaaaaaaaaaal ${value}");
      menuList = getMenus(_locale, value!);
      setState(() {});
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    fontSize = width * 0.009;
    isDesktop = Responsive.isDesktop(context);

    screenProvider = context.read<ScreenContentProvider>();
    return Container(
      height: height,
      width: drawerWidth(),
      decoration: BoxDecoration(
        color: secondary,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: titleSection(),
          ),
          SizedBox(
            height: height * 0.71,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < menuList.length; i++)
                    createMenuItem(menuList[i], i),
                ],
              ),
            ),
          ),
          accountSection(),

          // const Divider(), // Add a line before the logout button
          // const Padding(padding: EdgeInsets.all(5)),
          LogoutTab(isCollapse: false), // Pass the isCollapsed state
        ],
      ),
    );
  }

  accountSection() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              height: 50,
              decoration: const BoxDecoration(
                color: secondary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.account_circle_rounded,
                    color: Colors.white,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        widget.name!,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Container titleSection() {
    return Container(
      decoration: const BoxDecoration(),
      child: Row(
        mainAxisAlignment: !isCollapsed
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          !isCollapsed
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 15),
                          child: Image.asset(
                            "assets/images/logo-white.png",
                            width: isDesktop ? width * 0.075 : width * 0.5,
                          ),
                        ),
                        LanguageWidget(
                          color: Colors.white,
                          onLocaleChanged: (locale) {
                            context.read<LocaleProvider>().setLocale(locale);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                )
              : Container(),
          isDesktop
              ? MouseRegion(
                  onEnter: (event) {
                    setState(() {
                      isEnteredCollapseIcon = true;
                    });
                  },
                  onExit: (event) {
                    setState(() {
                      isEnteredCollapseIcon = false;
                    });
                  },
                  child: IconButton(
                    splashRadius: 1,
                    iconSize: width * 0.015,
                    onPressed: () {
                      setState(() {
                        isCollapsed = !isCollapsed;
                      });
                    },
                    icon: Icon(
                      Icons.flip_to_back_rounded,
                      color: isEnteredCollapseIcon ? primary : Colors.white,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget createMenuItem(MenuModel menu, int index) {
    Radius radius = const Radius.circular(100);
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 6,
            ),
            menuWidget(index, menu),
          ],
        ));
  }

  Container createSelecter(Radius radius) {
    return Container(
      width: isDesktop ? width * 0.002 : width * 0.004,
      height: 38,
      decoration: BoxDecoration(
        color: const Color.fromARGB(96, 87, 83, 83),
        borderRadius: BorderRadius.only(
          topRight: radius,
          bottomRight: radius,
        ),
      ),
    );
  }

  Widget menuWidget(int index, MenuModel menu) {
    Color activeColor = getActiveColor(index);
    String title = menu.title;
    bool isParent = menu.isParent;
    IconData icon = menu.icon;
    bool isOpened = menuList[index].isOpened;
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          selectedMenuHover = index;
        });
      },
      onExit: (event) {
        setState(() {
          selectedMenuHover = -1;
        });
      },
      child: Container(
          width: menuWidth(),
          decoration: BoxDecoration(
            color: activeColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    if (selectedMenuIndex == index) {
                      menuList[index].isOpened = !isOpened;
                    } else {
                      closeAllMenus(index);
                      menuList[index].isOpened = true;
                      selectedMenuIndex = index;
                    }
                    if (!menuList[index].isParent) {
                      screenProvider.setPage1(menu.pageNumber);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              icon,
                              size: isDesktop ? width * 0.011 : width * 0.05,
                              color: Colors.white,
                            ),
                            !isCollapsed
                                ? const SizedBox(
                                    width: 5,
                                  )
                                : Container(),
                            !isCollapsed
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...splitTitle(title).map((line) => Text(
                                            line,
                                            style: TextStyle(
                                              fontSize: isDesktop
                                                  ? fontSize
                                                  : width * 0.04,
                                              color: Colors.white,
                                            ),
                                            softWrap: true,
                                          )),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      !isCollapsed
                          ? isParent
                              ? Icon(
                                  selectedMenuIndex == index
                                      ? isOpened
                                          ? Icons.arrow_drop_down_rounded
                                          : Icons.arrow_right_rounded
                                      : Icons.arrow_right_rounded,
                                  size:
                                      isDesktop ? width * 0.011 : width * 0.05,
                                  color: Colors.white,
                                )
                              : Container()
                          : Container(),
                    ],
                  ),
                ),
              ),
              !isCollapsed
                  ? isParent
                      ? isOpened
                          ? Column(
                              children: [
                                for (int i = 0;
                                    i < menu.subMenuList.length;
                                    i++)
                                  createSubMenu(menu.subMenuList[i], index, i)
                              ],
                            )
                          : Container()
                      : Container()
                  : Container()
            ],
          )),
    );
  }

  List<String> splitTitle(String title) {
    List<String> words = title.split(' ');
    List<String> lines = [];
    String line = '';
    for (int i = 0; i < words.length; i++) {
      line += '${words[i]} ';
      if ((i + 1) % 3 == 0 || i == words.length - 1) {
        lines.add(line.trim());
        line = '';
      }
    }
    return lines;
  }

  void closeAllMenus(int index) {
    for (int i = 0; i < menuList.length; i++) {
      if (i != index) {
        menuList[i].isOpened = false;
      }
    }
  }

  Widget createSubMenu(
      SubMenuModel subMenu, int parentIndex, int subMenuIndex) {
    String title = subMenu.title;
    return InkWell(
      onTap: () {
        setState(() {
          selectedSubMenuParentIndex = parentIndex;
          selectedSubMenuIndex = subMenuIndex;
          screenProvider.setPage1(subMenu.pageNumber);
        });
      },
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            selectedSubMenuHover = subMenuIndex;
          });
        },
        onExit: (event) {
          setState(() {
            selectedSubMenuHover = -1;
          });
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? width * 0.018 : width * 0.1,
              vertical: 15),
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: isDesktop ? width * 0.09 : width * 0.3,
                child: Text(
                  title,
                  style: TextStyle(
                    color: getActiveSubColor(
                      subMenuIndex,
                      parentIndex,
                    ),
                    fontSize: isDesktop ? fontSize : width * 0.03,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createSubMenu1(
      SubMenuModel subMenu, int parentIndex, int subMenuIndex) {
    String title = subMenu.title;
    return InkWell(
      onTap: () {
        setState(() {
          selectedSubMenuParentIndex = parentIndex;

          selectedSubMenuIndex = subMenuIndex;
          screenProvider.setPage1(subMenu.pageNumber);
        });
      },
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            selectedSubMenuHover = subMenuIndex;
          });
        },
        onExit: (event) {
          setState(() {
            selectedSubMenuHover = -1;
          });
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? width * 0.018 : width * 0.1,
              vertical: 15),
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: isDesktop ? width * 0.09 : width * 0.3,
                child: Text(
                  title,
                  style: TextStyle(
                    color: getActiveSubColor(parentIndex, subMenuIndex),
                    fontSize: isDesktop ? fontSize : width * 0.03,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getActiveColor(int index) {
    if (selectedMenuIndex == index) {
      return selectedColor;
    }
    return selectedMenuHover == index
        ? Colors.grey.withOpacity(0.3)
        : Colors.transparent;
  }

  // Color getActiveSubColor(int parentIndex, int subMenuIndex) {
  //   if (selectedMenuIndex == parentIndex &&
  //       selectedSubMenuIndex == subMenuIndex) {
  //     return textSecondary; // Active color for the selected submenu
  //   }
  //   if (selectedSubMenuHover == subMenuIndex) {
  //     return Colors.grey; // Hover color for the submenu
  //   }
  //   return Colors.white;
  // }
  Color? getActiveSubColor(int subMenuIndex, int parentIndex) {
    if ((selectedSubMenuIndex == subMenuIndex &&
            selectedSubMenuParentIndex == parentIndex) ||
        selectedSubMenuHover == subMenuIndex) {
      return textSecondary;
    }
    return Colors.white;
  }

  double drawerWidth() {
    if (isDesktop) {
      return !isCollapsed ? width * 0.15 : 50;
    } else {
      return width * 0.6;
    }
  }

  double menuWidth() {
    if (isDesktop) {
      return !isCollapsed ? width * 0.14 : 35;
    } else {
      return width * 0.55;
    }
  }
}
