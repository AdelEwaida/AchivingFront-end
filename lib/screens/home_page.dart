import 'package:archiving_flutter_project/data/side_menu_data.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/side_menu/side_menu.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  ValueNotifier name = ValueNotifier("");
  FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  Future<void> didChangeDependencies() async {
    screenContentProvider = context.read<ScreenContentProvider>();
    _locale = AppLocalizations.of(context)!;
    name.value = await storage.read(key: "userName");

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    isDesktop = Responsive.isDesktop(context);

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        drawer: ValueListenableBuilder(
          valueListenable: name,
          builder: (context, value, child) {
            return SideMenu(
              name: name.value,
            );
          },
        ),
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
                          ? ValueListenableBuilder(
                              valueListenable: name,
                              builder: (context, value, child) {
                                return SideMenu(
                                  name: name.value,
                                );
                              },
                            )
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
