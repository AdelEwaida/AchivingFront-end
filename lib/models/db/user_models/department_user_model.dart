import 'package:pluto_grid/pluto_grid.dart';

class DepartmentUserModel {
  String? txtDeptName;
  String? txtUsercode;
  int? bolSelected;
  String? txtDeptkey;
  DepartmentUserModel({
    this.txtDeptName,
    this.txtDeptkey,
    this.txtUsercode,
    this.bolSelected,
  });

  factory DepartmentUserModel.fromJson(Map<String, dynamic> json) {
    return DepartmentUserModel(
      txtDeptName: json['txtDeptName'],
      txtUsercode: json['txtUsercode'],
      txtDeptkey: json['txtDeptkey'],
      bolSelected: json['bolSelected'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txtDeptkey': txtDeptkey,
      'txtDeptName': txtDeptName,
      'txtUsercode': txtUsercode,
      'bolSelected': bolSelected,
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(
      cells: {
        'txtDeptkey': PlutoCell(value: txtDeptkey),
        'txtDeptName': PlutoCell(value: txtDeptName),
        'txtUsercode': PlutoCell(value: txtUsercode),
        'bolSelected': PlutoCell(value: bolSelected),
      },
    );
  }

  static DepartmentUserModel fromPlutoRow(PlutoRow row) {
    return DepartmentUserModel(
      txtDeptkey: row.cells['txtDeptkey']?.value,
      txtDeptName: row.cells['txtDeptName']?.value,
      txtUsercode: row.cells['txtUsercode']?.value,
      bolSelected: row.cells['bolSelected']?.value,
    );
  }
@override
  String toString() {
    // TODO: implement toString
    return txtDeptName!;
  }
}
