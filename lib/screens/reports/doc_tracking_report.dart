import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/models/dto/doc_tracking_report_criteria.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/service/controller/reports_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:archiving_flutter_project/widget/custom_flutter_toast_message.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import 'package:archiving_flutter_project/widget/date_time_component.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pluto_grid/pluto_grid.dart';

const Color _primary = Color(0xFF185FA5);
const Color _accent = Color(0xFF0D9B8A);
const Color _bgPage = Color(0xFFF0F4F8);
const Color _cardBg = Colors.white;
const Color _border = Color(0xFFDDE3EE);
const Color _textPrimary = Color(0xFF1A2340);

class _FileStatusOption {
  final String code;
  final String label;

  const _FileStatusOption({required this.code, required this.label});

  @override
  String toString() => label;
}

class DocTrackingReport extends StatefulWidget {
  const DocTrackingReport({super.key});

  @override
  State<DocTrackingReport> createState() => _DocTrackingReportState();
}

class _DocTrackingReportState extends State<DocTrackingReport> {
  late AppLocalizations _locale;
  double _width = 0;
  double _height = 0;
  bool _isDesktop = false;

  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  List<DepartmentModel> _departments = [];
  List<_FileStatusOption> _statusOptions = [];
  List<PlutoColumn> _columns = [];
  List<PlutoRow> _rows = [];

  final ReportsController _reportsController = ReportsController();
  DocTrackingReportCriteria? _lastCriteria;

  String _selectedDeptKey = '';
  String _selectedStatusCode = '';
  bool _filtersLoaded = false;
  bool _loading = false;
  int _gridEpoch = 0;
  PlutoGridStateManager? _stateManager;

