import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/func/responsive.dart';

class DocumentStepsModel {
  String? txtKey;
  String? txtWorkflowcode;
  int? intStepno;
  String? txtStepdesc;
  String? txtUsercode;
  int? intStatus;
  String? txtFeedback;
  String? datActionDate;
  int? bolOptional;

  DocumentStepsModel(
      {this.intStepno,
      this.txtStepdesc,
      this.txtUsercode,
      this.bolOptional,
      this.txtWorkflowcode,
      this.txtFeedback,
      this.datActionDate,
      this.intStatus,
      this.txtKey});

  factory DocumentStepsModel.fromJson(Map<String, dynamic> json) {
    return DocumentStepsModel(
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
      txtWorkflowcode: json['txtWorkflowcode'].toString() == "null"
          ? ""
          : json['txtWorkflowcode'].toString(),
      datActionDate: json['datActionDate'].toString() == "null"
          ? ""
          : json['datActionDate'].toString(),
      txtFeedback: json['txtFeedback'].toString() == "null"
          ? ""
          : json['txtFeedback'].toString(),
      intStatus:
          json['txtFeedback'].toString() == "null" ? -1 : json['txtFeedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intStepno': intStepno,
      'txtStepdesc': txtStepdesc,
      'txtUsercode': txtUsercode,
      'bolOptional': bolOptional,
      'txtWorkflowcode': txtWorkflowcode,
      "txtKey": txtKey,
      'datActionDate': datActionDate,
      'txtFeedback': txtFeedback,
      'intStatus': intStatus
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(cells: {
      'count': PlutoCell(value: count),
      'intStepno': PlutoCell(value: intStepno),
      'txtStepdesc': PlutoCell(value: txtStepdesc),
      'txtUsercode': PlutoCell(value: txtUsercode),
      'bolOptional': PlutoCell(value: bolOptional),
      'datActionDate': PlutoCell(value: datActionDate),
      'txtFeedback': PlutoCell(value: txtFeedback),
      'intStatus': PlutoCell(value: intStatus)
    });
  }

  DocumentStepsModel.fromPluto(PlutoRow plutoRow) {
    intStepno = plutoRow.cells['intStepno']?.value as int?;
    txtStepdesc = plutoRow.cells['txtStepdesc']?.value as String?;
    txtUsercode = plutoRow.cells['txtUsercode']?.value as String?;
    datActionDate = plutoRow.cells['datActionDate']?.value as String?;
    txtFeedback = plutoRow.cells['txtFeedback']?.value as String?;
    bolOptional = plutoRow.cells['bolOptional']?.value as int?;
    intStatus = plutoRow.cells['intStatus']?.value as int?;
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
