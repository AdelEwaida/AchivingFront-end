import 'package:archiving_flutter_project/models/dto/side_menu/side_menu_model.dart';
import 'package:flutter/material.dart';

class ScreenContentProvider with ChangeNotifier {
  int _page = 0;
  int? _parentNum;
  int? _lastPage;
  bool dynamicSide = false;
  List<SideMenuModel> _menus = [];
  void setMenus(List<SideMenuModel> menus) {
    _menus = menus;
    notifyListeners();
  }

  List<SideMenuModel> get menus => _menus;
  void setLastPage(int page) {
    _lastPage = page;
    notifyListeners();
  }

  int? getLastPage() {
    return _lastPage;
  }

  void setPage1(int page, {int? parentNum}) {
    _page = page;
    _parentNum = parentNum;
    notifyListeners();
  }

  void setDynamic(bool dynamic) {
    dynamicSide = dynamic;
    notifyListeners();
  }

  bool getDynamicSideMenu() {
    return dynamicSide;
  }

  int getPage() {
    return _page;
  }

  int? getParentNum() {
    return _parentNum;
  }
}
