import 'package:pluto_grid/pluto_grid.dart';

class ActionModel {
  String? txtKey;
  String? txtServicecode;
  String? txtDescription;
  String? datDate;
  String? txtNotes;
  String? txtDocumentcode;
  String? txtUsercode;
  int? intRecurring;

  ActionModel(
      {this.txtKey,
      this.txtServicecode,
      this.txtDescription,
      this.datDate,
      this.txtNotes,
      this.txtDocumentcode,
      this.txtUsercode,
      this.intRecurring});

  // Factory constructor to create an instance from a JSON map
  factory ActionModel.fromJson(Map<String, dynamic> json) {
    return ActionModel(
        txtKey: json['txtKey'],
        txtServicecode: json['txtServicecode'],
        txtDescription: json['txtDescription'],
        datDate: json['datDate'],
        txtNotes: json['txtNotes'],
        txtDocumentcode: json['txtDocumentcode'],
        txtUsercode: json['txtUsercode'],
        intRecurring: json['intRecurring']);
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'txtKey': txtKey,
      'txtServicecode': txtServicecode,
      'txtDescription': txtDescription,
      'datDate': datDate,
      'txtNotes': txtNotes,
      'txtDocumentcode': txtDocumentcode,
      'txtUsercode': txtUsercode,
      'intRecurring': intRecurring
    };
  }

  Map<String, dynamic> toJsonAdd() {
    return {
      'datDate': datDate,
      'txtDescription': txtDescription,
      'txtNotes': txtNotes
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(cells: {
      'datDate': PlutoCell(value: datDate),
      'countNumber': PlutoCell(value: count),
      'txtDescription': PlutoCell(value: txtDescription ?? ""),
      'txtNotes': PlutoCell(value: txtNotes ?? ""),
    });
  }
}
