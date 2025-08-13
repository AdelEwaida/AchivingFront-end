import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

import '../../models/db/user_models/user_model.dart';
import '../../models/dto/searchs_model/search_model.dart';
import '../../providers/user_provider.dart';
import '../../service/controller/users_controller/user_controller.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/styles.dart';
import '../../utils/func/responsive.dart';
import '../../widget/table_component/table_component.dart';

class UserSelectionTable extends StatefulWidget {
  final String selectedCategoryId; // يتغير عند اختيار تصنيف جديد
  final double? tableHeight;
  final double? tableWidth;

  const UserSelectionTable({
    super.key,
    required this.selectedCategoryId,
    this.tableHeight,
    this.tableWidth,
  });

  @override
  State<UserSelectionTable> createState() => _UserSelectionTableState();
}

class _UserSelectionTableState extends State<UserSelectionTable> {
  late AppLocalizations _local;
  final _userController = UserController();

  PlutoGridStateManager? stateManager;

  // حالة الجدول
  final ValueNotifier<bool> _isSearch = ValueNotifier(false);
  final ValueNotifier<int> _page = ValueNotifier(1);

  final List<PlutoRow> _allRows = []; // كل الصفوف المجلوبة
  final List<PlutoRow> _pinnedRows = []; // الصفوف المحددة مسبقاً (تطلع فوق)
  final List<UserModel> _selectedUsersLocal = []; // تحديد محلي داخل الجدول

  final TextEditingController _searchCtrl = TextEditingController();

  bool _isDesktop = false;
  double _w = 0;
  double _h = 0;

  // الأعمدة
  late List<PlutoColumn> _cols;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _local = AppLocalizations.of(context)!;
    _w = MediaQuery.of(context).size.width;
    _h = MediaQuery.of(context).size.height;
    _isDesktop = Responsive.isDesktop(context);

