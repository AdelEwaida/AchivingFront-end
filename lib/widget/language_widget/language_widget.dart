
import 'package:archiving_flutter_project/providers/local_provider.dart';
import 'package:archiving_flutter_project/widget/language_widget/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageWidget extends StatefulWidget {
  final void Function(Locale)? onLocaleChanged;
  final Color color;
  const LanguageWidget({Key? key, this.onLocaleChanged, required this.color})
      : super(key: key);

  @override
  State<LanguageWidget> createState() => _LanguageWidgetState();
}

class _LanguageWidgetState extends State<LanguageWidget> {
  late AppLocalizations _local;
  late LocaleProvider _localeProvider;
  List<Widget> lang = [];
  List<Widget> lang2 = [];

  @override
  void didChangeDependencies() {
    _localeProvider = Provider.of<LocaleProvider>(context);
    _local = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    lang = getWidget(Colors.black);

    String initialFlag;
    if (_localeProvider.locale.languageCode == 'ar') {
      initialFlag = 'ar';
    } else {
      initialFlag = 'en';
    }

    return DropdownButton(
      underline: Container(color: Colors.transparent),
      // style: TextStyle,
      value: initialFlag,
      selectedItemBuilder: (_) {
        return getWidget(widget.color,
                textArabic: _local.selectedLangArb,
                textEng: _local.selectedLangEng)
            .map((e) => e)
            .toList();
      },
      // icon: const Icon(Icons.arrow_downward),
      items: [
        DropdownMenuItem(value: 'en', child: lang[0]),
        DropdownMenuItem(value: 'ar', child: lang[1]),
      ],
      onChanged: (value) async {
        Locale newLocale = Locale(value as String);
        widget.onLocaleChanged!(newLocale);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('selectedLanguage', value);
      },
    );
  }

  List<Widget> getWidget(Color color, {String? textArabic, String? textEng}) {
    double height = MediaQuery.of(context).size.height;
    return [
      SizedBox(
        //// width: textEng == null ? 130 : 60,
        child: Row(
          children: [
            CircleFlag('us', size: height * 0.026),
            //  SizedBox(width: textEng == null ? 5 : 10),
            // Text(
            //   textEng ?? _local.dropLangEN,
            //   style: TextStyle(
            //     // backgroundColor: Colors.black,
            //     color: color,
            //     fontSize: 12,
            //   ),
            // ),
          ],
        ),
      ),
      SizedBox(
        // width: textArabic == null ? 130 : 50,
        child: Row(
          children: [
            CircleFlag(
              'ps',
              size: height * 0.026,
            ),
            // SizedBox(width: textEng == null ? 5 : 10),
            // Text(
            //   textArabic ?? _local.dropLangAR,
            //   style: TextStyle(
            //     color: color,
            //     fontSize: 12,
            //   ),
            // ),
          ],
        ),
      ),
    ];
  }
}
