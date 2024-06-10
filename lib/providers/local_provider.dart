import 'package:archiving_flutter_project/utils/constants/supported_lang.dart';
import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  late Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!lang.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }
}