  @override
  void initState() {
    super.initState();
    _fromDateController.text = Converters.startOfCurrentYearAsString();
    _toDateController.text = Converters.formatDate2(DateTime.now().toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    _isDesktop = Responsive.isDesktop(context);
    _statusOptions = [
      _FileStatusOption(
        code: 'received',
        label: _locale.fileStatusReceived,
      ),
      _FileStatusOption(
        code: 'not_received',
        label: _locale.fileStatusNotReceived,
      ),
    ];
    _buildColumns();
    _syncColumnsToGrid();
    _loadFilters();
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    if (_filtersLoaded) return;
    final departments = await DepartmentController().getAllDepartments();
    if (!mounted) return;
    setState(() {
      _departments = departments;
      _filtersLoaded = true;
    });
  }

  void _buildColumns() {
    final colWidth = _isDesktop ? _width * 0.16 : _width * 0.32;
    _columns = List.generate(
      5,
      (index) => PlutoColumn(
        readOnly: true,
        title: '--',
        field: 'col${index + 1}',
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: colWidth,
        enableFilterMenuItem: true,
      ),
    );
  }

  _FileStatusOption? get _selectedStatusOption {
    for (final option in _statusOptions) {
      if (option.code == _selectedStatusCode) return option;
    }
    return null;
  }

  DepartmentModel? get _selectedDepartment {
    for (final dept in _departments) {
      if (dept.txtKey == _selectedDeptKey) return dept;
    }
    return null;
  }

  void _syncColumnsToGrid() {
    if (_stateManager == null || _columns.isEmpty) return;
    for (int i = 0;
        i < _columns.length && i < _stateManager!.columns.length;
        i++) {
      _stateManager!.columns[i].title = _columns[i].title;
      _stateManager!.columns[i].width = _columns[i].width;
    }
    _stateManager!.notifyListeners(true);
  }

  DocTrackingReportCriteria _buildCriteria() {
    return DocTrackingReportCriteria(
      fromDate: _fromDateController.text.trim(),
      toDate: _toDateController.text.trim(),
      status: _selectedStatusCode,
      dept: _selectedDeptKey,
    );
  }

  Future<void> _searchReport() async {
    if (_loading) return;

    final criteria = _buildCriteria();
    if (criteria.fromDate == null ||
        criteria.fromDate!.isEmpty ||
        criteria.toDate == null ||
        criteria.toDate!.isEmpty) {
      CustomToastMessage.error(context, _locale.fillRequiredFields);
      return;
    }

    setState(() => _loading = true);
    try {
      final items = await _reportsController.getDocTrackingReport(criteria);
      if (!mounted) return;
      setState(() {
        _lastCriteria = criteria;
        _rows = items.map((item) => item.toPlutoRow()).toList();
        _gridEpoch++;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      CustomToastMessage.error(context, _locale.error);
    }
  }

  void _onDownloadPdf() {
    final criteria = _lastCriteria ?? _buildCriteria();
    final _ = criteria.toJson();
    CustomToastMessage.warning(context, _locale.docTrackingReportPdfPending);
  }

  Widget _filterField(Widget child) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: child,
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.filter_alt_rounded,
                    color: _primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                _locale.documentTrackingReport,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _filterField(
                DateTimeComponent(
                  height: _height * 0.05,
                  label: _locale.fromDate,
                  dateController: _fromDateController,
                  dateWidth: double.infinity,
                  dateControllerToCompareWith: _toDateController,
                  readOnly: false,
                  isInitiaDate: true,
                  onValue: (isValid, value) {
                    if (isValid) _fromDateController.text = value;
                  },
                  timeControllerToCompareWith: null,
                ),
              ),
              _filterField(
                DateTimeComponent(
                  height: _height * 0.05,
                  label: _locale.toDate,
                  dateController: _toDateController,
                  dateWidth: double.infinity,
                  dateControllerToCompareWith: _fromDateController,
                  readOnly: false,
                  isInitiaDate: true,
                  onValue: (isValid, value) {
                    if (isValid) _toDateController.text = value;
                  },
                  timeControllerToCompareWith: null,
                ),
              ),
              _filterField(
                DropDown(
                  key: ValueKey('doc_tracking_status_$_selectedStatusCode'),
                  bordeText: _locale.fileStatus,
                  width: double.infinity,
                  height: _height * 0.055,
                  items: _statusOptions,
                  visiableClearIcon: true,
                  initialValue: _selectedStatusOption,
                  onChanged: (value) {
                    setState(() {
                      if (value == null) {
                        _selectedStatusCode = '';
                      } else {
                        _selectedStatusCode =
                            (value as _FileStatusOption).code;
                      }
                    });
                  },
                ),
              ),
              _filterField(
                DropDown(
                  key: ValueKey('doc_tracking_department_$_selectedDeptKey'),
                  bordeText: _locale.department,
                  width: double.infinity,
                  height: _height * 0.055,
                  items: _departments,
                  searchBox: true,
                  visiableClearIcon: true,
                  initialValue: _selectedDepartment,
                  onChanged: (value) {
                    setState(() {
                      if (value == null) {
                        _selectedDeptKey = '';
                      } else {
                        _selectedDeptKey =
                            (value as DepartmentModel).txtKey ?? '';
                      }
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CustomElevatedButton(
                  text: _locale.search,
                  color: _accent,
                  icon: Icons.search_rounded,
                  width: _isDesktop ? _width * 0.08 : _width * 0.24,
                  height: _height * 0.055,
                  fontSize: 13,
                  isLoading: _loading,
                  onPressed: _searchReport,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CustomElevatedButton(
                  text: _locale.downloadPdf,
                  color: _primary,
                  icon: Icons.picture_as_pdf_rounded,
                  width: _isDesktop ? _width * 0.10 : _width * 0.28,
                  height: _height * 0.055,
                  fontSize: 13,
                  onPressed: _loading ? () {} : _onDownloadPdf,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
      backgroundColor: _bgPage,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFiltersCard(),
            const SizedBox(height: 6),
            Expanded(
              child: Stack(
                children: [
                  TableComponent(
                    key: ValueKey('doc_tracking_report_table_$_gridEpoch'),
                    noHeader: true,
                    tableHeigt: _height * 0.66,
                    tableWidth: _width,
                    plCols: _columns,
                    polRows: _rows,
                    mode: PlutoGridMode.selectWithOneTap,
                    onLoaded: (event) {
                      _stateManager = event.stateManager;
                      _stateManager?.setShowColumnFilter(true);
                      _syncColumnsToGrid();
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
