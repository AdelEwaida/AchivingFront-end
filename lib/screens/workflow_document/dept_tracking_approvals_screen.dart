import 'package:archiving_flutter_project/dialogs/document_dialogs/bulk_receive_files_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/file_explor_dialog.dart';
import 'package:archiving_flutter_project/models/db/work_flow/tracking_response_model.dart';
import 'package:archiving_flutter_project/screens/workflow_document/dept_tracking_pluto_mapper.dart';
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
  String? _actionBusyKey;
  List<TrackingResponseModel> _items = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    _isDesktop = Responsive.isDesktop(context);
    _buildColumns();
    if (_stateManager != null && _columns.isNotEmpty) {
      for (int i = 0;
          i < _columns.length && i < _stateManager!.columns.length;
          i++) {
        _stateManager!.columns[i].title = _columns[i].title;
        _stateManager!.columns[i].width = _columns[i].width;
      }
      _stateManager!.notifyListeners(true);
    }
  }

  static const String _lookupKeyField = deptTrackingLookupKeyField;

  void _buildColumns() {
    _columns = buildDeptTrackingPlutoColumns(
      locale: _locale,
      width: _width,
      isDesktop: _isDesktop,
      showActionColumn: true,
      actionRenderer: _renderActionCell,
    );
  }

  Widget _renderActionCell(PlutoColumnRendererContext ctx) {
    final situation = ctx.cell.value?.toString() ?? '';
    if (situation == 'received_sent') {
      return const SizedBox.shrink();
    }

    final showSend = situation == 'received_only';
    final key = ctx.row.cells[_lookupKeyField]?.value?.toString() ?? '';
    final isBusy = _actionBusyKey == key;

    return Center(
      child: CustomElevatedButton(
        text: showSend
            ? _locale.deptTrackingSendOnly
            : _locale.deptTrackingReceive,
        color: showSend ? const Color(0xFF1565C0) : greenColor,
        icon: showSend ? Icons.send_rounded : Icons.inbox_rounded,
        width: _isDesktop ? _width * 0.085 : _width * 0.24,
        height: 26,
        fontSize: 12,
        isLoading: isBusy,
        onPressed: () {
          if (isBusy || _actionBusyKey != null) return;
          print('Action button pressed for key: $key, situation: $situation');
          final item = _findDeptItem(key);
          if (item != null) {
            _onActionButtonPressed(item);
          }
        },
      ),
    );
  }

  Future<void> _onActionButtonPressed(TrackingResponseModel item) async {
    final rowKey = item.routeTrackingKeyForGrid();
    final activeStepKey = trackingStepForAction(item)?.txtKey?.trim() ?? '';
    if (activeStepKey.isEmpty) {
      CustomToastMessage.warning(context, _locale.deptTrackingNoRouteRef);
      return;
    }

    setState(() => _actionBusyKey = rowKey);
    try {
      final flow = WorkFlowTemplateContoller();
      final situation = item.activeStepSituationCode();
      final dynamic res;

      if (situation == 'received_only') {
        // Grid quick send: empty notes; double-click dialog allows entering notes.
        res = await flow.postDocumentTrackingSend(
          stepKey: activeStepKey,
          notes: '',
        );
      } else {
        // Grid quick receive: lockup omitted (empty); lockup dialog kept commented above.
        res = await flow.postDocumentTrackingReceive(
          stepKey: activeStepKey,
          locationCode: '',
        );
      }

      if (!mounted) return;
      if (res?.statusCode == 200) {
        CustomToastMessage.success(context, _locale.updatedSuccess);
        await _load();
      } else {
        CustomToastMessage.error(context, _locale.error);
      }
    } finally {
      if (mounted) {
        setState(() => _actionBusyKey = null);
      }
    }
  }

  PlutoRow _deptTrackingRow(TrackingResponseModel e) =>
      deptTrackingToPlutoRow(e, _locale);

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
    final activeStepKey = trackingStepForAction(item)?.txtKey?.trim() ?? '';

    Future<bool> receive() async {
      if (activeStepKey.isEmpty) {
        CustomToastMessage.warning(context, _locale.deptTrackingNoRouteRef);
        return false;
      }
      // Lockup selection dialog disabled — send empty location to API.
      // To re-enable: import select_lockup_for_receive_dialog.dart and uncomment below.
      // final lockupLocationCode =
      //     await showSelectLockupForReceiveDialog(context);
      // if (!mounted) return false;
      // if (lockupLocationCode == null || lockupLocationCode.isEmpty) {
      //   return false;
      // }
      final res = await flow.postDocumentTrackingReceive(
        stepKey: activeStepKey,
        locationCode: '',
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

    final situation = item.activeStepSituationCode();
    final hideDeptActions = situation == 'received_sent';
    final receiveOnlyUi = situation == 'await_receive';
    final sendOnlyAfterReceived = situation == 'received_only';

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
                receiveOnlyLastStep: receiveOnlyUi,
                sendOnlyAfterReceived: sendOnlyAfterReceived,
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
                    height: _height * 0.038,
                    fontSize: 14,
                    onPressed: () {
                      if (!_loading) _load();
                    },
                  ),
                  const SizedBox(width: 10),
                  // select all
                  CustomElevatedButton(
                    text: _locale.deptTrackingBulkReceive,
                    color: greenColor,
                    icon: Icons.inbox_outlined,
                    width: _isDesktop ? _width * 0.12 : _width * 0.34,
                    height: _height * 0.038,
                    fontSize: 14,
                    onPressed: () async {
                      final refreshed =
                          await showBulkReceiveFilesDialog(context);
                      if (refreshed == true && mounted) _load();
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
                    rowsHeight: 68,
                    tableHeigt: _height * 0.75,
                    tableWidth: _width,
                    plCols: _columns,
                    mode: PlutoGridMode.selectWithOneTap,
                    polRows: _rows,
                    onLoaded: (e) {
                      _stateManager = e.stateManager;
                      _stateManager?.setShowColumnFilter(true);
                    },
                    doubleTab: (event) {
                      final key =
                          event.row.cells[_lookupKeyField]?.value?.toString() ??
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
