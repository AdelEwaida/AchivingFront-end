import 'package:pluto_grid/pluto_grid.dart';

import 'tracking_info_model.dart';
import 'tracking_step_info_model.dart';

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
  String? issueNo;
  String? barcode;
  String? docDescription;

  TrackingResponseModel({
    this.tracking,
    this.steps,
    this.issueNo,
    this.barcode,
    this.docDescription,
  });

  factory TrackingResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? docMap;
    final document = json['document'];
    if (document is Map) {
      docMap = Map<String, dynamic>.from(document);
    }

    return TrackingResponseModel(
      tracking: json['tracking'] != null
          ? TrackingInfoModel.fromJson(json['tracking'] as Map<String, dynamic>)
          : null,
      steps: json['steps'] != null
          ? (json['steps'] as List)
              .map((s) =>
                  TrackingStepInfoModel.fromJson(s as Map<String, dynamic>))
              .toList()
          : null,
      issueNo: _readJsonText(json, docMap, const [
        'issueNo',
        'txtIssueno',
        'issue_no',
      ]),
      barcode: _readJsonText(json, docMap, const [
        'barcode',
        'txtBarcode',
        'fileBarcode',
      ]),
      docDescription: _readJsonText(json, docMap, const [
        'docDescription',
        'txtDescription',
        'description',
      ]),
    );
  }

  static String? _readJsonText(
    Map<String, dynamic> json,
    Map<String, dynamic>? docMap,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'null') {
        return value;
      }
    }
    if (docMap != null) {
      for (final key in keys) {
        final value = docMap[key]?.toString().trim();
        if (value != null && value.isNotEmpty && value != 'null') {
          return value;
        }
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'tracking': tracking?.toJson(),
      'steps': steps?.map((s) => s.toJson()).toList(),
      'issueNo': issueNo,
      'barcode': barcode,
      'docDescription': docDescription,
    };
  }

  static List<TrackingResponseModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((item) =>
            TrackingResponseModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String trackingRouteNotesText() => (tracking?.name ?? '').trim();

  String documentIssueBarcodeLabel() {
    final issue = (issueNo ?? '').trim();
    final bc = (barcode ?? '').trim();
    if (issue.isNotEmpty && bc.isNotEmpty) return '$issue - $bc';
    if (issue.isNotEmpty) return issue;
    if (bc.isNotEmpty) return bc;
    return '';
  }

  String routeOverviewText() {
    final list = List<TrackingStepInfoModel>.from(steps ?? [])
      ..sort((a, b) => (a.intStepOrder ?? 0).compareTo(b.intStepOrder ?? 0));
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

  TrackingStepInfoModel? activeStepDisplayed() => trackingStepForAction(this);

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

  TrackingStepInfoModel? _stepByOrder(int order) {
    for (final s in steps ?? []) {
      if (s.intStepOrder == order) return s;
    }
    return null;
  }

  TrackingStepInfoModel? nextStepAfterActive() {
    final active = activeStepDisplayed();
    final order = active?.intStepOrder;
    if (order == null) return null;
    return _stepByOrder(order + 1);
  }

  String activeStepNotesOnly() {
    final s = activeStepDisplayed();
    if (s == null) return '';
    final direct = (s.txtNotes ?? '').trim();
    if (direct.isNotEmpty) return direct;
    final order = s.intStepOrder;
    if (order != null && order > 1) {
      return (_stepByOrder(order - 1)?.txtNotes ?? '').trim();
    }
    return '';
  }

  TrackingStepInfoModel? previousStepBeforeActive() {
    final active = activeStepDisplayed();
    final order = active?.intStepOrder;
    if (order == null || order <= 1) return null;
    return _stepByOrder(order - 1);
  }

  String gridSentByDisplay() {
    final active = activeStepDisplayed();
    if (active == null) return '';
    final fromActive = (active.txtSentBy ?? '').trim();
    if (fromActive.isNotEmpty) return fromActive;
    return (previousStepBeforeActive()?.txtSentBy ?? '').trim();
  }

  String gridSentAtDisplay() {
    final active = activeStepDisplayed();
    if (active == null) return '';
    final fromActive = (active.datSentAt ?? '').trim();
    if (fromActive.isNotEmpty) {
      return shortCreatedAt(fromActive);
    }
    final fromPrev = (previousStepBeforeActive()?.datSentAt ?? '').trim();
    if (fromPrev.isEmpty) return '';
    return shortCreatedAt(fromPrev);
  }

  String activeStepSituationCode() {
    final s = activeStepDisplayed();
    if (s == null) return 'unknown';
    final st = s.intStatus;
    if (st == 3) return 'received_sent';
    if (st == 2) return 'received_only';
    if (st == 1) return 'await_receive';

    final hasR = _nonEmptyDt(s.datReceivedAt);
    final hasOutboundSend =
        (s.txtSentBy != null && s.txtSentBy!.trim().isNotEmpty);
    if (hasR && hasOutboundSend) return 'received_sent';
    if (hasR) return 'received_only';
    return 'await_receive';
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
