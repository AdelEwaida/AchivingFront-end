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

  Map<String, dynamic> toJsonAdd() {
    return {
      'shortCode': txtShortcode,
      'description': txtDescription,
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(cells: {
      'countNumber': PlutoCell(value: count),
      'txtDescription': PlutoCell(value: txtDescription ?? ""),
      'txtShortcode': PlutoCell(value: txtShortcode ?? ""),
    });
  }
}
