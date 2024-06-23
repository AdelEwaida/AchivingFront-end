import 'package:archiving_flutter_project/dialogs/document_dialogs/info_document_dialogs.dart';
import 'package:archiving_flutter_project/models/db/actions_models/action_model.dart';
import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/providers/classification_name_and_code_provider.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../service/controller/actions_controllers/action_controller.dart';
import '../../utils/func/dates_controller.dart';

class DailyReminders extends StatefulWidget {
  const DailyReminders({super.key});

  @override
  State<DailyReminders> createState() => _DailyRemindersState();
}

class _DailyRemindersState extends State<DailyReminders> {
  List<PlutoColumn> polCols = [];
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  ActionController actionController = ActionController();
  late PlutoGridStateManager stateManager;
  ValueNotifier isSearch = ValueNotifier(false);
  String todayDate = DatesController().formatDateReverse(
      DatesController().formatDate(DatesController().todayDate()));
  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    polCols = [];
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);

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
      plCols: polCols,
      mode: PlutoGridMode.selectWithOneTap,
      polRows: [],
      footerBuilder: (stateManager) {
        return lazyLoadingfooter(stateManager);
      },
      onLoaded: (PlutoGridOnLoadedEvent event) {
        stateManager = event.stateManager;
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

  void fillColumnTable() {
    polCols.addAll([
      // PlutoColumn(
      //   title: "#",
      //   field: "txtKey",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.05 : width * 0.15,
      //   backgroundColor: columnColors,
      // ),
      //txtCode
      // PlutoColumn(
      //   title: _locale.userCode,
      //   field: "txtServicecode",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.16 : width * 0.4,
      //   backgroundColor: columnColors,
      // ),
      PlutoColumn(
        title: _locale.description,
        field: "txtDescription",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.45 : width * 0.4,
        backgroundColor: columnColors,
      ),
      // PlutoColumn(
      //   title: _locale.date,
      //   field: "datDate",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.07 : width * 0.2,
      //   backgroundColor: columnColors,
      // ),
      PlutoColumn(
        title: _locale.notes,
        field: "txtNotes",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.36 : width * 0.2,
        backgroundColor: columnColors,
      ),
      // PlutoColumn(
      //   title: _locale.email,
      //   field: "txtDocumentcode",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.1 : width * 0.2,
      //   backgroundColor: columnColors,
      // ),
      // PlutoColumn(
      //   title: _locale.userCode,
      //   field: "txtUsercode",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.1 : width * 0.2,
      //   backgroundColor: columnColors,
      // ),
      // PlutoColumn(
      //   title: _locale.recurring,
      //   field: "intRecurring",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.1 : width * 0.2,
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
  ValueNotifier pageLis = ValueNotifier(1);
  Future<PlutoInfinityScrollRowsResponse> fetch(
      PlutoInfinityScrollRowsRequest request) async {
    bool isLast = false;

    if (!isSearch.value) {
      List<ActionModel> result = [];
      List<PlutoRow> topList = [];
      result = await actionController.getActionByDateMethod(todayDate);

      for (int i = 0; i < result.length; i++) {
        rowList.add(result[i].toPlutoRow(i + 1));
        topList.add(result[i].toPlutoRow(rowList.length));
      }

      isLast = topList.isEmpty;
      pageLis.value++; // Increment the page number for next fetch
      return Future.value(
          PlutoInfinityScrollRowsResponse(isLast: isLast, rows: topList));
    }
    return Future.value(
        PlutoInfinityScrollRowsResponse(isLast: isLast, rows: []));
  }
}
