import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'document_steps_model.dart';
import 'steps_model.dart';
import 'template_model.dart';
import 'work_flow_doc_model.dart';

class WorkFlowDocumentInfo {
  WorkFlowDocumentModel? workflow;
  List<DocumentStepsModel>? stepsList;

  WorkFlowDocumentInfo({
    this.workflow,
    this.stepsList,
  });

  Map<String, dynamic> toJson() {
    return {
      'workflow': workflow?.toJson(),
      'stepsList': stepsList?.map((step) => step.toJson()).toList(),
    };
  }

  factory WorkFlowDocumentInfo.fromJson(Map<String, dynamic> json) {
    return WorkFlowDocumentInfo(
      workflow: json['workflow'] != null
          ? WorkFlowDocumentModel.fromJson(json['workflow'])
          : null,
      stepsList: json['stepsList'] != null
          ? (json['stepsList'] as List)
              .map((step) => DocumentStepsModel.fromJson(step))
              .toList()
          : null,
    );
  }

  // PlutoRow toPlutoRow(int index) {
  //   return PlutoRow(
  //     cells: {
  //       'txtKey': PlutoCell(value: template?.txtKey ?? ""),
  //       'templateName': PlutoCell(value: template?.txtName ?? ""),
  //       'templateDescription': PlutoCell(value: template?.txtDescription ?? ""),
  //       'txtDept': PlutoCell(value: template?.txtDept ?? ""),
  //       'txtDeptName': PlutoCell(value: template?.txtDeptName ?? ""),
  //       'stepsList': PlutoCell(value: stepsList), // Pass stepsList as-is
  //     },
  //   );
  // }

  // WorkFlowDocumentInfo.fromPluto(PlutoRow plutoRow) {
  //   // Ensure template is initialized
  //   template = TemplateModel();
  //   template?.txtKey = plutoRow.cells['txtKey']?.value as String? ?? "";
  //   template?.txtName = plutoRow.cells['templateName']?.value as String? ?? "";
  //   template?.txtDescription =
  //       plutoRow.cells['templateDescription']?.value as String? ?? "";
  //   template?.txtDept = plutoRow.cells['txtDept']?.value as String? ?? "";
  //   template?.txtDeptName =
  //       plutoRow.cells['txtDeptName']?.value as String? ?? "";
  //   // Extract stepsList (ensure it is cast to List<StepsModel>)
  //   stepsList = (plutoRow.cells['stepsList']?.value as List<dynamic>?)
  //       ?.map((step) => step as StepsModel)
  //       .toList();
  // }
}
