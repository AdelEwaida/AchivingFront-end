import 'package:flutter/material.dart';

class DatesProvider with ChangeNotifier {
  bool dayTemp = true;
  bool monthTemp = true;
  bool yearTemp = true;
  setDayTemp(bool temp) {
    dayTemp = temp;
    notifyListeners();
  }

  getDayTemp() {
    return dayTemp;
  }

  setMonthTemp(bool temp) {
    monthTemp = temp;
    notifyListeners();
  }

  getMonthTemp() {
    return monthTemp;
  }

  setYearTemp(bool temp) {
    yearTemp = temp;
    notifyListeners();
  }

  getYearTemp() {
    return yearTemp;
  }

  void setDatesController(TextEditingController fromController,
      TextEditingController toController) {
    // fromCont = fromController;
    // toCont = toController;
    notifyListeners();
  }

  // TextEditingController getFromCont() {
  //   return fromCont;
  // }

  // TextEditingController getToCont() {
  //   return toCont;
  // }
}
