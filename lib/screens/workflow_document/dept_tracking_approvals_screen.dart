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
  static const String _activeStepNotesField = '_activeStepNotes';

  static const Color _stepNotesSkinTone = Color(0xFF8D7569);

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
        title: '',
        field: _activeStepNotesField,
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
        title: _locale.deptTrackingRouteOverview,
        field: 'routeOverview',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.24 : w * 0.95,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.dateCreated,
        field: 'datCreatedAt',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.09 : w * 0.42,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.deptTrackingRouteCreator,
        field: 'txtCreatedBy',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.09 : w * 0.32,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.deptTrackingActiveStep,
        field: 'activeStepSummary',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.07 : w * 0.22,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.stepDescription,
        field: 'txtStepDescription',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.22 : w * 0.92,
        renderer: (PlutoColumnRendererContext ctx) {
          final descRaw = ctx.cell.value?.toString() ?? '';
          final desc = descRaw.trim();
          final notesRaw =
              ctx.row.cells[_activeStepNotesField]?.value?.toString() ?? '';
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
                    '${_locale.deptTrackingStepNotePrefix}$notes',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _stepNotesSkinTone,
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
        title: _locale.deptTrackingStepSituation,
        field: 'stepSituation',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.11 : w * 0.45,
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

  String _routeOverviewCellText(String overview) {
    final t = overview.trim();
    return t.isEmpty ? '—' : t;
  }

  String _stepOrderCellText(String order) {
    final t = order.trim();
    return t.isEmpty ? '—' : t;
  }

  PlutoRow _deptTrackingRow(TrackingResponseModel e) {
    final routeKey = e.routeTrackingKeyForGrid();
    final t = e.tracking;
    final stepDesc = e.activeStepDescriptionOnly();
    final notesForCell = e.activeStepNotesOnly();
    return PlutoRow(
      cells: {
        _lookupKeyField: PlutoCell(value: routeKey),
        _activeStepNotesField: PlutoCell(value: notesForCell),
        'activeStepSummary': PlutoCell(
          value: _stepOrderCellText(e.activeStepOrderDisplay()),
        ),
        'stepSituation':
            PlutoCell(value: _situationLabel(e.activeStepSituationCode())),
        'txtStepDescription': PlutoCell(
          value: stepDesc.isEmpty ? '—' : stepDesc,
        ),
        'txtCreatedBy': PlutoCell(value: t?.txtCreatedBy ?? ''),
        'datCreatedAt':
            PlutoCell(value: TrackingResponseModel.shortCreatedAt(t?.datCreatedAt)),
        'routeOverview': PlutoCell(
          value: _routeOverviewCellText(e.trackingRouteNotesText()),
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

    final last = item.isActiveStepLastInRoute();
    final situation = item.activeStepSituationCode();
    final hideDeptActions = last &&
        (situation == 'received_only' || situation == 'received_sent');

    final reload = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FileExplorDialog(
        listOfFiles: files,
        isWorkFlowScreen: true,
        deptTrackingExtras: hideDeptActions
            ? null
            : FileExplorerDeptTrackingExtras(
                onReceiveTap: receive,
                onSendTap: send,
                receiveOnlyLastStep: last,
                sendOnlyAfterReceived:
                    !last && situation == 'received_only',
              ),
      ),
    );
    if (!mounted) return;
    if (reload == true) {
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
