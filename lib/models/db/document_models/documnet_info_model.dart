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

  DocumentModel({
    this.txtKey,
    this.txtDescription,
    this.txtKeywords,
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
  });

  // Factory method to create an instance of DocumentModel from a Map
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      txtKey: json['txtKey'] ?? "",
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
    );
  }

  // Method to convert DocumentModel instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'txtKey': txtKey ?? "",
      'txtDescription': txtDescription ?? "",
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
    };
  }
}
