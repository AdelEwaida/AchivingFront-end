import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/func/responsive.dart';

class StepsModel {
  int? intStepno;
  String? txtStepdesc;
  String? txtUsercode;
  int? bolOptional;
  String? txtKey;
  String? txtTemplatecode;

  StepsModel(
      {this.intStepno,
      this.txtStepdesc,
      this.txtUsercode,
      this.bolOptional,
      this.txtTemplatecode,
      this.txtKey});

  factory StepsModel.fromJson(Map<String, dynamic> json) {
    return StepsModel(
      intStepno: json['intStepno'].toString() == "null" ? 0 : json['intStepno'],
      txtStepdesc: json['txtStepdesc'].toString() == "null"
          ? ""
          : json['txtStepdesc'].toString(),
      txtUsercode: json['txtUsercode'].toString() == "null"
          ? ""
          : json['txtUsercode'].toString(),
      bolOptional:
          json['bolOptional'].toString() == "null" ? 0 : json['bolOptional'],
      txtKey:
          json['txtKey'].toString() == "null" ? "" : json['txtKey'].toString(),
      txtTemplatecode: json['txtTemplatecode'].toString() == "null"
          ? ""
          : json['txtTemplatecode'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intStepno': intStepno,
      'txtStepdesc': txtStepdesc,
      'txtUsercode': txtUsercode,
      'bolOptional': bolOptional,
      'txtTemplatecode': txtTemplatecode,
      "txtKey": txtKey
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(cells: {
      'count': PlutoCell(value: count),
      'intStepno': PlutoCell(value: intStepno),
      'txtStepdesc': PlutoCell(value: txtStepdesc),
      'txtUsercode': PlutoCell(value: txtUsercode),
      'bolOptional': PlutoCell(value: bolOptional),
    });
  }

  StepsModel.fromPluto(PlutoRow plutoRow) {
    intStepno = plutoRow.cells['intStepno']?.value as int?;
    txtStepdesc = plutoRow.cells['txtStepdesc']?.value as String?;
    txtUsercode = plutoRow.cells['txtUsercode']?.value as String?;
    bolOptional = plutoRow.cells['bolOptional']?.value as int?;
  }
  @override
  String toString() {
    return txtStepdesc.toString();
  }

  static List<PlutoColumn> getColumnsForDialogSearchFillter(
      AppLocalizations localizations, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = Responsive.isDesktop(context);
    List<PlutoColumn> list = [
      PlutoColumn(
          readOnly: true,
          title: localizations.templateName,
          field: "txtStepdesc",
          backgroundColor: columnColors,
          type: PlutoColumnType.text(),
          width: isDesktop ? width * 0.11 : width * 0.3,
          enableRowChecked: true),
      PlutoColumn(
        readOnly: true,
        title: localizations.description,
        field: "bolOptional",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.35 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: localizations.department,
        field: "txtUsercode",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.35 : width * 0.4,
      ),
    ];
    return list;
  }
}
