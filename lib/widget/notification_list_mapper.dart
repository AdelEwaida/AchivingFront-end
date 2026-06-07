import 'package:archiving_flutter_project/models/db/work_flow/tracking_response_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/user_work_flow_steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum NotificationKind { workflowApproval, deptTrackingReceive }

class NotificationEntry {
  NotificationEntry.workflow(this.workflow)
      : kind = NotificationKind.workflowApproval,
        deptTracking = null;

  NotificationEntry.deptTracking(this.deptTracking)
      : kind = NotificationKind.deptTrackingReceive,
        workflow = null;

  final NotificationKind kind;
  final UserWorkflowSteps? workflow;
  final TrackingResponseModel? deptTracking;
}

String notificationEntryTitle(NotificationEntry entry) {
  switch (entry.kind) {
    case NotificationKind.workflowApproval:
      final w = entry.workflow!;
      return '${w.txtTemplateName ?? ''} - ${w.txtDeptName ?? ''}'.trim();
    case NotificationKind.deptTrackingReceive:
      final item = entry.deptTracking!;
      final route = item.trackingRouteNotesText();
      final step = item.activeStepDescriptionOnly();
      if (route.isNotEmpty && step.isNotEmpty) return '$route - $step';
      if (route.isNotEmpty) return route;
      return step;
  }
}

String notificationEntryTooltip(NotificationEntry entry) {
  switch (entry.kind) {
    case NotificationKind.workflowApproval:
      return entry.workflow?.txtTemplateName ?? '';
    case NotificationKind.deptTrackingReceive:
      return entry.deptTracking?.trackingRouteNotesText() ?? '';
  }
}

String notificationEntryStatusLabel(
  NotificationEntry entry,
  AppLocalizations locale,
) {
  switch (entry.kind) {
    case NotificationKind.workflowApproval:
      final status = entry.workflow?.intStatus ?? -1;
      if (status == 0) return locale.readyToApprove;
      if (status == 1) return locale.approved;
      if (status == 2) return locale.rejected;
      return locale.all;
    case NotificationKind.deptTrackingReceive:
      return locale.deptTrackingSituationAwaitReceive;
  }
}

Color notificationEntryStatusColor(NotificationEntry entry) {
  switch (entry.kind) {
    case NotificationKind.workflowApproval:
      final status = entry.workflow?.intStatus ?? -1;
      if (status == 1) return const Color(0xFF2E7D32);
      if (status == 2) return const Color(0xFFC62828);
      return const Color(0xFFFF9800);
    case NotificationKind.deptTrackingReceive:
      return const Color(0xFF1565C0);
  }
}
