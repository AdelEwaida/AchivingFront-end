import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/dialogs/users_dialogs/add_edit_user_dialog.dart';
import 'package:archiving_flutter_project/dialogs/users_dialogs/user_department_dialog.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/template_model.dart';
import 'package:archiving_flutter_project/providers/classification_name_and_code_provider.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../dialogs/document_dialogs/file_explor_dialog.dart';
import '../../dialogs/template_work_flow/add_edit_template_dialog.dart';
import '../../dialogs/template_work_flow/edit_template_document_dialog.dart';
import '../../models/db/user_models/department_user_model.dart';
import '../../models/db/work_flow/work_flow_doc_model.dart';
import '../../models/db/work_flow/work_flow_document_info.dart';
import '../../models/db/work_flow/work_flow_template_body.dart';
import '../../service/controller/documents_controllers/documents_controller.dart';
import '../../service/controller/work_flow_controllers/work_flow_template_controller.dart';
import '../../utils/constants/loading.dart';
import '../../utils/func/lists.dart';
import '../../widget/custom_drop_down.dart';

class WorkFlowDocumentScreen extends StatefulWidget {
  const WorkFlowDocumentScreen({super.key});

  @override
  State<WorkFlowDocumentScreen> createState() => _WorkFlowDocumentScreenState();
}

class _WorkFlowDocumentScreenState extends State<WorkFlowDocumentScreen> {
  List<PlutoColumn> polCols = [];
  PlutoGridStateManager? stateManager;
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  // late CalssificatonNameAndCodeProvider calssificatonNameAndCodeProvider;
  WorkFlowTemplateContoller userController = WorkFlowTemplateContoller();
  late DocumentListProvider documentListProvider;

  ValueNotifier isSearch = ValueNotifier(false);
  ValueNotifier totalUsersCount = ValueNotifier(0);

  WorkFlowDocumentInfo? workFlowTemplateBody;
  WorkFlowTemplateContoller workFlowTemplateContoller =
      WorkFlowTemplateContoller();
  String? searchValue = "";
  UserModel? userModel;
  var storage = const FlutterSecureStorage();
  String? userName = "";
  String selectedDep = "";
  String selctedDepDesc = "";
  List<DepartmentUserModel> departmetList = [];
  int selectedStatus = -2;

