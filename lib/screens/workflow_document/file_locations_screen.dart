import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_flutter_toast_message.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../models/db/work_flow/lockup_location_model.dart';
import '../../service/controller/lockup_location_controller.dart';
import 'add_edit_ockup_location_dialog.dart';

class FilesLocationScreen extends StatefulWidget {
  const FilesLocationScreen({super.key});

  @override
  State<FilesLocationScreen> createState() => _FilesLocationScreenState();
}

class _FilesLocationScreenState extends State<FilesLocationScreen> {
  late AppLocalizations _locale;
  final LockupLocationController _controller = LockupLocationController();

  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];
  PlutoGridStateManager? _stateManager;

  double _width = 0;
  double _height = 0;
  bool _isDesktop = false;
  bool _loading = true;
  int _gridEpoch = 0;

  List<LockupLocationModel> _items = [];
  LockupLocationModel? _selectedItem;

  static const String _lookupKeyField = '_lockupKey';

  // ── lifecycle ──────────────────────────────────────────────────────────────
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  // ── columns ────────────────────────────────────────────────────────────────
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
        title: _locale.lockupCode,
        field: 'lockupCode',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.10 : w * 0.28,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.name,
        field: 'name',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.30 : w * 0.50,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.dateCreated,
        field: 'createdAt',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.14 : w * 0.38,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.updatedAt,
        field: 'updatedAt',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: _isDesktop ? w * 0.14 : w * 0.38,
      ),
    ];
  }

  // ── row helpers ────────────────────────────────────────────────────────────
  PlutoRow _buildRow(LockupLocationModel e) {
    return PlutoRow(
      cells: {
        _lookupKeyField: PlutoCell(value: e.key ?? ''),
        'lockupCode': PlutoCell(value: e.lockupCode ?? '—'),
        'name':
            PlutoCell(value: (e.name?.trim().isEmpty ?? true) ? '—' : e.name!),
        'createdAt': PlutoCell(value: _fmt(e.createdAt)),
        'updatedAt': PlutoCell(value: _fmt(e.updatedAt)),
      },
    );
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}';
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  LockupLocationModel? _findByKey(String key) {
    final k = key.trim();
    if (k.isEmpty) return null;
    try {
      return _items.firstWhere((e) => e.key == k);
    } catch (_) {
      return null;
    }
  }

  // ── data ──────────────────────────────────────────────────────────────────
  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _controller.getAllLockupLocations();
    if (!mounted) return;
    setState(() {
      _items = list;
      _rows = list.map(_buildRow).toList();
      _selectedItem = null;
      _loading = false;
      _gridEpoch++;
    });
  }

  // ── CRUD actions ──────────────────────────────────────────────────────────
  void _openAddDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddEditLockupLocationDialog(),
    );
    if (result == true && mounted) {
      CustomToastMessage.success(context, _locale.addDoneSucess);
      _load();
    }
  }

  void _openEditDialog() async {
    if (_selectedItem == null) {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
      return;
    }
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddEditLockupLocationDialog(existingItem: _selectedItem),
    );
    if (result == true && mounted) {
      CustomToastMessage.success(context, _locale.editDoneSucess);
      _load();
    }
  }

  void _deleteSelected() async {
    if (_selectedItem == null) {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => CustomConfirmDialog(
        confirmMessage:
            _locale.areYouSureToDelete(_selectedItem!.lockupCode ?? ''),
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    final ok = await _controller.deleteLockupLocation(_selectedItem!.key ?? '');
    if (!mounted) return;
    if (ok) {
      CustomToastMessage.success(context, _locale.deleteDoneSuccess);
      _load();
    } else {
      setState(() => _loading = false);
      CustomToastMessage.error(context, _locale.error);
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────
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
            Expanded(
              child: Stack(
                children: [
                  TableComponent(
                    key: ValueKey('lockup_location_grid_$_gridEpoch'),
                    // ── header icon callbacks ─────────────────────────────
                    add: _openAddDialog,
                    genranlEdit: _openEditDialog,
                    delete: _deleteSelected,
                    refresh: _load,
                    // ── table config ──────────────────────────────────────
                    noHeader: false, // show the header bar
                    isworkFlow: false,
                    tableHeigt: _height * 0.75,
                    tableWidth: _width,
                    plCols: _columns,
                    mode: PlutoGridMode.selectWithOneTap,
                    polRows: _rows,
                    onLoaded: (e) {
                      _stateManager = e.stateManager;
                      _stateManager?.setShowColumnFilter(true);
                    },
                    // single-tap → select
                    onSelected: (event) {
                      final key = event.row?.cells[_lookupKeyField]?.value
                              ?.toString() ??
                          '';
                      setState(() => _selectedItem = _findByKey(key));
                    },
                    // double-tap → open edit dialog directly
                    doubleTab: (event) {
                      final key =
                          event.row.cells[_lookupKeyField]?.value?.toString() ??
                              '';
                      final item = _findByKey(key);
                      if (item != null) {
                        setState(() => _selectedItem = item);
                        _openEditDialog();
                      }
                    },
                  ),

                  // loading overlay
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
