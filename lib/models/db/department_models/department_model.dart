import 'package:pluto_grid/pluto_grid.dart';

class DepartmentModel {
  String? txtKey;
  String? txtDescription;
  String? txtShortcode;

  DepartmentModel({
    this.txtKey,
    this.txtDescription,
    this.txtShortcode,
  });

  // Factory constructor to create an instance from a JSON map
  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      txtKey: json['txtKey'],
      txtDescription: json['txtDescription'],
      txtShortcode: json['txtShortcode'],
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'txtKey': txtKey,
      'txtDescription': txtDescription,
      'txtShortcode': txtShortcode,
    };
  }

  Map<String, dynamic> toJsonEdit() {
    return {
      'id': txtKey,
      'description': txtDescription,
      'shortCode': txtShortcode,
    };
  }

  Map<String, dynamic> toJsonDelete() {
    return {
      'id': txtKey,
    };
  }

  Map<String, dynamic> toJsonAdd() {
    return {
      'shortCode': txtShortcode,
      'description': txtDescription,
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(cells: {
      'countNumber': PlutoCell(value: count),
      'txtKey': PlutoCell(value: txtKey),
      'txtDescription': PlutoCell(value: txtDescription ?? ""),
      'txtShortcode': PlutoCell(value: txtShortcode ?? ""),
    });
  }

  static DepartmentModel fromPlutoRow(PlutoRow row) {
    return DepartmentModel(
      txtKey: row.cells['txtKey']?.value,
      txtDescription: row.cells['txtDescription']?.value,
      txtShortcode: row.cells['txtShortcode']?.value,
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return txtDescription ?? "";
  }
}
