import 'package:archiving_flutter_project/screens/file_screens/document_dep_track_display.dart';
import 'package:pluto_grid/pluto_grid.dart';

class DocTrackingReportRowModel {
  final String? barcode;
  final String? issueNo;
  final String? deptName;
  final String? fileStatus;
  final String? sentBy;
  final String? sentAt;
  final String? receivedBy;
  final String? receivedAt;

  const DocTrackingReportRowModel({
    this.barcode,
    this.issueNo,
    this.deptName,
    this.fileStatus,
    this.sentBy,
    this.sentAt,
    this.receivedBy,
    this.receivedAt,
  });

  factory DocTrackingReportRowModel.fromJson(Map<String, dynamic> json) {
    return DocTrackingReportRowModel(
      barcode: json['barcode']?.toString(),
      issueNo: json['issueNo']?.toString(),
      deptName: json['deptName']?.toString(),
      fileStatus: json['fileStatus']?.toString(),
      sentBy: json['sentBy']?.toString(),
      sentAt: json['sentAt']?.toString(),
      receivedBy: json['receivedBy']?.toString(),
      receivedAt: json['receivedAt']?.toString(),
    );
  }

  static String _cellText(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty || value == 'null') return '—';
    return value;
  }

  static String _dateCellText(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty || value == 'null') return '—';
    return formatTrackingStepDate(value);
  }

  PlutoRow toPlutoRow() {
    return PlutoRow(
      cells: {
        'barcode': PlutoCell(value: _cellText(barcode)),
        'issueNo': PlutoCell(value: _cellText(issueNo)),
        'deptName': PlutoCell(value: _cellText(deptName)),
        'fileStatus': PlutoCell(value: _cellText(fileStatus)),
        'sentBy': PlutoCell(value: _cellText(sentBy)),
        'sentAt': PlutoCell(value: _dateCellText(sentAt)),
        'receivedBy': PlutoCell(value: _cellText(receivedBy)),
        'receivedAt': PlutoCell(value: _dateCellText(receivedAt)),
      },
    );
  }
}
