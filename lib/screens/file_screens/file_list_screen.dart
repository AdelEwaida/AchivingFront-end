import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archiving_flutter_project/dialogs/actions_dialogs/add_edit_action_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/add_file_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/file_explor_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/info_document_dialogs.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/dialogs/pdf_preview.dart';
import 'package:archiving_flutter_project/models/db/actions_models/action_model.dart';
import 'package:archiving_flutter_project/models/db/categories_models/document_category_tree.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/models/db/document_models/upload_file_mode.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_document_criterea.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';
import 'package:archiving_flutter_project/models/tree_model/my_node.dart';
import 'package:archiving_flutter_project/models/tree_model/tree_tile.dart';
import 'package:archiving_flutter_project/providers/classification_name_and_code_provider.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/screens/file_screens/fillter_section.dart';
import 'package:archiving_flutter_project/screens/file_screens/table_file_list_section.dart';
import 'package:archiving_flutter_project/service/controller/categories_controllers/categories_controller.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/loading.dart';
import 'package:archiving_flutter_project/utils/constants/sorted_by_constant.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/utils/func/save_excel_file.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:archiving_flutter_project/widget/date_time_component.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_searchField.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

import '../../dialogs/template_work_flow/edit_template_document_dialog.dart';
import '../../models/db/work_flow/work_flow_doc_model.dart';
import '../../models/db/work_flow/work_flow_document_info.dart';
import '../../service/controller/work_flow_controllers/work_flow_template_controller.dart';

class FileListScreen extends StatefulWidget {
  const FileListScreen({super.key});

  @override
  State<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  List<MyNode> treeNodes = [];
  List<PlutoColumn> polCols = [];

