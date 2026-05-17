// lib/models/db/work_flow/doc_tracking_template_model.dart

import 'doc_tracking_template_step_odel.dart';

class DocTrackingTemplateModel {
  String? key;
  String? name;
  String? description;
  String? note;
  String? createdAt;
  List<DocTrackingTemplateStepModel>? steps;

  DocTrackingTemplateModel({
    this.key,
    this.name,
    this.description,
    this.note,
    this.createdAt,
    this.steps,
  });

  factory DocTrackingTemplateModel.fromJson(Map<String, dynamic> json) {
    return DocTrackingTemplateModel(
      key: json['key'],
      name: json['name'],
      description: json['description'],
      note: json['note'],
      createdAt: json['createdAt'],
      steps: (json['steps'] as List<dynamic>?)
          ?.map((e) => DocTrackingTemplateStepModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'name': name,
        'note': note,
        'steps': steps?.map((e) => e.toJson()).toList(),
      };

  Map<String, dynamic> toUpdateJson() => {
        'name': name,
        'description': description,
        'steps': steps?.map((e) => e.toJson()).toList(),
      };
}
