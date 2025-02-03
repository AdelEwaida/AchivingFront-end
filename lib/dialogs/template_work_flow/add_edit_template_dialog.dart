import 'dart:typed_data';
import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/steps_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/template_model.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:archiving_flutter_project/widget/dialog_widgets/title_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/db/user_models/department_user_model.dart';
import '../../models/db/work_flow/work_flow_template_body.dart';
import '../../models/dto/searchs_model/search_model.dart';
import '../../service/controller/work_flow_controllers/work_flow_template_controller.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';

class AddEditTemplateDialog extends StatefulWidget {
  WorkFlowTemplateBody? workFlowTemplateBody;
  bool isEditDialog;
  AddEditTemplateDialog(
      {super.key, this.workFlowTemplateBody, required this.isEditDialog});

  @override
  State<AddEditTemplateDialog> createState() => _DepartmentDialogState();
}

class _DepartmentDialogState extends State<AddEditTemplateDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  double radius = 7;

  TextEditingController templateName = TextEditingController();
  TextEditingController templateDescription = TextEditingController();
  TextEditingController stepDescription = TextEditingController();
  TextEditingController stepDescriptionController = TextEditingController();
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
  List<StepsModel> steps = [];
  bool isActive = false;
  bool isOptional = false;
  bool isLoading = true;
  WorkFlowTemplateBody? workFlowTemplateBody;
  FocusNode templateNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      templateNameFocusNode.requestFocus();
    });
  }

  @override
  Future<void> didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    userName = await storage.read(key: "userName");
    departmetList = await UserController().getDepartmentSelectedUser(userName!);
    setState(() {});
    userList = await userController
        .getUsers(SearchModel(searchField: '', page: -1, status: -1));
    setState(() {});

    if (widget.workFlowTemplateBody != null) {
      workFlowTemplateBody = widget.workFlowTemplateBody!;
      templateName.text = workFlowTemplateBody!.template!.txtName ?? "";
      templateDescription.text =
          workFlowTemplateBody!.template!.txtDescription ?? "";
      selectedDep = workFlowTemplateBody!.template!.txtDept ?? "";
      selctedDepDesc = workFlowTemplateBody!.template!.txtDeptName ?? "";

      steps = workFlowTemplateBody!.stepsList ?? [];
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
        title: workFlowTemplateBody != null && widget.isEditDialog
            ? _locale.editWorkFlow
            : _locale.addWorkFlow,
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: height * 0.07,
      ),
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
        ),
        width: isDesktop ? width * 0.43 : width * 0.8,
        height: isDesktop ? height * 0.65 : height * 0.5,
        child: formSection(),
      ),
      actions: [
        isDesktop
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      addTemplateAndSteps();
                    },
                    style: customButtonStyle(
                        Size(isDesktop ? width * 0.1 : width * 0.4,
                            height * 0.045),
                        18,
                        primary),
                    child: Text(
                      _locale.save,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.01,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: customButtonStyle(
                        Size(isDesktop ? width * 0.1 : width * 0.4,
                            height * 0.045),
                        18,
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
                      ElevatedButton(
                        onPressed: () {
                          addTemplateAndSteps();
                        },
                        style: customButtonStyle(
                            Size(isDesktop ? width * 0.1 : width * 0.4,
                                height * 0.045),
                            18,
                            greenColor),
                        child: Text(
                          _locale.save,
                          style: const TextStyle(color: whiteColor),
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: customButtonStyle(
                            Size(isDesktop ? width * 0.1 : width * 0.4,
                                height * 0.045),
                            18,
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
          children: [
            customTextField(_locale.docName, templateName, isDesktop, 0.18,
                true, widget.isEditDialog,
                focusNode: templateNameFocusNode),
            const SizedBox(
              width: 5,
            ),
            customTextField(_locale.docDesc, templateDescription, isDesktop,
                0.18, true, widget.isEditDialog),
          ],
        ),
        Row(
          children: [
            DropDown(
              key: UniqueKey(),
              isMandatory: true,
              onChanged: (value) {
                selectedDep = value.txtDeptkey;
                selctedDepDesc = value.txtDeptName;
                // setState(() {});
              },
              initialValue: selctedDepDesc == "" ? null : selctedDepDesc,
              bordeText: _locale.department,
              width: width * 0.18,
              items: departmetList,
              height: height * 0.05,
            ),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              onPressed: () {
                addStep();
              },
              style: customButtonStyle(
                  Size(isDesktop ? width * 0.1 : width * 0.4, height * 0.036),
                  14,
                  primary),
              child: Text(
                _locale.addStep,
                style: TextStyle(color: whiteColor),
              ),
            ),
          ],
        ),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: steps.length,
            shrinkWrap: true,
            onReorder: reorderSteps,
            itemBuilder: (context, index) {
              final step = steps[index];
              return buildStepCard(step, index, Key("$index"));
            },
          ),
        ),
      ],
    );
  }

  Widget buildStepCard(StepsModel step, int index, Key key) {
    TextEditingController descriptionController =
        TextEditingController(text: step.txtStepdesc);
    String? selectedUserCode = step.txtUsercode;
    bool isOptional = step.bolOptional == 1;

    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("${index + 1}.", style: TextStyle(fontSize: 16)), // Step number

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
                        descriptionTextField(descriptionController, step),
                        const SizedBox(height: 5),
                        userListDropdown(step, selectedUserCode, isOptional),
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

  Widget buildStepCard1(StepsModel step, int index, Key key) {
    TextEditingController descriptionController =
        TextEditingController(text: step.txtStepdesc);
    String? selectedUserCode = step.txtUsercode;
    bool isOptional = step.bolOptional == 1;

    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("${index + 1}.", style: TextStyle(fontSize: 16)), // Step number
        Expanded(
          child: Card(
            elevation: 8,
            shadowColor: Colors.grey.withOpacity(0.5),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          descriptionTextField(descriptionController, step),
                          const SizedBox(height: 5),
                          userListDropdown(step, selectedUserCode, isOptional),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () async {
                            TemplateModel templateModel = TemplateModel(
                              txtKey: step.txtKey,
                            );
                            WorkFlowTemplateBody tempModel =
                                WorkFlowTemplateBody(
                                    stepsList: null, template: templateModel);
                            await workFlowTemplateContoller
                                .removeTemplate(tempModel);
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row userListDropdown(
      StepsModel step, String? selectedUserCode, bool isOptional) {
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
          width: width * 0.18,
          items: userList,
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
      TextEditingController descriptionController, StepsModel step) {
    return CustomTextField2(
      readOnly: false,
      isReport: true,
      isMandetory: true,
      width: width * 0.16,
      height: height * 0.04,
      text: Text(_locale.stepDescription),
      controller: descriptionController,
      onSubmitted: (text) {},
      onChanged: (value) {
        step.txtStepdesc = value;
      },
    );
  }

  void addStep() {
    setState(() {
      steps.add(StepsModel(
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
      bool isDesktop, double width1, bool isMandetory, bool readOnly,
      {FocusNode? focusNode}) {
    return CustomTextField2(
      readOnly: readOnly,
      isReport: true,
      isMandetory: isMandetory,
      width: width * width1,
      height: hint == _locale.notes ? height * 0.1 : height * 0.05,
      text: Text(hint),
      controller: controller,
      onSubmitted: (text) {},
      focusNode: focusNode,
      onChanged: (value) {},
    );
  }

  void addTemplateAndSteps() async {
    // Validate if any step has empty fields
    for (int i = 0; i < steps.length; i++) {
      StepsModel step = steps[i];
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

    // Check template fields
    if (templateName.text.trim().isEmpty ||
        templateDescription.text.trim().isEmpty ||
        selectedDep.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
              icon: Icons.error,
              errorDetails: _locale.error,
              errorTitle: _locale.pleaseAddAllRequiredFields,
              color: Colors.red,
              statusCode: 400);
        },
      );
      return;
    } else if (workFlowTemplateBody != null && widget.isEditDialog == true) {
      editMethod();
    } else {
      // Proceed with saving the template and steps
      TemplateModel templateModel = TemplateModel(
          txtDept: selectedDep,
          txtDescription: templateDescription.text,
          txtName: templateName.text);
      WorkFlowTemplateBody tempModel =
          WorkFlowTemplateBody(stepsList: steps, template: templateModel);
      await workFlowTemplateContoller.addTemplate(tempModel).then((value) {
        if (value.statusCode == 200) {
          showDialog(
            context: context,
            builder: (context) {
              return ErrorDialog(
                  icon: Icons.done_all,
                  errorDetails: _locale.done,
                  errorTitle: _locale.addDoneSucess,
                  color: Colors.green,
                  statusCode: 200);
            },
          ).then((value) {
            Navigator.pop(context, true);
          });
        }
      });
    }
  }

  void addTemplateAndSteps1() async {
    if (templateName.text.trim().isEmpty ||
        templateDescription.text.trim().isEmpty ||
        selctedDepDesc.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
              icon: Icons.error,
              errorDetails: _locale.error,
              errorTitle: _locale.pleaseAddAllRequiredFields,
              color: Colors.red,
              statusCode: 400);
        },
      );
    } else if (userModel != null && widget.isEditDialog == false) {
      editMethod();
    } else {
      TemplateModel templateModel = TemplateModel(
          txtDept: selctedDepDesc,
          txtDescription: templateDescription.text,
          txtName: templateName.text);
      WorkFlowTemplateBody workFlowTemplateBody =
          WorkFlowTemplateBody(stepsList: steps, template: templateModel);
      await workFlowTemplateContoller
          .addTemplate(workFlowTemplateBody)
          .then((value) {
        if (value.statusCode == 200) {
          showDialog(
            context: context,
            builder: (context) {
              return ErrorDialog(
                  icon: Icons.done_all,
                  errorDetails: _locale.done,
                  errorTitle: _locale.addDoneSucess,
                  color: Colors.green,
                  statusCode: 200);
            },
          ).then((value) {
            Navigator.pop(context, true);
          });
        }
      });
    }
  }

  void editMethod() async {
    TemplateModel templateModel = TemplateModel(
        txtDept: selectedDep,
        txtDescription: templateDescription.text,
        txtKey: widget.workFlowTemplateBody!.template!.txtKey,
        txtName: templateName.text);
    WorkFlowTemplateBody workFlowTemplateBody =
        WorkFlowTemplateBody(stepsList: steps, template: templateModel);
    await workFlowTemplateContoller
        .editTemplate(workFlowTemplateBody)
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
}
