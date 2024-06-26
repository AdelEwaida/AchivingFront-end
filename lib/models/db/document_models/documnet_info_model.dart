import 'package:pluto_grid/pluto_grid.dart';

class DocumentModel {
  String? txtKey;
  String? txtDescription;
  String? txtKeywords;
  String? txtReference1;
  String? txtReference2;
  int? intType;
  String? datCreationdate;
  String? txtLastupdateduser;
  String? txtMimetype;
  int? intVouchtype;
  int? intVouchnum;
  String? txtJcode;
  String? txtCategory;
  String? txtDept;
  String? txtIssueno;
  String? datIssuedate;
  String? txtUsercode;
  String? txtInsurance;
  String? txtLicense;
  String? txtMaintenance;
  String? txtOtherservices;
  int? bolHasfile;
  String? datArrvialdate;
  String? txtOriginalfilekey;
  String? txtOrganization;
  String? txtOtherRef;
  String? txtFollowing;
  String? fileName;
  String? catKey;
  String? deptKey;
  DocumentModel(
      {this.txtKey,
      this.txtDescription,
      this.txtOrganization,
      this.txtOtherRef,
      this.txtKeywords,
      this.txtFollowing,
      this.txtReference1,
      this.txtReference2,
      this.intType,
      this.datCreationdate,
      this.txtLastupdateduser,
      this.txtMimetype,
      this.intVouchtype,
      this.intVouchnum,
      this.txtJcode,
      this.txtCategory,
      this.txtDept,
      this.txtIssueno,
      this.datIssuedate,
      this.txtUsercode,
      this.txtInsurance,
      this.txtLicense,
      this.txtMaintenance,
      this.txtOtherservices,
      this.bolHasfile,
      this.datArrvialdate,
      this.txtOriginalfilekey,
      this.fileName,
      this.catKey,
      this.deptKey,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
        txtKey: json['txtKey'] ?? "",
        txtOtherRef: json['txtOtherRef'] ?? "",
        txtOrganization: json['txtOrganization'] ?? "",
        txtDescription: json['txtDescription'] ?? "",
        txtKeywords: json['txtKeywords'] ?? "",
        txtReference1: json['txtReference1'] ?? "",
        txtReference2: json['txtReference2'] ?? "",
        intType: json['intType'] ?? 0,
        datCreationdate: json['datCreationdate'] ?? "",
        txtLastupdateduser: json['txtLastupdateduser'] ?? "",
        txtMimetype: json['txtMimetype'] ?? "",
        intVouchtype: json['intVouchtype'] ?? 0,
        intVouchnum: json['intVouchnum'] ?? 0,
        txtJcode: json['txtJcode'] ?? "",
        txtFollowing: json['txtFollowing'] ?? "",
        txtCategory: json['txtCategory'] ?? "",
        txtDept: json['txtDept'] ?? "",
        txtIssueno: json['txtIssueno'] ?? "",
        datIssuedate: json['datIssuedate'] ?? "",
        txtUsercode: json['txtUsercode'] ?? "",
        txtInsurance: json['txtInsurance'] ?? "",
        txtLicense: json['txtLicense'] ?? "",
        txtMaintenance: json['txtMaintenance'] ?? "",
        txtOtherservices: json['txtOtherservices'] ?? "",
        bolHasfile: json['bolHasfile'] ?? 0,
        datArrvialdate: json['datArrvialdate'] ?? "",
        txtOriginalfilekey: json['txtOriginalfilekey'] ?? "",
        fileName: json['fileName'],
        catKey: json['catKey'] ?? "",
        deptKey: json['deptKey'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      'txtKey': txtKey ?? "",
      "txtOtherRef": txtOtherRef ?? "",
      'txtOrganization': txtOrganization ?? "",
      'txtDescription': txtDescription ?? "",
      "txtFollowing": txtFollowing ?? "",
      'txtKeywords': txtKeywords ?? "",
      'txtReference1': txtReference1 ?? "",
      'txtReference2': txtReference2 ?? "",
      'intType': intType ?? 0,
      'datCreationdate': datCreationdate ?? "",
      'txtLastupdateduser': txtLastupdateduser ?? "",
      'txtMimetype': txtMimetype ?? "",
      'intVouchtype': intVouchtype ?? 0,
      'intVouchnum': intVouchnum ?? 0,
      'txtJcode': txtJcode ?? "",
      'txtCategory': txtCategory ?? "",
      'txtDept': txtDept ?? "",
      'txtIssueno': txtIssueno ?? "",
      'datIssuedate': datIssuedate ?? "",
      'txtUsercode': txtUsercode ?? "",
      'txtInsurance': txtInsurance ?? "",
      'txtLicense': txtLicense ?? "",
      'txtMaintenance': txtMaintenance ?? "",
      'txtOtherservices': txtOtherservices ?? "",
      'bolHasfile': bolHasfile ?? 0,
      'datArrvialdate': datArrvialdate ?? "",
      'txtOriginalfilekey': txtOriginalfilekey ?? "",
      'fileName': fileName ?? "",
      'catKey': catKey ?? "",
      "deptKey": deptKey ?? ""
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(
      cells: {
        'countNumber': PlutoCell(value: count),

        'txtOtherRef': PlutoCell(value: txtOtherRef),
        'txtFollowing': PlutoCell(value: txtFollowing),
        'txtKey': PlutoCell(value: txtKey),
        'txtOrganization': PlutoCell(value: txtOrganization),
        'txtDescription': PlutoCell(value: txtDescription),
        'txtKeywords': PlutoCell(value: txtKeywords),
        'txtReference1': PlutoCell(value: txtReference1),
        'txtReference2': PlutoCell(value: txtReference2),
        'intType': PlutoCell(value: intType),
        'datCreationdate': PlutoCell(value: datCreationdate),
        'txtLastupdateduser': PlutoCell(value: txtLastupdateduser),
        'txtMimetype': PlutoCell(value: txtMimetype),
        'intVouchtype': PlutoCell(value: intVouchtype),
        'intVouchnum': PlutoCell(value: intVouchnum),
        'txtJcode': PlutoCell(value: txtJcode),
        'txtCategory': PlutoCell(value: txtCategory),
        'txtDept': PlutoCell(value: txtDept),
        'txtIssueno': PlutoCell(value: txtIssueno),
        'datIssuedate': PlutoCell(value: datIssuedate),
        'txtUsercode': PlutoCell(value: txtUsercode),
        'txtInsurance': PlutoCell(value: txtInsurance),
        'txtLicense': PlutoCell(value: txtLicense),
        'txtMaintenance': PlutoCell(value: txtMaintenance),
        'txtOtherservices': PlutoCell(value: txtOtherservices),
        'bolHasfile': PlutoCell(value: bolHasfile),
        'datArrvialdate': PlutoCell(value: datArrvialdate),
        'txtOriginalfilekey': PlutoCell(value: txtOriginalfilekey),
        'fileName': PlutoCell(value: fileName),
        'deptKey': PlutoCell(value: deptKey),
        'catKey': PlutoCell(value: catKey)
      },
    );
  }

  static DocumentModel fromPlutoRow(PlutoRow row) {
    return DocumentModel(
        txtKey: row.cells['txtKey']?.value,
        txtDescription: row.cells['txtDescription']?.value,
        txtKeywords: row.cells['txtKeywords']?.value,
        txtReference1: row.cells['txtReference1']?.value,
        txtReference2: row.cells['txtReference2']?.value,
        txtOtherRef: row.cells['txtOtherRef']?.value,
        txtOrganization: row.cells['txtOrganization']?.value,
        intType: row.cells['intType']?.value,
        datCreationdate: row.cells['datCreationdate']?.value,
        txtLastupdateduser: row.cells['txtLastupdateduser']?.value,
        txtMimetype: row.cells['txtMimetype']?.value,
        intVouchtype: row.cells['intVouchtype']?.value,
        intVouchnum: row.cells['intVouchnum']?.value,
        txtJcode: row.cells['txtJcode']?.value,
        txtCategory: row.cells['txtCategory']?.value,
        txtDept: row.cells['txtDept']?.value,
        txtIssueno: row.cells['txtIssueno']?.value,
        datIssuedate: row.cells['datIssuedate']?.value,
        txtFollowing: row.cells['txtFollowing']?.value,
        txtUsercode: row.cells['txtUsercode']?.value,
        txtInsurance: row.cells['txtInsurance']?.value,
        txtLicense: row.cells['txtLicense']?.value,
        txtMaintenance: row.cells['txtMaintenance']?.value,
        txtOtherservices: row.cells['txtOtherservices']?.value,
        bolHasfile: row.cells['bolHasfile']?.value,
        datArrvialdate: row.cells['datArrvialdate']?.value,
        txtOriginalfilekey: row.cells['txtOriginalfilekey']?.value,
        fileName: row.cells['fileName']?.value,
        deptKey: row.cells['deptKey']?.value,
        catKey: row.cells['catKey']?.value,
    );
  }
}
