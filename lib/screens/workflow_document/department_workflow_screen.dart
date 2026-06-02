import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/dialogs/template_work_flow/add_edit_doc_tracking_template_dialog.dart';
import 'package:archiving_flutter_project/models/db/work_flow/doc_tracking_template_model.dart';
import 'package:archiving_flutter_project/service/controller/work_flow_controllers/work_flow_template_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_flutter_toast_message.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/app_bar_title.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pluto_grid/pluto_grid.dart';

class DepartmentWorkFlowScreen extends StatefulWidget {
  const DepartmentWorkFlowScreen({super.key});

  @override
  State<DepartmentWorkFlowScreen> createState() =>
      _DepartmentWorkFlowScreenState();
}

class _DepartmentWorkFlowScreenState extends State<DepartmentWorkFlowScreen> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;

  List<PlutoColumn> polCols = [];
  PlutoGridStateManager? stateManager;

  DocTrackingTemplateModel? _selectedTemplate;
  final WorkFlowTemplateContoller _controller = WorkFlowTemplateContoller();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    polCols = [];
    _fillColumns();
  }

  void _fillColumns() {
    polCols = [
      PlutoColumn(
        readOnly: true,
        title: _locale.docName,
        field: 'name',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.25 : width * 0.35,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.notes,
        field: 'note',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.35 : width * 0.40,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.dateCreated,
        field: 'createdAt',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.20 : width * 0.25,
      ),
    ];
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  PlutoRow _toRow(DocTrackingTemplateModel m) {
    return PlutoRow(cells: {
      'name': PlutoCell(value: m.name ?? ''),
      'note': PlutoCell(value: m.note ?? ''),
      'createdAt': PlutoCell(value: _fmtDate(m.createdAt)),
      '_key': PlutoCell(value: m.key ?? ''),
    });
  }

  String _fmtDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  // ── Data ───────────────────────────────────────────────────────────────────

  List<DocTrackingTemplateModel> _allTemplates = [];

  Future<void> _loadAll() async {
    _allTemplates = await _controller.getDocTrackingTemplates();
  }

  Future<void> _refreshTable() async {
    stateManager?.setShowLoading(true);
    stateManager?.removeAllRows();
    _selectedTemplate = null;
    await _loadAll();
    final rows = _allTemplates.map(_toRow).toList();
    stateManager?.appendRows(rows);
    stateManager?.setShowLoading(false);
    stateManager?.notifyListeners(true);
  }

  // ── CRUD actions ───────────────────────────────────────────────────────────

  void _add() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const AddEditDocTrackingTemplateDialog(isEdit: false),
    ).then((ok) {
      if (ok == true) _refreshTable();
    });
  }

  void _edit() {
    if (_selectedTemplate == null) {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
      return;
    }
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AddEditDocTrackingTemplateDialog(
        isEdit: true,
        model: _selectedTemplate,
      ),
    ).then((ok) {
      if (ok == true) _refreshTable();
    });
  }

  void _delete() {
    if (_selectedTemplate == null) {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
      return;
    }

    showDialog(
      context: context,
      builder: (_) => CustomConfirmDialog(
        confirmMessage:
            _locale.areYouSureToDelete(_selectedTemplate!.name ?? ''),
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;

      // fetch full record by key before deleting (getByKey)
      final full = await _controller
          .getDocTrackingTemplateByKey(_selectedTemplate!.key!);

      if (full == null) {
        if (!mounted) return;
        CustomToastMessage.error(context, _locale.error);
        return;
      }

      final res = await _controller
          .deleteDocTrackingTemplateReq(_selectedTemplate!.key!);

      if (!mounted) return;
      if (res.statusCode == 200) {
        _selectedTemplate = null;
        CustomToastMessage.success(context, _locale.editDoneSucess)
            .then((_) => _refreshTable());
      } else {
        CustomToastMessage.error(context, _locale.error);
      }
    });
  }

  // ── Lazy-load footer ───────────────────────────────────────────────────────

  PlutoInfinityScrollRows _footer(PlutoGridStateManager sm) {
    return PlutoInfinityScrollRows(
      initialFetch: true,
      fetchWithSorting: false,
      fetchWithFiltering: false,
      stateManager: sm,
      fetch: (request) async {
        await _loadAll();
        final rows = _allTemplates.map(_toRow).toList();
        return PlutoInfinityScrollRowsResponse(isLast: true, rows: rows);
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: TableComponent(
            appBarTitleWidget: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppBarTitle(
                title: _locale.fileTrackingWorkflow,
                icon: Icons.account_tree_outlined,
              ),
            ),
            tableHeigt: height * 0.78,
            tableWidth: width,
            add: _add,
            search: (_) {},
            delete: _delete,
            genranlEdit: _edit,
            refresh: _refreshTable,
            plCols: polCols,
            mode: PlutoGridMode.selectWithOneTap,
            polRows: [],
            footerBuilder: _footer,
            onLoaded: (event) {
              stateManager = event.stateManager;
              stateManager!.setShowColumnFilter(true);
            },
            doubleTab: (event) {
              final row = event.row;
              if (row == null) return;
              _selectedTemplate = _findTemplate(row);
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) => AddEditDocTrackingTemplateDialog(
                  isEdit: true,
                  model: _selectedTemplate,
                ),
              ).then((ok) {
                if (ok == true) _refreshTable();
              });
            },
            onSelected: (event) {
              final row = event.row;
              if (row == null) return;
              _selectedTemplate = _findTemplate(row);
            },
          ),
        ),
      ),
    );
  }

  DocTrackingTemplateModel? _findTemplate(PlutoRow row) {
    final key = row.cells['_key']?.value as String?;
    if (key == null) return null;
    try {
      return _allTemplates.firstWhere((t) => t.key == key);
    } catch (_) {
      return null;
    }
  }
}
