import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/func/responsive.dart';

class TemplateModel {
  String? txtKey;
  String? txtName;
  String? txtDept;
  String? txtDescription;
  String? txtDeptName;
  String? dept;

  TemplateModel(
      {this.txtKey,
      this.txtName,
      this.txtDept,
      this.txtDescription,
      this.dept,
      this.txtDeptName});

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      txtKey:
          json['txtKey'].toString() == "null" ? "" : json['txtKey'].toString(),
      txtName: json['txtName'].toString() == "null"
          ? ""
          : json['txtName'].toString(),
      txtDept: json['txtDept'].toString() == "null"
          ? ""
          : json['txtDept'].toString(),
      txtDescription: json['txtDescription'].toString() == "null"
          ? ""
          : json['txtDescription'].toString(),
      txtDeptName: json['txtDeptName'].toString() == "null"
          ? ""
          : json['txtDeptName'].toString(),
      dept: json['dept'].toString() == "null" ? "" : json['dept'].toString(),
    );
  }

  Map<String, dynamic> toJsonSearch() {
    return {
      'dept': dept,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'txtKey': txtKey,
      'txtName': txtName,
      'txtDept': txtDept,
      'txtDescription': txtDescription,
      'txtDeptName': txtDeptName,
      'dept': dept
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(cells: {
      'count': PlutoCell(value: count),
      'txtKey': PlutoCell(value: txtKey),
      'txtName': PlutoCell(value: txtName),
      'txtDept': PlutoCell(value: txtDept),
      'txtDescription': PlutoCell(value: txtDescription),
      'txtDeptName': PlutoCell(value: txtDeptName)
    });
  }

  TemplateModel.fromPluto(PlutoRow plutoRow) {
    txtKey = plutoRow.cells['txtKey']?.value as String?;
    txtName = plutoRow.cells['txtName']?.value as String?;
    txtDept = plutoRow.cells['txtDept']?.value as String?;
    txtDescription = plutoRow.cells['txtDescription']?.value as String?;
    txtDeptName = plutoRow.cells['txtDeptName']?.value as String?;
  }
  @override
  String toString() {
    return txtName.toString();
  }

  List<PlutoColumn> getTemplateColumns(
      AppLocalizations localizations, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = Responsive.isDesktop(context);
    List<PlutoColumn> list = [
      PlutoColumn(
        readOnly: true,
        title: localizations.templateName,
        field: "txtName",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.35 : width * 0.3,
      ),
      PlutoColumn(
        readOnly: true,
        title: localizations.description,
        field: "txtDescription",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.4 : width * 0.4,
      ),
    ];
    return list;
  }
}
