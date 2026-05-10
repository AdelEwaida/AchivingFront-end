import 'package:pluto_grid/pluto_grid.dart';
import 'tracking_step_model.dart';

class TrackingDocModel {
  String? documentKey;
  String? notes;
  List<TrackingStepModel>? steps;

  TrackingDocModel({
    this.documentKey,
    this.notes,
    this.steps,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentKey': documentKey,
      'notes': notes,
      'steps': steps?.map((step) => step.toJson()).toList(),
    };
  }

  factory TrackingDocModel.fromJson(Map<String, dynamic> json) {
    return TrackingDocModel(
      documentKey: json['documentKey']?.toString() == "null"
          ? ""
          : json['documentKey'].toString(),
      notes:
          json['notes']?.toString() == "null" ? "" : json['notes'].toString(),
      steps: json['steps'] != null
          ? (json['steps'] as List)
              .map((step) => TrackingStepModel.fromJson(step))
              .toList()
          : null,
    );
  }

  PlutoRow toPlutoRow(int index) {
    return PlutoRow(
      cells: {
        'documentKey': PlutoCell(value: documentKey ?? ""),
        'notes': PlutoCell(value: notes ?? ""),
        'steps': PlutoCell(value: steps),
      },
    );
  }

  TrackingDocModel.fromPluto(PlutoRow plutoRow) {
    documentKey = plutoRow.cells['documentKey']?.value as String?;
    notes = plutoRow.cells['notes']?.value as String?;
    steps = (plutoRow.cells['steps']?.value as List<dynamic>?)
        ?.map((step) => step as TrackingStepModel)
        .toList();
  }
}
