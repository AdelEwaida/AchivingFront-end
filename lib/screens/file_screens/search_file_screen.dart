import 'dart:convert';
import 'dart:typed_data';

import 'package:archiving_flutter_project/dialogs/actions_dialogs/add_edit_action_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/add_file_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/file_explor_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/info_document_dialogs.dart';
import 'package:archiving_flutter_project/models/db/actions_models/action_model.dart';
import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/models/db/document_models/upload_file_mode.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_document_criterea.dart';
import 'package:archiving_flutter_project/providers/classification_name_and_code_provider.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/loading.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/utils/func/save_excel_file.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SearchFileScreen extends StatefulWidget {
  const SearchFileScreen({super.key});

  @override
  State<SearchFileScreen> createState() => _SearchFileScreenState();
}

class _SearchFileScreenState extends State<SearchFileScreen> {
  List<PlutoColumn> polCols = [];
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  late CalssificatonNameAndCodeProvider calssificatonNameAndCodeProvider;
  DocumentsController documentsController = DocumentsController();
  late DocumentListProvider documentListProvider;
  PlutoGridStateManager? stateManager;
  ValueNotifier isSearch = ValueNotifier(false);
  ValueNotifier pageLis = ValueNotifier(1);
  ValueNotifier totalDocCount = ValueNotifier(0);
  getCount() {
    documentsController
        .getDocInfoCount(SearchDocumentCriteria(page: -1))
        .then((value) {
      totalDocCount.value = value;
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
        title: Text(_locale.searchByContnet),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
                width: isDesktop ? width * 0.8 : width * 0.9,
                // height: height * 0.5,
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(30),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black.withOpacity(0.2),
                //       spreadRadius: 1,
                //       blurRadius: 5,
                //     ),
                //   ],
                // ),
                child: TableComponent(
                  // key: UniqueKey(),
                  tableHeigt: height * 0.75,
                  tableWidth: width * 0.85,

                  download: download,
                  plCols: polCols,
                  mode: PlutoGridMode.selectWithOneTap,
                  polRows: [],
                  footerBuilder: (stateManager) {
                    return lazyLoadingfooter(stateManager);
                  },
                  search: search,
                  // explor: explorFiels,
                  view: viewDocumentInfo,
                  // genranlEdit: editDocumentInfo,
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    stateManager = event.stateManager;
                    stateManager!.setShowColumnFilter(true);
                    // pageLis.value = pageLis.value > 1 ? 0 : 1;
                    // totalActionsCount.value = 0;
                    getCount();
                  },
                  doubleTab: (event) async {
                    PlutoRow? tappedRow = event.row;
                  },
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
                      valueListenable: totalDocCount,
                      builder: ((context, value, child) {
                        return Text(
                          "${totalDocCount.value}",
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
      ),
    );
  }

  Future<void> download() async {
    if (selectedRow != null) {
      try {
        FileUploadModel? file = await documentsController
            .getLatestFileMethod(selectedRow!.cells['txtKey']!.value);

        // Uint8List bytes = base64Decode(selectedRow!.cells['imgBlob']!.value);

        // String fileName = selectedRow!.cells['fileName']!.value;
        Uint8List bytes = base64Decode(file!.imgBlob!);

        String? fileName = file.txtFilename!;
        saveExcelFile(bytes, fileName!);
      } catch (e) {
        print("Error downloading file: $e");
        // Handle error here
      }
    }
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
      });
    }
  }

  void uploadFile() {
    if (selectedRow != null) {
      DocumentModel documentModel =
          DocumentModel.fromPlutoRow(selectedRow!, _locale);
      showDialog(
        context: context,
        builder: (context) {
          return AddFileDialog(documentModel: documentModel);
        },
      );
    }
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
      );
    }
  }

  viewDocumentInfo() {
    if (selectedRow != null) {
      DocumentModel documentModel =
          DocumentModel.fromPlutoRow(selectedRow!, _locale);
      showDialog(
        context: context,
        builder: (context) {
          return InfoDocumentDialog(
            isEdit: false,
            documentModel: documentModel,
          );
        },
      );
    }
  }

  void deleteFile() {
    if (selectedRow != null) {}
  }

  void copyFile() async {
    if (selectedRow != null) {
      DocumentModel documentModel =
          DocumentModel.fromPlutoRow(selectedRow!, _locale);
      var response = await documentsController.copyDocument(documentModel);
      if (response.statusCode == 200) {
        // print("DONE");
        documentListProvider.setDocumentSearchCriterea(
            documentListProvider.searchDocumentCriteria);
      }
    }
  }

  editDocumentInfo() {
    if (selectedRow != null) {
      DocumentModel documentModel =
          DocumentModel.fromPlutoRow(selectedRow!, _locale);
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
          documentListProvider.setDocumentSearchCriterea(
              documentListProvider.searchDocumentCriteria);
        }
      });
    }
  }

  void fillColumnTable() {
    polCols.addAll([
      PlutoColumn(
        enableFilterMenuItem: true,
        title: "#",
        field: "countNumber",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.05 : width * 0.15,
        backgroundColor: columnColors,
        renderer: (rendererContext) {
          return Center(
            child: Text((rendererContext.rowIdx + 1).toString()),
          );
        },
      ),
      PlutoColumn(
        enableFilterMenuItem: true,
        title: _locale.description,
        field: "txtDescription",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.16 : width * 0.4,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        enableFilterMenuItem: true,
        title: _locale.issueNo,
        field: "txtIssueno",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.28 : width * 0.2,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        enableFilterMenuItem: true,
        title: _locale.dateCreated,
        field: "datIssuedate",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.35 : width * 0.2,
        backgroundColor: columnColors,
      ),
    ]);
  }

  search(String text) async {
    isSearch.value = true;
    print(text);
    if (text.trim().isEmpty) {
      isSearch.value = false;
      stateManager!.removeAllRows();
      stateManager!.appendRows(rowList);
    } else if (isSearch.value) {
      List<DocumentModel> result = [];
      List<PlutoRow> topList = [];
      result = await documentsController.searchByContent(
          SearchDocumentCriteria(searchField: text.trim(), page: -1));
      if (documentListProvider.searchDocumentCriteria.page! >= 1) {
        documentListProvider.searchDocumentCriteria.page =
            documentListProvider.searchDocumentCriteria.page! + 1;
      } else {
        stateManager!.removeAllRows();
        // rowList.clear();
        // rowList = [];
      }
      for (int i = 0; i < result.length; i++) {
        // rowList.add(result[i].toPlutoRow(i + 1));
        topList.add(result[i].toPlutoRow(rowList.length, _locale));
      }
      stateManager!.removeAllRows();
      stateManager!.appendRows(topList);
    }
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

  Future<PlutoInfinityScrollRowsResponse> fetch(
      PlutoInfinityScrollRowsRequest request) async {
    bool isLast = false;

    if (!isSearch.value) {
      List<DocumentModel> result = [];
      List<PlutoRow> topList = [];

      // Fetch data for current page
      result = await documentsController
          .searchDocCriterea(SearchDocumentCriteria(page: pageLis.value));

      // Convert to PlutoRows
      for (int i = 0; i < result.length; i++) {
        final index = rowList.length + 1;
        final row = result[i].toPlutoRow(index, _locale);
        rowList.add(row);
        topList.add(row);
      }

      // Increment page number for next fetch
      pageLis.value++;

      // If no more rows returned, set isLast to true
      if (result.isEmpty) {
        isLast = true;
      }

      return PlutoInfinityScrollRowsResponse(isLast: isLast, rows: topList);
    }

    return PlutoInfinityScrollRowsResponse(isLast: true, rows: []);
  }
}
