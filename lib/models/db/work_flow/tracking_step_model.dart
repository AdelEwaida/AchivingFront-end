import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/func/responsive.dart';

class TrackingStepModel {
  int? stepOrder;
  String? deptKey;
  String? description;

  TrackingStepModel({
    this.stepOrder,
    this.deptKey,
    this.description,
  });

  factory TrackingStepModel.fromJson(Map<String, dynamic> json) {
    return TrackingStepModel(
      stepOrder:
          json['stepOrder']?.toString() == "null" ? 0 : json['stepOrder'],
      deptKey: json['deptKey']?.toString() == "null"
          ? ""
          : json['deptKey'].toString(),
      description: json['description']?.toString() == "null"
          ? ""
          : json['description'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepOrder': stepOrder,
      'deptKey': deptKey,
      'description': description,
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(cells: {
      'count': PlutoCell(value: count),
      'stepOrder': PlutoCell(value: stepOrder ?? 0),
      'deptKey': PlutoCell(value: deptKey ?? ""),
      'description': PlutoCell(value: description ?? ""),
    });
  }

  TrackingStepModel.fromPluto(PlutoRow plutoRow) {
    stepOrder = plutoRow.cells['stepOrder']?.value as int?;
    deptKey = plutoRow.cells['deptKey']?.value as String?;
    description = plutoRow.cells['description']?.value as String?;
  }

  @override
  String toString() {
    return description.toString();
  }

  static List<PlutoColumn> getColumnsForDialogSearchFillter(
      AppLocalizations localizations, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = Responsive.isDesktop(context);
    return [
      PlutoColumn(
        readOnly: true,
        title: localizations.templateName,
        field: "description",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.11 : width * 0.3,
        enableRowChecked: true,
      ),
      PlutoColumn(
        readOnly: true,
        title: localizations.description,
        field: "stepOrder",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.35 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: localizations.department,
        field: "deptKey",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.35 : width * 0.4,
      ),
    ];
  }
}
