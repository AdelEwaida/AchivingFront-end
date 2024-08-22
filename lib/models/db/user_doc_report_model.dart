import 'package:pluto_grid/pluto_grid.dart';

class UserDocReportModel {
  String? username;
  int? countFiles;

  UserDocReportModel({
    this.username,
    this.countFiles,
  });

  // Factory constructor to create an instance from a JSON map
  factory UserDocReportModel.fromJson(Map<String, dynamic> json) {
    return UserDocReportModel(
      username: json['username'],
      countFiles: json['countFiles'],
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'countFiles': countFiles,
    };
  }

  Map<String, dynamic> toJsonEdit() {
    return {
      'id': username,
      'description': countFiles,
    };
  }

  Map<String, dynamic> toJsonDelete() {
    return {
      'id': username,
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
      'username': PlutoCell(value: username),
      'countFiles': PlutoCell(value: countFiles ?? ""),
    });
  }

  static UserDocReportModel fromPlutoRow(PlutoRow row) {
    return UserDocReportModel(
      username: row.cells['username']?.value,
      countFiles: row.cells['countFiles']?.value,
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return countFiles.toString();
  }
}
