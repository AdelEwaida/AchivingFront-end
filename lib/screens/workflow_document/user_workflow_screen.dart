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
import '../../models/db/work_flow/user_step_request_body.dart';
import '../../models/db/work_flow/user_work_flow_steps.dart';
import '../../models/db/work_flow/work_flow_doc_model.dart';
import '../../models/db/work_flow/work_flow_document_info.dart';
import '../../models/db/work_flow/work_flow_template_body.dart';
import '../../service/controller/documents_controllers/documents_controller.dart';
import '../../service/controller/work_flow_controllers/work_flow_template_controller.dart';
import '../../utils/constants/loading.dart';
import '../../utils/constants/styles.dart';
import '../../widget/custom_drop_down.dart';
import '../../widget/dialog_widgets/title_dialog_widget.dart';

class UserWorkFlow extends StatefulWidget {
  const UserWorkFlow({super.key});

  @override
  State<UserWorkFlow> createState() => _UserWorkFlowState();
}

class _UserWorkFlowState extends State<UserWorkFlow> {
  List<PlutoColumn> polCols = [];
  PlutoGridStateManager? stateManager;
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;

  late DocumentListProvider documentListProvider;

  ValueNotifier isSearch = ValueNotifier(false);
  ValueNotifier totalUsersCount = ValueNotifier(0);

  UserWorkflowSteps? workFlowTemplateBody;
  WorkFlowTemplateContoller workFlowTemplateContoller =
      WorkFlowTemplateContoller();
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

