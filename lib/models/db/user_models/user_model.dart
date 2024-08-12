import 'package:archiving_flutter_project/utils/constants/user_types_constant/user_types_constant.dart';
import 'package:flutter/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/func/responsive.dart';

class UserModel {
  String? txtCode;
  String? txtNamee;
  String? txtPwd;
  int? intType;
  int? bolActive;
  String? txtDeptkey;
  String? email;
  String? activeToken;
  String? txtReferenceUsername;
  String? url;
  UserModel({
    this.txtCode,
    this.txtNamee,
    this.txtPwd,
    this.intType,
    this.bolActive,
    this.txtDeptkey,
    this.email,
    this.activeToken,
    this.txtReferenceUsername,
    this.url,
  });
  static List<PlutoColumn> getColumnsForDialogSearchFillter(
      AppLocalizations localizations, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = Responsive.isDesktop(context);
    List<PlutoColumn> list = [
      PlutoColumn(
          readOnly: true,
          // suppressedAutoSize: true,
          title: localizations.userCode,
          field: "txtCode",
          backgroundColor: columnColors,
          type: PlutoColumnType.text(),
          width: isDesktop ? width * 0.11 : width * 0.3,
          enableRowChecked: true),
      PlutoColumn(
        readOnly: true,
        // suppressedAutoSize: true,
        title: localizations.userName,
        field: "txtNamee",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.35 : width * 0.4,
      ),
    ];
    return list;
  }

  // fromJson method
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        txtCode: json['txtCode'],
        txtReferenceUsername: json['txtReferenceUsername'],
        txtNamee: json['txtNamee'],
        txtPwd: json['txtPwd'],
        intType: json['intType'],
        bolActive: json['bolActive'],
        txtDeptkey: json['txtDeptkey'],
        email: json['email'],
        activeToken: json['activeToken'],
        url: json['url']);
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'txtReferenceUsername': txtReferenceUsername,
      'txtCode': txtCode,
      'txtNamee': txtNamee,
      'txtPwd': txtPwd,
      'intType': intType,
      'bolActive': bolActive,
      'txtDeptkey': txtDeptkey,
      'email': email,
      'activeToken': activeToken,
      'url': url
    };
  }

  // toPlutoRow method
  PlutoRow toPlutoRow(int count, AppLocalizations localizations) {
    return PlutoRow(
      cells: {
        "count": PlutoCell(value: count),
        'txtCode': PlutoCell(value: txtCode),
        'txtNamee': PlutoCell(value: txtNamee),
        'txtPwd': PlutoCell(value: txtPwd ?? ""),
        'txtReferenceUsername': PlutoCell(value: txtReferenceUsername ?? ""),
        'intType':
            PlutoCell(value: getNameOfUserType(localizations, intType! ?? 0)),
        'bolActive': PlutoCell(
            value: bolActive == 1
                ? localizations.active
                : localizations.notActive),
        'txtDeptkey': PlutoCell(value: txtDeptkey ?? ""),
        'email': PlutoCell(value: email ?? ""),
        'activeToken': PlutoCell(value: activeToken ?? ""),
        'url': PlutoCell(value: url ?? "")
      },
    );
  }

  factory UserModel.fromPlutoRow(PlutoRow row, AppLocalizations localizations) {
    return UserModel(
      txtReferenceUsername: row.cells['txtReferenceUsername']?.value,
      txtCode: row.cells['txtCode']?.value,
      txtNamee: row.cells['txtNamee']?.value,
      txtPwd: row.cells['txtPwd']?.value,
      intType: getCodeOfUserType(localizations, row.cells['intType']?.value),
      bolActive: row.cells['bolActive']?.value == localizations.active ? 1 : 0,
      txtDeptkey: row.cells['txtDeptkey']?.value,
      email: row.cells['email']?.value,
      activeToken: row.cells['activeToken']?.value,
      url: row.cells['url']?.value,
    );
  }
  @override
  String toString() {
    // TODO: implement toString
    return txtNamee!;
  }
}
