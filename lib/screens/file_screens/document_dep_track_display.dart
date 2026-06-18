import 'dart:convert';

import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/tracking_step_info_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String stepDeptDisplayName(TrackingStepInfoModel step) {
  return (step.txtDeptName ?? '').trim();
}

String formatInDepartmentLabel(AppLocalizations locale, String dept) {
  if (locale.localeName.startsWith('ar')) {
    return 'في دائرة $dept';
  }
  return 'in department $dept';
}

List<TrackingStepInfoModel> sortedTrackingSteps(DocumentModel document) {
  final steps = List<TrackingStepInfoModel>.from(document.trackingSteps ?? []);
  steps.sort(
    (a, b) => (a.intStepOrder ?? 0).compareTo(b.intStepOrder ?? 0),
  );
  return steps;
}

/// Same date format as [ViewTrackingDialog].
String formatTrackingStepDate(String? raw) {
  if (raw == null || raw.isEmpty) return '';

  try {
    final dt = DateTime.parse(raw);
    final hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
            ? 12
            : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period';
  } catch (_) {
    return raw;
  }
}

bool isDepTrackInTransitAwaitingReceive(DocumentModel document) {
  final steps = sortedTrackingSteps(document);
  for (int i = 0; i < steps.length - 1; i++) {
    final currentStatus = steps[i].intStatus ?? 0;
    final nextStatus = steps[i + 1].intStatus ?? 0;
    if (currentStatus == 3 && nextStatus == 1) return true;
  }
  return false;
}

/// Step used for sent/received-by rows in the dep-track column.
/// When in transit (sent → awaiting receive), uses the previous step that
/// actually holds the sender/receiver info, not the pending destination step.
TrackingStepInfoModel? resolveDepTrackInfoStep(DocumentModel document) {
  final steps = sortedTrackingSteps(document);
  if (steps.isEmpty) return null;

  for (int i = 0; i < steps.length - 1; i++) {
    final currentStatus = steps[i].intStatus ?? 0;
    final nextStatus = steps[i + 1].intStatus ?? 0;
    if (currentStatus == 3 && nextStatus == 1) {
      return steps[i];
    }
  }

  return resolveCurrentDepTrackStep(document);
}

TrackingStepInfoModel? resolveCurrentDepTrackStep(DocumentModel document) {
  final steps = sortedTrackingSteps(document);
  if (steps.isEmpty) return null;

  for (int i = 0; i < steps.length - 1; i++) {
    final currentStatus = steps[i].intStatus ?? 0;
    final nextStatus = steps[i + 1].intStatus ?? 0;
    if (currentStatus == 3 && nextStatus == 1) {
      return steps[i + 1];
    }
  }

  for (int i = 0; i < steps.length - 1; i++) {
    final currentStatus = steps[i].intStatus ?? 0;
    final nextStatus = steps[i + 1].intStatus ?? 0;
    if (currentStatus == 2 && nextStatus == 0) {
      return steps[i];
    }
  }

  for (final step in steps) {
    if ((step.intStatus ?? 0) == 1) return step;
  }

  final last = steps.last;
  if ((last.intStatus ?? 0) == 2) return last;

  return null;
}

TrackingStepInfoModel? resolveDepTrackSentStep(
  List<TrackingStepInfoModel> steps,
  TrackingStepInfoModel? displayStep,
) {
  if (displayStep == null) return null;

  final hasSentOnDisplay = (displayStep.txtSentBy ?? '').trim().isNotEmpty ||
      (displayStep.datSentAt ?? '').trim().isNotEmpty;
  if (hasSentOnDisplay) return displayStep;

  final idx = steps.indexWhere((s) => s.txtKey == displayStep.txtKey);
  if (idx > 0) {
    final prev = steps[idx - 1];
    if ((prev.intStatus ?? 0) == 3) return prev;
  }
  return displayStep;
}

TrackingStepInfoModel? depTrackSentStepForDocument(DocumentModel document) {
  final steps = sortedTrackingSteps(document);
  final infoStep = resolveDepTrackInfoStep(document);
  if (infoStep == null) return null;
  return resolveDepTrackSentStep(steps, infoStep);
}

/// Step eligible for send (received, not yet sent) — same rule as dept approvals.
TrackingStepInfoModel? documentTrackingStepForSend(DocumentModel document) {
  final step = resolveCurrentDepTrackStep(document);
  if (step == null) return null;
  if ((step.intStatus ?? 0) == 2) return step;
  return null;
}

TrackingStepInfoModel? documentNextStepAfter(
  DocumentModel document,
  TrackingStepInfoModel active,
) {
  final order = active.intStepOrder;
  if (order == null) return null;
  for (final step in sortedTrackingSteps(document)) {
    if (step.intStepOrder == order + 1) return step;
  }
  return null;
}

