class TrackingStepInfoModel {
  String? txtKey;
  String? txtTrackingcode;
  int? intStepOrder;
  String? txtDeptcode;
  int? intStatus;
  String? txtReceivedBy;
  String? datReceivedAt;
  String? txtSentBy;
  String? datSentAt;
  String? txtNotes;
  String? txtStepDescription;
  int? isDeleted;

  TrackingStepInfoModel({
    this.txtKey,
    this.txtTrackingcode,
    this.intStepOrder,
    this.txtDeptcode,
    this.intStatus,
    this.txtReceivedBy,
    this.datReceivedAt,
    this.txtSentBy,
    this.datSentAt,
    this.txtNotes,
    this.txtStepDescription,
    this.isDeleted,
  });

  factory TrackingStepInfoModel.fromJson(Map<String, dynamic> json) {
    return TrackingStepInfoModel(
      txtKey: json['txtKey']?.toString(),
      txtTrackingcode: json['txtTrackingcode']?.toString(),
      intStepOrder: json['intStepOrder'],
      txtDeptcode: json['txtDeptcode']?.toString(),
      intStatus: json['intStatus'],
      txtReceivedBy: json['txtReceivedBy']?.toString(),
      datReceivedAt: json['datReceivedAt']?.toString(),
      txtSentBy: json['txtSentBy']?.toString(),
      datSentAt: json['datSentAt']?.toString(),
      txtNotes: json['txtNotes']?.toString(),
      txtStepDescription: json['txtStepDescription']?.toString(),
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txtKey': txtKey,
      'txtTrackingcode': txtTrackingcode,
      'intStepOrder': intStepOrder,
      'txtDeptcode': txtDeptcode,
      'intStatus': intStatus,
      'txtReceivedBy': txtReceivedBy,
      'datReceivedAt': datReceivedAt,
      'txtSentBy': txtSentBy,
      'datSentAt': datSentAt,
      'txtNotes': txtNotes,
      'txtStepDescription': txtStepDescription,
      'isDeleted': isDeleted,
    };
  }
}
