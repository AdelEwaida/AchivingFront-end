import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog_text.dart';
import 'package:archiving_flutter_project/dialogs/users_dialogs/add_edit_user_dialog.dart';
import 'package:archiving_flutter_project/dialogs/users_dialogs/user_department_dialog.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/template_model.dart';
import 'package:archiving_flutter_project/providers/classification_name_and_code_provider.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/lists.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timelines/timelines.dart';
import '../../dialogs/document_dialogs/file_explor_dialog.dart';
import '../../dialogs/template_work_flow/add_edit_template_dialog.dart';
import '../../dialogs/template_work_flow/edit_template_document_dialog.dart';
import '../../models/db/user_models/department_user_model.dart';
import '../../models/db/work_flow/setup_model.dart';
import '../../models/db/work_flow/user_step_request_body.dart';
import '../../models/db/work_flow/user_work_flow_steps.dart';
import '../../models/db/work_flow/work_flow_doc_model.dart';
import '../../models/db/work_flow/work_flow_document_info.dart';
import '../../models/db/work_flow/work_flow_template_body.dart';
import '../../service/controller/documents_controllers/documents_controller.dart';
import '../../service/controller/work_flow_controllers/setup_controller.dart';
import '../../service/controller/work_flow_controllers/work_flow_template_controller.dart';
import '../../utils/constants/loading.dart';
import '../../utils/constants/styles.dart';
import '../../widget/custom_drop_down.dart';
import '../../widget/dialog_widgets/title_dialog_widget.dart';

class UserWorkFlowSettings extends StatefulWidget {
  const UserWorkFlowSettings({super.key});

  @override
  State<UserWorkFlowSettings> createState() => _UserWorkFlowSettings();
}

class _UserWorkFlowSettings extends State<UserWorkFlowSettings> {
  List<PlutoColumn> polCols = [];
  PlutoGridStateManager? stateManager;
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;

  late DocumentListProvider documentListProvider;

  ValueNotifier isSearch = ValueNotifier(false);
  ValueNotifier totalUsersCount = ValueNotifier(0);

