import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/func/responsive.dart';

class WorkFlowDocumentModel {
  String? txtKey;
  String? txtDocumentcode;
  String? dept;
  String? txtTemplatecode;
  int? intStatus;
  String? datMaxDate;
  String? txtDept;
  String? txtDeptName;

  WorkFlowDocumentModel(
      {this.txtKey,
      this.txtDocumentcode,
      this.txtDept,
      this.txtTemplatecode,
      this.dept,
      this.datMaxDate,
      this.intStatus,
      this.txtDeptName});

  factory WorkFlowDocumentModel.fromJson(Map<String, dynamic> json) {
    return WorkFlowDocumentModel(
        txtKey: json['txtKey'].toString() == "null"
            ? ""
            : json['txtKey'].toString(),
        txtDocumentcode: json['txtDocumentcode'].toString() == "null"
            ? ""
            : json['txtDocumentcode'].toString(),
        txtDept: json['txtDept'].toString() == "null"
            ? ""
            : json['txtDept'].toString(),
        txtTemplatecode: json['txtTemplatecode'].toString() == "null"
            ? ""
            : json['txtTemplatecode'].toString(),
        txtDeptName: json['txtDeptName'].toString() == "null"
            ? ""
            : json['txtDeptName'].toString(),
        dept: json['dept'].toString() == "null" ? "" : json['dept'].toString(),
        datMaxDate: json['datMaxDate'].toString() == "null"
            ? ""
            : json['datMaxDate'].toString(),
        intStatus:
            json['intStatus'].toString() == "null" ? -1 : json['intStatus']);
  }

  Map<String, dynamic> toJsonSearch() {
    return {
      'dept': dept,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'txtKey': txtKey,
      'txtDocumentcode': txtDocumentcode,
      'txtDept': txtDept,
      'txtTemplatecode': txtTemplatecode,
      'txtDeptName': txtDeptName,
      'dept': dept,
      'datMaxDate': datMaxDate,
      'intStatus': intStatus
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(cells: {
      'count': PlutoCell(value: count),
      'txtKey': PlutoCell(value: txtKey),
      'txtDocumentcode': PlutoCell(value: txtDocumentcode),
      'txtDept': PlutoCell(value: txtDept),
      'txtTemplatecode': PlutoCell(value: txtTemplatecode),
      'txtDeptName': PlutoCell(value: txtDeptName),
      'datMaxDate': PlutoCell(value: datMaxDate),
      'intStatus': PlutoCell(value: intStatus),
    });
  }

  WorkFlowDocumentModel.fromPluto(PlutoRow plutoRow) {
    txtKey = plutoRow.cells['txtKey']?.value as String?;
    txtDocumentcode = plutoRow.cells['txtDocumentcode']?.value as String?;
    txtDept = plutoRow.cells['txtDept']?.value as String?;
    txtTemplatecode = plutoRow.cells['txtTemplatecode']?.value as String?;
    txtDeptName = plutoRow.cells['txtDeptName']?.value as String?;
    intStatus = plutoRow.cells['intStatus']?.value as int?;
    datMaxDate = plutoRow.cells['datMaxDate']?.value as String?;
  }
  @override
  String toString() {
    return txtDocumentcode.toString();
  }

  List<PlutoColumn> getTemplateColumns(
      AppLocalizations localizations, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = Responsive.isDesktop(context);
    List<PlutoColumn> list = [
      PlutoColumn(
        readOnly: true,
        title: localizations.templateName,
        field: "txtDocumentcode",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.35 : width * 0.3,
      ),
      PlutoColumn(
        readOnly: true,
        title: localizations.description,
        field: "txtTemplatecode",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.4 : width * 0.4,
      ),
    ];
    return list;
  }
}
