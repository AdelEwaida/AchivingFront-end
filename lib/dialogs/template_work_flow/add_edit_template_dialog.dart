import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/steps_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/template_model.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/db/user_models/department_user_model.dart';
import '../../models/db/work_flow/work_flow_template_body.dart';
import '../../models/dto/searchs_model/search_model.dart';
import '../../service/controller/work_flow_controllers/work_flow_template_controller.dart';
import '../../widget/dashboard_components/custom_elevated_button.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';
import '../app_dialog.dart';

class AddEditTemplateDialog extends StatefulWidget {
  final WorkFlowTemplateBody? workFlowTemplateBody;
  final bool isEditDialog;
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
    return AppDialog(
      width: isDesktop ? width * 0.68 : width * 0.96,
      height: isDesktop ? height * 0.86 : height * 0.8,
      // titlePadding: EdgeInsets.all(0),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      // backgroundColor: Colors.white,
      title: workFlowTemplateBody != null && widget.isEditDialog
          ? _locale.editWorkFlow
          : _locale.addWorkFlow,
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: const Color(0xFFF8FAFC),
        ),
        width: isDesktop ? width * 0.68 : width * 0.96,
        height: isDesktop ? height * 0.82 : height * 0.8,
        padding: const EdgeInsets.all(12),
        child: formSection(),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomElevatedButton(
              text: _locale.save,
              color: primary,
              icon: Icons.save,
              width: isDesktop ? width * 0.11 : width * 0.36,
              height: height * 0.048,
              fontSize: 15,
              onPressed: addTemplateAndSteps,
            ),
            SizedBox(width: isDesktop ? 8 : 10),
            CustomElevatedButton(
              text: _locale.cancel,
              color: redColor,
              icon: Icons.close,
              width: isDesktop ? width * 0.11 : width * 0.36,
              height: height * 0.048,
              fontSize: 15,
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        )
      ],
    );
  }

  Widget formSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: customTextField(_locale.docName, templateName, isDesktop,
                    0.18, true, widget.isEditDialog,
                    focusNode: templateNameFocusNode),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: customTextField(_locale.docDesc, templateDescription,
                    isDesktop, 0.18, true, widget.isEditDialog),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropDown(
                  key: UniqueKey(),
                  isMandatory: true,
                  onChanged: (value) {
                    selectedDep = value.txtDeptkey;
                    selctedDepDesc = value.txtDeptName;
                  },
                  initialValue: selctedDepDesc == "" ? null : selctedDepDesc,
                  bordeText: _locale.department,
                  width: width * 0.18,
                  items: departmetList,
              height: height * 0.058,
                ),
              ),
              const SizedBox(width: 8),
              CustomElevatedButton(
                text: _locale.addStep,
                color: primary,
                icon: Icons.add_task,
                width: isDesktop ? width * 0.12 : width * 0.34,
                height: height * 0.042,
                fontSize: 13,
                onPressed: addStep,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _locale.stepDescription,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: steps.length,
              shrinkWrap: true,
              onReorder: reorderSteps,
              itemBuilder: (context, index) {
                final step = steps[index];
                return buildStepCard(step, index, Key("$index"));
              },
            ),
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
        Container(
          width: 26,
          alignment: Alignment.center,
          child: Text(
            "${index + 1}.",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2563EB),
            ),
          ),
        ),

        Expanded(
          child: Card(
            elevation: 1.2,
            shadowColor: Colors.black.withOpacity(0.04),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Step description and dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        descriptionTextField(descriptionController, step),
                        const SizedBox(height: 8),
                        userListDropdown(step, selectedUserCode, isOptional),
                      ],
                    ),
                  ),

                  // Right side: Delete icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          steps.removeAt(index);
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
        Expanded(
          child: DropDown(
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
            height: height * 0.058,
          ),
        ),
        const SizedBox(width: 8),
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
      width: width * 0.2,
      height: height * 0.048,
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
      height: hint == _locale.notes ? height * 0.11 : height * 0.058,
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
