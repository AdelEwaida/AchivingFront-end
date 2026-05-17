class DocTrackingTemplateStepModel {
  int? stepOrder;
  String? deptKey;
  String? description;

  DocTrackingTemplateStepModel({
    this.stepOrder,
    this.deptKey,
    this.description,
  });

  factory DocTrackingTemplateStepModel.fromJson(Map<String, dynamic> json) {
    return DocTrackingTemplateStepModel(
      stepOrder: json['stepOrder'],
      deptKey: json['deptKey'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepOrder': stepOrder,
      'deptKey': deptKey,
      'description': description,
    };
  }
}
