import 'package:archiving_flutter_project/dialogs/document_dialogs/bulk_receive_files_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/dept_tracking_send_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/file_explor_dialog.dart';
import 'package:archiving_flutter_project/models/db/work_flow/tracking_response_model.dart';
import 'package:archiving_flutter_project/screens/workflow_document/dept_tracking_pluto_mapper.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/service/controller/work_flow_controllers/work_flow_template_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/loading.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_flutter_toast_message.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/app_bar_title.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

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
      approvalsGridLayout: true,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    if (_loading) return;
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      await _load();
      return;
    }
    if (RegExp(r'^\d+$').hasMatch(query)) {
      await _load(barcode: query);
    } else {
      await _load(issueNo: query);
    }
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
        final sent = await _sendTracking(item);
        if (!mounted) return;
        if (sent == true) {
          CustomToastMessage.success(context, _locale.updatedSuccess);
          await _runSearch();
        } else if (sent == false) {
          CustomToastMessage.error(context, _locale.error);
        }
        return;
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
        await _runSearch();
      } else {
        CustomToastMessage.error(context, _locale.error);
      }
    } finally {
      if (mounted) {
        setState(() => _actionBusyKey = null);
      }
    }
  }

  /// null = cancelled, true = sent, false = API error
  Future<bool?> _sendTracking(
    TrackingResponseModel item, {
    String initialNotes = '',
  }) async {
    final activeStepKey = trackingStepForAction(item)?.txtKey?.trim() ?? '';
    if (activeStepKey.isEmpty) {
      CustomToastMessage.warning(context, _locale.deptTrackingNoRouteRef);
      return false;
    }
    final next = item.nextStepAfterActive();
    final deptCode = (next?.txtDeptcode ?? '').trim();
    final deptName = (next?.txtDeptName ?? '').trim();

    final request = await showDeptTrackingSendDialog(
      context,
      defaultDeptCode: deptCode,
      defaultDeptName: deptName,
      initialNotes: initialNotes,
    );
    if (!mounted || request == null) return null;

    final documentCode =
        (item.tracking?.txtDocumentcode ?? '').trim();
    final res = await WorkFlowTemplateContoller().postDocumentTrackingSend(
      stepKey: activeStepKey,
      deptCode: request.deptCode,
      documentCode: documentCode,
      notes: request.notes,
    );
    return res?.statusCode == 200;
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

  Future<void> _load({String? issueNo, String? barcode}) async {
    setState(() => _loading = true);
    final list = await _controller.searchAwaitingReceive(
      issueNo: issueNo,
      barcode: barcode,
    );
    if (!mounted) return;
    setState(() {
      _items = list;
      _rows = list.map(_deptTrackingRow).toList();
      _loading = false;
      _gridEpoch++;
    });
    _requestSearchFocus();
  }

  void _requestSearchFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_searchFocusNode.canRequestFocus) {
          _searchFocusNode.requestFocus();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestSearchFocus();
      _load();
    });
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
      final sent = await _sendTracking(item, initialNotes: notes);
      return sent == true;
    }

    final situation = item.activeStepSituationCode();
    final hideDeptActions = situation == 'received_sent';
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
                sendOnlyAfterReceived: sendOnlyAfterReceived,
              ),
      ),
    );
    if (!mounted) return;
    if (reload == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _runSearch();
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
                textDirection: TextDirection.rtl,
                children: [
                  SizedBox(
                    width: _isDesktop ? _width * 0.28 : _width * 0.46,
                    child: CustomTextField2(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      autoFocus: true,
                      height: _height * 0.048,
                      width: double.infinity,
                      isReport: true,
                      text: Text(
                        _locale.deptTrackingIssueOrBarcodeSearchHint(
                          _locale.issueNo,
                          _locale.fileBarcode,
                        ),
                      ),
                      onSubmitted: (_) => _runSearch(),
                      customIconSuffix: IconButton(
                        icon: const Icon(Icons.search_rounded, size: 20),
                        color: primary,
                        onPressed: _runSearch,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                      if (refreshed == true && mounted) {
                        await _runSearch();
                      }
                    },
                  ),
                  const Spacer(),
                  CustomElevatedButton(
                    text: _locale.refresh,
                    color: primary,
                    icon: Icons.refresh_rounded,
                    width: _isDesktop ? _width * 0.09 : _width * 0.22,
                    height: _height * 0.038,
                    fontSize: 14,
                    onPressed: () {
                      if (!_loading) _runSearch();
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
                    appBarTitleWidget: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AppBarTitle(
                        title: _locale.deptApprovals,
                        icon: Icons.notification_important,
                      ),
                    ),
                    polRows: _rows,
                    onLoaded: (e) {
                      _stateManager = e.stateManager;
                      _stateManager?.setShowColumnFilter(true);
                      _requestSearchFocus();
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
