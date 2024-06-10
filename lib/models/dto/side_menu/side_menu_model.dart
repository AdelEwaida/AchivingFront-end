import 'package:flutter/material.dart';

class SideMenuModel {
  String? _title;
  String getTitle() => _title ?? "";
  int? _index;
  String? _route;
  void setRoute(String route) => _route = route;
  String getRoute() => _route!;
  void setIndex(int index) => _index = index;
  int getIndex() => _index!;
  void setTitle(String title) => _title = title;

  IconData? _icons;
  IconData getIcon() => _icons ?? Icons.abc;
  void setIcon(IconData icon) => _icons = icon;

  bool? _isSelected;
  bool getIsSelected() => _isSelected ?? false;
  void setIsSelected(bool isSelected) => _isSelected = isSelected;

  SideMenuModel(
      {required title, required icon, isSelected, required index, route}) {
    _title = title;
    _icons = icon;
    _isSelected = isSelected ?? false;
    _index = index;
    _route = route;
  }
}