String encodeTrackingStep(TrackingStepInfoModel? step) {
  if (step == null) return '';
  return jsonEncode(step.toJson());
}

TrackingStepInfoModel? decodeTrackingStep(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return null;
  try {
    return TrackingStepInfoModel.fromJson(
      jsonDecode(value) as Map<String, dynamic>,
    );
  } catch (_) {
    return null;
  }
}

bool shouldShowTrackingStepReceivedRow(TrackingStepInfoModel step) {
  return (step.txtReceivedBy != null &&
          step.txtReceivedBy!.trim().isNotEmpty) ||
      (step.datReceivedAt != null && step.datReceivedAt!.trim().isNotEmpty);
}

bool shouldShowTrackingStepSentRow(TrackingStepInfoModel step) {
  return (step.txtSentBy != null && step.txtSentBy!.trim().isNotEmpty) ||
      (step.datSentAt != null && step.datSentAt!.trim().isNotEmpty);
}

Widget buildTrackingStepReceivedRow(
  TrackingStepInfoModel step,
  AppLocalizations locale, {
  bool includeDeptInLabel = false,
  String? departmentName,
}) {
  if (!shouldShowTrackingStepReceivedRow(step)) {
    return const SizedBox.shrink();
  }

  final by = (step.txtReceivedBy ?? '').trim();
  final at = formatTrackingStepDate(step.datReceivedAt);
  final dept = (departmentName ?? '').trim().isNotEmpty
      ? departmentName!.trim()
      : stepDeptDisplayName(step);
  if (by.isEmpty && at.isEmpty) return const SizedBox.shrink();

  final label = StringBuffer('${locale.receivedBy}:');
  if (by.isNotEmpty) label.write(' $by');
  if (includeDeptInLabel && dept.isNotEmpty) {
    label.write(' ${formatInDepartmentLabel(locale, dept)}');
  }
  if (at.isNotEmpty) label.write(' ${locale.byDate}: $at');

  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.download_done_rounded,
          size: 12.5,
          color: Color(0xFF0D9B8A),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label.toString(),
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF0D9B8A)),
          ),
        ),
      ],
    ),
  );
}

Widget buildTrackingStepSentRow(
  TrackingStepInfoModel step,
  AppLocalizations locale,
) {
  if (!shouldShowTrackingStepSentRow(step)) {
    return const SizedBox.shrink();
  }

  final by = (step.txtSentBy ?? '').trim();
  final at = formatTrackingStepDate(step.datSentAt);
  if (by.isEmpty && at.isEmpty) return const SizedBox.shrink();

  final label = StringBuffer('${locale.sentBy}:');
  if (by.isNotEmpty) label.write(' $by');
  if (at.isNotEmpty) label.write(' ${locale.byDate}: $at');

  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.send_rounded,
          size: 12.5,
          color: Color(0xFF7C3AED),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label.toString(),
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF7C3AED)),
          ),
        ),
      ],
    ),
  );
}

String formatDocumentDepTrackDisplay(
  DocumentModel document,
  AppLocalizations locale,
) {
  final steps = sortedTrackingSteps(document);
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

  final last = steps.last;
  if ((last.intStatus ?? 0) == 2) {
    final name = stepDeptDisplayName(last);
    if (name.isEmpty) return locale.currentDepTrackFullyReceivedAt;
    return locale.currentDepTrackFullyReceivedAtNamed(name);
  }

  return '';
}

Widget buildDepTrackColumnCell({
  required String mainLabel,
  required TrackingStepInfoModel? displayStep,
  required TrackingStepInfoModel? sentStep,
  required AppLocalizations locale,
  bool receivedInDeptLabel = false,
}) {
  final receivedRow = displayStep == null
      ? const SizedBox.shrink()
      : buildTrackingStepReceivedRow(
          displayStep,
          locale,
          includeDeptInLabel: receivedInDeptLabel,
        );
  final sentRow = sentStep == null
      ? const SizedBox.shrink()
      : buildTrackingStepSentRow(sentStep, locale);

  final hasReceived =
      displayStep != null && shouldShowTrackingStepReceivedRow(displayStep);
  final hasSent = sentStep != null && shouldShowTrackingStepSentRow(sentStep);

  if (mainLabel.isEmpty && !hasReceived && !hasSent) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (mainLabel.isNotEmpty)
          Text(
            mainLabel,
            style: const TextStyle(fontSize: 12, height: 1.25),
          ),
        if (hasSent) sentRow,
        if (hasReceived) receivedRow,
      ],
    ),
  );
}
