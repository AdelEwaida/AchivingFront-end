import 'package:pluto_grid/pluto_grid.dart';

class DepartmentModel {
  String? txtKey;
  String? txtDescription;
  String? txtShortcode;
  int? barcodeRequired;
  int? bolBarcodeRequired;
  //

  DepartmentModel({
    this.txtKey,
    this.txtDescription,
    this.txtShortcode,
    this.barcodeRequired,
    this.bolBarcodeRequired,
  });

  // Factory constructor to create an instance from a JSON map
  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      txtKey: json['txtKey'],
      txtDescription: json['txtDescription'],
      txtShortcode: json['txtShortcode'],
      barcodeRequired: json['bolBarcodeRequired'] ?? 0,
      bolBarcodeRequired: json['bolBarcodeRequired'] ?? 0,
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'txtKey': txtKey,
      'txtDescription': txtDescription,
      'txtShortcode': txtShortcode,
      'barcodeRequired': barcodeRequired,
      'bolBarcodeRequired': bolBarcodeRequired,
    };
  }

  Map<String, dynamic> toJsonEdit() {
    return {
      'id': txtKey,
      'description': txtDescription,
      'shortCode': txtShortcode,
      'barcodeRequired': barcodeRequired,
      'bolBarcodeRequired': bolBarcodeRequired,
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
      'barcodeRequired': barcodeRequired,
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(cells: {
      'countNumber': PlutoCell(value: count),
      'txtKey': PlutoCell(value: txtKey),
      'txtDescription': PlutoCell(value: txtDescription ?? ""),
      'txtShortcode': PlutoCell(value: txtShortcode ?? ""),
      'bolBarcodeRequired': PlutoCell(value: bolBarcodeRequired ?? 0),
    });
  }

  static DepartmentModel fromPlutoRow(PlutoRow row) {
    return DepartmentModel(
      txtKey: row.cells['txtKey']?.value,
      txtDescription: row.cells['txtDescription']?.value,
      txtShortcode: row.cells['txtShortcode']?.value,
      bolBarcodeRequired: row.cells['bolBarcodeRequired']?.value,
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return txtDescription ?? "";
  }
}
