import 'package:archiving_flutter_project/models/dto/side_menu/sub_menu_model.dart';
import 'package:flutter/material.dart';

class MenuModel {
  final String title;
  final IconData icon;
  final bool isParent;
  final int pageNumber;
  bool isOpened;
  List<SubMenuModel> subMenuList;
  int selectedSubMenuIndex; // Add this line

  MenuModel({
    required this.title,
    required this.icon,
    required this.isParent,
    required this.pageNumber,
    this.isOpened = false,
    this.subMenuList = const [],
    this.selectedSubMenuIndex = -1, // Initialize it
  });
}
