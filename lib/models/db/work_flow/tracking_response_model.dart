import 'package:pluto_grid/pluto_grid.dart';

import 'tracking_info_model.dart';
import 'tracking_step_info_model.dart';

/// Current workflow step (`intStepOrder == intCurrentStep`), else pending (`intStatus == 1`).
TrackingStepInfoModel? trackingStepForAction(TrackingResponseModel item) {
  final steps = item.steps ?? [];
  final curOrder = item.tracking?.intCurrentStep;
  if (curOrder != null) {
    for (final s in steps) {
      if (s.intStepOrder == curOrder) return s;
    }
  }
  for (final s in steps) {
    if (s.intStatus == 1) return s;
  }
  return steps.isEmpty ? null : steps.first;
}

class TrackingResponseModel {
  TrackingInfoModel? tracking;
  List<TrackingStepInfoModel>? steps;

  TrackingResponseModel({
    this.tracking,
    this.steps,
  });

  factory TrackingResponseModel.fromJson(Map<String, dynamic> json) {
    return TrackingResponseModel(
      tracking: json['tracking'] != null
          ? TrackingInfoModel.fromJson(
              json['tracking'] as Map<String, dynamic>)
          : null,
      steps: json['steps'] != null
          ? (json['steps'] as List)
              .map((s) => TrackingStepInfoModel.fromJson(
                  s as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tracking': tracking?.toJson(),
      'steps': steps?.map((s) => s.toJson()).toList(),
    };
  }

  /// Parse the root list directly
  static List<TrackingResponseModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((item) => TrackingResponseModel.fromJson(
            item as Map<String, dynamic>))
        .toList();
  }

  String trackingRouteNotesText() => (tracking?.txtNotes ?? '').trim();

  /// Summary of step descriptions in order (for grid / previews).
  String routeOverviewText() {
    final list = List<TrackingStepInfoModel>.from(steps ?? [])
      ..sort((a, b) =>
          (a.intStepOrder ?? 0).compareTo(b.intStepOrder ?? 0));
    return list
        .map((s) => (s.txtStepDescription ?? '').trim())
        .where((s) => s.isNotEmpty)
        .join(' → ');
  }

  static String shortCreatedAt(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    if (raw.length >= 19) return raw.substring(0, 19).replaceFirst('T', ' ');
    return raw;
  }

  static bool _nonEmptyDt(String? s) => s != null && s.trim().isNotEmpty;

  TrackingStepInfoModel? activeStepDisplayed() =>
      trackingStepForAction(this);

  String routeTrackingKeyForGrid() {
    final s = activeStepDisplayed();
    final tc = (s?.txtTrackingcode ?? '').trim();
    if (tc.isNotEmpty) return tc;
    return (tracking?.txtKey ?? '').trim();
  }

  String activeStepSummaryLabel() {
    final s = activeStepDisplayed();
    if (s == null) return '';
    final ord = s.intStepOrder;
    final desc = (s.txtStepDescription ?? '').trim();
    if (ord != null && desc.isNotEmpty) return '$ord — $desc';
    if (desc.isNotEmpty) return desc;
    if (ord != null) return ord.toString();
    return '';
  }

  String activeStepOrderDisplay() {
    final s = activeStepDisplayed();
    final o = s?.intStepOrder ?? tracking?.intCurrentStep;
    if (o != null) return o.toString();
    return '';
  }

  String activeStepDescriptionOnly() =>
      (activeStepDisplayed()?.txtStepDescription ?? '').trim();

  String activeStepSituationCode() {
    final s = activeStepDisplayed();
    if (s == null) return 'unknown';
    final hasR = _nonEmptyDt(s.datReceivedAt);
    final hasS = _nonEmptyDt(s.datSentAt);
    if (hasR && hasS) return 'received_sent';
    if (hasR) return 'received_only';
    return 'await_receive';
  }

  bool isActiveStepLastInRoute() {
    final list = steps ?? [];
    if (list.isEmpty) return true;
    final orders = <int>[];
    for (final s in list) {
      final o = s.intStepOrder;
      if (o != null) orders.add(o);
    }
    if (orders.isEmpty) {
      return list.length <= 1;
    }
    final maxOrder = orders.reduce((a, b) => a > b ? a : b);
    final active = activeStepDisplayed();
    final cur = active?.intStepOrder ?? tracking?.intCurrentStep;
    if (cur == null) return false;
    return cur >= maxOrder;
  }

  String trackingOverallStatusCode() {
    final v = tracking?.intStatus;
    if (v == null) return 'overall_unknown';
    switch (v) {
      case 0:
        return 'overall_open';
      case 1:
        return 'overall_done';
      default:
        return 'overall_$v';
    }
  }

  String combinedNotesForGrid() {
    final s = activeStepDisplayed();
    final stepN = (s?.txtNotes ?? '').trim();
    final trackN = (tracking?.txtNotes ?? '').trim();
    if (stepN.isNotEmpty && trackN.isNotEmpty && stepN != trackN) {
      return '$trackN · $stepN';
    }
    if (stepN.isNotEmpty) return stepN;
    return trackN;
  }

  static String shortStepMoment(String? raw) =>
      raw == null ? '' : shortCreatedAt(raw);

  PlutoRow toPlutoRow() {
    final t = tracking;
    final step = trackingStepForAction(this);
    final routeRefDisplay = (step?.txtTrackingcode != null &&
            step!.txtTrackingcode!.trim().isNotEmpty)
        ? step.txtTrackingcode!.trim()
        : (t?.txtKey ?? '');
    return PlutoRow(
      cells: {
        'txtTrackingcode': PlutoCell(value: routeRefDisplay),
        'txtDocumentcode': PlutoCell(value: t?.txtDocumentcode ?? ''),
        'txtCreatedBy': PlutoCell(value: t?.txtCreatedBy ?? ''),
        'datCreatedAt': PlutoCell(value: shortCreatedAt(t?.datCreatedAt)),
        'intStatus': PlutoCell(value: t?.intStatus?.toString() ?? ''),
        'intCurrentStep': PlutoCell(value: t?.intCurrentStep?.toString() ?? ''),
        'routeOverview': PlutoCell(value: trackingRouteNotesText()),
        'txtNotes': PlutoCell(value: t?.txtNotes ?? ''),
      },
    );
  }
}
