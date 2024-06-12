import 'package:archiving_flutter_project/dialogs/dep_dialogs/departemnt_dialog.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/service/controller/actions_controllers/action_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../dialogs/actions_dialogs/add_edit_action_dialog.dart';
import '../../dialogs/error_dialgos/confirm_dialog.dart';
import '../../models/db/actions_models/action_model.dart';

class ActionScreen extends StatefulWidget {
  const ActionScreen({super.key});

  @override
  State<ActionScreen> createState() => _OfficeScreenState();
}

class _OfficeScreenState extends State<ActionScreen> {
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  late PlutoGridStateManager stateManager;
  List<PlutoColumn> polCols = [];
  late AppLocalizations _locale;
  ValueNotifier pageLis = ValueNotifier(1);
  ValueNotifier isSearch = ValueNotifier(false);
  PlutoRow? selectedRow;
  ActionController actionController = ActionController();
  late ScreenContentProvider screenContentProvider;

  @override
  void didChangeDependencies() {
    polCols = [];
    _locale = AppLocalizations.of(context)!;
    screenContentProvider = context.read<ScreenContentProvider>();
    isDesktop = Responsive.isDesktop(context);
    width = MediaQuery.of(context).size.width;
    polCols.addAll([
      PlutoColumn(
        title: "#",
        field: "countNumber",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.05 : width * 0.15,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.date,
        field: "datDate",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.16 : width * 0.4,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.txtDescription,
        field: "txtDescription",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.28 : width * 0.2,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.notes,
        field: "txtNotes",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.35 : width * 0.2,
        backgroundColor: columnColors,
      ),
    ]);

    getCount();
    super.didChangeDependencies();
  }

  ValueNotifier totalActionsCount = ValueNotifier(0);

  getCount() {
    actionController.getActionCount().then((value) {
      totalActionsCount.value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    isDesktop = Responsive.isDesktop(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(),
      width: width,
      height: height,
      child: buildMainContent(),
    );
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
    return SizedBox(
      width: width,
      height: height,
      child: buildMainContent(),
    );
  }

  Widget desktopView() {
    return SizedBox(
      width: width,
      height: height,
      child: buildMainContent(),
    );
  }

  Widget buildMainContent() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TableComponent(
                key: UniqueKey(),
                tableHeigt: height * 0.85,
                tableWidth: width,
                delete: deleteAction,
                add: addAction,
                genranlEdit: editAction,
                plCols: polCols,
                mode: PlutoGridMode.selectWithOneTap,
                polRows: [],
                footerBuilder: (stateManager) {
                  return lazyLoadingfooter(stateManager);
                },
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  pageLis.value = pageLis.value > 1 ? 0 : 1;
                  totalActionsCount.value = 0;
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
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "${_locale.totalCount}: ",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ValueListenableBuilder(
                valueListenable: totalActionsCount,
                builder: ((context, value, child) {
                  return Text(
                    "${totalActionsCount.value}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                }),
              ),
            ],
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

  void exportToExcel() {}

  void addAction() {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditActionDialog(
          isFromList: false,
        );
      },
    ).then((value) {
      if (value) {
        reloadData();
      }
    });
  }

  int count = 0;
  List<PlutoRow> rowList = [];

  Future<PlutoInfinityScrollRowsResponse> fetch(
      PlutoInfinityScrollRowsRequest request) async {
    bool isLast = false;
    List<ActionModel> result = [];
    List<PlutoRow> topList = [];
    if (!isSearch.value) {
      await actionController
          .getAllActions(SearchModel(page: pageLis.value))
          .then((value) {
        result = value;
      });
      for (int i = 0; i < result.length; i++) {
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
    return Future.value(
        PlutoInfinityScrollRowsResponse(isLast: isLast, rows: []));
  }

  void deleteAction() async {
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
          await actionController
              .deleteAction(
                  ActionModel(txtKey: selectedRow!.cells['txtKey']!.value))
              .then((value) {
            if (value.statusCode == 200) {
              reloadData();
            }
          });
        }
      });
    }
  }

  void reloadData() {
    pageLis.value = 1; // Reset the page to the first one
    count = 0; // Reset the count
    rowList.clear(); // Clear the existing rows
    getCount();
    stateManager.removeAllRows();
    stateManager.setShowLoading(true); // Show loading indicator
    fetch(PlutoInfinityScrollRowsRequest()).then((response) {
      stateManager.appendRows(response.rows);
      stateManager.setShowLoading(false); // Hide loading indicator
    });
  }

  void editAction() {
    if (selectedRow != null) {
      ActionModel actionModel = ActionModel.fromPlutoRow(selectedRow!);
      print(
          "actionModelactionModelactionModelactionModel:${actionModel.toJson()}");
      showDialog(
        context: context,
        builder: (context) {
          return AddEditActionDialog(
            isFromList: false,
            actionModel: actionModel,
          );
        },
      ).then((value) {
        if (value) {
          reloadData();
        }
      });
    }
  }
}
