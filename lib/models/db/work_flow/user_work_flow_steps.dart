import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/func/lists.dart';
import '../../../utils/func/responsive.dart';

class UserWorkflowSteps {
  String? txtKey;
  String? txtWorkflowcode;
  int? intStepno;
  String? txtStepdesc;
  String? txtUsercode;
  int? intStatus;
  String? txtFeedback;
  String? datActionDate;
  int? bolOptional;
  int? intCurrStep;
  String? txtTemplatecode;
  String? txtTemplateName;
  String? txtDocumentcode;
  String? txtDocumentName;
  String? txtDept;
  String? txtDeptName;

  UserWorkflowSteps({
    this.intStepno,
    this.txtStepdesc,
    this.txtUsercode,
    this.bolOptional,
    this.txtWorkflowcode,
    this.txtFeedback,
    this.datActionDate,
    this.intStatus,
    this.txtKey,
    this.intCurrStep,
    this.txtTemplatecode,
    this.txtTemplateName,
    this.txtDocumentcode,
    this.txtDocumentName,
    this.txtDept,
    this.txtDeptName,
  });

  factory UserWorkflowSteps.fromJson(Map<String, dynamic> json) {
    return UserWorkflowSteps(
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
          json['intStatus'].toString() == "null" ? -1 : json['intStatus'],
      intCurrStep:
          json['intCurrStep'].toString() == "null" ? -1 : json['intCurrStep'],
      txtTemplatecode: json['txtTemplatecode'].toString() == "null"
          ? ""
          : json['txtTemplatecode'].toString(),
      txtTemplateName: json['txtTemplateName'].toString() == "null"
          ? ""
          : json['txtTemplateName'].toString(),
      txtDocumentcode: json['txtDocumentcode'].toString() == "null"
          ? ""
          : json['txtDocumentcode'].toString(),
      txtDocumentName: json['txtDocumentName'].toString() == "null"
          ? ""
          : json['txtDocumentName'].toString(),
      txtDept: json['txtDept'].toString() == "null"
          ? ""
          : json['txtDept'].toString(),
      txtDeptName: json['txtDeptName'].toString() == "null"
          ? ""
          : json['txtDeptName'].toString(),
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
      'intStatus': intStatus,
      'intCurrStep': intCurrStep,
      'txtTemplatecode': txtTemplatecode,
      'txtTemplateName': txtTemplateName,
      'txtDocumentcode': txtDocumentcode,
      'txtDocumentName': txtDocumentName,
      'txtDept': txtDept,
      'txtDeptName': txtDeptName,
    };
  }

  PlutoRow toPlutoRow(int count, AppLocalizations localizations) {
    return PlutoRow(cells: {
      'count': PlutoCell(value: count),
      'intStepno': PlutoCell(value: intStepno ?? ""),
      'txtStepdesc': PlutoCell(value: txtStepdesc ?? ""),
      'txtUsercode': PlutoCell(value: txtUsercode ?? ""),
      'bolOptional': PlutoCell(value: bolOptional ?? -1),
      'datActionDate': PlutoCell(value: datActionDate ?? ""),
      'txtFeedback': PlutoCell(value: txtFeedback ?? ""),
      'intStatus': PlutoCell(
          value: ListConstants.getStatusName(intStatus ?? -1, localizations)),
      'intCurrStep': PlutoCell(value: intCurrStep ?? -1),
      'txtTemplatecode': PlutoCell(value: txtTemplatecode ?? ""),
      'txtTemplateName': PlutoCell(value: txtTemplateName ?? ""),
      'txtDocumentcode': PlutoCell(value: txtDocumentcode ?? ""),
      'txtDocumentName': PlutoCell(value: txtDocumentName ?? ""),
      'txtDept': PlutoCell(value: txtDept ?? ""),
      'txtDeptName': PlutoCell(value: txtDeptName ?? ""),
      'txtKey': PlutoCell(value: txtKey ?? ""),
      'txtWorkflowcode': PlutoCell(value: txtWorkflowcode ?? ""),
    });
  }

  UserWorkflowSteps.fromPluto(
      PlutoRow plutoRow, AppLocalizations localizations) {
    txtKey = plutoRow.cells['txtKey']?.value as String?;
    txtWorkflowcode = plutoRow.cells['txtWorkflowcode']?.value as String?;
    intStepno = plutoRow.cells['intStepno']?.value as int?;
    txtStepdesc = plutoRow.cells['txtStepdesc']?.value as String?;
    txtUsercode = plutoRow.cells['txtUsercode']?.value as String?;
    datActionDate = plutoRow.cells['datActionDate']?.value as String?;
    txtFeedback = plutoRow.cells['txtFeedback']?.value as String?;
    bolOptional = plutoRow.cells['bolOptional']?.value as int?;
    intStatus = ListConstants.getStatusCode(
        plutoRow.cells['intStatus']?.value ?? -1, localizations);
    intCurrStep = plutoRow.cells['intCurrStep']?.value as int?;
    txtTemplatecode = plutoRow.cells['txtTemplatecode']?.value as String?;
    txtTemplateName = plutoRow.cells['txtTemplateName']?.value as String?;
    txtDocumentcode = plutoRow.cells['txtDocumentcode']?.value as String?;
    txtDocumentName = plutoRow.cells['txtDocumentName']?.value as String?;
    txtDept = plutoRow.cells['txtDept']?.value as String?;
    txtDeptName = plutoRow.cells['txtDeptName']?.value as String?;
  }

  @override
  String toString() {
    return txtStepdesc.toString();
  }
}
