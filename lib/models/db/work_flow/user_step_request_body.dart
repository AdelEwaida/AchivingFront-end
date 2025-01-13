import 'package:pluto_grid/pluto_grid.dart';

class UserStepRequestBody {
  int? stepStatus;
  int? curStep;
  String? workflowCode;

  UserStepRequestBody({this.stepStatus, this.curStep, this.workflowCode});

  // Factory constructor to create an instance from a JSON map
  factory UserStepRequestBody.fromJson(Map<String, dynamic> json) {
    return UserStepRequestBody(
        stepStatus: json['stepStatus'],
        curStep: json['curStep'],
        workflowCode: json['workflowCode ']);
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'stepStatus': stepStatus,
      'curStep': curStep,
      "workflowCode": workflowCode
    };
  }

  Map<String, dynamic> toJsonEdit() {
    return {
      'id': stepStatus,
      'description': curStep,
      "workflowCode": workflowCode
    };
  }

  Map<String, dynamic> toJsonDelete() {
    return {
      'id': stepStatus,
    };
  }

  Map<String, dynamic> toJsonAdd() {
    return {
      'description': curStep,
    };
  }

  PlutoRow toPlutoRow(int count) {
    return PlutoRow(cells: {
      'countNumber': PlutoCell(value: count),
      'stepStatus': PlutoCell(value: stepStatus),
      'curStep': PlutoCell(value: curStep ?? -2),
      'workflowCode ': PlutoCell(value: workflowCode ?? ""),
    });
  }

  static UserStepRequestBody fromPlutoRow(PlutoRow row) {
    return UserStepRequestBody(
      stepStatus: row.cells['stepStatus']?.value,
      curStep: row.cells['curStep']?.value,
      workflowCode: row.cells['workflowCode ']?.value,
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return curStep.toString();
  }
}
