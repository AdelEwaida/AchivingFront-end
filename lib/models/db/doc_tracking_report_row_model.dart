import 'package:pluto_grid/pluto_grid.dart';

class DocTrackingReportRowModel {
  final String? col1;
  final String? col2;
  final String? col3;
  final String? col4;
  final String? col5;

  const DocTrackingReportRowModel({
    this.col1,
    this.col2,
    this.col3,
    this.col4,
    this.col5,
  });

  factory DocTrackingReportRowModel.fromJson(Map<String, dynamic> json) {
    return DocTrackingReportRowModel(
      col1: json['col1']?.toString() ?? '',
      col2: json['col2']?.toString() ?? '',
      col3: json['col3']?.toString() ?? '',
      col4: json['col4']?.toString() ?? '',
      col5: json['col5']?.toString() ?? '',
    );
  }

  PlutoRow toPlutoRow() {
    return PlutoRow(cells: {
      'col1': PlutoCell(value: col1 ?? ''),
      'col2': PlutoCell(value: col2 ?? ''),
      'col3': PlutoCell(value: col3 ?? ''),
      'col4': PlutoCell(value: col4 ?? ''),
      'col5': PlutoCell(value: col5 ?? ''),
    });
  }
}
