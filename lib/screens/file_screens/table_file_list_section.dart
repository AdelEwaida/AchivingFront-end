import 'dart:convert';
import 'dart:typed_data';
import 'package:archiving_flutter_project/dialogs/actions_dialogs/add_edit_action_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/add_file_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/file_explor_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/info_document_dialogs.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/models/db/actions_models/action_model.dart';
import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/providers/classification_name_and_code_provider.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/loading.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../utils/func/save_excel_file.dart';

class TableFileListSection extends StatefulWidget {
  const TableFileListSection({super.key});

  @override
  State<TableFileListSection> createState() => _TableFileListSectionState();
}

class _TableFileListSectionState extends State<TableFileListSection> {
  List<PlutoColumn> polCols = [];
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  late CalssificatonNameAndCodeProvider calssificatonNameAndCodeProvider;
  DocumentsController documentsController = DocumentsController();
  late DocumentListProvider documentListProvider;
  late PlutoGridStateManager stateManager;
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
    return Consumer<DocumentListProvider>(
      builder: (context, value, child) {
        return TableComponent(
          key: UniqueKey(),
          tableHeigt: height * 0.45,
          tableWidth: width * 0.81,
          addReminder: addRemider,
          upload: uploadFile,

          copy: copyFile,
          delete: deleteFile,
          download: download,
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
          genranlEdit: editDocumentInfo,
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
        );
      },
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
            actionModel: actionModel,
            isFromList: true,
          );
        },
      );
    }
  }

  Future<void> download() async {
    if (selectedRow != null) {
      try {
        Uint8List bytes = base64Decode(selectedRow!.cells['imgBlob']!.value);

        String fileName = selectedRow!.cells['fileName']!.value;

        saveExcelFile(bytes, fileName);
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
      );
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
            documentListProvider.setDocumentSearchCriterea(
                documentListProvider.searchDocumentCriteria);
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
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.05 : width * 0.15,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.description,
        field: "txtDescription",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.16 : width * 0.4,
        backgroundColor: columnColors,
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
        width: isDesktop ? width * 0.28 : width * 0.2,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.issueDate,
        field: "datIssuedate",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.35 : width * 0.2,
        backgroundColor: columnColors,
      ),
      // PlutoColumn(
      //   title: _locale.userCode,
      //   field: "txtUsercode",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.35 : width * 0.2,
      //   backgroundColor: columnColors,
      // ),
      // PlutoColumn(
      //   title: _locale.arrivalDate,
      //   field: "datArrvialdate",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.35 : width * 0.2,
      //   backgroundColor: columnColors,
      // ),
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

  Future<PlutoInfinityScrollRowsResponse> fetch(
      PlutoInfinityScrollRowsRequest request) async {
    bool isLast = false;
    if (documentListProvider.searchDocumentCriteria.fromIssueDate != null &&
        documentListProvider.searchDocumentCriteria.page! <= 1) {
      stateManager.removeAllRows();
      rowList.clear();
    }
    List<DocumentModel> result = [];
    List<PlutoRow> topList = [];
    result = await documentsController
        .searchDocCriterea(documentListProvider.searchDocumentCriteria);
    if (documentListProvider.searchDocumentCriteria.page! >= 1) {
      documentListProvider.searchDocumentCriteria.page =
          documentListProvider.searchDocumentCriteria.page! + 1;
    } else {
      rowList.clear();
      rowList = [];
    }
    for (int i = 0; i < result.length; i++) {
      rowList.add(result[i].toPlutoRow(i + 1));
      topList.add(result[i].toPlutoRow(rowList.length));
    }

    isLast = documentListProvider.searchDocumentCriteria.page == -1
        ? true
        : topList.isEmpty
            ? true
            : false;
    return Future.value(
        PlutoInfinityScrollRowsResponse(isLast: isLast, rows: topList));
  }
}
