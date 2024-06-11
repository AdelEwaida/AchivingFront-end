import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FileListScreen extends StatefulWidget {
  const FileListScreen({super.key});

  @override
  State<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  late AppLocalizations _locale;
  double width = 0;
  double hight = 0;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    hight = MediaQuery.of(context).size.height;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    hight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topRight,
                  width: width * 0.2,
                  height: hight * 0.4,
                  color: Colors.red,
                ),
              ],
            ),
          ]),
    );
  }
}
