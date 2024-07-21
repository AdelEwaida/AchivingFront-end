import 'dart:convert';
import 'dart:typed_data';
import 'package:archiving_flutter_project/dialogs/actions_dialogs/add_edit_action_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/add_file_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/file_explor_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/files_view_dilaog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/info_document_dialogs.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/dialogs/pdf_preview.dart';
import 'package:archiving_flutter_project/models/db/actions_models/action_model.dart';
import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_document_criterea.dart';
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
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../models/db/document_models/upload_file_mode.dart';
import '../../utils/func/save_excel_file.dart';

class ViewTable extends StatefulWidget {
  const ViewTable({super.key});

  @override
  State<ViewTable> createState() => _ViewTableState();
}

class _ViewTableState extends State<ViewTable> {
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
    if (documentListProvider.issueNumber != null) {
      documentListProvider.setDocumentSearchCriterea(
          SearchDocumentCriteria(issueNo: documentListProvider.issueNumber));
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    documentListProvider.setIssueNumber(null);

    super.dispose();
  }

  PlutoRow? selectedRow;
  @override
  Widget build(BuildContext context) {
    return TableComponent(
      // key: UniqueKey(),
      tableHeigt: height * 0.8,
      tableWidth: width * 0.81,
      // addReminder: addRemider,
      // upload: uploadFile,

      // copy: copyFile,
      // delete: deleteFile,
      download: download,
      // add: addAction,
      // genranlEdit: editAction,
      filesList: fileViewScreen,
      plCols: polCols,
      mode: PlutoGridMode.selectWithOneTap,
      polRows: [],
      footerBuilder: (stateManager) {
        return lazyLoadingfooter(stateManager);
      },
      explor: explorFiels,
      view: viewDocumentInfo,
      // genranlEdit: editDocumentInfo,
      onLoaded: (PlutoGridOnLoadedEvent event) async {
        stateManager = event.stateManager;
        // stateManager.setShowLoading(true);
        stateManager.setShowColumnFilter(true);
      },
      rowColor: (p0) {
        if (p0.rowIdx == 0 && selectedRow!.sortIdx == p0.rowIdx) {
          return const Color.fromARGB(255, 37, 171, 233).withOpacity(0.5);
        } else {
          return Colors.white;
        }
      },
      doubleTab: (event) async {
        PlutoRow? tappedRow = event.row;
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
      },
      onSelected: (event) async {
        selectedRow = event.row;
      },
    );
  }

  void explorFiels() {
    if (selectedRow != null) {
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
      );
    }
  }

  fileViewScreen() {
    openLoadinDialog(context);
    documentsController
        .getFilesByHdrKey(selectedRow!.cells['txtKey']!.value)
        .then((value) {
      print("test test stest :${value[0]}");
      var encoded = base64Decode(value[0].imgBlob!);
      var bytes = Uint8List.fromList(encoded);
      Navigator.pop(context);
      if (selectedRow!.cells['txtFilename']!.value.contains(".pdf") ||
          selectedRow!.cells['txtFilename']!.value.contains(".jpeg") ||
          selectedRow!.cells['txtFilename']!.value.contains(".png") ||
          selectedRow!.cells['txtFilename']!.value.contains(".jpg")) {
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
        documentListProvider.searchDocumentCriteria.page = 0;
        documentListProvider.setDocumentSearchCriterea(
            documentListProvider.searchDocumentCriteria);
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
        width: isDesktop ? width * 0.28 : width * 0.2,
        backgroundColor: columnColors,
        enableFilterMenuItem: true,
      ),
      PlutoColumn(
        title: _locale.issueDate,
        field: "datIssuedate",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.313 : width * 0.2,
        backgroundColor: columnColors,
        enableFilterMenuItem: true,
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
  ValueNotifier<int> pageLis = ValueNotifier(1);

  Future<PlutoInfinityScrollRowsResponse> fetch(
      PlutoInfinityScrollRowsRequest request) async {
    bool isLast = false;

    // if (documentListProvider.searchDocumentCriteria.fromIssueDate != null &&
    //     documentListProvider.searchDocumentCriteria.page! <= 1) {
    //   stateManager.removeAllRows();
    //   rowList.clear();
    // }

    if (documentListProvider.isSearch) {
      List<PlutoRow> searchList = [];

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
              documentListProvider.searchDocumentCriteria.page != -1 ? 0 : 10;
          i < result.length;
          i++) {
        PlutoRow row = result[i].toPlutoRow(i + 1);
        // rowList.add(row);
        // searchList.add(row);
        stateManager.appendRows([row]);
      }

      await Future.delayed(const Duration(milliseconds: 500));

      return Future.value(PlutoInfinityScrollRowsResponse(
        isLast: documentListProvider.searchDocumentCriteria.page == -1
            ? true
            : false,
        rows: searchList.toList(),
      ));
    } else {
      if (documentListProvider.searchDocumentCriteria.page == 1) {
        documentListProvider.searchDocumentCriteria.page = -1;
      } else {
        documentListProvider.searchDocumentCriteria.page = 1;
      }
      print(1);
      List<DocumentModel> result = [];
      List<PlutoRow> topList = [];
      print(2);

      result = await documentsController
          .searchDocCriterea(documentListProvider.searchDocumentCriteria);
      print(3);

      int currentPage = documentListProvider.page!; //1
      print(4);
      for (int i =
              documentListProvider.searchDocumentCriteria.page != -1 ? 0 : 10;
          i < result.length;
          i++) {
        int rowIndex = (currentPage - 1) * result.length + (i + 1);
        PlutoRow row = result[i].toPlutoRow(rowList.length + 1);
        // stateManager.appendRows([row]);
        rowList.add(row);
        topList.add(row);
      }
      selectedRow = rowList[0];
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
  }

  fetchData() async {
    List<DocumentModel> result = [];
    List<PlutoRow> topList = [];
    result = await documentsController
        .searchDocCriterea(documentListProvider.searchDocumentCriteria);
    for (int i = 0; i < result.length; i++) {
      stateManager.appendRows([result[i].toPlutoRow(i)]);
    }
  }
  // Future<PlutoInfinityScrollRowsResponse> fetch1(
  //     PlutoInfinityScrollRowsRequest request) async {
  //   bool isLast = false;
  //   if (documentListProvider.searchDocumentCriteria.fromIssueDate != null &&
  //       documentListProvider.searchDocumentCriteria.page! <= 1) {
  //     stateManager.removeAllRows();
  //     rowList.clear();
  //   }
  //   List<DocumentModel> result = [];
  //   List<PlutoRow> topList = [];
  //   result = await documentsController
  //       .searchDocCriterea(documentListProvider.searchDocumentCriteria);
  //   if (documentListProvider.searchDocumentCriteria.page! >= 1) {
  //     documentListProvider.searchDocumentCriteria.page =
  //         documentListProvider.searchDocumentCriteria.page! + 1;
  //   } else {
  //     rowList.clear();
  //     rowList = [];
  //   }
  //   for (int i = 0; i < result.length; i++) {
  //     rowList.add(result[i].toPlutoRow(i + 1));
  //     topList.add(result[i].toPlutoRow(rowList.length));
  //   }

  //   isLast = documentListProvider.searchDocumentCriteria.page == -1
  //       ? true
  //       : topList.isEmpty
  //           ? true
  //           : false;
  //   return Future.value(
  //       PlutoInfinityScrollRowsResponse(isLast: isLast, rows: topList));
  // }
}
