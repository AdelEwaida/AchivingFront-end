import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../../../utils/func/lists.dart';
import 'document_steps_model.dart';
import 'steps_model.dart';
import 'template_model.dart';
import 'work_flow_doc_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  PlutoRow toPlutoRow(int index, AppLocalizations localizations) {
    return PlutoRow(
      cells: {
        'txtKey': PlutoCell(value: workflow?.txtKey ?? ""),
        'txtDocumentName': PlutoCell(value: workflow?.txtDocumentName ?? ""),
        'txtDeptName': PlutoCell(value: workflow?.txtDeptName ?? ""),
        'txtTemplateName': PlutoCell(value: workflow?.txtTemplateName ?? ""),
        'intStatus': PlutoCell(
            value: ListConstants.getStatusName(
                workflow?.intStatus ?? -1, localizations)),
        'datMaxDate': PlutoCell(value: workflow?.datMaxDate ?? ""),
        'stepsList': PlutoCell(value: stepsList),
      },
    );
  }

  WorkFlowDocumentInfo.fromPluto(
      PlutoRow plutoRow, AppLocalizations localizations) {
    // Ensure template is initialized
    workflow = WorkFlowDocumentModel();
    workflow?.txtKey = plutoRow.cells['txtKey']?.value as String? ?? "";
    workflow?.txtDocumentName =
        plutoRow.cells['txtDocumentName']?.value as String? ?? "";

    workflow?.txtTemplateName =
        plutoRow.cells['txtTemplateName']?.value as String? ?? "";
    workflow?.txtDeptName =
        plutoRow.cells['txtDeptName']?.value as String? ?? "";
    workflow?.datMaxDate = plutoRow.cells['datMaxDate']?.value as String? ?? "";
    // workflow?.intStatus = plutoRow.cells['intStatus']?.value as int? ?? -1;
    workflow?.intStatus = ListConstants.getStatusCode(
        plutoRow.cells['intStatus']?.value ?? -1,
        localizations); // Default to 0 if null
    // Extract stepsList (ensure it is cast to List<StepsModel>)
    stepsList = (plutoRow.cells['stepsList']?.value as List<dynamic>?)
        ?.map((step) => step as DocumentStepsModel)
        .toList();
  }
}