  @override
  void didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    polCols = [];
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);

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
    for (int i = 0; i < stateManager!.rows.length; i++) {
      print(
          "stateManager!.rows[i].cells['intStatus']!.value :${stateManager!.rows[i].cells['intStatus']!.value}");
      stateManager!.rows[i].cells['intStatus']!.value =
          getStatusNameDependsLang(
              stateManager!.rows[i].cells['intStatus']!.value, _locale);
    }
    stateManager!.notifyListeners(true);
    userName = await storage.read(key: "userName");
    departmetList = await UserController().getDepartmentSelectedUser(userName!);
    setState(() {});
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  PlutoRow? selectedRow;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_locale.approvals),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                Container(
                    width: isDesktop ? width * 0.78 : width * 0.9,
                    child: TableComponent(
                      hasDropdown: true,
                      isworkFlow: true,
                      delete: deleteWorkFlow,
                      dropdown: departmentDropdown(),
                      tableHeigt: height * 0.78,
                      tableWidth: width * 0.85,
                      search: searchField,
                      statusDropDown: statusDropDown(),
                      // delete: deleteTemplate,
                      plCols: polCols,
                      mode: PlutoGridMode.selectWithOneTap,
                      polRows: [],
                      footerBuilder: (stateManager) {
                        return lazyLoadingfooter(stateManager);
                      },
                      view: editTemplate,
                      refresh: refreshTable,
                      explor: explorFiels,
                      onLoaded: (PlutoGridOnLoadedEvent event) {
                        stateManager = event.stateManager;
                        stateManager!.setShowColumnFilter(true);
                      },
                      doubleTab: (event) async {
                        PlutoRow? tappedRow = event.row;
                        workFlowTemplateBody =
                            WorkFlowDocumentInfo.fromPluto(tappedRow!, _locale);
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return EditTemplateDocumentDialog(
                              workFlowTemplateBody: workFlowTemplateBody,
                            );
                          },
                        ).then((value) {
                          if (value == true) {
                            refreshTable();
                          }
                        });
                      },
                      onSelected: (event) async {
                        PlutoRow? tappedRow = event.row;
                        selectedRow = tappedRow;
                        workFlowTemplateBody = WorkFlowDocumentInfo.fromPluto(
                            selectedRow!, _locale);
                      },
                    )),
                // Container(
                //   width: isDesktop ? width * 0.8 : width * 0.9,
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         Text(
                //           "${_locale.totalCount}: ",
                //           style: const TextStyle(fontWeight: FontWeight.bold),
                //         ),
                //         ValueListenableBuilder(
                //           valueListenable: totalUsersCount,
                //           builder: ((context, value, child) {
                //             return Text(
                //               "${totalUsersCount.value}",
                //               style:
                //                   const TextStyle(fontWeight: FontWeight.bold),
                //             );
                //           }),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ));
  }

  DropDown statusDropDown() {
    return DropDown(
      key: UniqueKey(),
      isMandatory: true,
      onChanged: (value) {
        selectedStatus =
            ListConstants.getStatusCodeWorkFlowDoc(value, _locale)!;

        search();
        setState(() {});
      },
      initialValue: selectedStatus == -2
          ? ListConstants.getStatusNameWorkFlowDoc(0, _locale)
          : ListConstants.getStatusNameWorkFlowDoc(selectedStatus, _locale),
      bordeText: _locale.searchByStatus,
      width: width * 0.15,
      items: ListConstants.getStatusWorkFlowAllOption(_locale),
      height: height * 0.048,
    );
  }

  void explorFiels() {
    if (selectedRow != null) {
      openLoadinDialog(context);
      DocumentsController()
          .getFilesByHdrKey(selectedRow!.cells['txtDocumentcode']!.value)
          .then((value) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return FileExplorDialog(
              listOfFiles: value,
              isWorkFlowScreen: true,
            );
          },
        );
      }).then((value) {});
    }
  }

  DropDown departmentDropdown() {
    return DropDown(
      onClearIconPressed: () {
        selctedDepDesc = "";
        setState(() {});
      },
      key: UniqueKey(),
      isMandatory: true,
      onChanged: (value) {
        selectedDep = value.txtDeptkey;
        selctedDepDesc = value.txtDeptName;

        search();
        setState(() {});
      },
      initialValue: selctedDepDesc == "" ? null : selctedDepDesc,
      bordeText: _locale.searchByDep,
      width: width * 0.15,
      items: departmetList,
      height: height * 0.048,
    );
  }

  void editTemplate() {
    if (workFlowTemplateBody != null) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return EditTemplateDocumentDialog(
            workFlowTemplateBody: workFlowTemplateBody,
          );
        },
      ).then((value) {
        if (value == true) {
          refreshTable();
        }
      });
    }
  }

  void deleteWorkFlow() async {
    if (selectedRow != null) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomConfirmDialog(
              confirmMessage: _locale.areYouSureToDelete(
                  selectedRow!.cells['txtTemplateName']!.value));
        },
      ).then((value) async {
        if (value == true) {
          WorkFlowDocumentModel templateModel = WorkFlowDocumentModel(
              txtKey: workFlowTemplateBody!.workflow!.txtKey);
          WorkFlowDocumentInfo tempModel =
              WorkFlowDocumentInfo(stepsList: null, workflow: templateModel);
          var response =
              await workFlowTemplateContoller.removeWorkflowDocument(tempModel);
          if (response.statusCode == 200) {
            refreshTable();
          }
        }
      });
    }
  }

  void refreshTable() async {
    stateManager!.setShowLoading(true);
    stateManager!.removeAllRows();
    stateManager!.notifyListeners(true);
    selectedRow = null;
    isSearch.value = false;
    workFlowTemplateBody = null;
    selectedDep = "";
    selctedDepDesc = "";
    selectedStatus = -2;
    setState(() {});
    rowList.clear();
    pageLis.value = 1;
    var response = await fetch(PlutoInfinityScrollRowsRequest());
    stateManager!.appendRows(response.rows);
    stateManager!.notifyListeners(true);
    stateManager!.resetCurrentState();
    stateManager!.setShowLoading(false);
  }

  void fillColumnTable() {
    polCols = [
      PlutoColumn(
        readOnly: true,
        title: _locale.fileName,
        field: "txtDocumentName",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.16 : width * 0.3,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.templateName,
        field: "txtTemplateName",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.16 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.department,
        field: "txtDeptName",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.16 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.date,
        field: "datMaxDate",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.15 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.status,
        field: "intStatus",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.15 : width * 0.4,
      ),
    ];
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

  search() async {
    isSearch.value = true;
    print("insidee search :${isSearch.value}");
    stateManager!.setShowLoading(true); // Show loading indicator

    if (selectedDep.isEmpty && selectedStatus == -2) {
      print("insidee search1111 :${isSearch.value}");

      isSearch.value = false;
      stateManager!.removeAllRows();
      stateManager!.appendRows(
          rowList); // Use existing rows if no department is selected
    } else if (isSearch.value) {
      print("insidee search333 :${isSearch.value}");

      List<WorkFlowDocumentInfo> result = [];
      List<PlutoRow> topList = [];
      pageLis.value = 1;

      // Fetch templates based on department
      result = await workFlowTemplateContoller.getWorkFlowDocumentInfo(
          WorkFlowDocumentModel(
              dept: selectedDep,
              document: searchValue,
              stepStatus: selectedStatus));

      // Update PlutoRows
      for (int i = 0; i < result.length; i++) {
        topList.add(result[i].toPlutoRow(rowList.length, _locale));
      }

      // Refresh the table with new data
      stateManager!.removeAllRows(); // Clear existing rows
      stateManager!.appendRows(topList); // Add new rows
      stateManager!.notifyListeners(true); // Ensure UI updates
    }

    stateManager!.setShowLoading(false); // Hide loading indicator
    setState(() {}); // Trigger rebuild of dropdown or other elements
  }

  searchField(String text) async {
    isSearch.value = true;
    print("insidee search");
    stateManager!.setShowLoading(true); // Show loading indicator

    if (text.isEmpty) {
      isSearch.value = false;
      List<WorkFlowDocumentInfo> result = [];
      List<PlutoRow> topList = [];
      pageLis.value = 1;
      searchValue = text;
      // Fetch templates based on department
      result = await workFlowTemplateContoller
          .getWorkFlowDocumentInfo(WorkFlowDocumentModel(
        stepStatus: selectedStatus,
        dept: selectedDep,
        document: text.trim(),
      ));

      // Update PlutoRows
      for (int i = 0; i < result.length; i++) {
        topList.add(result[i].toPlutoRow(rowList.length, _locale));
      }

      // Refresh the table with new data
      stateManager!.removeAllRows(); // Clear existing rows
      stateManager!.appendRows(topList); // Add new rows
      stateManager!.notifyListeners(true); // Ensure UI updates
    } else if (isSearch.value) {
      List<WorkFlowDocumentInfo> result = [];
      List<PlutoRow> topList = [];
      pageLis.value = 1;
      searchValue = text;
      // Fetch templates based on department
      result = await workFlowTemplateContoller.getWorkFlowDocumentInfo(
          WorkFlowDocumentModel(
              dept: selectedDep,
              document: text.trim(),
              stepStatus: selectedStatus));

      // Update PlutoRows
      for (int i = 0; i < result.length; i++) {
        topList.add(result[i].toPlutoRow(rowList.length, _locale));
      }

      // Refresh the table with new data
      stateManager!.removeAllRows(); // Clear existing rows
      stateManager!.appendRows(topList); // Add new rows
      stateManager!.notifyListeners(true); // Ensure UI updates
    }

    stateManager!.setShowLoading(false); // Hide loading indicator
    setState(() {}); // Trigger rebuild of dropdown or other elements
  }

  List<PlutoRow> rowList = [];
  ValueNotifier pageLis = ValueNotifier(1);
  Future<PlutoInfinityScrollRowsResponse> fetch(
      PlutoInfinityScrollRowsRequest request) async {
    bool isLast = false;
    print("inside ftchhhhhh");
    if (!isSearch.value) {
      if (pageLis.value != -1) {
        if (pageLis.value > 1) {
          pageLis.value = -1;
        }
        List<WorkFlowDocumentInfo> result = [];
        List<PlutoRow> topList = [];
        result = await userController.getWorkFlowDocumentInfo(
            WorkFlowDocumentModel(txtDept: "", stepStatus: 0));

        for (int i = pageLis.value == -1 ? 50 : 0; i < result.length; i++) {
          rowList.add(result[i].toPlutoRow(i + 1, _locale)); // Updated here
          topList.add(
              result[i].toPlutoRow(rowList.length, _locale)); // Updated here
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
