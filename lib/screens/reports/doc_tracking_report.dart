import 'dart:typed_data';

import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/models/dto/doc_tracking_report_criteria.dart';
import 'package:archiving_flutter_project/dialogs/pdf_preview.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/service/controller/reports_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/loading.dart';
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

  final ReportsController _reportsController = ReportsController();
  DocTrackingReportCriteria? _lastCriteria;

  String _selectedDeptKey = '';
  String _selectedStatusCode = '';
  String _appliedStatusCode = '';
  bool _filtersLoaded = false;
  bool _loading = false;
  bool _exportingPdf = false;
  bool _initialSearchDone = false;
  bool _fetchEnabled = false;
  int _currentPage = 1;
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
      // _FileStatusOption(
      //   code: 'sent',
      //   label: _locale.fileStatusSent,
      // ),
    ];
    _buildColumns();
    _syncColumnsToGrid();
    _loadFilters().then((_) {
      if (!mounted || _initialSearchDone) return;
      _initialSearchDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchReport();
      });
    });
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
    final showReceivedColumns =
        _appliedStatusCode != 'not_received' && _appliedStatusCode != 'sent';
    final colWidth = _isDesktop ? _width * 0.105 : _width * 0.34;

    PlutoColumn col(String title, String field) {
      return PlutoColumn(
        readOnly: true,
        title: title,
        field: field,
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: colWidth,
        enableFilterMenuItem: false,
      );
    }

    _columns = [
      col(_locale.fileBarcode, 'barcode'),
      col(_locale.issueNo, 'issueNo'),
      col(_locale.department, 'deptName'),
      col(_locale.fileStatus, 'fileStatus'),
      col(_locale.deptTrackingSentBy, 'sentBy'),
      col(_locale.deptTrackingSentAt, 'sentAt'),
      if (showReceivedColumns) ...[
        col(_locale.receivedBy, 'receivedBy'),
        col(_locale.deptTrackingReceivedAt, 'receivedAt'),
      ],
    ];
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

  DocTrackingReportCriteria _buildCriteria({int? page}) {
    int? status;
    if (_selectedStatusCode == 'received') {
      status = 2;
    } else if (_selectedStatusCode == 'not_received') {
      status = 1;
    } 
    // else if (_selectedStatusCode == 'sent') {
    //   status = 3;
    // }

    return DocTrackingReportCriteria(
      fromDate: _fromDateController.text.trim(),
      toDate: _toDateController.text.trim(),
      status: status,
      deptKey: _selectedDeptKey,
      page: page,
    );
  }

  DocTrackingReportCriteria? _criteriaForFetch() {
    if (_lastCriteria == null) return null;
    return DocTrackingReportCriteria(
      fromDate: _lastCriteria!.fromDate,
      toDate: _lastCriteria!.toDate,
      status: _lastCriteria!.status,
      deptKey: _lastCriteria!.deptKey,
      page: _currentPage,
    );
  }

  DocTrackingReportCriteria _criteriaForPdfExport() {
    final base = _lastCriteria ?? _buildCriteria(page: 1);
    return DocTrackingReportCriteria(
      fromDate: base.fromDate,
      toDate: base.toDate,
      status: base.status,
      deptKey: base.deptKey,
      page: -1,
    );
  }

  Future<void> _searchReport() async {
    if (_loading) return;

    final criteria = _buildCriteria(page: 1);
    if (criteria.fromDate == null ||
        criteria.fromDate!.isEmpty ||
        criteria.toDate == null ||
        criteria.toDate!.isEmpty) {
      CustomToastMessage.error(context, _locale.fillRequiredFields);
      return;
    }

    setState(() {
      _loading = true;
      _lastCriteria = criteria;
      _appliedStatusCode = _selectedStatusCode;
      _currentPage = 1;
      _fetchEnabled = true;
      _buildColumns();
      _gridEpoch++;
    });
  }

  PlutoInfinityScrollRows _lazyLoadingFooter(
      PlutoGridStateManager stateManager) {
    return PlutoInfinityScrollRows(
      initialFetch: true,
      fetchWithSorting: false,
      fetchWithFiltering: false,
      fetch: _fetchReportRows,
      stateManager: stateManager,
    );
  }

  Future<PlutoInfinityScrollRowsResponse> _fetchReportRows(
      PlutoInfinityScrollRowsRequest request) async {
    if (!_fetchEnabled) {
      return PlutoInfinityScrollRowsResponse(isLast: true, rows: []);
    }

    final criteria = _criteriaForFetch();
    if (criteria == null) {
      return PlutoInfinityScrollRowsResponse(isLast: true, rows: []);
    }

    final pageToFetch = _currentPage;
    _stateManager?.setShowLoading(true);

    try {
      final items = await _reportsController.getDocTrackingReport(criteria);
      if (!mounted) {
        return PlutoInfinityScrollRowsResponse(isLast: true, rows: []);
      }

      final rows = items.map((item) => item.toPlutoRow()).toList();
      _currentPage = pageToFetch + 1;

      if (pageToFetch == 1) {
        setState(() => _loading = false);
      }

      return PlutoInfinityScrollRowsResponse(
        isLast: items.isEmpty,
        rows: rows,
      );
    } catch (_) {
      if (!mounted) {
        return PlutoInfinityScrollRowsResponse(isLast: true, rows: []);
      }
      if (pageToFetch == 1) {
        setState(() => _loading = false);
        CustomToastMessage.error(context, _locale.error);
      }
      return PlutoInfinityScrollRowsResponse(isLast: true, rows: []);
    } finally {
      _stateManager?.setShowLoading(false);
    }
  }

  Future<void> _onDownloadPdf() async {
    if (_loading || _exportingPdf) return;

    final criteria = _criteriaForPdfExport();
    if (criteria.fromDate == null ||
        criteria.fromDate!.isEmpty ||
        criteria.toDate == null ||
        criteria.toDate!.isEmpty) {
      CustomToastMessage.error(context, _locale.fillRequiredFields);
      return;
    }

    setState(() => _exportingPdf = true);
    openLoadinDialog(context);
    try {
      final bytes = await _reportsController.getDocTrackingReportPdf(criteria);
      if (!mounted) return;
      Navigator.of(context).pop();

      if (bytes == null || bytes.isEmpty) {
        CustomToastMessage.error(context, _locale.error);
        return;
      }

      await showDialog(
        context: context,
        
        builder: (_) => PdfPreview1(
          pdfFile: Uint8List.fromList(bytes),
          fileName: 'tracking-report.pdf',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      CustomToastMessage.error(context, _locale.error);
    } finally {
      if (mounted) {
        setState(() => _exportingPdf = false);
      }
    }
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
                  isInitiaDate: false,
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
                  isLoading: _exportingPdf,
                  onPressed: (_loading || _exportingPdf) ? () {} : _onDownloadPdf,
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
                    polRows: <PlutoRow>[],
                    mode: PlutoGridMode.selectWithOneTap,
                    footerBuilder: _lazyLoadingFooter,
                    onLoaded: (event) {
                      _stateManager = event.stateManager;
                      _stateManager?.setShowColumnFilter(false);
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
