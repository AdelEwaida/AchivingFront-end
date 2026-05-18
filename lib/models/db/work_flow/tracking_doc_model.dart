import 'package:pluto_grid/pluto_grid.dart';
import 'tracking_step_model.dart';

class TrackingDocModel {
  String? documentKey;
  String? notes;
  String? templateKey;
  List<TrackingStepModel>? steps;
  String? name;

  TrackingDocModel({
    this.documentKey,
    this.notes,
    this.steps,
    this.templateKey,
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentKey': documentKey,
      'notes': notes,
      'templateKey': templateKey,
      'steps': steps?.map((step) => step.toJson()).toList(),
      'name': name,
    };
  }

  factory TrackingDocModel.fromJson(Map<String, dynamic> json) {
    return TrackingDocModel(
      documentKey: json['documentKey']?.toString() == "null"
          ? ""
          : json['documentKey'].toString(),
      templateKey: json['templateKey']?.toString() == "null"
          ? ""
          : json['templateKey'].toString(),
      notes:
          json['notes']?.toString() == "null" ? "" : json['notes'].toString(),
      steps: json['steps'] != null
          ? (json['steps'] as List)
              .map((step) => TrackingStepModel.fromJson(step))
              .toList()
          : null,
      name: json['name']?.toString() == "null" ? "" : json['name'].toString(),
    );
  }

  PlutoRow toPlutoRow(int index) {
    return PlutoRow(
      cells: {
        'documentKey': PlutoCell(value: documentKey ?? ""),
        'notes': PlutoCell(value: notes ?? ""),
        'steps': PlutoCell(value: steps),
        'templateKey': PlutoCell(value: templateKey ?? ""),
        'name': PlutoCell(value: name ?? ""),
      },
    );
  }

  TrackingDocModel.fromPluto(PlutoRow plutoRow) {
    documentKey = plutoRow.cells['documentKey']?.value as String?;
    notes = plutoRow.cells['notes']?.value as String?;
    templateKey = plutoRow.cells['templateKey']?.value as String?;
    steps = (plutoRow.cells['steps']?.value as List<dynamic>?)
        ?.map((step) => step as TrackingStepModel)
        .toList();
    name = plutoRow.cells['name']?.value as String?;
  }
}
