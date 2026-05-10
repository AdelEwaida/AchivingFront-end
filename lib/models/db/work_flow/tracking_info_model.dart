class TrackingInfoModel {
  String? txtKey;
  String? txtDocumentcode;
  int? intStatus;
  int? intCurrentStep;
  String? txtCreatedBy;
  String? datCreatedAt;
  String? datCompletedAt;
  String? txtNotes;
  int? isDeleted;

  TrackingInfoModel({
    this.txtKey,
    this.txtDocumentcode,
    this.intStatus,
    this.intCurrentStep,
    this.txtCreatedBy,
    this.datCreatedAt,
    this.datCompletedAt,
    this.txtNotes,
    this.isDeleted,
  });

  factory TrackingInfoModel.fromJson(Map<String, dynamic> json) {
    return TrackingInfoModel(
      txtKey: json['txtKey']?.toString(),
      txtDocumentcode: json['txtDocumentcode']?.toString(),
      intStatus: json['intStatus'],
      intCurrentStep: json['intCurrentStep'],
      txtCreatedBy: json['txtCreatedBy']?.toString(),
      datCreatedAt: json['datCreatedAt']?.toString(),
      datCompletedAt: json['datCompletedAt']?.toString(),
      txtNotes: json['txtNotes']?.toString(),
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txtKey': txtKey,
      'txtDocumentcode': txtDocumentcode,
      'intStatus': intStatus,
      'intCurrentStep': intCurrentStep,
      'txtCreatedBy': txtCreatedBy,
      'datCreatedAt': datCreatedAt,
      'datCompletedAt': datCompletedAt,
      'txtNotes': txtNotes,
      'isDeleted': isDeleted,
    };
  }
}
