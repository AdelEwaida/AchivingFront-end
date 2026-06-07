import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/tracking_step_info_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String stepDeptDisplayName(TrackingStepInfoModel step) {
  return (step.txtDeptName ?? '').trim();
}

List<TrackingStepInfoModel> _sortedSteps(DocumentModel document) {
  final steps = List<TrackingStepInfoModel>.from(document.trackingSteps ?? []);
  steps.sort(
    (a, b) => (a.intStepOrder ?? 0).compareTo(b.intStepOrder ?? 0),
  );
  return steps;
}

String formatDocumentDepTrackDisplay(
  DocumentModel document,
  AppLocalizations locale,
) {
  final steps = _sortedSteps(document);
  if (steps.isEmpty) return '';

  for (int i = 0; i < steps.length - 1; i++) {
    final currentStatus = steps[i].intStatus ?? 0;
    final nextStatus = steps[i + 1].intStatus ?? 0;
    if (currentStatus == 3 && nextStatus == 1) {
      final name = stepDeptDisplayName(steps[i + 1]);
      if (name.isEmpty) return locale.currentDepTrackInTransitToDept;
      return locale.currentDepTrackInTransitToDeptNamed(name);
    }
  }

  for (int i = 0; i < steps.length - 1; i++) {
    final currentStatus = steps[i].intStatus ?? 0;
    final nextStatus = steps[i + 1].intStatus ?? 0;
    if (currentStatus == 2 && nextStatus == 0) {
      final name = stepDeptDisplayName(steps[i]);
      if (name.isEmpty) return locale.currentDepTrackReceivedInThisDept;
      return locale.currentDepTrackReceivedInThisDeptNamed(name);
    }
  }

  for (final step in steps) {
    if ((step.intStatus ?? 0) == 1) {
      final name = stepDeptDisplayName(step);
      if (name.isEmpty) return locale.currentDepTrackAwaitReceiveAt;
      return locale.currentDepTrackAwaitReceiveAtNamed(name);
    }
  }

  for (int i = steps.length - 1; i >= 0; i--) {
    if ((steps[i].intStatus ?? 0) == 4) {
      final name = stepDeptDisplayName(steps[i]);
      if (name.isEmpty) return locale.currentDepTrackFullyReceivedAt;
      return locale.currentDepTrackFullyReceivedAtNamed(name);
    }
  }

  return '';
}
