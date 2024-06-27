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
  late PlutoGridStateManager stateManager;
  ValueNotifier isSearch = ValueNotifier(false);
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
          child: Container(
              width: isDesktop ? width * 0.8 : width * 0.9,
              child: TableComponent(
                key: UniqueKey(),
                tableHeigt: height * 0.85,
                tableWidth: width * 0.85,
                editPassword: chagnePassword,
                delete: deleteUser,
                add: addUser,
                chooseDep: addDepartmentUser,
                search: search,
                plCols: polCols,
                mode: PlutoGridMode.selectWithOneTap,
                polRows: [],
                footerBuilder: (stateManager) {
                  return lazyLoadingfooter(stateManager);
                },
                genranlEdit: editUser,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  // pageLis.value = pageLis.value > 1 ? 0 : 1;
                  // totalActionsCount.value = 0;
                  // getCount();
                },
                doubleTab: (event) async {
                  PlutoRow? tappedRow = event.row;
                },
                onSelected: (event) async {
                  PlutoRow? tappedRow = event.row;
                  selectedRow = tappedRow;
                },
              )),
        ));
  }

  void addDepartmentUser() {
    if (selectedRow != null) {
      UserModel userModel = UserModel.fromPlutoRow(selectedRow!, _locale);
      showDialog(
        context: context,
        builder: (context) {
          return UserDepartmentDialog(
            userModel: userModel,
          );
        },
      );
    }
  }

  void editUser() {
    if (selectedRow != null) {
      UserModel userModel = UserModel.fromPlutoRow(selectedRow!, _locale);
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AddUserDialog(
            isChangePassword: false,
            userModel: userModel,
          );
        },
      ).then((value) {
        if (value == true) {
          refreshTable();
        }
      });
    }
  }

  void chagnePassword() {
    if (selectedRow != null) {
      UserModel userModel = UserModel.fromPlutoRow(selectedRow!, _locale);
      showDialog(
        context: context,
        builder: (context) {
          return AddUserDialog(
            isChangePassword: true,
            userModel: userModel,
          );
        },
      );
    }
  }

  void addUser() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AddUserDialog(
          isChangePassword: false,
        );
      },
    ).then((value) {
      if (value == true) {
        refreshTable();
      }
    });
  }

  void deleteUser() async {
    if (selectedRow != null) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomConfirmDialog(
              confirmMessage: _locale
                  .areYouSureToDelete(selectedRow!.cells['txtNamee']!.value));
        },
      ).then((value) async {
        if (value == true) {
          UserModel userModel = UserModel.fromPlutoRow(selectedRow!, _locale);
          var response = await userController.deleteUser(userModel);
          if (response.statusCode == 200) {
            refreshTable();
          }
        }
      });
    }
  }

  void refreshTable() async {
    stateManager.setShowLoading(true);
    stateManager.removeAllRows();
    stateManager.notifyListeners(true);
    rowList.clear();
    pageLis.value = 1;
    var response = await fetch(PlutoInfinityScrollRowsRequest());
    stateManager.appendRows(response.rows);
    stateManager.notifyListeners(true);
    stateManager.resetCurrentState();
    stateManager.setShowLoading(false);
  }

  void fillColumnTable() {
    polCols.addAll([
      PlutoColumn(
        title: "#",
        field: "count",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.05 : width * 0.15,
        backgroundColor: columnColors,
        renderer: (rendererContext) {
          return Center(
            child: Text((rendererContext.rowIdx + 1).toString()),
          );
        },
      ),
      //txtCode
      PlutoColumn(
        title: _locale.userCode,
        field: "txtCode",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.19 : width * 0.4,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.userName,
        field: "txtNamee",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.25 : width * 0.4,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.type,
        field: "intType",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.11 : width * 0.2,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.userStatus,
        field: "bolActive",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.09 : width * 0.2,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.email,
        field: "email",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.1 : width * 0.2,
        backgroundColor: columnColors,
      ),
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
      stateManager.removeAllRows();
      stateManager.appendRows(rowList);
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
      stateManager.removeAllRows();
      stateManager.appendRows(topList);
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
