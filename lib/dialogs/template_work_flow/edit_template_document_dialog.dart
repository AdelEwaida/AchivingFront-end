import 'dart:typed_data';
import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/steps_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/template_model.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/lists.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:archiving_flutter_project/widget/dialog_widgets/title_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../../models/db/user_models/department_user_model.dart';
import '../../models/db/work_flow/document_steps_model.dart';
import '../../models/db/work_flow/work_flow_doc_model.dart';
import '../../models/db/work_flow/work_flow_document_info.dart';
import '../../models/db/work_flow/work_flow_template_body.dart';
import '../../models/dto/searchs_model/search_model.dart';
import '../../service/controller/work_flow_controllers/work_flow_template_controller.dart';
import '../../utils/func/converters.dart';
import '../../widget/date_time_component.dart';
import '../../widget/table_component/table_component.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';

class EditTemplateDocumentDialog extends StatefulWidget {
  final dynamic workFlowTemplateBody;
  EditTemplateDocumentDialog({
    super.key,
    this.workFlowTemplateBody,
  });

  @override
  State<EditTemplateDocumentDialog> createState() => _DepartmentDialogState();
}

class _DepartmentDialogState extends State<EditTemplateDocumentDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  double radius = 7;

  TextEditingController documentName = TextEditingController();
  TextEditingController departmentName = TextEditingController();
  TextEditingController templateName = TextEditingController();
  TextEditingController workflowStatusController = TextEditingController();

  TextEditingController stepDescription = TextEditingController();
  TextEditingController stepDescriptionController = TextEditingController();

  TextEditingController feedbackController = TextEditingController();
  UserController userController = UserController();
  WorkFlowTemplateContoller workFlowTemplateContoller =
      WorkFlowTemplateContoller();

  UserModel? userModel;
  var storage = const FlutterSecureStorage();
  String? userName = "";

  List<UserModel> userList = [];
  String selectedDep = "";
  String selctedDepDesc = "";
  List<DepartmentUserModel> departmetList = [];
  ValueNotifier<List<StepsModel>> favoritesNotifier =
      ValueNotifier<List<StepsModel>>([]);
  String selectedUserCode = "";
  String selectedUserName = "";
  List<DocumentStepsModel> steps = [];
  bool isActive = false;
  bool isOptional = false;
  bool isLoading = true;
  WorkFlowDocumentInfo? workFlowTemplateBody;
  int selectedStatus = -1;
  TextEditingController datMaxDate = TextEditingController();
  TextEditingController stepDate = TextEditingController();
  List<PlutoColumn> polCols = [];
  PlutoGridStateManager? stateManager;

  @override
  Future<void> didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    userName = await storage.read(key: "userName");
    fillColumnTable();
    departmetList = await UserController().getDepartmentSelectedUser(userName!);
    userList = await userController
        .getUsers(SearchModel(searchField: '', page: -1, status: -1));

    if (widget.workFlowTemplateBody != null) {
      if (widget.workFlowTemplateBody is List<WorkFlowDocumentInfo>) {
        if (widget.workFlowTemplateBody.isNotEmpty) {
          workFlowTemplateBody =
              widget.workFlowTemplateBody[0]; // Take the first one
        } else {}
      } else if (widget.workFlowTemplateBody is WorkFlowDocumentInfo) {
        workFlowTemplateBody = widget.workFlowTemplateBody;
      }

      if (workFlowTemplateBody != null) {
        documentName.text =
            workFlowTemplateBody!.workflow!.txtDocumentName ?? "";
        departmentName.text = workFlowTemplateBody!.workflow!.txtDeptName ?? "";
        templateName.text =
            workFlowTemplateBody!.workflow!.txtTemplateName ?? "";
        workflowStatusController.text = ListConstants.getStatusNameWorkFlow(
                workFlowTemplateBody!.workflow!.intStatus!, _locale)!
            .toString();

        selectedDep = workFlowTemplateBody!.workflow!.txtDept ?? "";
        selctedDepDesc = workFlowTemplateBody!.workflow!.txtDeptName ?? "";
        datMaxDate.text =
            workFlowTemplateBody!.workflow!.datMaxDate?.isNotEmpty == true
                ? workFlowTemplateBody!.workflow!.datMaxDate!
                : Converters.formatDate2(DateTime.now().toString());
        steps = workFlowTemplateBody!.stepsList ?? [];
        for (int i = 0; i < workFlowTemplateBody!.stepsList!.length; i++) {
          rowList.add(
              workFlowTemplateBody!.stepsList![i].toPlutoRow(i + 1, _locale));
        }
      }
    }

    setState(() {
      isLoading = false;
    });

    super.didChangeDependencies();
  }

  bool isDesktop = false;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      backgroundColor: Colors.white,
      title: TitleDialogWidget(
        title: _locale.approvals,
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: height * 0.07,
      ),
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
        ),
        width: isDesktop ? width * 0.5 : width * 0.8,
        height: isDesktop ? height * 0.65 : height * 0.5,
        child: formSection(),
      ),
      actions: [
        isDesktop
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ElevatedButton(
                  //   onPressed: () {
                  //     addTemplateAndSteps();
                  //   },
                  //   style: customButtonStyle(    context,
                  //       Size(isDesktop ? width * 0.1 : width * 0.4,
                  //           height * 0.045),
                  //       18,
                  //       primary),
                  //   child: Text(
                  //     _locale.save,
                  //     style: const TextStyle(color: whiteColor),
                  //   ),
                  // ),
                  SizedBox(
                    width: width * 0.01,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: customButtonStyle(    context,
                        Size(isDesktop ? width * 0.1 : width * 0.4,
                            height * 0.045),
                        16,
                        redColor),
                    child: Text(
                      _locale.cancel,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      // ElevatedButton(
                      //   onPressed: () {
                      //     addTemplateAndSteps();
                      //   },
                      //   style: customButtonStyle(    context,
                      //       Size(isDesktop ? width * 0.1 : width * 0.4,
                      //           height * 0.045),
                      //       18,
                      //       greenColor),
                      //   child: Text(
                      //     _locale.save,
                      //     style: const TextStyle(color: whiteColor),
                      //   ),
                      // ),
                      SizedBox(height: height * 0.01),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: customButtonStyle(    context,
                            Size(isDesktop ? width * 0.1 : width * 0.4,
                                height * 0.045),
                            16,
                            redColor),
                        child: Text(
                          _locale.cancel,
                          style: const TextStyle(color: whiteColor),
                        ),
                      ),
                    ],
                  ),
                ],
              )
      ],
    );
  }

  Widget formSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DateTimeComponent(
              dateController: datMaxDate,
              // controller: ,
              readOnly: true,
              label: _locale.date,
              onValue: (isValid, value) {
                if (isValid) {
                  datMaxDate.text = value;
                }
              },
              height: height * 0.05,
              dateWidth: width * 0.135,
              dateControllerToCompareWith: null,
              isInitiaDate: false,
              timeControllerToCompareWith: null,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            customTextField(
                _locale.docName, documentName, isDesktop, 0.18, true, true),
            const SizedBox(
              width: 5,
            ),
            customTextField(_locale.department, departmentName, isDesktop, 0.18,
                true, true),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            customTextField(_locale.templateName, templateName, isDesktop, 0.18,
                true, true),
            const SizedBox(
              width: 5,
            ),
            // customTextField(_locale.department, departmentName, isDesktop, 0.18,
            //     true, false),
            customTextField(_locale.status, workflowStatusController, isDesktop,
                0.18, true, true),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TableComponent(
              hasDropdown: true,
              isworkFlow: true,

              tableHeigt: height * 0.33,
              tableWidth: width * 0.49,
              // delete: deleteTemplate,
              plCols: polCols,
              mode: PlutoGridMode.selectWithOneTap,
              polRows: rowList,

              rowColor: (colorContext) {
                String localizedStatus =
                    colorContext.row.cells['intStatus']!.value as String;

                int? statusCode = ListConstants.getStatusCodeWorkFlow(
                    localizedStatus, _locale);

                if (statusCode == 1) {
                  // Approved
                  return Colors.green[100]!;
                } else if (statusCode == 0) {
                  // Pending
                  return Colors.orange[100]!;
                } else if (statusCode == 2) {
                  // Rejected
                  return Colors.red[100]!;
                }

                // Default color if status is unknown
                return Colors.grey[200]!;
              },

              doubleTab: (event) async {
                PlutoRow? tappedRow = event.row;
                workFlowTemplateBody =
                    WorkFlowDocumentInfo.fromPluto(tappedRow!, _locale);
              },
              onSelected: (event) async {
                PlutoRow? tappedRow = event.row;
              },
            ),
          ],
        )
      ],
    );
  }

  Widget buildStepCard(DocumentStepsModel step, int index, Key key) {
    TextEditingController descriptionController =
        TextEditingController(text: step.txtStepdesc);
    TextEditingController feedbackController =
        TextEditingController(text: step.txtFeedback);
    String? selectedUserCode = step.txtUsercode;
    int? selectedStatus = step.intStatus;
    TextEditingController stepDate = TextEditingController(
        text: (step.datActionDate!.isEmpty || step.datActionDate == null
            ? Converters.formatDate2(DateTime.now().toString())
            : step.datActionDate)!);

    bool isOptional = step.bolOptional == 1;

    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("${step.intStepno}.",
            style: TextStyle(fontSize: 16)), // Step number

        Expanded(
          child: Card(
            elevation: 8,
            shadowColor: Colors.grey.withOpacity(0.5),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Step description and dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            descriptionTextField(descriptionController, step),
                            const SizedBox(width: 5),
                            feedbackTextField(feedbackController, step),
                          ],
                        ),
                        const SizedBox(height: 5),
                        userListDropdown(step, selectedUserCode, isOptional,
                            selectedStatus!),
                        DateTimeComponent(
                          dateController: stepDate,
                          // controller: ,
                          readOnly: false,
                          label: _locale.date,
                          onValue: (isValid, value) {
                            if (isValid) {
                              stepDate.text = value;
                            }
                          },
                          height: height * 0.05,
                          dateWidth: width * 0.135,
                          dateControllerToCompareWith: null,
                          isInitiaDate: false,
                          timeControllerToCompareWith: null,
                        ),
                      ],
                    ),
                  ),

                  // Right side: Delete icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                      onPressed: () {
                        // Delete step action
                        setState(() {
                          setState(() {
                            steps.removeAt(index);
                          });
                        });
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row userListDropdown(DocumentStepsModel step, String? selectedUserCode,
      bool isOptional, int? status) {
    return Row(
      children: [
        DropDown(
          key: UniqueKey(),
          isMandatory: true,
          onChanged: (value) {
            setState(() {
              step.txtUsercode = value.txtCode;
            });
          },
          initialValue: selectedUserCode == "" ? null : selectedUserCode,
          bordeText: _locale.userName,
          width: width * 0.14,
          items: userList,
          height: height * 0.05,
        ),
        SizedBox(
          width: 5,
        ),
        DropDown(
          key: UniqueKey(),
          isMandatory: true,
          onChanged: (value) {
            // setState(() {
            //   step.intStatus = value.txtCode;
            // });
            selectedStatus =
                ListConstants.getStatusCodeWorkFlow(value, _locale)!;
            step.intStatus =
                ListConstants.getStatusCodeWorkFlow(value, _locale)!;
          },
          // initialValue: selectedUserCode == "" ? null : selectedUserCode,
          initialValue: ListConstants.getStatusNameWorkFlow(status!, _locale),
          bordeText: _locale.status,
          width: width * 0.14,
          items: ListConstants.getStatusWorkFlow(_locale),
          height: height * 0.05,
        ),
        Row(
          children: [
            Checkbox(
              value: isOptional,
              onChanged: (bool? value) {
                setState(() {
                  isOptional = value!;
                  step.bolOptional = isOptional ? 1 : 0; // Update bolOptional
                });
              },
            ),
            Text(_locale.optional),
          ],
        ),
      ],
    );
  }

  CustomTextField2 descriptionTextField(
      TextEditingController descriptionController, DocumentStepsModel step) {
    return CustomTextField2(
      readOnly: false,
      isReport: true,
      isMandetory: true,
      width: width * 0.16,
      height: height * 0.04,
      text: Text(_locale.description),
      controller: descriptionController,
      onSubmitted: (text) {},
      onChanged: (value) {
        step.txtStepdesc = value;
      },
    );
  }

  CustomTextField2 feedbackTextField(
      TextEditingController feedbackController, DocumentStepsModel step) {
    return CustomTextField2(
      readOnly: false,
      isReport: true,
      isMandetory: true,
      width: width * 0.16,
      height: height * 0.04,
      text: Text("Feedback"),
      controller: feedbackController,
      onSubmitted: (text) {},
      onChanged: (value) {
        step.txtFeedback = value;
      },
    );
  }

  void addStep() {
    setState(() {
      steps.add(DocumentStepsModel(
        intStepno: steps.length + 1,
        txtStepdesc: "",
        txtUsercode: null,
        bolOptional: 0,
      ));
    });
  }

  void reorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final step = steps.removeAt(oldIndex);
      steps.insert(newIndex, step);

      // Update step numbers
      for (int i = 0; i < steps.length; i++) {
        steps[i].intStepno = i + 1;
      }
    });
  }

  Widget row(Widget widget1, Widget widget2) {
    return Row(
      children: [
        widget1,
        SizedBox(
          width: width * 0.003,
        ),
        widget2
      ],
    );
  }

  Widget customTextField(String hint, TextEditingController controller,
      bool isDesktop, double width1, bool isMandetory, bool readOnly) {
    return CustomTextField2(
      readOnly: readOnly,
      isReport: true,
      isMandetory: isMandetory,
      width: width * width1,
      height: hint == _locale.notes ? height * 0.1 : height * 0.05,
      text: Text(hint),
      controller: controller,
      onSubmitted: (text) {},
      onChanged: (value) {},
    );
  }

  void addTemplateAndSteps() async {
    // Validate if any step has empty fields
    for (int i = 0; i < steps.length; i++) {
      DocumentStepsModel step = steps[i];
      if (step.txtStepdesc!.trim().isEmpty || step.txtUsercode == null) {
        // Show a dialog with the step number
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              icon: Icons.error,
              errorDetails: _locale.error,
              errorTitle:
                  "Please fill step number ${step.intStepno} or delete it",
              color: Colors.red,
              statusCode: 400,
            );
          },
        );
        return;
      }
    }

    if (workFlowTemplateBody != null) {
      editMethod();
    }
  }

  void editMethod() async {
    WorkFlowDocumentModel templateModel = WorkFlowDocumentModel(
        txtKey: widget.workFlowTemplateBody!.workflow!.txtKey,
        txtDocumentcode: widget.workFlowTemplateBody!.workflow!.txtDocumentcode,
        txtDocumentName: widget.workFlowTemplateBody!.workflow!.txtDocumentName,
        txtTemplatecode: widget.workFlowTemplateBody!.workflow!.txtTemplatecode,
        txtTemplateName: widget.workFlowTemplateBody!.workflow!.txtTemplateName,
        intStatus: widget.workFlowTemplateBody!.workflow!.intStatus,
        datMaxDate: widget.workFlowTemplateBody!.workflow!.datMaxDate,
        dept: widget.workFlowTemplateBody!.workflow!.dept,
        txtDept: selectedDep,
        txtDeptName: widget.workFlowTemplateBody!.workflow!.txtDeptName);
    WorkFlowDocumentInfo workFlowTemplateBody =
        WorkFlowDocumentInfo(stepsList: steps, workflow: templateModel);
    await workFlowTemplateContoller
        .updateDocumentTemplate(workFlowTemplateBody)
        .then((value) {
      if (value.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
                icon: Icons.done_all,
                errorDetails: _locale.done,
                errorTitle: _locale.editDoneSucess,
                color: Colors.green,
                statusCode: 200);
          },
        ).then((value) {
          Navigator.pop(context, true);
        });
      }
    });
  }

  void fillColumnTable() {
    polCols = [
      PlutoColumn(
        readOnly: true,
        title: _locale.description,
        field: "txtStepdesc",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.1 : width * 0.3,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.userCode,
        field: "txtUsercode",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.1 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.status,
        field: "intStatus",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.08 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.notes,
        field: "txtFeedback",
        backgroundColor: columnColors,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.1 : width * 0.4,
      ),
      PlutoColumn(
        readOnly: true,
        title: _locale.date,
        field: "datActionDate",
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

  List<PlutoRow> rowList = [];
  ValueNotifier pageLis = ValueNotifier(1);
  Future<PlutoInfinityScrollRowsResponse> fetch(
      PlutoInfinityScrollRowsRequest request) async {
    bool isLast = false;
    print("inside ftchhhhhh");

    if (pageLis.value != -1) {
      if (pageLis.value > 1) {
        pageLis.value = -1;
      }
      List<WorkFlowDocumentInfo> result = [];
      List<PlutoRow> topList = [];
      result = await WorkFlowTemplateContoller()
          .getWorkFlowDocumentInfo(WorkFlowDocumentModel(txtDept: ""));

      for (int i = pageLis.value == -1 ? 50 : 0; i < result.length; i++) {
        rowList.add(result[i].toPlutoRow(i + 1, _locale)); // Updated here
        topList
            .add(result[i].toPlutoRow(rowList.length, _locale)); // Updated here
      }

      isLast = topList.isEmpty;
      if (pageLis.value == 1) {
        pageLis.value++; // Increment the page number for next fetch
      }
      return Future.value(
          PlutoInfinityScrollRowsResponse(isLast: false, rows: topList));
    }

    return Future.value(
        PlutoInfinityScrollRowsResponse(isLast: isLast, rows: []));
  }
}
