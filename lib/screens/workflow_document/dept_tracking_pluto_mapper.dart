import 'package:archiving_flutter_project/models/db/work_flow/tracking_response_model.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pluto_grid/pluto_grid.dart';

const String deptTrackingLookupKeyField = '_deptLookupKey';
const String deptTrackingActiveStepNotesField = '_activeStepNotes';
const String deptTrackingRouteNotesField = '_routeNotes';
const Color deptTrackingStepNotesMuted = Color.fromARGB(255, 161, 167, 176);

String deptTrackingSituationLabel(AppLocalizations locale, String code) {
  switch (code) {
    case 'await_receive':
      return locale.deptTrackingSituationAwaitReceive;
    case 'received_only':
      return locale.deptTrackingSituationReceivedOnly;
    case 'received_sent':
      return locale.deptTrackingSituationReceivedSent;
    default:
      return locale.deptTrackingSituationUnknown;
  }
}

String _routeOverviewCellText(String overview) {
  final t = overview.trim();
  return t.isEmpty ? '—' : t;
}

String _stepOrderCellText(String order) {
  final t = order.trim();
  return t.isEmpty ? '—' : t;
}

PlutoRow deptTrackingToPlutoRow(
  TrackingResponseModel item,
  AppLocalizations locale,
) {
  final routeKey = item.routeTrackingKeyForGrid();
  final t = item.tracking;
  final stepDesc = item.activeStepDescriptionOnly();
  final notesForCell = item.activeStepNotesOnly();
  return PlutoRow(
    cells: {
      deptTrackingLookupKeyField: PlutoCell(value: routeKey),
      deptTrackingActiveStepNotesField: PlutoCell(value: notesForCell),
      deptTrackingRouteNotesField: PlutoCell(value: item.tracking?.txtNotes ?? ''),
      'activeStepSummary': PlutoCell(
        value: _stepOrderCellText(item.activeStepOrderDisplay()),
      ),
      'stepSituation': PlutoCell(
        value: deptTrackingSituationLabel(
          locale,
          item.activeStepSituationCode(),
        ),
      ),
      'txtStepDescription': PlutoCell(
        value: stepDesc.isEmpty ? '—' : stepDesc,
      ),
      'txtCreatedBy': PlutoCell(value: t?.txtCreatedBy ?? ''),
      'datCreatedAt': PlutoCell(
        value: TrackingResponseModel.shortCreatedAt(t?.datCreatedAt),
      ),
      'action': PlutoCell(value: item.activeStepSituationCode()),
      'routeOverview': PlutoCell(
        value: _routeOverviewCellText(item.trackingRouteNotesText()),
      ),
    },
  );
}

