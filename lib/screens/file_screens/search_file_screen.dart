import 'package:archiving_flutter_project/dialogs/actions_dialogs/add_edit_action_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/add_file_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/file_explor_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/info_document_dialogs.dart';
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
    return TableComponent(
      key: UniqueKey(),
      tableHeigt: height * 0.85,
      tableWidth: width * 0.85,

      download: downLoad,
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
  }

  void downLoad() {}

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

  void deleteFile() {
    if (selectedRow != null) {}
  }

  void copyFile() async {
    if (selectedRow != null) {
      DocumentModel documentModel = DocumentModel.fromPlutoRow(selectedRow!);
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
          // documentListProvider.setDocumentSearchCriterea(
          //     documentListProvider.searchDocumentCriteria);
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
      PlutoColumn(
        title: _locale.issueNo,
        field: "txtIssueno",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.28 : width * 0.2,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
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
      stateManager.removeAllRows();
      stateManager.appendRows(rowList);
    } else if (isSearch.value) {
      List<DocumentModel> result = [];
      List<PlutoRow> topList = [];
      result = await documentsController
          .searchByContent(SearchDocumentCriteria(searchField: text.trim()));
      if (documentListProvider.searchDocumentCriteria.page! >= 1) {
        documentListProvider.searchDocumentCriteria.page =
            documentListProvider.searchDocumentCriteria.page! + 1;
      } else {
        stateManager.removeAllRows();
        // rowList.clear();
        // rowList = [];
      }
      for (int i = 0; i < result.length; i++) {
        // rowList.add(result[i].toPlutoRow(i + 1));
        topList.add(result[i].toPlutoRow(rowList.length));
      }
      stateManager.removeAllRows();
      stateManager.appendRows(topList);
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
    // if (documentListProvider.searchDocumentCriteria.fromIssueDate != null &&
    //     documentListProvider.searchDocumentCriteria.page! <= 1) {
    //   stateManager.removeAllRows();
    //   rowList.clear();
    // }

    if (!isSearch.value) {
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
    return Future.value(
        PlutoInfinityScrollRowsResponse(isLast: isLast, rows: []));
  }
}