  // bool isLoading = false;
  ValueNotifier selectedCamp = ValueNotifier("");
  ValueNotifier selectedValue = ValueNotifier("");
  Color currentColor = Color.fromARGB(255, 225, 65, 65);
  Color selectedColor = Colors.grey;
  bool isDesktop = false;
  DocumentCategory? selectedCategory;
  late final TreeController<MyNode> treeController;
  List<MyNode> roots = [];
  CategoriesController categoriesController = CategoriesController();
  TextEditingController searchController = TextEditingController();
  TextEditingController fromDateController =
      TextEditingController(text: Converters.startOfCurrentYearAsString());
  TextEditingController toDateController = TextEditingController(
      text: Converters.formatDate2(DateTime.now().toString()));
  late DocumentListProvider documentListProvider;
  late CalssificatonNameAndCodeProvider calssificatonNameAndCodeProvider;
  DocumentsController documentsController = DocumentsController();
  PlutoRow? selectedRow;
  TextEditingController descreptionController = TextEditingController();
  TextEditingController issueNoController = TextEditingController();
  TextEditingController classificationController = TextEditingController();
  TextEditingController keyWordController = TextEditingController();
  TextEditingController ref1Controller = TextEditingController();
  TextEditingController ref2Controller = TextEditingController();
  TextEditingController otherRefController = TextEditingController();
  TextEditingController organizationController = TextEditingController();
  TextEditingController followingController = TextEditingController();
  TextEditingController sortedByController = TextEditingController();
  String selectedDep = "";
  int selectedSortedType = -1;
  List<DepartmentModel> listOfDep = [];
  late PlutoGridStateManager stateManager;
  DocumentModel? documentModel;
  @override
  Future<void> didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    fillColumnTable();
    documentListProvider = context.read<DocumentListProvider>();
    calssificatonNameAndCodeProvider =
        context.read<CalssificatonNameAndCodeProvider>();
    if (treeNodes.isEmpty) {
      roots = <MyNode>[
        MyNode(title: '/', children: treeNodes, extra: null, isRoot: true),
      ];
      treeController = TreeController<MyNode>(
        roots: roots,
        childrenProvider: (MyNode node) => node.children,
      );
      await fetchData();
    }
    if (documentListProvider.issueNumber != null) {
      issueNoController.text = documentListProvider.issueNumber ?? "";
      // search();

      documentListProvider.setDocumentSearchCriterea(SearchDocumentCriteria(
          issueNo: issueNoController.text,
          fromIssueDate: "",
          toIssueDate: "",
          page: -1));
    }
    // listOfDep =
    // setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text(_locale.documentExplorer),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Adding some spacing between search field and tree
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.start,
                    crossAxisAlignment:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                    children: [
                      context.read<DocumentListProvider>().isViewFile == true
                          ? SizedBox.shrink()
                          : Container(
                              width: width * 0.35,
                              height: height * 0.34,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomSearchField(
                                    label: _locale.search,
                                    width: width * 0.3,
                                    padding: 8,
                                    controller: searchController,
                                    onChanged: (value) {
                                      searchTree(value);
                                      // Add search functionality if needed
                                    },
                                  ),
                                  Expanded(child: treeSection()),
                                ],
                              ),
                            ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      fillterSection()
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [tableSection()],
                )
              ],
            ),
          ),
        ));
  }

  Widget tableSection() {
    return Column(
      children: [
        SizedBox(
          height: 3,
        ),
        ElevatedButton(
          onPressed: () async {
            if (documentModel != null) {
              // Fetch templates based on department
              List<WorkFlowDocumentInfo> result =
                  await WorkFlowTemplateContoller().getWorkFlowDocumentInfo(
                      WorkFlowDocumentModel(
                          documentCode: documentModel!.txtKey));

              if (result.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ErrorDialog(
                      icon: Icons.error,
                      errorDetails: "Error",
                      errorTitle: "No workflow template data available.",
                      color: Colors.red,
                      statusCode: 400,
                    );
                  },
                );
                return;
              }

              await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return EditTemplateDocumentDialog(
                    workFlowTemplateBody: result,
                  );
                },
              ).then((value) {
                // Handle dialog result if needed
                if (value == true) {
                  // Perform post-dialog actions if required
                }
              });
            }
          },
          style: customButtonStyle(
              Size(isDesktop ? width * 0.1 : width * 0.19, height * 0.043),
              14,
              primary),
          child: Text(
           _locale.viewApprovals,
            style: const TextStyle(color: whiteColor),
          ),
        ),
        TableComponent(
          key: UniqueKey(),
          tableHeigt: height * 0.45,
          tableWidth: width * 0.81,
          addReminder: context.read<DocumentListProvider>().isViewFile == true
              ? null
              : addRemider,
          upload: context.read<DocumentListProvider>().isViewFile == true
              ? null
              : uploadFile,

          copy: context.read<DocumentListProvider>().isViewFile == true
              ? null
              : copyFile,
          delete: context.read<DocumentListProvider>().isViewFile == true
              ? null
              : deleteFile,
          genranlEdit: context.read<DocumentListProvider>().isViewFile == true
              ? null
              : editDocumentInfo,
          exportToExcel: exportToExecl,
          // add: addAction,
          // genranlEdit: editAction,
          plCols: polCols,
          mode: PlutoGridMode.selectWithOneTap,
          polRows: [],
          footerBuilder: (stateManager) {
            return lazyLoadingfooter(stateManager);
          },
          explor: explorFiels,
          view: viewDocumentInfo,
          download: download,
          filesList: context.read<DocumentListProvider>().isViewFile == true
              ? fileViewScreen
              : null,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;

            stateManager.setShowColumnFilter(true);
            // pageLis.value = pageLis.value > 1 ? 0 : 1;
            // totalActionsCount.value = 0;
            // getCount();
          },
          doubleTab: (event) async {
            PlutoRow? tappedRow = event.row;
            documentModel = DocumentModel.fromPlutoRow(tappedRow!);
          },
          onSelected: (event) async {
            PlutoRow? tappedRow = event.row;
            selectedRow = tappedRow;
            documentModel = DocumentModel.fromPlutoRow(selectedRow!);
          },
        ),
      ],
    );
  }

  Future<void> exportToExecl() async {
    final excel = Excel.createExcel(); // Create a new Excel workbook
    final sheet = excel['Sheet1']; // Access the first sheet

    if (stateManager == null) return;

    // Extract columns and rows
    List<String> headers = stateManager!.columns.map((column) {
      return column.title ?? '';
    }).toList();

    // Append headers as the first row
    sheet.appendRow(headers);
    List<PlutoRow> temp = [];
    SearchDocumentCriteria searchDocumentCriteria = SearchDocumentCriteria();
    searchDocumentCriteria.fromIssueDate =
        documentListProvider.issueNumber != null
            ? null
            : fromDateController.text;
    searchDocumentCriteria.toIssueDate =
        documentListProvider.issueNumber != null ? null : toDateController.text;

    searchDocumentCriteria.desc = descreptionController.text;

    searchDocumentCriteria.issueNo = issueNoController.text;

    searchDocumentCriteria.dept = selectedDep;
    searchDocumentCriteria.keywords = keyWordController.text;
    searchDocumentCriteria.ref1 = ref1Controller.text;
    searchDocumentCriteria.ref2 = ref2Controller.text;
    searchDocumentCriteria.otherRef = otherRefController.text;
    searchDocumentCriteria.cat =
        calssificatonNameAndCodeProvider.classificatonKey;

    searchDocumentCriteria.organization = organizationController.text;
    searchDocumentCriteria.following = followingController.text;
    searchDocumentCriteria.sortedBy = selectedSortedType;

    searchDocumentCriteria.page = -1;
    // documentListProvider.setIsSearch(true);

    // documentListProvider.setDocumentSearchCriterea(searchDocumentCriteria);
    List<DocumentModel> result =
        await documentsController.searchDocCriterea(searchDocumentCriteria);
    // result = await documentsController
    //     .searchDocCriterea(documentListProvider.searchDocumentCriteria);
    for (int i = 0; i < result.length; i++) {
      temp.add(result[i].toPlutoRow(i));
    }
    List<List<String>> rows = temp.map((row) {
      return stateManager.columns.map((column) {
        return row.cells[column.field]?.value.toString() ?? '';
      }).toList();
    }).toList();

    // Append each row
    for (var row in rows) {
      sheet.appendRow(row);
    }

    // Convert the workbook to a list of bytes
    final excelBytes = excel.encode();

    // Create a blob from the bytes
    final blob = html.Blob([excelBytes!],
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

    // Create a URL for the blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create an anchor element and trigger the download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'exported_data.xlsx')
      ..click();

    // Clean up
    html.Url.revokeObjectUrl(url);
  }

  Widget fillterSection() {
    return Container(
      width: context.read<DocumentListProvider>().isViewFile == true
          ? width * 0.81
          : width * 0.44,
      height: height * 0.34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DateTimeComponent(
                          height: height * 0.04,
                          dateControllerToCompareWith: null,
                          isInitiaDate: true,
                          dateWidth:
                              context.read<DocumentListProvider>().isViewFile ==
                                      true
                                  ? width * 0.19
                                  : width * 0.1,
                          dateController: fromDateController,
                          label: _locale.fromDate,
                          onValue: (isValid, value) {
                            if (isValid) {
                              // setState(() {
                              fromDateController.text = value;
                              // });
                            }
                          },
                          timeControllerToCompareWith: null),
                      space(0.01),
                      DateTimeComponent(
                          dateControllerToCompareWith: null,
                          isInitiaDate: true,
                          height: height * 0.04,
                          dateWidth:
                              context.read<DocumentListProvider>().isViewFile ==
                                      true
                                  ? width * 0.19
                                  : width * 0.1,
                          dateController: toDateController,
                          label: _locale.toDate,
                          onValue: (isValid, value) {
                            if (isValid) {
                              // setState(() {
                              toDateController.text = value;
                              // });
                            }
                          },
                          timeControllerToCompareWith: null),
                    ],
                  ),
                  space(0.01),
                  DropDown(
                    key: UniqueKey(),
                    onChanged: (value) {
                      selectedDep = value.txtKey;
                      // setState(() {});
                    },
                    initialValue: selectedDep.isEmpty ? null : selectedDep,
                    bordeText: _locale.department,
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                    // items: listOfDep,
                    onSearch: (p0) async {
                      return await DepartmentController()
                          .search(SearchModel(page: 1, searchField: p0));
                    },
                  ),
                  space(0.01),
                  DropDown(
                    key: UniqueKey(),
                    onChanged: (value) {
                      selectedSortedType = getSortedByTyepsCode(_locale, value);
                    },
                    initialValue: selectedSortedType == -1
                        ? null
                        : getSortedByTyepsByCode(_locale, selectedSortedType),
                    bordeText: _locale.sortedBy,
                    items: getSortedByTyeps(_locale),
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.00001,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomTextField2(
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                    text: Text(_locale.description),
                    controller: descreptionController,
                  ),
                  space(0.01),
                  Consumer<CalssificatonNameAndCodeProvider>(
                    builder: (context, value, child) {
                      classificationController.text = value.classificatonName;

                      return CustomTextField2(
                        text: Text(_locale.classification),
                        controller: classificationController,
                        width:
                            context.read<DocumentListProvider>().isViewFile ==
                                    true
                                ? width * 0.19
                                : width * 0.1,
                        height: height * 0.04,
                        readOnly: true,
                      );
                    },
                  ),
                  space(0.01),
                  CustomTextField2(
                    text: Text(_locale.keyword),
                    controller: keyWordController,
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                  ),
                  space(0.01),
                  CustomTextField2(
                    text: Text(_locale.ref1),
                    controller: ref1Controller,
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.00001,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomTextField2(
                    text: Text(_locale.ref2),
                    controller: ref2Controller,
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                  ),
                  space(0.01),
                  CustomTextField2(
                    text: Text(_locale.otherRef),
                    controller: otherRefController,
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                  ),
                  space(0.01),
                  CustomTextField2(
                    text: Text(_locale.organization),
                    controller: organizationController,
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                  ),
                  space(0.01),
                  CustomTextField2(
                    text: Text(_locale.following),
                    controller: followingController,
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.00001,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // space(0.02),
                    CustomTextField2(
                      width: context.read<DocumentListProvider>().isViewFile ==
                              true
                          ? width * 0.19
                          : width * 0.1,
                      height: height * 0.04,
                      text: Text(_locale.issueNo),
                      controller: issueNoController,
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: height * 0.00001,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  search();
                },
                style: customButtonStyle(
                    Size(
                        isDesktop
                            ? context.read<DocumentListProvider>().isViewFile ==
                                    true
                                ? width * 0.14
                                : width * 0.1
                            : width * 0.19,
                        height * 0.043),
                    14,
                    primary),
                child: Text(
                  _locale.search,
                  style: const TextStyle(color: whiteColor),
                ),
              ),
              SizedBox(
                width: width * 0.01,
              ),
              ElevatedButton(
                onPressed: () {
                  resetForm();
                },
                style: customButtonStyle(
                    Size(
                        isDesktop
                            ? context.read<DocumentListProvider>().isViewFile ==
                                    true
                                ? width * 0.14
                                : width * 0.12
                            : width * 0.19,
                        height * 0.043),
                    14,
                    Colors.red),
                child: Text(
                  _locale.resetFilter,
                  style: const TextStyle(color: whiteColor),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> resetForm() async {
    fromDateController.text = Converters.startOfCurrentYearAsString();
    toDateController.text = Converters.formatDate2(DateTime.now().toString());
    descreptionController.clear();
    issueNoController.clear();
    classificationController.clear();
    keyWordController.clear();
    ref1Controller.clear();
    ref2Controller.clear();
    otherRefController.clear();
    organizationController.clear();
    followingController.clear();
    selectedDep = "";
    documentListProvider.setIssueNumber(null);
    selectedSortedType = -1;
    calssificatonNameAndCodeProvider.setSelectedClassificatonKey("");
    calssificatonNameAndCodeProvider.setSelectedClassificatonName("");
    documentListProvider.setIsSearch(false);
    documentListProvider.setPage(1);

    documentListProvider.setDocumentSearchCriterea(SearchDocumentCriteria());
    setState(() {});
  }

  Future<void> search() async {
    SearchDocumentCriteria searchDocumentCriteria = SearchDocumentCriteria();
    searchDocumentCriteria.fromIssueDate =
        documentListProvider.issueNumber != null
            ? null
            : fromDateController.text;
    searchDocumentCriteria.toIssueDate =
        documentListProvider.issueNumber != null ? null : toDateController.text;

    searchDocumentCriteria.desc = descreptionController.text;

    searchDocumentCriteria.issueNo = issueNoController.text;

    searchDocumentCriteria.dept = selectedDep;
    searchDocumentCriteria.keywords = keyWordController.text;
    searchDocumentCriteria.ref1 = ref1Controller.text;
    searchDocumentCriteria.ref2 = ref2Controller.text;
    searchDocumentCriteria.otherRef = otherRefController.text;
    searchDocumentCriteria.cat =
        calssificatonNameAndCodeProvider.classificatonKey;

    searchDocumentCriteria.organization = organizationController.text;
    searchDocumentCriteria.following = followingController.text;
    searchDocumentCriteria.sortedBy = selectedSortedType;

    searchDocumentCriteria.page = -1;
    documentListProvider.setIsSearch(true);

    // documentListProvider.setDocumentSearchCriterea(searchDocumentCriteria);
    List<DocumentModel> result =
        await documentsController.searchDocCriterea(searchDocumentCriteria);
    stateManager.setShowLoading(true);
    stateManager.removeAllRows();
    for (int i = 0; i < result.length; i++) {
      stateManager.appendRows([result[i].toPlutoRow(i + 1)]);
    }
    stateManager.setShowLoading(false);
    stateManager.notifyListeners();
  }

  Widget space(double width1) {
    return SizedBox(
      width: width * width1,
    );
  }

  void explorFiels() {
    if (selectedRow != null) {
      print(
          "selectedRow!.cells['txtKey']!.value ${selectedRow!.cells['txtDescription']!.value} ${selectedRow!.cells['txtKey']!.value}");
      openLoadinDialog(context);
      documentsController
          .getFilesByHdrKey(selectedRow!.cells['txtKey']!.value)
          .then((value) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return FileExplorDialog(listOfFiles: value);
          },
        );
      }).then((value) {
        // print("valuevaluevaluevaluevaluevaluevalue:${value}");
        // if (value != null) {
        //   // print("DONE");
        //   documentListProvider.setDocumentSearchCriterea(
        //       documentListProvider.searchDocumentCriteria);
        //   Navigator.pop(context);
        //   Navigator.pop(context);
        // }
      });
    }
  }

  void uploadFile() {
    if (selectedRow != null) {
      DocumentModel documentModel = DocumentModel.fromPlutoRow(selectedRow!);
      showDialog(
        context: context,
        builder: (context) {
          return AddFileDialog(documentModel: documentModel);
        },
      ).then((value) {
        if (value) {
          documentListProvider.searchDocumentCriteria.page = 0;
          documentListProvider.setDocumentSearchCriterea(
              documentListProvider.searchDocumentCriteria);
        }
      });
    }
  }

  fileViewScreen() {
    openLoadinDialog(context);
    documentsController
        .getFilesByHdrKey(selectedRow!.cells['txtKey']!.value)
        .then((value) {
      var encoded = base64Decode(value[0].imgBlob!);
      var bytes = Uint8List.fromList(encoded);
      Navigator.pop(context);
      if (value[0].txtFilename!.contains(".pdf") ||
          value[0].txtFilename!.contains(".jpeg") ||
          value[0].txtFilename!.contains(".png") ||
          value[0].txtFilename!.contains(".jpg")) {
        showDialog(
          context: context,
          builder: (context) {
            return PdfPreview1(
              pdfFile: bytes,
              fileName: value[0].txtFilename!,
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
                icon: Icons.error_outlined,
                errorDetails: _locale.previewNotAvilable,
                errorTitle: _locale.error,
                color: Colors.red,
                statusCode: 500);
          },
        );
      }
    });
  }

  void addRemider() {
    if (selectedRow != null) {
      ActionModel actionModel = ActionModel();
      actionModel.txtDescription = selectedRow!.cells['txtDescription']!.value;
      showDialog(
        context: context,
        builder: (context) {
          return AddEditActionDialog(
            title: _locale.addReminder,
            actionModel: actionModel,
            isFromList: true,
          );
        },
      ).then((value) {
        selectedRow = null;
      });
    }
  }

  Future<void> download() async {
    if (selectedRow != null) {
      try {
        FileUploadModel? file = await documentsController
            .getLatestFileMethod(selectedRow!.cells['txtKey']!.value);

        // Uint8List bytes = base64Decode(selectedRow!.cells['imgBlob']!.value);

        // String fileName = selectedRow!.cells['fileName']!.value;
        Uint8List bytes = base64Decode(file!.imgBlob!);

        String? fileName = file.txtFilename;
        saveExcelFile(bytes, fileName!);
      } catch (e) {
        print("Error downloading file: $e");
        // Handle error here
      }
    }
  }

  viewDocumentInfo() {
    if (selectedRow != null) {
      DocumentModel documentModel = DocumentModel.fromPlutoRow(selectedRow!);
      showDialog(
        context: context,
        builder: (context) {
          return InfoDocumentDialog(
            isEdit: false,
            documentModel: documentModel,
          );
        },
      ).then((value) {
        // selectedRow = null;
      });
    }
  }

  Future<void> deleteFile() async {
    if (selectedRow != null) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomConfirmDialog(
              confirmMessage: _locale.areYouSureToDelete(
                  selectedRow!.cells['txtDescription']!.value));
        },
      ).then((value) async {
        if (value) {
          DocumentModel documentModel =
              DocumentModel.fromPlutoRow(selectedRow!);
          var response =
              await documentsController.deleteDocument(documentModel);
          if (response.statusCode == 200) {
            // print("DONE");
            documentListProvider.searchDocumentCriteria.page = 0;
            setState(() {});
            // documentListProvider.setDocumentSearchCriterea(
            //     documentListProvider.searchDocumentCriteria);
          }
        }
      });
    }
  }

  void copyFile() async {
    if (selectedRow != null) {
      DocumentModel documentModel = DocumentModel.fromPlutoRow(selectedRow!);
      var response = await documentsController.copyDocument(documentModel);
      if (response.statusCode == 200) {
        // print("DONE");
        documentListProvider.searchDocumentCriteria.page = 0;
        setState(() {});
        // documentListProvider.setDocumentSearchCriterea(
        //     documentListProvider.searchDocumentCriteria);
      }
    }
  }

  editDocumentInfo() {
    if (selectedRow != null) {
      DocumentModel documentModel = DocumentModel.fromPlutoRow(selectedRow!);
      showDialog(
        context: context,
        builder: (context) {
          return InfoDocumentDialog(
            isEdit: true,
            documentModel: documentModel,
          );
        },
      ).then((value) {
        if (value) {
          documentListProvider.searchDocumentCriteria.page = 0;
          selectedRow = null;
          setState(() {});
          documentListProvider.setDocumentSearchCriterea(
              documentListProvider.searchDocumentCriteria);
        }
      });
    }
  }

  void fillColumnTable() {
    polCols.addAll([
      PlutoColumn(
        title: "#",
        field: "countNumber",
        enableFilterMenuItem: true,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.05 : width * 0.15,
        backgroundColor: columnColors,
        readOnly: true,
        renderer: (rendererContext) {
          return Center(child: Text((rendererContext.rowIdx + 1).toString()));
        },
      ),
      PlutoColumn(
        title: _locale.description,
        field: "txtDescription",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.16 : width * 0.4,
        backgroundColor: columnColors,
        enableFilterMenuItem: true,
      ),
      // PlutoColumn(
      //   title: _locale.dateCreated,
      //   field: "datCreationdate",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.35 : width * 0.2,
      //   backgroundColor: columnColors,
      // ),
      PlutoColumn(
        title: _locale.issueNo,
        field: "txtIssueno",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.24 : width * 0.2,
        backgroundColor: columnColors,
        enableFilterMenuItem: true,
      ),
      PlutoColumn(
        title: _locale.issueDate,
        field: "datIssuedate",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.1 : width * 0.2,
        backgroundColor: columnColors,
        enableFilterMenuItem: true,
      ),
      PlutoColumn(
        title: _locale.userCode,
        field: "txtUsercode",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.08 : width * 0.2,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.department,
        field: "txtDept",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.08 : width * 0.2,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.category,
        field: "txtCategory",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.08 : width * 0.2,
        backgroundColor: columnColors,
      ),
      // PlutoColumn(
      //   title: _locale.ref1,
      //   field: "ref1",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.35 : width * 0.2,
      //   backgroundColor: columnColors,
      // ),
      // PlutoColumn(
      //   title: _locale.ref2,
      //   field: "ref2",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.35 : width * 0.2,
      //   backgroundColor: columnColors,
      // ),
      // PlutoColumn(
      //   title: _locale.active,
      //   field: "imgBlob",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.35 : width * 0.2,
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

  List<PlutoRow> rowList = [];
  ValueNotifier<int> pageLis = ValueNotifier(1);

  Future<PlutoInfinityScrollRowsResponse> fetch(
      PlutoInfinityScrollRowsRequest request) async {
    bool isLast = false;

    // if (documentListProvider.searchDocumentCriteria.fromIssueDate != null &&
    //     documentListProvider.searchDocumentCriteria.page! <= 1) {
    //   stateManager.removeAllRows();
    //   rowList.clear();
    // }
    print("documentListProvider.isSearch ${documentListProvider.isSearch}");
    print(
        "documentListProvider.searchDocumentCriteria.page ${documentListProvider.searchDocumentCriteria.page}");
    if (documentListProvider.issueNumber == null) {
      if (documentListProvider.isSearch) {
        print("SSSSSSDDDDDDDDDDD");
        List<PlutoRow> searchList = [];
        documentListProvider.searchDocumentCriteria.fromIssueDate =
            documentListProvider.issueNumber != null
                ? null
                : fromDateController.text;
        documentListProvider.searchDocumentCriteria.toIssueDate =
            documentListProvider.issueNumber != null
                ? null
                : toDateController.text;

        documentListProvider.searchDocumentCriteria.desc =
            descreptionController.text;

        documentListProvider.searchDocumentCriteria.issueNo =
            issueNoController.text;

        documentListProvider.searchDocumentCriteria.dept = selectedDep;
        documentListProvider.searchDocumentCriteria.keywords =
            keyWordController.text;
        documentListProvider.searchDocumentCriteria.ref1 = ref1Controller.text;
        documentListProvider.searchDocumentCriteria.ref2 = ref2Controller.text;
        documentListProvider.searchDocumentCriteria.otherRef =
            otherRefController.text;
        documentListProvider.searchDocumentCriteria.cat =
            calssificatonNameAndCodeProvider.classificatonKey;

        documentListProvider.searchDocumentCriteria.organization =
            organizationController.text;
        documentListProvider.searchDocumentCriteria.following =
            followingController.text;
        documentListProvider.searchDocumentCriteria.sortedBy =
            selectedSortedType;
        // rowList.clear();
        if (documentListProvider.searchDocumentCriteria.page == 0) {
          stateManager.removeAllRows();
          documentListProvider.searchDocumentCriteria.page = 1;
        } else {
          documentListProvider.searchDocumentCriteria.page = -1;
        }
        List<DocumentModel> result = [];

        result = await documentsController
            .searchDocCriterea(documentListProvider.searchDocumentCriteria);

        for (int i =
                documentListProvider.searchDocumentCriteria.page != -1 ? 0 : 50;
            i < result.length;
            i++) {
          PlutoRow row = result[i].toPlutoRow(i + 1);
          // rowList.add(row);
          searchList.add(row);
        }

        await Future.delayed(const Duration(milliseconds: 500));

        return Future.value(PlutoInfinityScrollRowsResponse(
          isLast: documentListProvider.searchDocumentCriteria.page == -1
              ? true
              : false,
          rows: [],
        ));
      } else {
        print(11111111111);
        if (documentListProvider.searchDocumentCriteria.page == 1) {
          documentListProvider.searchDocumentCriteria.page = -1;
        } else {
          documentListProvider.searchDocumentCriteria.page = 1;
        }

        List<DocumentModel> result = [];
        List<PlutoRow> topList = [];

        result = await documentsController
            .searchDocCriterea(documentListProvider.searchDocumentCriteria);

        int currentPage = documentListProvider.page!; //1

        for (int i =
                documentListProvider.searchDocumentCriteria.page != -1 ? 0 : 50;
            i < result.length;
            i++) {
          int rowIndex = (currentPage - 1) * result.length + (i + 1);
          PlutoRow row = result[i].toPlutoRow(rowList.length + 1);
          rowList.add(row);
          topList.add(row);
        }

        isLast = topList.isEmpty;

        await Future.delayed(const Duration(milliseconds: 500));

        return Future.value(PlutoInfinityScrollRowsResponse(
          isLast: documentListProvider.searchDocumentCriteria.page == -1
              ? true
              : false,
          rows: topList.toList(),
        ));
        // }
      }
    } else {
      List<PlutoRow> searchList = [];
      print("INNNNNNNNNNNNELLLLLLLLLLLL");
      // rowList.clear();
      documentListProvider.searchDocumentCriteria.page = -1;

      List<DocumentModel> result = [];
      documentListProvider.searchDocumentCriteria.fromIssueDate = null;
      documentListProvider.searchDocumentCriteria.toIssueDate = null;
      documentListProvider.searchDocumentCriteria.issueNo =
          documentListProvider.issueNumber;

      result = await documentsController
          .searchDocCriterea(documentListProvider.searchDocumentCriteria);

      for (int i = 0; i < result.length; i++) {
        PlutoRow row = result[i].toPlutoRow(i + 1);
        // rowList.add(row);
        searchList.add(row);
      }

      await Future.delayed(const Duration(milliseconds: 500));

      return Future.value(PlutoInfinityScrollRowsResponse(
        isLast: false,
        rows: searchList.toList(),
      ));
    }
    // return Future.value(PlutoInfinityScrollRowsResponse(
    //     isLast: documentListProvider.searchDocumentCriteria.page == -1
    //         ? true
    //         : false,
    //     rows: []));
  }

  Widget treeSection() {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, value, child) {
        return isLoading.value
            ? Center(
                child: SpinKitCircle(
                  color: Theme.of(context).primaryColor,
                  size: 50.0,
                ),
              )
            : TreeView<MyNode>(
                key: ValueKey(treeController),
                treeController: treeController,
                nodeBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
                  return MyTreeTile(
                    onPointerDown: (p0) {},
                    key: ValueKey(entry.node),
                    entry: entry,
                    folderOnTap: () {
                      if (entry.node.children.isNotEmpty) {
                        selectedCategory = entry.node.extra;
                        selectedCamp.value =
                            selectedCategory!.docCatParent!.txtDescription!;

                        selectedValue.value =
                            selectedCategory!.docCatParent!.txtShortcode;
                        calssificatonNameAndCodeProvider
                            .setSelectedClassificatonName(selectedCamp.value);
                        calssificatonNameAndCodeProvider
                            .setSelectedClassificatonKey(
                                selectedCategory!.docCatParent!.txtKey!);
                        treeController.toggleExpansion(entry.node);
                      } else {
                        selectedCategory = entry.node.extra;
                        selectedCamp.value =
                            selectedCategory!.docCatParent!.txtDescription!;
                        selectedValue.value =
                            selectedCategory!.docCatParent!.txtShortcode;
                      }
                    },
                    textWidget: nodeDesign(entry.node),
                  );
                },
              );
      },
    );
  }

  void searchTree(String query) {
    if (query == "") {
      selectedCamp.value = "";
      selectedValue.value = "";

      treeController.roots = [];
      treeNodes = [];
      treeController.collapseAll();
      convertToTreeList(campClassificationList);
      MyNode node =
          MyNode(title: '/', children: treeNodes, extra: null, isRoot: true);
      treeController.toggleExpansion(node);
      treeController.roots = <MyNode>[node];
      treeController.notifyListeners();
      // setState(() {});
    } else {
      for (final node in treeNodes) {
        if (searchNode(node, query)) {
          print("INNNNNNNNN SEEEEEEAAAAAAAAAARCH");
          // selectedCategory = node;
          selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
          selectedValue.value = selectedCategory!.docCatParent!.txtShortcode;

          treeController.roots = [];
          treeNodes = [];

          convertToTreeList(campClassificationList);
          MyNode node = MyNode(
              title: '/', children: treeNodes, extra: null, isRoot: true);
          treeController.toggleExpansion(node);
          treeController.roots = <MyNode>[node];
          // setState(() {});
          treeController.notifyListeners();

          break;
        }
      }
    }
  }

  bool searchNode(MyNode node, String query) {
    if (node.title.contains(query)) {
      selectedCategory = node.extra;
      selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
      selectedValue.value = selectedCategory!.docCatParent!.txtShortcode;
      return true;
    }
    for (final child in node.children) {
      if (searchNode(child, query)) {
        return true;
      }
    }
    return false;
  }

  Widget nodeDesign(MyNode node) {
    return SizedBox(
      width: node.isRoot ? 200 : 200,
      child: InkWell(
        onTap: () {
          // documentListProvider
          //     .setDocumentSearchCriterea(SearchDocumentCriteria());

          selectedCategory = node.extra;
          selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
          selectedValue.value = selectedCategory!.docCatParent!.txtShortcode;
          calssificatonNameAndCodeProvider
              .setSelectedClassificatonName(selectedCamp.value);
          calssificatonNameAndCodeProvider.setSelectedClassificatonKey(
              selectedCategory!.docCatParent!.txtKey!);
          treeController.notifyListeners();
          documentListProvider.setDocumentSearchCriterea(SearchDocumentCriteria(
              page: -1, cat: selectedCategory!.docCatParent!.txtKey!));

          treeController.toggleExpansion(node);
          // setState(() {});
        },
        onDoubleTap: () {
          if (!node.isRoot && node.children.isEmpty) {
            selectedCategory = node.extra;
            selectedCamp.value =
                selectedCategory!.docCatParent!.txtDescription!;
          }
        },
        child: ValueListenableBuilder(
          valueListenable: selectedValue,
          builder: (context, value, child) {
            return Text(
              node.title,
              style: TextStyle(
                fontSize: 14,
                color: getColor(node.extra, value.toString())
                    ? currentColor
                    : Colors.black,
              ),
            );
          },
        ),
      ),
    );
  }

  List<DocumentCategory> campClassificationList = [];
  List<DocumentCategory> children = [];
  Future<void> fetchData() async {
    // setState(() {
    //   isLoading = true;
    // });
    isLoading.value = true;
    campClassificationList = await categoriesController.getCategoriesTree();

    convertToTreeList(campClassificationList);

    children = [];
    for (int i = 0; i < campClassificationList.length; i++) {
      children.addAll(getChildren(campClassificationList[i]));
    }
    treeController.toggleExpansion(roots.first);
  }

  ValueNotifier isLoading = ValueNotifier(false);
  void convertToTreeList(List<DocumentCategory> result) {
    for (int i = 0; i < result.length; i++) {
      treeNodes.add(getNodes(result[i]));
    }
    isLoading.value = false;
    // setState(() {
    //   isLoading = false;
    // });
  }

  MyNode getNodes(DocumentCategory data) {
    MyNode node = MyNode(
      title:
          "${data.docCatParent!.txtShortcode}@${data.docCatParent!.txtDescription!}",
      extra: data,
      isRoot: false,
      children: List.from(data.docCatChildren!.map((x) => getNodes(x))),
    );
    treeController.setExpansionState(node, checkChildren(data));
    return node;
  }

  bool checkChildren(DocumentCategory data) {
    if (selectedCategory != null &&
        selectedCategory!.docCatParent!.txtShortcode ==
            data.docCatParent!.txtShortcode) {
      return true;
    }
    if (data.docCatChildren != null) {
      for (int i = 0; i < data.docCatChildren!.length; i++) {
        if (checkChildren(data.docCatChildren![i])) {
          return true;
        }
      }
    }
    return false;
  }

  List<DocumentCategory> getChildren(DocumentCategory data) {
    List<DocumentCategory> discountList = [];
    if (data.docCatChildren!.isEmpty) {
      discountList.add(data);
      return discountList;
    }
    if (data.docCatChildren != null) {
      for (int i = 0; i < data.docCatChildren!.length; i++) {
        List<DocumentCategory> childList = getChildren(data.docCatChildren![i]);
        discountList.addAll(childList);
      }
    }
    return discountList;
  }

  bool getColor(DocumentCategory? current, String value) {
    if (current != null) {
      String code = current.docCatParent!.txtShortcode!;
      return value.compareTo(code) == 0;
    }
    return false;
  }

  @override
  void dispose() {
    documentListProvider.setDocumentSearchCriterea(SearchDocumentCriteria());
    // TODO: implement dispose
    super.dispose();
  }
}
