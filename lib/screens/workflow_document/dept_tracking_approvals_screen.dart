import 'package:archiving_flutter_project/dialogs/document_dialogs/file_explor_dialog.dart';
import 'package:archiving_flutter_project/models/db/work_flow/tracking_response_model.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/service/controller/work_flow_controllers/work_flow_template_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/loading.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_flutter_toast_message.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// "موافقاتي عبر الدوائر" — lists document tracking rows awaiting receive.
class DeptTrackingApprovalsScreen extends StatefulWidget {
  const DeptTrackingApprovalsScreen({super.key});

  @override
  State<DeptTrackingApprovalsScreen> createState() =>
      _DeptTrackingApprovalsScreenState();
}

class _DeptTrackingApprovalsScreenState
    extends State<DeptTrackingApprovalsScreen> {
  late AppLocalizations _locale;
  final WorkFlowTemplateContoller _controller = WorkFlowTemplateContoller();
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  PlutoGridStateManager? _stateManager;
  double _width = 0;
  double _height = 0;
  bool _isDesktop = false;
  bool _loading = true;
  /// Bumps after each load so [TableComponent] / PlutoGrid rebuild with new rows.
  int _gridEpoch = 0;
  List<TrackingResponseModel> _items = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context);
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    _isDesktop = Responsive.isDesktop(context);
    _buildColumns();
    if (_stateManager != null && _columns.isNotEmpty) {
      for (int i = 0; i < _columns.length &&
          i < _stateManager!.columns.length;
          i++) {
        _stateManager!.columns[i].title = _columns[i].title;
        _stateManager!.columns[i].width = _columns[i].width;
      }
      _stateManager!.notifyListeners(true);
    }
  }

  static const String _lookupKeyField = '_deptLookupKey';

  void _buildColumns() {
    final w = _width;
    _columns = [
      PlutoColumn(
        readOnly: true,
        title: '',
        field: _lookupKeyField,
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
        title: _locale.deptTrackingActiveStep,
        field: 'activeStepSummary',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.16 : w * 0.72,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.deptTrackingStepSituation,
        field: 'stepSituation',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.11 : w * 0.45,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.stepDescription,
        field: 'txtStepDescription',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.22 : w * 0.92,
        renderer: (ctx) => _DeptStepDescCellPainter(
          data: ctx.cell.value is _DeptStepDescCell
              ? ctx.cell.value as _DeptStepDescCell
              : _DeptStepDescCell.tryParseFallback(ctx.cell.value),
          captionLabel: _locale.deptTrackingStepNoteCaption,
        ),
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.user,
        field: 'txtCreatedBy',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.06 : w * 0.28,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.dateCreated,
        field: 'datCreatedAt',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.08 : w * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.deptTrackingReceiveSummary,
        field: 'receiveSummary',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.10 : w * 0.52,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.deptTrackingSendSummary,
        field: 'sendSummary',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.10 : w * 0.52,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.deptTrackingRouteOverview,
        field: 'routeOverview',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.22 : w * 0.92,
      ),
    ];
  }

  String _situationLabel(String code) {
    switch (code) {
      case 'await_receive':
        return _locale.deptTrackingSituationAwaitReceive;
      case 'received_only':
        return _locale.deptTrackingSituationReceivedOnly;
      case 'received_sent':
        return _locale.deptTrackingSituationReceivedSent;
      default:
        return _locale.deptTrackingSituationUnknown;
    }
  }

  String _receiveSendLine(String? user, String? rawDt) {
    final u = (user ?? '').trim();
    final t = TrackingResponseModel.shortStepMoment(rawDt);
    if (u.isEmpty && t.isEmpty) return '—';
    if (u.isEmpty) return t;
    if (t.isEmpty) return u;
    return '$u · $t';
  }

  String _routeOverviewCellText(String overview) {
    final t = overview.trim();
    return t.isEmpty ? '—' : t;
  }

  PlutoRow _deptTrackingRow(TrackingResponseModel e) {
    final step = e.activeStepDisplayed();
    final routeKey = e.routeTrackingKeyForGrid();
    final t = e.tracking;
    final stepDesc = e.activeStepDescriptionOnly();
    return PlutoRow(
      cells: {
        _lookupKeyField: PlutoCell(value: routeKey),
        'activeStepSummary': PlutoCell(value: e.activeStepSummaryLabel()),
        'stepSituation':
            PlutoCell(value: _situationLabel(e.activeStepSituationCode())),
        'txtStepDescription': PlutoCell(
          value: _DeptStepDescCell(
            description: stepDesc.isEmpty ? '—' : stepDesc,
            notes: (step?.txtNotes ?? '').trim(),
          ),
        ),
        'txtCreatedBy': PlutoCell(value: t?.txtCreatedBy ?? ''),
        'datCreatedAt':
            PlutoCell(value: TrackingResponseModel.shortCreatedAt(t?.datCreatedAt)),
        'receiveSummary': PlutoCell(
            value: _receiveSendLine(step?.txtReceivedBy, step?.datReceivedAt)),
        'sendSummary': PlutoCell(
            value: _receiveSendLine(step?.txtSentBy, step?.datSentAt)),
        'routeOverview': PlutoCell(
          value: _routeOverviewCellText(e.routeOverviewText()),
        ),
      },
    );
  }

  TrackingResponseModel? _findDeptItem(String key) {
    final k = key.trim();
    if (k.isEmpty) return null;
    for (final item in _items) {
      if (item.routeTrackingKeyForGrid() == k) return item;
      if ((item.tracking?.txtKey ?? '').trim() == k) return item;
    }
    return null;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _controller.getAwaitingReceiveTracking();
    if (!mounted) return;
    setState(() {
      _items = list;
      _rows = list.map(_deptTrackingRow).toList();
      _loading = false;
      _gridEpoch++;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _openFileExplorerLikeFileList(TrackingResponseModel item) async {
    final hdr = item.tracking?.txtDocumentcode?.trim() ?? '';
    if (hdr.isEmpty) {
      CustomToastMessage.warning(context, _locale.deptTrackingNoDocumentHdr);
      return;
    }

    openLoadinDialog(context);
    final files = await DocumentsController().getFilesByHdrKey(hdr);
    if (!mounted) return;
    Navigator.of(context).pop();

    final flow = WorkFlowTemplateContoller();
    /// Receive/send APIs expect current step row [TrackingStepInfoModel.txtKey].
    final activeStepKey = trackingStepForAction(item)?.txtKey?.trim() ?? '';

    Future<bool> receive() async {
      if (activeStepKey.isEmpty) {
        CustomToastMessage.warning(context, _locale.deptTrackingNoRouteRef);
        return false;
      }
      final res = await flow.postDocumentTrackingReceive(
        stepKey: activeStepKey,
      );
      return res?.statusCode == 200;
    }

    Future<bool> send(String notes) async {
      if (activeStepKey.isEmpty) {
        CustomToastMessage.warning(context, _locale.deptTrackingNoRouteRef);
        return false;
      }
      final res = await flow.postDocumentTrackingSend(
        stepKey: activeStepKey,
        notes: notes,
      );
      return res?.statusCode == 200;
    }

    final reload = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FileExplorDialog(
        listOfFiles: files,
        isWorkFlowScreen: true,
        deptTrackingExtras: FileExplorerDeptTrackingExtras(
          onReceiveTap: receive,
          onSendTap: send,
        ),
      ),
    );
    if (!mounted) return;
    if (reload == true) {
      // إطارَي رسم بعد إزالة route الحوار لتفادي تعارض Pluto وشاشة Flutter الحمراء على Web.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _load();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_width == 0) {
      _width = MediaQuery.of(context).size.width;
      _height = MediaQuery.of(context).size.height;
      _isDesktop = Responsive.isDesktop(context);
      _buildColumns();
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  CustomElevatedButton(
                    text: _locale.refresh,
                    color: primary,
                    icon: Icons.refresh_rounded,
                    width: _isDesktop ? _width * 0.09 : _width * 0.28,
                    height: _height * 0.043,
                    fontSize: 14,
                    onPressed: () {
                      if (!_loading) _load();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  TableComponent(
                    key: ValueKey('dept_tracking_approvals_$_gridEpoch'),
                    noHeader: true,
                    isworkFlow: true,
                    tableHeigt: _height * 0.82,
                    tableWidth: _width,
                    plCols: _columns,
                    mode: PlutoGridMode.selectWithOneTap,
                    polRows: _rows,
                    onLoaded: (e) {
                      _stateManager = e.stateManager;
                      _stateManager?.setShowColumnFilter(true);
                    },
                    doubleTab: (event) {
                      final key = event.row.cells[_lookupKeyField]
                              ?.value
                              ?.toString() ??
                          '';
                      final item = _findDeptItem(key);
                      if (item != null) {
                        _openFileExplorerLikeFileList(item);
                      }
                    },
                  ),
                  if (_loading)
                    Container(
                      color: Colors.white.withOpacity(0.6),
                      child: const Center(
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Holds [txtStepDescription] + خطوة [txtNotes] for the Pluto cell renderer.
class _DeptStepDescCell {
  const _DeptStepDescCell({
    required this.description,
    required this.notes,
  });

  final String description;
  final String notes;

  static _DeptStepDescCell tryParseFallback(dynamic v) {
    if (v == null) {
      return const _DeptStepDescCell(description: '—', notes: '');
    }
    final s = v.toString();
    return _DeptStepDescCell(description: s.isEmpty ? '—' : s, notes: '');
  }

  @override
  String toString() =>
      notes.isEmpty ? description : '$description • $notes';
}

class _DeptStepDescCellPainter extends StatelessWidget {
  const _DeptStepDescCellPainter({
    required this.data,
    required this.captionLabel,
  });

  final _DeptStepDescCell data;
  final String captionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryStyle = theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w300,
          height: 1.35,
          color: Colors.black54,
          fontSize: (theme.textTheme.bodyMedium?.fontSize ?? 14) - 2,
        ) ??
        TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 12,
          height: 1.35,
          color: Colors.grey.shade700,
        );

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 4, top: 4, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              data.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            if (data.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '$captionLabel: ${data.notes}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: secondaryStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