    _cols = [
      PlutoColumn(
        title: '#',
        field: 'count',
        type: PlutoColumnType.number(),
        readOnly: true,
        enableEditingMode: false,
        width: _isDesktop ? _w * 0.06 : _w * 0.25,
        backgroundColor: columnColors,
        renderer: (ctx) => Text(
          (ctx.rowIdx + 1).toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      PlutoColumn(
        enableFilterMenuItem: true,
        title: _local.userCode,
        field: "txtCode",
        enableRowChecked: true,
        type: PlutoColumnType.text(),
        width: _isDesktop ? _w * 0.14 : _w * 0.45,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        enableFilterMenuItem: true,
        title: _local.refNumber,
        field: "txtReferenceUsername",
        type: PlutoColumnType.text(),
        width: _isDesktop ? _w * 0.12 : _w * 0.45,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        enableFilterMenuItem: true,
        title: _local.userName,
        field: "txtNamee",
        type: PlutoColumnType.text(),
        width: _isDesktop ? _w * 0.18 : _w * 0.55,
        backgroundColor: columnColors,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    // مبدئياً: الصفحة الأولى، بدون بحث
    _page.value = 1;
    _isSearch.value = false;
  }

  @override
  void didUpdateWidget(covariant UserSelectionTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لما يتغير التصنيف المختار: نظّف وابدأ من جديد
    if (oldWidget.selectedCategoryId != widget.selectedCategoryId) {
      _resetAndRefillForCategory();
    }
  }

  void _resetAndRefillForCategory() {
    stateManager?.removeAllRows();
    _allRows.clear();
    _pinnedRows.clear();
    _selectedUsersLocal
      ..clear()
      ..addAll(context
          .read<UserProvider>()
          .selectedUsers); // المزوّد محدث مسبقاً من الشاشة
    _page.value = 1;
    _isSearch.value = false;
    // خلي PlutoInfinityScroll يطلب من fetch() تلقائياً أول دفعة
    stateManager?.notifyListeners();
  }

  // البحث
  Future<void> _onSearch(String text) async {
    if (stateManager == null) return;
    final q = text.trim();
    if (q.isEmpty) {
      _isSearch.value = false;
      stateManager!.removeAllRows();
      // أعد ترتيب: المثبتين أولاً ثم الباقي
      final rows = [..._pinnedRows, ..._allRows];
      stateManager!.appendRows(rows);
      return;
    }

    _isSearch.value = true;
    _page.value = 1;

    final List<UserModel> result = await _userController.getUsers(
      SearchModel(searchField: q, page: _page.value, status: -1),
    );
    _page.value += 1;

    final List<PlutoRow> searchRows = [];
    for (final user in result) {
      searchRows.add(user.toPlutoRow(searchRows.length + 1, _local));
    }

    // تحقق من المحددين مسبقاً
    final selectedCodes = context
        .read<UserProvider>()
        .selectedUsers
        .map((e) => e.txtCode)
        .toSet();
    for (final r in searchRows) {
      if (selectedCodes.contains(r.cells['txtCode']!.value)) {
        r.setChecked(true);
      }
    }

    stateManager!.removeAllRows();
    stateManager!.appendRows(searchRows);
  }

  PlutoInfinityScrollRows _footer(PlutoGridStateManager sm) {
    return PlutoInfinityScrollRows(
      initialFetch: true,
      fetchWithSorting: false,
      fetchWithFiltering: false,
      fetch: _fetch,
      stateManager: sm,
    );
  }

  Future<PlutoInfinityScrollRowsResponse> _fetch(
      PlutoInfinityScrollRowsRequest request,
      ) async {
    // إذا كنا في وضع البحث: لا نحمّل Lazy (النتائج تُعرض من _onSearch)
    if (_isSearch.value) {
      return PlutoInfinityScrollRowsResponse(isLast: true, rows: []);
    }

    // نجيب صفحة
    final List<UserModel> result = await _userController.getUsers(
      SearchModel(page: _page.value, searchField: "", status: -1),
    );

    // خلصت الصفحات؟
    final bool isLast = result.isEmpty;
    if (!isLast) _page.value += 1;

    // حوّل لصفوف Pluto
    final newlyFetched = <PlutoRow>[];
    for (final user in result) {
      newlyFetched.add(
          user.toPlutoRow(_allRows.length + newlyFetched.length + 1, _local));
    }

    // افصل المحددين مسبقاً لأعلى الجدول وتفعيل check
    final selectedCodes = context
        .read<UserProvider>()
        .selectedUsers
        .map((e) => e.txtCode)
        .toSet();

    final stillAllRows = <PlutoRow>[];
    for (final r in newlyFetched) {
      if (selectedCodes.contains(r.cells['txtCode']!.value)) {
        r.setChecked(true);
        _pinnedRows.add(r);
      } else {
        stillAllRows.add(r);
      }
    }

    _allRows.addAll(stillAllRows);

    // أول تحميل: اعرض المثبتين أولاً
    if (_page.value == 2) {
      final combined = [..._pinnedRows, ..._allRows];
      return PlutoInfinityScrollRowsResponse(isLast: false, rows: combined);
    }

    return PlutoInfinityScrollRowsResponse(
        isLast: isLast, rows: List<PlutoRow>.from(newlyFetched));
  }

  void _onRowChecked(PlutoGridOnRowCheckedEvent e) {
    final provider = context.read<UserProvider>();

    if (e.isRow) {
      final code = e.row!.cells['txtCode']!.value as String;
      if (e.isChecked == false) {
        // أزل من المحددين
        provider.removeByCode(code);
        _selectedUsersLocal.removeWhere((u) => u.txtCode == code);
      } else {
        final model = UserModel.fromPlutoRow(e.row!, _local);
        provider.addUser(model);
        _selectedUsersLocal.add(model);
      }
    } else {
      // تحديد الكل من الصفحات المعرُوضة
      final selectedRows = stateManager!.checkedRows;
      _selectedUsersLocal.clear();
      for (final row in selectedRows) {
        final model = UserModel.fromPlutoRow(row, _local);
        _selectedUsersLocal.add(model);
      }
      provider.replaceWith(
          _selectedUsersLocal); // وفّر دالة مساعدة اختيارية في الـ Provider
    }
  }

  @override
  Widget build(BuildContext context) {
    final tableH = widget.tableHeight ?? _h * 0.68;
    final tableW = widget.tableWidth ?? _w * 0.42;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // شريط البحث أعلى الجدول
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  labelText: _local.search,
                  isDense: true,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Consumer<UserProvider>(
              builder: (_, p, __) => Text(
                '${_local.users}: ${p.selectedUsers.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TableComponent(
          tableHeigt: tableH,
          tableWidth: tableW,
          plCols: _cols,
          polRows: const [],
          mode: PlutoGridMode.selectWithOneTap,
          search: _onSearch,
          footerBuilder: (sm) => _footer(sm),
          handleOnRowChecked: _onRowChecked,
          onLoaded: (e) {
            stateManager = e.stateManager;
            stateManager!.setShowColumnFilter(true);
          },
          onSelected: (_) {},
        ),
      ],
    );
  }
}
