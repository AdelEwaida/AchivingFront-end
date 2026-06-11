import '../../models/db/work_flow/setup_model.dart';
import '../constants/setup_constants.dart';

extension SetupModelListExtension on List<SetupModel> {
  int bolActiveFor(String propertyName) {
    try {
      final value = firstWhere((item) => item.txtPropertyname == propertyName)
          .bolActive;
      if (value is int) return value;
      if (value is String) return int.tryParse(value!) ?? 0;
      if (value is bool) return value! ? 1 : 0;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  bool isActive(String propertyName) => bolActiveFor(propertyName) == 1;

  Map<String, int> toBolActiveMap() {
    return {
      for (final item in this)
        if (item.txtPropertyname != null) item.txtPropertyname!: item.bolActive ?? 0,
    };
  }
}

int workflowBolActive(List<SetupModel> list) =>
    list.bolActiveFor(SetupPropertyNames.workflow);

int docTrackingBolActive(List<SetupModel> list) =>
    list.bolActiveFor(SetupPropertyNames.docTracking);
