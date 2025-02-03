import 'package:flutter/material.dart';

class CalssificatonNameAndCodeProvider with ChangeNotifier {
  String _selectedClassificatonName = "";
  String _selectedClassificatonKey = "";
  void setSelectedClassificatonName(String classificatoon) {
    _selectedClassificatonName = classificatoon;
    notifyListeners();
  }

  String get classificatonName => _selectedClassificatonName;
  void setSelectedClassificatonKey(String key) {
    _selectedClassificatonKey = key;
    notifyListeners();
  }

  void clearProvider() {
    _selectedClassificatonName = "";
    _selectedClassificatonKey = "";
  }

  String get classificatonKey => _selectedClassificatonKey;
}
