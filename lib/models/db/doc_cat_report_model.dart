import 'package:pluto_grid/pluto_grid.dart';

class DocCatReportModel {
  String? cat;
  int? countFiles;

  DocCatReportModel({
    this.cat,
    this.countFiles,
  });

  // Factory constructor to create an instance from a JSON map
  factory DocCatReportModel.fromJson(Map<String, dynamic> json) {
    return DocCatReportModel(
      cat: json['cat'],
      countFiles: json['countFiles'],
      
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'cat': cat,
      'countFiles': countFiles,
    };
  }

  Map<String, dynamic> toJsonEdit() {
    return {
      'id': cat,
      'description': countFiles,
    };
  }

  Map<String, dynamic> toJsonDelete() {
    return {
      'id': cat,
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
      'cat': PlutoCell(value: cat),
      'countFiles': PlutoCell(value: countFiles ?? ""),
    });
  }

  static DocCatReportModel fromPlutoRow(PlutoRow row) {
    return DocCatReportModel(
      cat: row.cells['cat']?.value,
      countFiles: row.cells['countFiles']?.value,
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return countFiles.toString();
  }
}
