import 'package:archiving_flutter_project/data/side_menu_data.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/side_menu/side_menu.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/file_list_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  late ScreenContentProvider screenContentProvider;
  late AppLocalizations _locale;

  @override
  void didChangeDependencies() {
    screenContentProvider = context.read<ScreenContentProvider>();
    _locale = AppLocalizations.of(context)!;

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    isDesktop = Responsive.isDesktop(context);

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        drawer: !isDesktop ? const SideMenu() : null,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              decoration: const BoxDecoration(),
              width: width,
              height: height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  context.read<DocumentListProvider>().isViewFile == true
                      ? Container()
                      : isDesktop
                          ? const SideMenu()
                          : Container(
                              color: Colors.white,
                            ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Consumer<ScreenContentProvider>(
                          builder: (builder, value, child) {
                        Widget tabView =
                            getScreenContent(screenContentProvider.getPage());

                        return tabView;
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
