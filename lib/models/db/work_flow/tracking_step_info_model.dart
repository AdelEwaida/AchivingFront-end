class TrackingStepInfoModel {
  String? txtKey;
  String? txtTrackingcode;
  int? intStepOrder;
  String? txtDeptcode;
  String? txtDeptName;
  int? intStatus;
  String? txtReceivedBy;
  String? datReceivedAt;
  String? txtSentBy;
  String? datSentAt;
  String? txtNotes;
  String? txtStepDescription;
  int? isDeleted;
  String? txtLocationCode;
  String? txtLocationName;

  TrackingStepInfoModel({
    this.txtKey,
    this.txtTrackingcode,
    this.intStepOrder,
    this.txtDeptcode,
    this.txtDeptName,
    this.intStatus,
    this.txtReceivedBy,
    this.datReceivedAt,
    this.txtSentBy,
    this.datSentAt,
    this.txtNotes,
    this.txtStepDescription,
    this.isDeleted,
    this.txtLocationCode,
    this.txtLocationName,
  });

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  factory TrackingStepInfoModel.fromJson(Map<String, dynamic> json) {
    return TrackingStepInfoModel(
      txtKey: json['txtKey']?.toString() ?? json['stepKey']?.toString(),
      txtTrackingcode: json['txtTrackingcode']?.toString(),
      intStepOrder: _asInt(json['intStepOrder'] ?? json['stepOrder']),
      txtDeptcode:
          json['txtDeptcode']?.toString() ?? json['deptKey']?.toString(),
      txtDeptName: json['txtDeptName']?.toString() ??
          json['deptName']?.toString(),
      intStatus: _asInt(json['intStatus']),
      txtReceivedBy: json['txtReceivedBy']?.toString(),
      datReceivedAt: json['datReceivedAt']?.toString(),
      txtSentBy: json['txtSentBy']?.toString(),
      datSentAt: json['datSentAt']?.toString(),
      txtNotes: json['txtNotes']?.toString(),
      txtStepDescription: json['txtStepDescription']?.toString() ??
          json['description']?.toString(),
      isDeleted: _asInt(json['isDeleted']),
      txtLocationCode: json['txtLocationCode']?.toString(),
      txtLocationName: json['txtLocationName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txtKey': txtKey,
      'txtTrackingcode': txtTrackingcode,
      'intStepOrder': intStepOrder,
      'txtDeptcode': txtDeptcode,
      'txtDeptName': txtDeptName,
      'intStatus': intStatus,
      'txtReceivedBy': txtReceivedBy,
      'datReceivedAt': datReceivedAt,
      'txtSentBy': txtSentBy,
      'datSentAt': datSentAt,
      'txtNotes': txtNotes,
      'txtStepDescription': txtStepDescription,
      'isDeleted': isDeleted,
      'txtLocationCode': txtLocationCode,
      'txtLocationName': txtLocationName,
    };
  }
}