  SetupModel? setupModel;
  SetupController setupController = SetupController();
  String? searchValue = "";
  UserModel? userModel;
  var storage = const FlutterSecureStorage();
  String? userName = "";
  int selectedStatus = -2;
  TextEditingController notesController = TextEditingController();
  @override
  void didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    polCols = [];
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);

    fillColumns();
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
    userName = await storage.read(key: "userName");
    // departmetList = await UserController().getDepartmentSelectedUser(userName!);
    setState(() {});
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  PlutoRow? selectedRow;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_locale.workFlowSettings),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                      width: isDesktop ? width * 0.78 : width * 0.9,
                      child: TableComponent(
                        hasDropdown: true,
                        noHeader: true,
                        isworkFlow: true,
                        // dropdown: statusDropDown(),
                        tableHeigt: height * 0.78,
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
                        },
                        doubleTab: (event) async {
                          PlutoRow? tappedRow = event.row;
                          setupModel =
                              SetupModel.fromPluto(tappedRow!, _locale);
                        },
                        onSelected: (event) async {
                          PlutoRow? tappedRow = event.row;
                          selectedRow = tappedRow;
                          setupModel =
                              SetupModel.fromPluto(selectedRow!, _locale);
                        },
                      )),
                ),
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
        selectedStatus = ListConstants.getStatusCode(value, _locale)!;

        // search();
        setState(() {});
      },
      initialValue: selectedStatus == -2
          ? ListConstants.getStatusName(0, _locale)
          : ListConstants.getStatusName(selectedStatus, _locale),
      bordeText: _locale.searchByStatus,
      width: width * 0.18,
      items: ListConstants.getStatus(_locale),
      height: height * 0.048,
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

  void refreshTable() async {
    stateManager!.setShowLoading(true);
    stateManager!.removeAllRows();
    stateManager!.notifyListeners(true);
    selectedRow = null;
    isSearch.value = false;
    setupModel = null;
    selectedStatus = 0;

    setState(() {});
    rowList.clear();
    pageLis.value = 1;
    var response = await fetch(PlutoInfinityScrollRowsRequest());
    stateManager!.appendRows(response.rows);
    stateManager!.notifyListeners(true);
    stateManager!.resetCurrentState();
    stateManager!.setShowLoading(false);
  }

  List<PlutoRow> rowList = [];
  ValueNotifier pageLis = ValueNotifier(1);
  Future<PlutoInfinityScrollRowsResponse> fetch(
      PlutoInfinityScrollRowsRequest request) async {
    bool isLast = false; // Indicates whether the last page has been fetched.

    try {
      // Fetch the list of objects from the API.
      List<SetupModel>? results = await setupController.getSetupList();

      if (results.isNotEmpty) {
        // Convert the list of objects into PlutoRows.
        List<PlutoRow> newRows = results
            .asMap()
            .entries
            .map((entry) => entry.value.toPlutoRow(entry.key + 1, _locale))
            .toList();

        // Append the new rows to the rowList.
        rowList.addAll(newRows);

        return PlutoInfinityScrollRowsResponse(
          isLast: isLast, // Set `isLast` based on your pagination logic.
          rows: newRows,
        );
      } else {
        // Handle the case where the API response is an empty list.
        return PlutoInfinityScrollRowsResponse(isLast: true, rows: []);
      }
    } catch (e) {
      // Log or handle any errors during the API call.
      print('Error fetching data: $e');
      return PlutoInfinityScrollRowsResponse(isLast: true, rows: []);
    }
  }

  void showApprovalFlowDialog(
      BuildContext context, List<Map<String, String>> steps, int currentStep) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          backgroundColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(_locale.approvalFlowDetails),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: List.generate(steps.length, (index) {
                return Column(
                  children: [
                    _buildStepCard(
                        steps[index], currentStep), // Pass isLastStep
                    if (index < steps.length - 1)
                      _buildConnector(), // Add connector if not the last step
                  ],
                );
              }),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  style: customButtonStyle(
                    Size(
                        isDesktop ? width * 0.1 : width * 0.35, height * 0.042),
                    16,
                    redColor,
                  ),
                  child: Text(
                    _locale.close,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepCard(Map<String, String> step, int currentStep) {
    return SizedBox(
      width: width * 0.27, // Adjust card width as needed
      child: Card(
        elevation: 4,
        color: currentStep == 1
            ? Colors.red[50]
            : Colors.white, // Set background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center horizontally
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center vertically
              children: [
                Icon(
                  step['status'] == _locale.approved
                      ? Icons.check_circle
                      : Icons.hourglass_empty,
                  color: step['status'] == _locale.approved
                      ? Colors.green
                      : Colors.orange,
                  // size: 35, // Adjust icon size as needed
                ),
                SizedBox(width: 16), // Space between icon and text
                Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center vertically
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text to start
                  children: [
                    Text(
                      step['name']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: currentStep == 1 ? Colors.red : Colors.black,
                      ),
                    ),
                    SizedBox(height: 4), // Space between name and status
                    Text(
                      step['status']!,
                      style: TextStyle(
                        fontWeight: currentStep == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                        color: currentStep == 1 ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void fillColumns() {
    polCols = [
      PlutoColumn(
        readOnly: true,
        title: _locale.workFlow,
        field: "txtPropertyname",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.25 : width * 0.3,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.description,
        field: "description",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.25 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.arDescription,
        field: "arDescription",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.12 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: false, // Allow editing for the toggle switch
        title: _locale.status,
        field: "bolActive",
        backgroundColor: columnColors,
        type: PlutoColumnType
            .text(), // Still using text type for data representation
        width: isDesktop ? width * 0.13 : width * 0.4,
        renderer: (rendererContext) {
          bool isActive = rendererContext.cell.value ==
              _locale.active; // Determine current status
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Switch(
                value: isActive,
                activeColor: Colors.green, // Green color when active
                inactiveThumbColor: Colors.red, // Red color when inactive
                onChanged: (value) async {
                  // Call the API to update the status
                  bool result =
                      await setupController.updateSetupMethod(SetupModel(
                    arDescription:
                        rendererContext.row.cells['arDescription']?.value,
                    description:
                        rendererContext.row.cells['description']?.value,
                    txtPropertyname:
                        rendererContext.row.cells['txtPropertyname']?.value,
                    bolActive: value ? 1 : 0,
                  ));

                  if (result) {
                    // Update the cell value in the state manager
                    rendererContext.stateManager.changeCellValue(
                      rendererContext.cell,
                      value ? _locale.active : _locale.notActive,
                    );
                  } else {
                    // Revert the switch if the API fails
                    rendererContext.stateManager.changeCellValue(
                      rendererContext.cell,
                      !value ? _locale.active : _locale.notActive,
                    );
                  }
                  refreshTable();
                },
              ),
              SizedBox(width: 8), // Add some spacing
              Text(
                isActive ? _locale.active : _locale.notActive,
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    ];
  }
}

Widget _buildConnector() {
  return SizedBox(
    height: 40,
    child: CustomPaint(
      painter: DottedLinePainter(),
    ),
  );
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double startY = 0;
    const double gap = 6;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + gap),
        paint,
      );
      startY += gap * 2;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
