import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/func/lists.dart';
import '../../../utils/func/responsive.dart';

class SetupModel {
  String? txtPropertyname;
  String? description;
  int? bolActive;
  String? arDescription;

  SetupModel({
    this.txtPropertyname,
    this.description,
    this.bolActive,
    this.arDescription,
  });

  factory SetupModel.fromJson(Map<String, dynamic> json) {
    return SetupModel(
      txtPropertyname: json['txtPropertyname'],
      description: json['description'],
      bolActive: json['bolActive'],
      arDescription: json['arDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'txtPropertyname': txtPropertyname,
      'description': description,
      'bolActive': bolActive,
      'arDescription': arDescription,
    };
  }

  @override
  String toString() {
    return description.toString();
  }

  PlutoRow toPlutoRow(int count, AppLocalizations localizations) {
    return PlutoRow(cells: {
      'txtPropertyname': PlutoCell(value: txtPropertyname ?? ""),
      'description': PlutoCell(value: description ?? ""),
      'arDescription': PlutoCell(value: arDescription ?? ""),
      'bolActive': PlutoCell(
          value: ListConstants.workFlowStatus(bolActive ?? -1, localizations)),
    });
  }

  SetupModel.fromPluto(PlutoRow plutoRow, AppLocalizations localizations) {
    txtPropertyname = plutoRow.cells['txtPropertyname']?.value as String?;
    description = plutoRow.cells['description']?.value as String?;
    arDescription = plutoRow.cells['arDescription']?.value as String?;
    bolActive = ListConstants.workFlowStatusCode(
        plutoRow.cells['bolActive']?.value ?? -1, localizations);
  }

  static List<PlutoColumn> getColumns(
      AppLocalizations localizations, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = Responsive.isDesktop(context);
    List<PlutoColumn> list = [
     
    ];
    return list;
  }
}
