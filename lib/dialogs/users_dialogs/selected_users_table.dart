import 'dart:async';
import 'dart:developer';
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
import '../../utils/func/text_and_number_inputFormater.dart';
import '../../widget/table_component/table_component.dart';

class UserSelectionTable extends StatefulWidget {
  final String selectedCategoryId;
  const UserSelectionTable({
    Key? key,
    required this.selectedCategoryId,
  }) : super(key: key);

  @override
  State<UserSelectionTable> createState() => _UserSelectionTableState();
}

class _UserSelectionTableState extends State<UserSelectionTable> {
  late AppLocalizations _local;
  TextEditingController searchName = TextEditingController();
  TextEditingController searchCode = TextEditingController();

  PlutoGridStateManager? stateManager;
  ValueNotifier isLoading = ValueNotifier(true);
  bool isSearching = false;
  UserController _userController = UserController();
  List<UserModel> _availableUsers = [];
  late UserProvider filterProvider;
  ValueNotifier pageLis = ValueNotifier(1);
  ValueNotifier serachPageLis = ValueNotifier(1);
  ValueNotifier isSearch = ValueNotifier(false);
  List<UserModel> selectedUsersModel = [];

  ValueNotifier selectAll = ValueNotifier(false);
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  bool isEnteredSearch = false;
  bool bolIsLooding = false;
  int isSuppStock = 0;
  List<PlutoRow> rowList = [];
  List<PlutoRow> rowList2 = [];
  bool isDesktop = false;

