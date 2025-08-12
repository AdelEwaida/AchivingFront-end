import 'dart:async';
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

class UserSelectionTableDialog extends StatefulWidget {
  final int? index;
  final List<UserModel>? selectedUsersModel;
  const UserSelectionTableDialog({
    this.selectedUsersModel,
    this.index,
    super.key,
  });

  @override
  State<UserSelectionTableDialog> createState() =>
      _UserSelectionTableDialogState();
}

class _UserSelectionTableDialogState extends State<UserSelectionTableDialog> {
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
  void didChangeDependencies() {
    _local = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    polCols = [];
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    filterProvider = context.read<UserProvider>();

    selectedUsersModel.clear();
    rowList2.clear();
    filterProvider.setSelectedUsers([]);

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

    for (int i = 0; i < filterProvider.selectedUsers.length!; i++) {
      selectedUsersModel.add(filterProvider.selectedUsers[i]);
      rowList2.add(filterProvider.selectedUsers[i].toPlutoRow(i + 1, _local));
    }
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
  void initState() {
    super.initState();
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

                    // after the table paints, sync the checked state
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final codes = provider.selectedUsers
                          .map((u) => u.txtCode ?? '')
                          .where((c) => c.isNotEmpty)
                          .toSet();
                      print('Selected user codes: $codes');

                      _applyPreselection(codes);
                    });

                    return TableComponent(
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
                      },
                      onSelected: (event) {},
                    );
                  },
                ),
              ),
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