List<PlutoColumn> buildDeptTrackingPlutoColumns({
  required AppLocalizations locale,
  required double width,
  required bool isDesktop,
  PlutoColumnRenderer? actionRenderer,
  PlutoColumnRenderer? removeRenderer,
  bool showActionColumn = false,
  bool showRemoveColumn = false,
}) {
  final w = width;
  final columns = <PlutoColumn>[
    PlutoColumn(
      readOnly: true,
      title: '',
      field: deptTrackingLookupKeyField,
      backgroundColor: columnColors,
      type: PlutoColumnType.text(),
      hide: true,
      enableColumnDrag: false,
      enableContextMenu: false,
      enableDropToResize: false,
      enableFilterMenuItem: false,
      enableHideColumnMenuItem: false,
      enableSetColumnsMenuItem: false,
    ),
    PlutoColumn(
      readOnly: true,
      title: '',
      field: deptTrackingActiveStepNotesField,
      backgroundColor: columnColors,
      type: PlutoColumnType.text(),
      hide: true,
      enableColumnDrag: false,
      enableContextMenu: false,
      enableDropToResize: false,
      enableFilterMenuItem: false,
      enableHideColumnMenuItem: false,
      enableSetColumnsMenuItem: false,
    ),
    PlutoColumn(
      readOnly: true,
      title: '',
      field: deptTrackingRouteNotesField,
      backgroundColor: columnColors,
      type: PlutoColumnType.text(),
      hide: true,
      enableColumnDrag: false,
      enableContextMenu: false,
      enableDropToResize: false,
      enableFilterMenuItem: false,
      enableHideColumnMenuItem: false,
      enableSetColumnsMenuItem: false,
    ),
  ];

  if (showActionColumn && actionRenderer != null) {
    columns.add(
      PlutoColumn(
        readOnly: true,
        title: locale.deptTrackingAction,
        field: 'action',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? w * 0.1 : w * 0.3,
        enableColumnDrag: false,
        enableFilterMenuItem: false,
        renderer: actionRenderer,
      ),
    );
  }

  columns.addAll([
    PlutoColumn(
      readOnly: true,
      title: locale.deptTrackingRouteOverview,
      field: 'routeOverview',
      backgroundColor: columnColors,
      type: PlutoColumnType.text(),
      width: isDesktop ? w * 0.12 : w * 0.95,
      renderer: (PlutoColumnRendererContext ctx) {
        final name = ctx.cell.value?.toString().trim() ?? '';
        final notes =
            ctx.row.cells[deptTrackingRouteNotesField]?.value?.toString().trim() ??
                '';
        final hasName = name.isNotEmpty && name != '—';
        final hasNotes = notes.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasName ? name : '—',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                  height: 1.25,
                ),
              ),
              if (hasNotes) ...[
                const SizedBox(height: 4),
                Text(
                  '${locale.notes}: $notes',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: deptTrackingStepNotesMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    ),
    PlutoColumn(
      readOnly: true,
      title: locale.dateCreated,
      field: 'datCreatedAt',
      backgroundColor: columnColors,
      type: PlutoColumnType.text(),
      width: isDesktop ? w * 0.09 : w * 0.42,
    ),
    PlutoColumn(
      readOnly: true,
      title: locale.deptTrackingRouteCreator,
      field: 'txtCreatedBy',
      backgroundColor: columnColors,
      type: PlutoColumnType.text(),
      width: isDesktop ? w * 0.09 : w * 0.32,
    ),
    PlutoColumn(
      readOnly: true,
      title: locale.deptTrackingActiveStep,
      field: 'activeStepSummary',
      backgroundColor: columnColors,
      type: PlutoColumnType.text(),
      width: isDesktop ? w * 0.07 : w * 0.22,
    ),
    PlutoColumn(
      readOnly: true,
      title: locale.stepDescription,
      field: 'txtStepDescription',
      backgroundColor: columnColors,
      type: PlutoColumnType.text(),
      width: isDesktop ? w * 0.12 : w * 0.92,
      renderer: (PlutoColumnRendererContext ctx) {
        final descRaw = ctx.cell.value?.toString() ?? '';
        final desc = descRaw.trim();
        final notesRaw =
            ctx.row.cells[deptTrackingActiveStepNotesField]?.value?.toString() ??
                '';
        final notes = notesRaw.trim();
        final showDesc = desc.isNotEmpty && desc != '—';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                showDesc ? desc : '—',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                  height: 1.25,
                ),
              ),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '${locale.deptTrackingStepNotesLabel} $notes',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: deptTrackingStepNotesMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    ),
    PlutoColumn(
      readOnly: true,
      title: locale.deptTrackingStepSituation,
      field: 'stepSituation',
      backgroundColor: columnColors,
      type: PlutoColumnType.text(),
      width: isDesktop ? w * 0.11 : w * 0.45,
    ),
  ]);

  if (showRemoveColumn && removeRenderer != null) {
    columns.add(
      PlutoColumn(
        readOnly: true,
        title: '',
        field: 'remove',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? w * 0.05 : w * 0.1,
        enableFilterMenuItem: false,
        enableColumnDrag: false,
        renderer: removeRenderer,
      ),
    );
  }

  return columns;
}