    for (int i = 0; i < stateManager!.rows.length; i++) {
      print(
          "stateManager!.rows[i].cells['intStatus']!.value :${stateManager!.rows[i].cells['intStatus']!.value}");
      stateManager!.rows[i].cells['intStatus']!.value =
          getStatusNameDependsLang(
              stateManager!.rows[i].cells['intStatus']!.value, _locale);
    }
    stateManager!.notifyListeners(true);
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
          title: Text(_locale.myApprovals),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: isDesktop ? width * 0.78 : width * 0.9,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            statusDropDown(),
                          ],
                        ),
                        SizedBox(),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                if (selectedRow != null) {
                                  openLoadinDialog(context);
                                  DocumentsController()
                                      .getFilesByHdrKey(selectedRow!
                                          .cells['txtDocumentcode']!.value)
                                      .then((value) {
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return FileExplorDialog(
                                          listOfFiles: value,
                                          isWorkFlowScreen: true,
                                        );
                                      },
                                    );
                                  }).then((value) {});
                                }
                              },
                              style: customButtonStyle(    context,
                                  Size(isDesktop ? width * 0.07 : width * 0.19,
                                      height * 0.043),
                                  14,
                                  primary),
                              child: Text(
                                _locale.attachments,
                                style: const TextStyle(color: whiteColor),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (workFlowTemplateBody != null) {
                                  if (workFlowTemplateBody!.intStatus == 1) {
                                    CoolAlert.show(
                                      width: width * 0.4,
                                      // ignore: use_build_context_synchronously
                                      context: context,
                                      type: CoolAlertType.error,
                                      title: _locale.error,
                                      text: _locale.cannotEdit,
                                      confirmBtnText: _locale.ok,
                                      onConfirmBtnTap: () {},
                                    );
                                  } else {
                                    if (workFlowTemplateBody!.intCurrStep !=
                                        1) {
                                      showDialog(
                                        barrierDismissible: false,
                                        // ignore: use_build_context_synchronously
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomConfirmDialog(
                                            confirmMessage:
                                                _locale.notAuthorized,
                                          );
                                        },
                                      );
                                    } else {
                                      updateApproved(context);
                                    }
                                  }
                                }
                              },
                              style: customButtonStyle(    context,
                                  Size(isDesktop ? width * 0.07 : width * 0.19,
                                      height * 0.043),
                                  14,
                                  greenColor),
                              child: Text(
                                _locale.approve,
                                style: const TextStyle(color: whiteColor),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (workFlowTemplateBody != null) {
                                  if (workFlowTemplateBody!.intStatus == 1) {
                                    CoolAlert.show(
                                      width: width * 0.4,
                                      // ignore: use_build_context_synchronously
                                      context: context,
                                      type: CoolAlertType.error,
                                      title: _locale.error,
                                      text: _locale.cannotEdit,
                                      confirmBtnText: _locale.ok,
                                      onConfirmBtnTap: () {},
                                    );
                                  } else {
                                    if (workFlowTemplateBody!.intCurrStep !=
                                        1) {
                                      showDialog(
                                        barrierDismissible: false,
                                        // ignore: use_build_context_synchronously
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomConfirmDialog(
                                            confirmMessage:
                                                _locale.notAuthorized,
                                          );
                                        },
                                      );
                                    } else {
                                      updateRejectedBody(context);
                                    }
                                  }
                                }
                              },
                              style: customButtonStyle(    context,
                                  Size(isDesktop ? width * 0.07 : width * 0.19,
                                      height * 0.043),
                                  14,
                                  Colors.red),
                              child: Text(
                                _locale.reject,
                                style: const TextStyle(color: whiteColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
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
                        workFlowTemplateBody =
                            UserWorkflowSteps.fromPluto(tappedRow!, _locale);
                      },
                      onSelected: (event) async {
                        PlutoRow? tappedRow = event.row;
                        selectedRow = tappedRow;
                        workFlowTemplateBody =
                            UserWorkflowSteps.fromPluto(selectedRow!, _locale);
                      },
                    )),
              ],
            ),
          ),
        ));
  }

  void updateApproved(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return TextCustomConfirmDialog(
          confirmMessage: _locale.sureToApproveStep,
          editingController: notesController,
        );
      },
    ).then((value) {
      if (value) {
        UserWorkflowSteps userWorkflowSteps = UserWorkflowSteps(
            txtKey: workFlowTemplateBody!.txtKey,
            txtWorkflowcode: workFlowTemplateBody!.txtWorkflowcode,
            intStepno: workFlowTemplateBody!.intStepno,
            txtFeedback: notesController.text,
            bolOptional: workFlowTemplateBody!.bolOptional,
            datActionDate: workFlowTemplateBody!.datActionDate,
            intCurrStep: workFlowTemplateBody!.intCurrStep,
            txtDept: workFlowTemplateBody!.txtDept,
            txtDeptName: workFlowTemplateBody!.txtDeptName,
            txtDocumentName: workFlowTemplateBody!.txtDocumentName,
            txtDocumentcode: workFlowTemplateBody!.txtDocumentcode,
            txtStepdesc: workFlowTemplateBody!.txtStepdesc,
            txtTemplateName: workFlowTemplateBody!.txtTemplateName,
            txtTemplatecode: workFlowTemplateBody!.txtTemplatecode,
            txtUsercode: workFlowTemplateBody!.txtUsercode,
            intStatus: 1);
        workFlowTemplateContoller
            .updateUserStep(userWorkflowSteps)
            .then((value) {
          CoolAlert.show(
            width: width * 0.4,
            // ignore: use_build_context_synchronously
            context: context,
            type: CoolAlertType.success,
            title: _locale.success,
            text: _locale.updatedSuccess,
            confirmBtnText: _locale.ok,
            onConfirmBtnTap: () {},
          ).then((value) {
            refreshTable();
          });
        });
      }
    });
  }

  DropDown statusDropDown() {
    return DropDown(
      key: UniqueKey(),
      isMandatory: true,
      onChanged: (value) {
        selectedStatus = ListConstants.getStatusCode(value, _locale)!;

        search();
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

  void updateRejectedBody(BuildContext context) {
    UserWorkflowSteps userWorkflowSteps = UserWorkflowSteps(
        txtKey: workFlowTemplateBody!.txtKey,
        txtWorkflowcode: workFlowTemplateBody!.txtWorkflowcode,
        intStepno: workFlowTemplateBody!.intStepno,
        intStatus: 2);
    showDialog(
      context: context,
      builder: (context) {
        return CustomConfirmDialog(confirmMessage: _locale.sureToRejectStep);
      },
    ).then((value) {
      if (value) {
        workFlowTemplateContoller
            .updateUserStep(userWorkflowSteps)
            .then((value) {
          CoolAlert.show(
            width: width * 0.4,
            // ignore: use_build_context_synchronously
            context: context,
            type: CoolAlertType.success,
            title: _locale.success,
            text: _locale.updatedSuccess,
            confirmBtnText: _locale.ok,
            onConfirmBtnTap: () {},
          ).then((value) {
            refreshTable();
          });
        });
      }
    });
  }

  void fillColumnTable() {
    polCols = [
      PlutoColumn(
        readOnly: true,
        title: _locale.stepNo,
        field: "intStepno",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.1 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.templateName,
        field: "txtTemplateName",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.1 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.description,
        field: "txtStepdesc",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.16 : width * 0.3,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.user,
        field: "txtUsercode",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.16 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.status, // Localized title
        field: "intStatus",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.12 : width * 0.4,
        renderer: (rendererContext) {
          // Retrieve the status and current step values from the row
          String statusText =
              rendererContext.cell.value; // Get the string value for status
          int currentStep = rendererContext.row.cells['intCurrStep']?.value ??
              0; // Get the current step

          Color backgroundColor = Colors.grey;

          // Conditional logic to map the status and current step to the appropriate label
          if (statusText == _locale.readyToApprove) {
            // Check current step
            if (currentStep == 1) {
              // It's the user's turn to approve
              statusText = _locale
                  .readyToApprove; // Localized string for "Ready to Approve"
              backgroundColor = Colors.orange;
            } else {
              // Not the user's turn to approve
              statusText = _locale
                  .pending; // New localized string for "Waiting for Others"
              backgroundColor =
                  Colors.orange[300]!; // A different color for this status
            }
          } else if (statusText == _locale.approved) {
            backgroundColor = Colors.green; // Approved
          } else if (statusText == _locale.rejected) {
            backgroundColor = Colors.red; // Rejected
          }

          return GestureDetector(
            onTap: () async {
              // Example: Pass necessary data to the dialog
              final rowData = rendererContext.row.cells;
              final userName = rowData['txtUsercode']?.value ?? "";
              // if (currentStep != 1) {
              final PlutoRow row = rendererContext.row;

              List<UserWorkflowSteps> result = [];
              final Map<String, PlutoCell> cells = row.cells;

              // Retrieve the workFlowCode value
              final String workFlowCode = cells['txtWorkflowcode']?.value ?? "";

              // print("Current workFlowCode: $workFlowCode");
              result = await workFlowTemplateContoller.getAllUsersWorkFlowSteps(
                UserStepRequestBody(
                    stepStatus: -1, curStep: -1, workflowCode: workFlowCode),
              );

              // Populate steps dynamically using localized statuses
              List<Map<String, String>> steps = result.map((step) {
                String? status =
                    ListConstants.getStatusName(step.intStatus ?? -1, _locale);

                return {
                  "name": step.txtUsercode ?? "Unknown User",
                  "status": status == _locale.readyToApprove
                      ? _locale.pending
                      : status ?? "Unknown",
                };
              }).toList();

              showApprovalFlowDialog(context, steps, currentStep);
              // }
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.department,
        field: "txtDeptName",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.13 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.fileName,
        field: "txtDocumentName",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.1 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.notes,
        field: "txtFeedback",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.1 : width * 0.4,
      ),
    ];
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

  search() async {
    isSearch.value = true;
    print("insidee search");
    stateManager!.setShowLoading(true); // Show loading indicator

    if (isSearch.value) {
      List<UserWorkflowSteps> result = [];
      List<PlutoRow> topList = [];
      pageLis.value = 1;

      // Fetch templates based on department
      result = await workFlowTemplateContoller.getUserWorkFlowSteps(
          UserStepRequestBody(stepStatus: selectedStatus, curStep: -1));
      // Update PlutoRows
      for (int i = 0; i < result.length; i++) {
        topList.add(result[i].toPlutoRow(rowList.length, _locale));
      }

      // Refresh the table with new data
      stateManager!.removeAllRows(); // Clear existing rows
      stateManager!.appendRows(topList); // Add new rows
      stateManager!.notifyListeners(true); // Ensure UI updates
    }

    stateManager!.setShowLoading(false); // Hide loading indicator
    setState(() {}); // Trigger rebuild of dropdown or other elements
  }

  void refreshTable() async {
    stateManager!.setShowLoading(true);
    stateManager!.removeAllRows();
    stateManager!.notifyListeners(true);
    selectedRow = null;
    isSearch.value = false;
    workFlowTemplateBody = null;
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
    bool isLast = false;
    if (!isSearch.value) {
      if (pageLis.value != -1) {
        if (pageLis.value > 1) {
          pageLis.value = -1;
        }
        List<PlutoRow> topList = [];
        List<UserWorkflowSteps> result = [];

        result = await workFlowTemplateContoller.getUserWorkFlowSteps(
            UserStepRequestBody(stepStatus: 0, curStep: -1));

        for (int i = pageLis.value == -1 ? 50 : 0; i < result.length; i++) {
          rowList.add(result[i].toPlutoRow(i + 1, _locale)); // Updated here
          topList.add(
              result[i].toPlutoRow(rowList.length, _locale)); // Updated here
        }

        isLast = topList.isEmpty;
        if (pageLis.value == 1) {
          pageLis.value++; // Increment the page number for next fetch
        }
        return Future.value(
            PlutoInfinityScrollRowsResponse(isLast: false, rows: topList));
      }
    }
    return Future.value(
        PlutoInfinityScrollRowsResponse(isLast: isLast, rows: []));
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
                  style: customButtonStyle(    context,
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