  ValueNotifier itemsNumber = ValueNotifier(0);
  List<PlutoColumn> polCols = [];
  @override
  void didUpdateWidget(covariant UserSelectionTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedCategoryId != widget.selectedCategoryId) {
      selectedUsersModel.clear();
      rowList2.clear();

      // Only run if there’s something to load
      if (filterProvider.selectedUsers.isNotEmpty) {
        for (int i = 0; i < filterProvider.selectedUsers.length; i++) {
          selectedUsersModel.add(filterProvider.selectedUsers[i]);
          rowList2.add(
            filterProvider.selectedUsers[i].toPlutoRow(i + 1, _local),
          );
          print(
              "filterProvider.selectedUsers[i] :${filterProvider.selectedUsers[i]}");
        }
      }

      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    _local = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    polCols = [];
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    filterProvider = context.read<UserProvider>();
    print("ttttttttttttttttttttttttttttttttttttttttttttttttttttttttt");
    selectedUsersModel.clear();
    rowList2.clear();
    // filterProvider.setSelectedUsers([]);/

    fillColumnTable();
    if (stateManager != null) {
      for (int i = 0; i < polCols.length; i++) {
        String title = polCols[i].title;
        polCols[i].titleSpan = TextSpan(
          children: [
            WidgetSpan(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
        polCols[i].titleTextAlign = PlutoColumnTextAlign.center;
        polCols[i].textAlign = PlutoColumnTextAlign.center;

        stateManager!.columns[i].title = polCols[i].title;
        stateManager!.columns[i].width = polCols[i].width;
        stateManager!.columns[i].titleTextAlign = polCols[i].titleTextAlign;
        stateManager!.columns[i].textAlign = polCols[i].textAlign;
        stateManager!.columns[i].titleSpan = polCols[i].titleSpan;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final users = filterProvider.selectedUsers;
      if (users.isNotEmpty) {
        selectedUsersModel = List.from(users);
        rowList2 = users
            .asMap()
            .entries
            .map((e) => e.value.toPlutoRow(e.key + 1, _local))
            .toList();
        setState(() {});
      }
    });

    super.didChangeDependencies();
  }

  void fillColumnTable() {
    polCols.addAll([
      PlutoColumn(
        title: '#',
        field: 'count',
        type: PlutoColumnType.text(),
        readOnly: true,
        enableFilterMenuItem: false,
        enableRowChecked: true,
        enableSorting: false,
        width: isDesktop ? width * 0.06 : width * 0.15,
        backgroundColor: columnColors,
        renderer: (ctx) {
          // rowIdx is 0-based; show 1-based
          return Center(child: Text('${ctx.rowIdx + 1}'));
        },
      ),
      PlutoColumn(
        enableFilterMenuItem: true,
        title: _local.userCode,
        field: "txtCode",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.15 : width * 0.4,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        enableFilterMenuItem: true,
        title: _local.refNumber,
        field: "txtReferenceUsername",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.12 : width * 0.4,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        enableFilterMenuItem: true,
        title: _local.userName,
        field: "txtNamee",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.16 : width * 0.4,
        backgroundColor: columnColors,
      ),
    ]);
  }

  @override
  void dispose() {
    setState(() {
      isSearching = true;
    });
    super.dispose();
  }

  double width = 0;
  double height = 0;
  bool isFirstSpace = true;
  void _applyPreselection(Set<String> preselectedCodes) {
    if (stateManager == null) return;

    for (final row in stateManager!.rows) {
      final code = row.cells['txtCode']?.value?.toString();
      row.setChecked(preselectedCodes.contains(code));
    }
    stateManager!.notifyListeners(true);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth * 0.3;
    final double dialogHeight = screenHeight * 0.7;

    return bolIsLooding
        ? Center(child: CircularProgressIndicator()) // Loading indicator
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: isDesktop ? width * 0.8 : width * 0.9,
                child: Consumer<UserProvider>(
                  builder: (context, provider, _) {
                    selectedUsersModel =
                        List<UserModel>.from(provider.selectedUsers);

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (stateManager == null) return;
                      final codes = provider.selectedUsers
                          .map((u) => u.txtCode ?? '')
                          .where((c) => c.isNotEmpty)
                          .toSet();

                      _applyPreselection(codes);
                      _placeSelectedFirstAndPrecheck(codes);
                    });

                    return TableComponent(
                      key: ValueKey(widget.selectedCategoryId),
                      tableHeigt: height * 0.6,
                      tableWidth: width * 0.85,
                      search: search,
                      plCols: polCols,
                      mode: PlutoGridMode.selectWithOneTap,
                      polRows: [],
                      footerBuilder: (stateManager) =>
                          lazyLoadingfooter(stateManager),
                      handleOnRowChecked: handleOnRowChecked,
                      onLoaded: (PlutoGridOnLoadedEvent event) {
                        stateManager = event.stateManager;
                        stateManager!.setShowColumnFilter(true);

                        // Apply immediately if provider already has users
                        final codes = provider.selectedUsers
                            .map((u) => u.txtCode ?? '')
                            .where((c) => c.isNotEmpty)
                            .toSet();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _placeSelectedFirstAndPrecheck(codes);
                        });
                      },
                      onSelected: (event) {},
                    );
                  },
                ),
              )
            ],

            // actions: [
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            // ElevatedButton(
            //   onPressed: () {
            //     filterProvider.clearUsers();
            //     filterProvider.addUsers(selectedUsersModel);
            //     Navigator.pop(context);
            //   },
            //   style: customButtonStyle(
            //     Size(width * 0.09, height * 0.045),
            //     18,
            //     const Color(0xff1F6E8C),
            //   ),
            //   child: Text(
            //     _local.save,
            //     style: const TextStyle(color: whiteColor),
            //   ),
            // ),
            //     ],
            //   ),
            // ],
          );
  }

  void _syncProvider() {
    final p = context.read<UserProvider>();
    p.clearUsers();
    p.addUsers(selectedUsersModel);
  }

  void _placeSelectedFirstAndPrecheck(Set<String> codes) {
    print('[_placeSelectedFirstAndPrecheck] codes: $codes');
    if (codes.isEmpty || stateManager == null) return;

    // 1) شفرة الصفوف الموجودة الآن في الجدول
    final all = List<PlutoRow>.from(stateManager!.rows);
    final presentCodes = <String>{
      for (final r in all) (r.cells['txtCode']?.value?.toString() ?? '')
    };

    // 2) الأكواد الناقصة (موجودة في الـ provider بس مش موجودة كصفوف في الجدول)
    final missingCodes = codes.difference(presentCodes);
    print('Missing selected codes (not in grid yet): $missingCodes');

    // 3) ابنِ صفوف للناقص من الـ provider وأضفها أعلى الجدول
    if (missingCodes.isNotEmpty) {
      final prov = context.read<UserProvider>();
      final toInsert = <PlutoRow>[];

      for (final u in prov.selectedUsers) {
        final c = (u.txtCode ?? '').trim();
        if (missingCodes.contains(c)) {
          final row = u.toPlutoRow(0, _local);
          row.setChecked(true); // precheck
          toInsert.add(row);
        }
      }

      // أدخلهم من الأخير للأول عشان يحافظ على نفس الترتيب المقصود
      for (final r in toInsert.reversed) {
        stateManager!.insertRows(0, [r]);
      }

      print('Inserted ${toInsert.length} missing selected rows at top.');
    }

    // 4) الآن اقسم كل الصفوف إلى مختارة/غير مختارة ثم أعد الترتيب
    final current = List<PlutoRow>.from(stateManager!.rows);
    final selected = <PlutoRow>[];
    final rest = <PlutoRow>[];

    for (final r in current) {
      final code = r.cells['txtCode']?.value?.toString() ?? '';
      final isSelected = codes.contains(code);
      if (isSelected) {
        r.setChecked(true);
        selected.add(r);
      } else {
        rest.add(r);
      }
    }

    print('Selected rows count (after insert): ${selected.length}');
    print('Unselected rows count: ${rest.length}');

    // لإزالة التكرار: امسح كل الصفوف وأعد إدراجها بالترتيب
    stateManager!
      ..removeRows(current)
      ..appendRows([...selected, ...rest]);

    print('Reordered grid → selected first.');
  }

  PlutoInfinityScrollRows lazyLoadingfooter(
      PlutoGridStateManager stateManager) {
    return PlutoInfinityScrollRows(
      initialFetch: true,
      fetchWithSorting: false,
      fetchWithFiltering: false,
      fetch: fetch,
      stateManager: stateManager,
    );
  }

  search(String text) async {
    isSearch.value = true;
    if (text.trim().isEmpty) {
      isSearch.value = false;
      stateManager!.removeAllRows();
      stateManager!.appendRows(rowList);
    } else if (isSearch.value) {
      List<UserModel> result = [];
      List<PlutoRow> topList = [];
      pageLis.value = 1;
      result = await _userController.getUsers(SearchModel(
          searchField: text.trim(), page: pageLis.value, status: -1));
      pageLis.value = pageLis.value + 1;
      for (int i = 0; i < result.length; i++) {
        // rowList.add(result[i].toPlutoRow(i + 1));
        topList.add(result[i].toPlutoRow(rowList.length, _local));
      }
      stateManager!.removeAllRows();
      stateManager!.appendRows(topList);
    }
  }

  Future<PlutoInfinityScrollRowsResponse> fetch(
      PlutoInfinityScrollRowsRequest request) async {
    bool isLast = false;

    if (!isSearch.value) {
      if (pageLis.value != -1) {
        if (pageLis.value > 1) {
          pageLis.value = -1;
        }
        List<UserModel> result = [];
        List<PlutoRow> topList = [];
        result = await _userController.getUsers(
            SearchModel(page: pageLis.value, searchField: "", status: -1));

        for (int i = pageLis.value == -1 ? 50 : 0; i < result.length; i++) {
          rowList.add(result[i].toPlutoRow(i + 1, _local));
          topList.add(result[i].toPlutoRow(rowList.length, _local));
        }

        isLast = topList.isEmpty;
        if (pageLis.value == 1) {
          pageLis.value++; // Increment the page number for next fetch
        }
        for (int i = 0; i < selectedUsersModel.length; i++) {
          for (int j = 0; j < topList.length; j++) {
            if (selectedUsersModel[i].txtCode ==
                topList[j].cells['txtCode']!.value) {
              PlutoRow fetchedRow = topList[j];

              if (i < rowList2.length) {
                rowList2[i] = fetchedRow;
              } else {
                rowList2.add(fetchedRow);
              }

              rowList.remove(fetchedRow);
              topList.remove(fetchedRow);
            }
          }
        }

        if (pageLis.value == 2) {
          List<PlutoRow> fetchedRows2 = [];
          for (int i = 0; i < topList.length; i++) {
            fetchedRows2.add(topList[i]);
          }
          topList = [];
          rowList = [];
          for (int i = 0; i < rowList2.length; i++) {
            topList.add(rowList2[i]);
            rowList.add(rowList2[i]);
            topList[i].setChecked(true);
          }
          for (int i = 0; i < fetchedRows2.length; i++) {
            rowList.add(fetchedRows2[i]);
            topList.add(fetchedRows2[i]);
          }
        }
        return Future.value(
            PlutoInfinityScrollRowsResponse(isLast: false, rows: topList));
      }
    }
    return Future.value(
        PlutoInfinityScrollRowsResponse(isLast: isLast, rows: []));
  }

  void handleOnRowChecked(PlutoGridOnRowCheckedEvent event) {
    if (event.isRow) {
      if (event.isChecked == false) {
        for (int i = 0; i < selectedUsersModel.length; i++) {
          if (selectedUsersModel[i].txtCode ==
              event.row!.cells['txtCode']!.value) {
            selectedUsersModel.removeAt(i);
            break;
          }
        }
      } else {
        selectedUsersModel.add(UserModel.fromPlutoRow(event.row!, _local));
      }
    } else {
      final selectedRows = stateManager!.checkedRows;
      selectedUsersModel = [];
      for (final row in selectedRows) {
        selectedUsersModel.add(UserModel.fromPlutoRow(row, _local));
      }
    }

    itemsNumber.value = selectedUsersModel.length;
    _syncProvider();
  }
}
