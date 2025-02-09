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
  PlutoGridStateManager? stateManager;
  ValueNotifier isSearch = ValueNotifier(false);
  String todayDate = DatesController().formatDateReverse(
      DatesController().formatDate(DatesController().todayDate()));
  ValueNotifier totalDailySales = ValueNotifier(0);
  getCount() {
    actionController.getActionCountByDate(todayDate).then((value) {
      totalDailySales.value = value;
    });
  }

  @override
  void didChangeDependencies() {
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
    getCount();

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  PlutoRow? selectedRow;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _locale.dailyReminders,
        ),
      ),
      body: Center(
        child: Container(
          width: isDesktop ? width * 0.8 : width * 0.9,
          child: Column(
            children: [
              TableComponent(
                // key: UniqueKey(),
                isWhiteText: true,
                tableHeigt: height * 0.75,
                tableWidth: width * 0.85,
                plCols: polCols,
                mode: PlutoGridMode.selectWithOneTap,
                polRows: [],
                footerBuilder: (stateManager) {
                  return lazyLoadingfooter(stateManager);
                },
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  stateManager!.setShowColumnFilter(true);
                  getCount();
                },
                doubleTab: (event) async {
                  PlutoRow? tappedRow = event.row;
                },
                onSelected: (event) async {
                  PlutoRow? tappedRow = event.row;
                  selectedRow = tappedRow;
                },
              ),
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
                        valueListenable: totalDailySales,
                        builder: ((context, value, child) {
                          return Text(
                            "${totalDailySales.value}",
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
      ),
    );
    // return Padding(
    // padding: const EdgeInsets.all(8.0),
    // child: TableComponent(
    //   key: UniqueKey(),
    //   tableHeigt: height * 0.85,
    //   tableWidth: width * 0.85,
    //   plCols: polCols,
    //   mode: PlutoGridMode.selectWithOneTap,
    //   polRows: [],
    //   footerBuilder: (stateManager) {
    //     return lazyLoadingfooter(stateManager);
    //   },
    //   onLoaded: (PlutoGridOnLoadedEvent event) {
    //     stateManager = event.stateManager;
    //   },
    //   doubleTab: (event) async {
    //     PlutoRow? tappedRow = event.row;
    //   },
    //   onSelected: (event) async {
    //     PlutoRow? tappedRow = event.row;
    //     selectedRow = tappedRow;
    //   },
    // ),
    // );
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
      //txtCode
      // PlutoColumn(
      //   title: _locale.userCode,
      //   field: "txtServicecode",
      //   type: PlutoColumnType.text(),
      //   width: isDesktop ? width * 0.16 : width * 0.4,
      //   backgroundColor: columnColors,
      // ),
      PlutoColumn(
        enableFilterMenuItem: true,
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
        enableFilterMenuItem: true,
        title: _locale.notes,
        field: "txtNotes",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.35 : width * 0.2,
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
