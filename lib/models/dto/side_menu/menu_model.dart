import 'package:archiving_flutter_project/models/dto/side_menu/sub_menu_model.dart';
import 'package:flutter/material.dart';

class MenuModel {
  String title;
  IconData icon;
  bool isParent;
  int pageNumber;
  List<SubMenuModel> subMenuList;
  bool isOpened;

  MenuModel(
      {required this.title,
      required this.icon,
      required this.isParent,
      required this.pageNumber,
      required this.subMenuList,
      required this.isOpened});
}
