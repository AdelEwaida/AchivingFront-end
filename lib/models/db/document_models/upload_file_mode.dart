import 'package:pluto_grid/pluto_grid.dart';

class FileUploadModel {
  String? txtKey;
  String? txtHdrkey;
  String? txtFilename;
  String? imgBlob;
  int? dblFilesize;
  String? txtUsercode;
  String? datDate;
  String? txtMimetype;
  int? intLinenum;
  int? intType;
  String? categoryName;

  FileUploadModel(
      {this.txtKey,
      this.txtHdrkey,
      this.txtFilename,
      this.imgBlob,
      this.dblFilesize,
      this.txtUsercode,
      this.datDate,
      this.txtMimetype,
      this.intLinenum,
      this.intType,
      this.categoryName});

  // Factory method to create an instance of FileUploadModel from a Map
  factory FileUploadModel.fromJson(Map<String, dynamic> json) {
    return FileUploadModel(
        txtKey: json['txtKey'] ?? "",
        txtHdrkey: json['txtHdrkey'] ?? "",
        txtFilename: json['txtFilename'] ?? "",
        imgBlob: json['imgBlob'] ?? "",
        dblFilesize: json['dblFilesize'] ?? 0,
        txtUsercode: json['txtUsercode'] ?? "",
        datDate: json['datDate'] ?? "",
        txtMimetype: json['txtMimetype'] ?? "",
        intLinenum: json['intLinenum'] ?? 0,
        intType: json['intType'] ?? 0,
        categoryName: json['categoryName'] ?? "");
  }

  // Method to convert FileUploadModel instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'txtKey': txtKey ?? "",
      'txtHdrkey': txtHdrkey ?? "",
      'txtFilename': txtFilename ?? "",
      'imgBlob': imgBlob ?? "",
      'dblFilesize': dblFilesize ?? 0,
      'txtUsercode': txtUsercode ?? "",
      'datDate': datDate ?? "",
      'txtMimetype': txtMimetype ?? "",
      'intLinenum': intLinenum ?? 0,
      'intType': intType ?? 0,
      'categoryName': categoryName ?? ""
    };
  }

  PlutoRow toPlutoRow(int countNumber) {
    return PlutoRow(
      cells: {
        'countNumber': PlutoCell(value: countNumber),
        'txtKey': PlutoCell(value: txtKey),
        'txtHdrkey': PlutoCell(value: txtHdrkey),
        'txtFilename': PlutoCell(value: txtFilename),
        'imgBlob': PlutoCell(value: imgBlob),
        'dblFilesize': PlutoCell(value: dblFilesize),
        'txtUsercode': PlutoCell(value: txtUsercode),
        'datDate': PlutoCell(value: datDate),
        'txtMimetype': PlutoCell(value: txtMimetype),
        'intLinenum': PlutoCell(value: intLinenum),
        'intType': PlutoCell(value: intType),
        'categoryName': PlutoCell(value: categoryName)
      },
    );
  }
}
