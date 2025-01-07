import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/func/responsive.dart';

class WorkFlowDocumentModel {
  String? txtKey;
  String? txtDocumentcode;
  String? txtDocumentName;
  String? txtTemplatecode;
  String? txtTemplateName;
  int? intStatus;
  String? datMaxDate;
  String? txtDept;
  String? txtDeptName;
  String? dept;
  String? document;
  String? documentCode;

  WorkFlowDocumentModel(
      {this.txtKey,
      this.txtDocumentcode,
      this.txtDept,
      this.txtTemplatecode,
      this.dept,
      this.document,
      this.datMaxDate,
      this.intStatus,
      this.txtDocumentName,
      this.txtTemplateName,
      this.documentCode,
      this.txtDeptName});

  factory WorkFlowDocumentModel.fromJson(Map<String, dynamic> json) {
    return WorkFlowDocumentModel(
      txtKey:
          json['txtKey'].toString() == "null" ? "" : json['txtKey'].toString(),
      txtDocumentcode: json['txtDocumentcode'].toString() == "null"
          ? ""
          : json['txtDocumentcode'].toString(),
      txtDocumentName: json['txtDocumentName'].toString() == "null"
          ? ""
          : json['txtDocumentName'].toString(),
      txtTemplatecode: json['txtTemplatecode'].toString() == "null"
          ? ""
          : json['txtTemplatecode'].toString(),
      txtDeptName: json['txtDeptName'].toString() == "null"
          ? ""
          : json['txtDeptName'].toString(),
      intStatus:
          json['intStatus'].toString() == "null" ? -1 : json['intStatus'],
      txtDept: json['txtDept'].toString() == "null"
          ? ""
          : json['txtDept'].toString(),
      dept: json['dept'].toString() == "null" ? "" : json['dept'].toString(),
      document: json['document'].toString() == "null"
          ? ""
          : json['document'].toString(),
      datMaxDate: json['datMaxDate'].toString() == "null"
          ? ""
          : json['datMaxDate'].toString(),
      txtTemplateName: json['txtTemplateName'].toString() == "null"
          ? ""
          : json['txtTemplateName'].toString(),
      documentCode: json['documentCode'].toString() == "null"
          ? ""
          : json['documentCode'].toString(),
    );
  }

  Map<String, dynamic> toJsonSearch() {
    return {'dept': dept, 'document': document, 'documentCode': documentCode};
  }

  Map<String, dynamic> toJson() {
    return {
      'txtKey': txtKey,
      'txtDocumentcode': txtDocumentcode,
      'txtDept': txtDept,
      'txtTemplatecode': txtTemplatecode,
      'txtDeptName': txtDeptName,
      'dept': dept,
      'document': document,
      'datMaxDate': datMaxDate,
      'intStatus': intStatus,
      'txtDocumentName': txtDocumentName,
      'txtTemplateName': txtTemplateName,
      'documentCode': documentCode
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(cells: {
      'count': PlutoCell(value: count),
      'txtKey': PlutoCell(value: txtKey ?? ""),
      'txtDocumentcode': PlutoCell(value: txtDocumentcode ?? ""),
      'txtDocumentName': PlutoCell(value: txtDocumentName ?? ""),
      'txtTemplatecode': PlutoCell(value: txtTemplatecode ?? ""),
      'txtTemplateName': PlutoCell(value: txtTemplateName),
      'intStatus': PlutoCell(value: intStatus),
      'datMaxDate': PlutoCell(value: datMaxDate),
      'txtDept': PlutoCell(value: txtDept),
      'txtDeptName': PlutoCell(value: txtDeptName),
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
    txtDocumentName = plutoRow.cells['txtDocumentName']?.value as String?;
    txtTemplateName = plutoRow.cells['txtTemplateName']?.value as String?;
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
