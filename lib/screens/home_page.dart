import 'package:archiving_flutter_project/data/side_menu_data.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/side_menu/side_menu.dart';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../providers/file_list_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  late ScreenContentProvider screenContentProvider;
  ValueNotifier name = ValueNotifier("");
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Future<void> didChangeDependencies() async {
    screenContentProvider = context.read<ScreenContentProvider>();
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
      key: _scaffoldKey,
      appBar: !isDesktop
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            )
          : null,
      drawer: Drawer(
        child: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: name,
            builder: (context, value, child) {
              return SideMenu(
                name: name.value,
              );
            },
          ),
        ),
      ),
      body: SizedBox(
        width: width,
        height: height,
        child: Column(
          children: [
            if (context.read<DocumentListProvider>().isViewFile != true &&
                isDesktop)
              ValueListenableBuilder(
                valueListenable: name,
                builder: (context, value, child) {
                  return SideMenu(
                    name: name.value,
                  );
                },
              ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Consumer<ScreenContentProvider>(
                  builder: (builder, value, child) {
                    Widget tabView =
                        getScreenContent(screenContentProvider.getPage());
                    return tabView;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
