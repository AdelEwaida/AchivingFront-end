import 'package:pluto_grid/pluto_grid.dart';

class DocDeptReportModel {
  String? dept;
  int? countFiles;

  DocDeptReportModel({
    this.dept,
    this.countFiles,
  });

  // Factory constructor to create an instance from a JSON map
  factory DocDeptReportModel.fromJson(Map<String, dynamic> json) {
    return DocDeptReportModel(
      dept: json['dept'],
      countFiles: json['countFiles'],
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'dept': dept,
      'countFiles': countFiles,
    };
  }

  Map<String, dynamic> toJsonEdit() {
    return {
      'id': dept,
      'description': countFiles,
    };
  }

  Map<String, dynamic> toJsonDelete() {
    return {
      'id': dept,
    };
  }

  Map<String, dynamic> toJsonAdd() {
    return {
      'description': countFiles,
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(cells: {
      'countNumber': PlutoCell(value: count),
      'dept': PlutoCell(value: dept),
      'countFiles': PlutoCell(value: countFiles ?? ""),
    });
  }

  static DocDeptReportModel fromPlutoRow(PlutoRow row) {
    return DocDeptReportModel(
      dept: row.cells['dept']?.value,
      countFiles: row.cells['countFiles']?.value,
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return countFiles.toString();
  }
}
