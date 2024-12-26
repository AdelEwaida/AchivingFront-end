import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'steps_model.dart';
import 'template_model.dart';

class WorkFlowTemplateBody {
  TemplateModel? template;
  List<StepsModel>? stepsList;

  WorkFlowTemplateBody({
    this.template,
    this.stepsList,
  });

  Map<String, dynamic> toJson() {
    return {
      'template': template?.toJson(),
      'stepsList': stepsList?.map((step) => step.toJson()).toList(),
    };
  }

  factory WorkFlowTemplateBody.fromJson(Map<String, dynamic> json) {
    return WorkFlowTemplateBody(
      template: json['template'] != null
          ? TemplateModel.fromJson(json['template'])
          : null,
      stepsList: json['stepsList'] != null
          ? (json['stepsList'] as List)
              .map((step) => StepsModel.fromJson(step))
              .toList()
          : null,
    );
  }

  PlutoRow toPlutoRow(int index) {
    return PlutoRow(
      cells: {
        'txtKey': PlutoCell(value: template?.txtKey ?? ""),
        'templateName': PlutoCell(value: template?.txtName ?? ""),
        'templateDescription': PlutoCell(value: template?.txtDescription ?? ""),
        'txtDept': PlutoCell(value: template?.txtDept ?? ""),
        'txtDeptName': PlutoCell(value: template?.txtDeptName ?? ""),
        'stepsList': PlutoCell(value: stepsList), // Pass stepsList as-is
      },
    );
  }

  WorkFlowTemplateBody.fromPluto(PlutoRow plutoRow) {
    // Ensure template is initialized
    template = TemplateModel();
    template?.txtKey = plutoRow.cells['txtKey']?.value as String? ?? "";
    template?.txtName = plutoRow.cells['templateName']?.value as String? ?? "";
    template?.txtDescription =
        plutoRow.cells['templateDescription']?.value as String? ?? "";
    template?.txtDept = plutoRow.cells['txtDept']?.value as String? ?? "";
    template?.txtDeptName =
        plutoRow.cells['txtDeptName']?.value as String? ?? "";
    // Extract stepsList (ensure it is cast to List<StepsModel>)
    stepsList = (plutoRow.cells['stepsList']?.value as List<dynamic>?)
        ?.map((step) => step as StepsModel)
        .toList();
  }
}
