import 'package:archiving_flutter_project/utils/constants/user_types_constant/user_types_constant.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserModel {
  String? txtCode;
  String? txtNamee;
  String? txtPwd;
  int? intType;
  int? bolActive;
  String? txtDeptkey;
  String? email;
  String? activeToken;

  UserModel({
    this.txtCode,
    this.txtNamee,
    this.txtPwd,
    this.intType,
    this.bolActive,
    this.txtDeptkey,
    this.email,
    this.activeToken,
  });

  // fromJson method
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      txtCode: json['txtCode'],
      txtNamee: json['txtNamee'],
      txtPwd: json['txtPwd'],
      intType: json['intType'],
      bolActive: json['bolActive'],
      txtDeptkey: json['txtDeptkey'],
      email: json['email'],
      activeToken: json['activeToken'],
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'txtCode': txtCode,
      'txtNamee': txtNamee,
      'txtPwd': txtPwd,
      'intType': intType,
      'bolActive': bolActive,
      'txtDeptkey': txtDeptkey,
      'email': email,
      'activeToken': activeToken,
    };
  }

  // toPlutoRow method
  PlutoRow toPlutoRow(int count, AppLocalizations localizations) {
    return PlutoRow(
      cells: {
        "count": PlutoCell(value: count),
        'txtCode': PlutoCell(value: txtCode),
        'txtNamee': PlutoCell(value: txtNamee),
        'txtPwd': PlutoCell(value: txtPwd),
        'intType': PlutoCell(value: getNameOfUserType(localizations, intType!)),
        'bolActive': PlutoCell(
            value: bolActive == 1
                ? localizations.active
                : localizations.notActive),
        'txtDeptkey': PlutoCell(value: txtDeptkey),
        'email': PlutoCell(value: email ?? ""),
        'activeToken': PlutoCell(value: activeToken),
      },
    );
  }

  factory UserModel.fromPlutoRow(PlutoRow row, AppLocalizations localizations) {
    return UserModel(
      txtCode: row.cells['txtCode']?.value,
      txtNamee: row.cells['txtNamee']?.value,
      txtPwd: row.cells['txtPwd']?.value,
      intType: getCodeOfUserType(localizations, row.cells['intType']?.value),
      bolActive: row.cells['bolActive']?.value == localizations.active ? 1 : 0,
      txtDeptkey: row.cells['txtDeptkey']?.value,
      email: row.cells['email']?.value,
      activeToken: row.cells['activeToken']?.value,
    );
  }
}
