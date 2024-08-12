import 'package:archiving_flutter_project/dialogs/actions_dialogs/add_edit_action_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/add_file_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/file_explor_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/info_document_dialogs.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/dialogs/users_dialogs/add_edit_user_dialog.dart';
import 'package:archiving_flutter_project/dialogs/users_dialogs/user_department_dialog.dart';
import 'package:archiving_flutter_project/models/db/actions_models/action_model.dart';
import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_document_criterea.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';
import 'package:archiving_flutter_project/providers/classification_name_and_code_provider.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/loading.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<PlutoColumn> polCols = [];
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  late CalssificatonNameAndCodeProvider calssificatonNameAndCodeProvider;
  UserController userController = UserController();
  late DocumentListProvider documentListProvider;
  PlutoGridStateManager? stateManager;
  ValueNotifier isSearch = ValueNotifier(false);
  ValueNotifier totalUsersCount = ValueNotifier(0);
  getCount() {
    userController.getUserCount().then((value) {
      totalUsersCount.value = value;
    });
  }

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    polCols = [];
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    documentListProvider = context.read<DocumentListProvider>();
    calssificatonNameAndCodeProvider =
        context.read<CalssificatonNameAndCodeProvider>();
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
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  PlutoRow? selectedRow;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_locale.users),
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                  width: isDesktop ? width * 0.8 : width * 0.9,
                  child: TableComponent(
                    // key: UniqueKey(),
                    tableHeigt: height * 0.75,
                    tableWidth: width * 0.85,
                    search: search,
                    plCols: polCols,
                    mode: PlutoGridMode.selectWithOneTap,
                    polRows: [],
                    footerBuilder: (stateManager) {
                      return lazyLoadingfooter(stateManager);
                    },
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      stateManager = event.stateManager;
                      stateManager!.setShowColumnFilter(true);
                      // pageLis.value = pageLis.value > 1 ? 0 : 1;
                      // totalActionsCount.value = 0;
                      // getCount();
                    },
                    // doubleTab: (event) async {
                    //   PlutoRow? tappedRow = event.row;
                    //   UserModel userModel =
                    //       UserModel.fromPlutoRow(tappedRow!, _locale);
                    //   showDialog(
                    //     barrierDismissible: false,
                    //     context: context,
                    //     builder: (context) {
                    //       return AddUserDialog(
                    //         isChangePassword: false,
                    //         userModel: userModel,
                    //       );
                    //     },
                    //   ).then((value) {
                    //     if (value == true) {
                    //       refreshTable();
                    //     }
                    //   });
                    // },
                    onSelected: (event) async {
                      PlutoRow? tappedRow = event.row;
                      selectedRow = tappedRow;
                    },
                  )),
              Container(
                width: isDesktop ? width * 0.8 : width * 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${_locale.totalCount}: ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ValueListenableBuilder(
                        valueListenable: totalUsersCount,
                        builder: ((context, value, child) {
                          return Text(
                            "${totalUsersCount.value}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void fillColumnTable() {
    polCols.addAll([
      PlutoColumn(
        enableFilterMenuItem: true,
        title: "#",
        field: "count",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.07 : width * 0.15,
        backgroundColor: columnColors,
        renderer: (rendererContext) {
          return Center(
            child: Text((rendererContext.rowIdx + 1).toString()),
          );
        },
      ),
      //txtCode
      PlutoColumn(
        enableFilterMenuItem: true,
        title: _locale.userCode,
        field: "txtCode",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.21 : width * 0.4,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        enableFilterMenuItem: true,
        title: _locale.userName,
        field: "txtNamee",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.21 : width * 0.4,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        enableFilterMenuItem: true,
        title: _locale.type,
        field: "intType",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.13 : width * 0.2,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        enableFilterMenuItem: true,
        title: _locale.userStatus,
        field: "bolActive",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.15 : width * 0.2,
        backgroundColor: columnColors,
      ),
      // PlutoColumn(
      //   enableFilterMenuItem: true,
      //   title: _locale.email,
      //   field: "email",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.116 : width * 0.2,
      //   backgroundColor: columnColors,
      // ),
    ]);
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
      result = await userController.getUsers(SearchModel(
          searchField: text.trim(), page: pageLis.value, status: -1));
      pageLis.value = pageLis.value + 1;
      for (int i = 0; i < result.length; i++) {
        // rowList.add(result[i].toPlutoRow(i + 1));
        topList.add(result[i].toPlutoRow(rowList.length, _locale));
      }
      stateManager!.removeAllRows();
      stateManager!.appendRows(topList);
    }
  }

  List<PlutoRow> rowList = [];
  ValueNotifier pageLis = ValueNotifier(1);
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
        result = await userController.getUsers(
            SearchModel(page: pageLis.value, searchField: "", status: -1));

        for (int i = pageLis.value == -1 ? 50 : 0; i < result.length; i++) {
          rowList.add(result[i].toPlutoRow(i + 1, _locale));
          topList.add(result[i].toPlutoRow(rowList.length, _locale));
        }

        isLast = topList.isEmpty;
        if (pageLis.value == 1) {
          pageLis.value++; // Increment the page number for next fetch
        }
        return Future.value(
            PlutoInfinityScrollRowsResponse(isLast: false, rows: topList));
      }
    }
    return Future.value(
        PlutoInfinityScrollRowsResponse(isLast: isLast, rows: []));
  }
}
