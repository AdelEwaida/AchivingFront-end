import 'dart:typed_data';

import 'package:archiving_flutter_project/dialogs/dep_dialogs/departemnt_dialog.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'dart:html' as html;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class DepartemntScreen extends StatefulWidget {
  const DepartemntScreen({super.key});

  @override
  State<DepartemntScreen> createState() => _OfficeScreenState();
}

class _OfficeScreenState extends State<DepartemntScreen> {
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  PlutoGridStateManager? stateManager;
  List<PlutoColumn> polCols = [];
  late AppLocalizations _locale;
  ValueNotifier pageLis = ValueNotifier(1);
  ValueNotifier isSearch = ValueNotifier(false);
  PlutoRow? selectedRow;
  DepartmentController departmentController = DepartmentController();
  late ScreenContentProvider screenContentProvider;

  @override
  void didChangeDependencies() {
    polCols = [];
    _locale = AppLocalizations.of(context)!;
    screenContentProvider = context.read<ScreenContentProvider>();
    isDesktop = Responsive.isDesktop(context);
    width = MediaQuery.of(context).size.width;
    polCols.addAll([
      //countNumber
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
        // enableFilterMenuItem: true,
      ),
      PlutoColumn(
        enableFilterMenuItem: true,

        title: _locale.txtShortcode,
        field: "txtShortcode",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.3 : width * 0.2,
        backgroundColor: columnColors,
        // enableFilterMenuItem: true,
      ),
      PlutoColumn(
        enableFilterMenuItem: true,

        // suppressedAutoSize: true,
        title: _locale.txtDescription,
        field: "txtDescription",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.44 : width * 0.4,
        // width: width * 0.2,
        backgroundColor: columnColors,
      ),
    ]);
    getCount();
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
    super.didChangeDependencies();
  }

  ValueNotifier totalDepCount = ValueNotifier(0);
  getCount() {
    departmentController.getOfficeCount().then((value) {
      totalDepCount.value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    isDesktop = Responsive.isDesktop(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text(_locale.listOfDepartment),
        ),
        body: buildMainContent());
  }

  Widget mobileView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.minHeight,
              maxHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Expanded(
                    child: buildMainContent(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget tabletView() {
    return Container(
      width: width,
      height: height,
      child: buildMainContent(),
    );
  }

  Widget desktopView() {
    return Container(
      width: width,
      height: height,
      child: buildMainContent(),
    );
  }

  Widget buildMainContent() {
    return Column(
      children: [
        Center(
          child: Container(
            width: isDesktop ? width * 0.8 : width * 0.9,
            child: TableComponent(
              // key: UniqueKey(),
              tableHeigt: height * 0.75,
              tableWidth: width,
              delete: deleteDep,
              add: addDep,
              genranlEdit: editDep,
              plCols: polCols,
              mode: PlutoGridMode.selectWithOneTap,
              polRows: [],
              footerBuilder: (stateManager) {
                return lazyLoadingfooter(stateManager);
              },
              onLoaded: (PlutoGridOnLoadedEvent event) {
                stateManager = event.stateManager;
                pageLis.value = pageLis.value > 1 ? 0 : 1;
                totalDepCount.value = 0;
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
          ),
        ),
        Container(
          width: isDesktop ? width * 0.8 : width * 0.9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Text(
                //   "${_locale.officeNumberDisplayed}: ",
                //   style: const TextStyle(fontWeight: FontWeight.bold),
                // ),
                // ValueListenableBuilder(
                //   valueListenable: officeNumberDisplayed,
                //   builder: ((context, value, child) {
                //     return Text(
                //       "${officeNumberDisplayed.value}",
                //       style: const TextStyle(fontWeight: FontWeight.bold),
                //     );
                //   }),
                // ),
                // SizedBox(
                //   width: width * 0.05,
                // ),
                Text(
                  "${_locale.totalCount}: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ValueListenableBuilder(
                  valueListenable: totalDepCount,
                  builder: ((context, value, child) {
                    return Text(
                      "${totalDepCount.value}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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

  void deleteDep() async {
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
          await departmentController
              .deleteDep(
                  DepartmentModel(txtKey: selectedRow!.cells['txtKey']!.value))
              .then((value) {
            if (value.statusCode == 200) {
              reloadData();
            }
          });
        }
      });
    }
  }

  void editDep() {
    if (selectedRow != null) {
      DepartmentModel departmentModel =
          DepartmentModel.fromPlutoRow(selectedRow!);
      showDialog(
        context: context,
        builder: (context) {
          return DepartmentDialog(
            departmentModel: departmentModel,
          );
        },
      ).then((value) {
        if (value) {
          reloadData();
        }
      });
    }
  }

  void addDep() {
    showDialog(
      context: context,
      builder: (context) {
        return DepartmentDialog();
      },
    ).then((value) {
      if (value) {
        reloadData();
      }
    });
  }

  void reloadData() {
    pageLis.value = 1; // Reset the page to the first one
    count = 0; // Reset the count
    rowList.clear(); // Clear the existing rows
    getCount();
    stateManager!.removeAllRows();
    stateManager!.setShowLoading(true); // Show loading indicator
    fetch(PlutoInfinityScrollRowsRequest()).then((response) {
      stateManager!.appendRows(response.rows);
      stateManager!.setShowLoading(false); // Hide loading indicator
    });
  }

  int count = 0;
  List<PlutoRow> rowList = [];

  Future<PlutoInfinityScrollRowsResponse> fetch(
      PlutoInfinityScrollRowsRequest request) async {
    bool isLast = false;
    List<DepartmentModel> result = [];
    List<PlutoRow> topList = [];
    if (!isSearch.value) {
      if (pageLis.value != -1) {
        if (pageLis.value > 1) {
          pageLis.value = -1;
        }
        await departmentController
            .getDep(SearchModel(page: pageLis.value))
            .then((value) {
          result = value;
        });
        for (int i = pageLis.value == -1 ? 50 : 0; i < result.length; i++) {
          topList.add(result[i].toPlutoRow(i + 1));
          rowList.add(result[i].toPlutoRow(i + 1));
        }
        count += result.length;
        if (pageLis.value == 1) {
          pageLis.value = pageLis.value + 1;
        }
        isLast = pageLis.value == 0 ? true : false;

        return Future.value(
            PlutoInfinityScrollRowsResponse(isLast: isLast, rows: topList));
      }
    }
    return Future.value(
        PlutoInfinityScrollRowsResponse(isLast: isLast, rows: []));
  }
}
