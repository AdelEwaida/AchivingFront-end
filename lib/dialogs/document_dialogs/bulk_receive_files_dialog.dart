import 'package:archiving_flutter_project/dialogs/app_dialog.dart';
import 'package:archiving_flutter_project/models/db/work_flow/awaiting_receive_issue_no_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/tracking_response_model.dart';
import 'package:archiving_flutter_project/screens/workflow_document/dept_tracking_pluto_mapper.dart';
import 'package:archiving_flutter_project/service/controller/work_flow_controllers/work_flow_template_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down_new.dart';
import 'package:archiving_flutter_project/widget/custom_flutter_toast_message.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pluto_grid/pluto_grid.dart';

Future<bool?> showBulkReceiveFilesDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _BulkReceiveFilesDialog(),
  );
}

class _BulkReceiveFilesDialog extends StatefulWidget {
  const _BulkReceiveFilesDialog();

  @override
  State<_BulkReceiveFilesDialog> createState() => _BulkReceiveFilesDialogState();
}

class _BulkReceiveFilesDialogState extends State<_BulkReceiveFilesDialog> {
  static const Color _headerBg = Color(0xFFF1F5F9);
  static const Color _textPrimary = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF64748B);

  late AppLocalizations _locale;
  double _width = 0;
  double _height = 0;
  bool _isDesktop = false;

  final TextEditingController _refController = TextEditingController();
  final FocusNode _refFocusNode = FocusNode();
  final WorkFlowTemplateContoller _controller = WorkFlowTemplateContoller();

  final List<TrackingResponseModel> _items = [];
  final Set<String> _addedIssueNos = {};
  List<AwaitingReceiveIssueNoModel> _issueNoOptions = [];
  bool _loadingIssueNos = true;
  bool _searching = false;
  bool _confirming = false;
  String _dropdownSearchQuery = '';
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _plutoRows = [];
  int _gridEpoch = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialIssueNos();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureRefFieldFocused();
      Future.delayed(const Duration(milliseconds: 280), _ensureRefFieldFocused);
    });
  }

  Future<void> _loadInitialIssueNos() async {
    final items = await _controller.getAwaitingReceiveIssueNos();
    if (!mounted) return;
    setState(() {
      _issueNoOptions = items;
      _loadingIssueNos = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    _isDesktop = Responsive.isDesktop(context);
    _buildColumns();
  }

  void _ensureRefFieldFocused() {
    if (!mounted) return;
    FocusScope.of(context).requestFocus(_refFocusNode);
  }

  @override
  void dispose() {
    _refController.dispose();
    _refFocusNode.dispose();
    super.dispose();
  }

  List<AwaitingReceiveIssueNoModel> get _availableIssueNos {
    return _issueNoOptions
        .where((item) => !_addedIssueNos.contains((item.issueNo ?? '').trim()))
        .toList();
  }

  List<AwaitingReceiveIssueNoModel> get _filteredIssueNos {
    final query = _dropdownSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return _availableIssueNos;
    return _availableIssueNos.where((item) {
      final issueNo = (item.issueNo ?? '').trim().toLowerCase();
      final desc = (item.documentDescription ?? '').trim().toLowerCase();
      return issueNo.contains(query) || desc.contains(query);
    }).toList();
  }

  Widget _issueNoDropdownPopupTop() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              isDense: true,
              hintText: _locale.search,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            onChanged: (value) => setState(() => _dropdownSearchQuery = value),
          ),
        ),
        _issueNoDropdownHeader(),
      ],
    );
  }

  Widget _issueNoDropdownHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: _headerBg,
        border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _locale.issueNo,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _locale.txtDescription,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _issueNoDropdownRow(
    BuildContext context,
    dynamic item,
    bool isSelected,
  ) {
    if (item is! AwaitingReceiveIssueNoModel) {
      return const SizedBox.shrink();
    }

    final issueNo = (item.issueNo ?? '').trim();
    final desc = (item.documentDescription ?? '').trim();
    final textColor = isSelected ? Colors.white : _textPrimary;
    final descColor = isSelected ? Colors.white70 : _textMuted;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF185FA5) : Colors.transparent,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              issueNo.isEmpty ? '—' : issueNo,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              desc.isEmpty ? '—' : desc,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: 12,
                color: descColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _buildColumns() {
    _columns = buildDeptTrackingPlutoColumns(
      locale: _locale,
      width: _dialogContentWidth,
      isDesktop: _isDesktop,
      showRemoveColumn: true,
      removeRenderer: _renderRemoveCell,
    );
  }

  Widget _renderRemoveCell(PlutoColumnRendererContext ctx) {
    final key =
        ctx.row.cells[deptTrackingLookupKeyField]?.value?.toString() ?? '';
    return Center(
      child: IconButton(
        tooltip: _locale.cancel,
        visualDensity: VisualDensity.compact,
        icon: const Icon(
          Icons.close_rounded,
          size: 20,
          color: Color(0xFFDC2626),
        ),
        onPressed: key.isEmpty ? null : () => _removeItem(key),
      ),
    );
  }

  PlutoRow _toPlutoRow(TrackingResponseModel item) {
    final row = deptTrackingToPlutoRow(item, _locale);
    row.cells['remove'] =
        PlutoCell(value: item.routeTrackingKeyForGrid());
    return row;
  }

  void _syncPlutoRows() {
    _plutoRows = _items.map(_toPlutoRow).toList();
    _gridEpoch++;
  }

  bool _hasItem(TrackingResponseModel item) {
    final key = item.routeTrackingKeyForGrid();
    return _items.any((e) => e.routeTrackingKeyForGrid() == key);
  }

  void _addSearchResults(
    List<TrackingResponseModel> results, {
    String? sourceIssueNo,
  }) {
    var changed = false;
    for (final item in results) {
      if (_hasItem(item)) continue;
      _items.add(item);
      changed = true;
    }
    final issueNo = sourceIssueNo?.trim() ?? '';
    if (issueNo.isNotEmpty && results.isNotEmpty) {
      _addedIssueNos.add(issueNo);
      changed = true;
    }
    if (changed) {
      setState(_syncPlutoRows);
    }
  }

  Future<void> _addReferenceFromField() async {
    final ref = _refController.text.trim();
    if (ref.isEmpty || _searching) return;

    setState(() => _searching = true);
    try {
      final results =
          await _controller.searchAwaitingReceive(issueNo: ref);
      if (!mounted) return;
      if (results.isEmpty) {
        CustomToastMessage.warning(
          context,
          _locale.deptTrackingBulkReceiveNoSearchResults,
        );
        return;
      }
      _addSearchResults(results, sourceIssueNo: ref);
      _refController.clear();
    } finally {
      if (mounted) setState(() => _searching = false);
      _ensureRefFieldFocused();
    }
  }

  Future<void> _addFromDropdown(AwaitingReceiveIssueNoModel item) async {
    final issueNo = (item.issueNo ?? '').trim();
    if (issueNo.isEmpty || _searching) return;

    setState(() => _searching = true);
    try {
      final results =
          await _controller.searchAwaitingReceive(issueNo: issueNo);
      if (!mounted) return;
      _addSearchResults(results, sourceIssueNo: issueNo);
      setState(() => _dropdownSearchQuery = '');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _removeItem(String key) {
    setState(() {
      _items.removeWhere((item) => item.routeTrackingKeyForGrid() == key);
      _syncPlutoRows();
    });
  }

  List<String> _collectStepKeys() {
    final keys = <String>{};
    for (final item in _items) {
      final stepKey = trackingStepForAction(item)?.txtKey?.trim() ?? '';
      if (stepKey.isNotEmpty) keys.add(stepKey);
    }
    return keys.toList();
  }

  Future<void> _confirmBulkReceive() async {
    if (_items.isEmpty || _confirming || _searching) return;

    final stepKeys = _collectStepKeys();
    if (stepKeys.isEmpty) {
      CustomToastMessage.warning(context, _locale.deptTrackingNoRouteRef);
      return;
    }

    setState(() => _confirming = true);
    try {
      final res = await _controller.postDocumentTrackingBulkReceive(
        stepKeys: stepKeys,
      );
      if (!mounted) return;
      if (res?.statusCode == 200) {
        CustomToastMessage.success(context, _locale.updatedSuccess);
        Navigator.of(context).pop(true);
      } else {
        CustomToastMessage.error(context, _locale.error);
      }
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  double get _dialogContentWidth =>
      _isDesktop ? _width * 0.88 : _width * 0.92;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: _locale.deptTrackingBulkReceiveTitle,
      width: _isDesktop ? _width * 0.92 : _width * 0.98,
      height: _height * 0.82,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField2(
            width: double.infinity,
            height: 50,
            isReport: true,
            enabled: !_searching && !_confirming,
            controller: _refController,
            focusNode: _refFocusNode,
            autoFocus: true,
            text: Text(_locale.deptTrackingRefNumberLabel),
            customIcon: _searching
                ? const Icon(Icons.hourglass_top_rounded)
                : const Icon(Icons.tag_rounded),
            onSubmitted: (_) => _addReferenceFromField(),
          ),
          const SizedBox(height: 14),
          if (_loadingIssueNos)
            SizedBox(
              height: 50,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: greenColor,
                  ),
                ),
              ),
            )
          else
            NewCustomDropDown(
              key: ValueKey('bulk_issue_nos_${_items.length}'),
              searchBox: false,
              isReports: true,
              isEnabled: !_searching && !_confirming,
              width: _dialogContentWidth,
              heightVal: _height * 0.28,
              bordeText: _locale.issueNo,
              items: _filteredIssueNos,
              popupTitle: _issueNoDropdownPopupTop(),
              customItemBuilder: _issueNoDropdownRow,
              onChanged: (value) {
                if (value is AwaitingReceiveIssueNoModel) {
                  _addFromDropdown(value);
                }
              },
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                _locale.deptTrackingBulkReceiveSelectedFiles,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _headerBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_items.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TableComponent(
              key: ValueKey('bulk_receive_files_$_gridEpoch'),
              noHeader: true,
              isworkFlow: true,
              rowsHeight: 48,
              tableHeigt: _height * 0.41,
              tableWidth: _dialogContentWidth,
              plCols: _columns,
              mode: PlutoGridMode.selectWithOneTap,
              polRows: _plutoRows,
              onLoaded: (e) {
                e.stateManager.setShowColumnFilter(false);
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_locale.cancel),
        ),
        CustomElevatedButton(
          text: _locale.deptTrackingBulkReceiveConfirm,
          color: greenColor,
          icon: Icons.inbox_rounded,
          width: _isDesktop ? 150 : 130,
          height: 40,
          fontSize: 13,
          isLoading: _confirming,
          onPressed: _items.isEmpty || _confirming ? () {} : _confirmBulkReceive,
        ),
      ],
    );
  }
}
