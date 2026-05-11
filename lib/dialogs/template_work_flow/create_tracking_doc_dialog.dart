import 'package:archiving_flutter_project/models/db/user_models/department_user_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/tracking_doc_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/tracking_step_model.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/service/controller/work_flow_controllers/work_flow_template_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:archiving_flutter_project/widget/custom_flutter_toast_message.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../app_dialog.dart';

class CreateTrackingDocDialog extends StatefulWidget {
  final String documentKey;

  const CreateTrackingDocDialog({super.key, required this.documentKey});

  @override
  State<CreateTrackingDocDialog> createState() =>
      _CreateTrackingDocDialogState();
}

class _CreateTrackingDocDialogState extends State<CreateTrackingDocDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  bool isLoading = true;

  TextEditingController notesController = TextEditingController();
  WorkFlowTemplateContoller workFlowTemplateContoller =
      WorkFlowTemplateContoller();

  List<DepartmentUserModel> departmentList = [];
  List<TrackingStepModel> steps = [];
  bool _departmentLoadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
    if (_departmentLoadStarted) return;
    _departmentLoadStarted = true;
    _loadDepartmentsForDropdown();
  }

  Future<void> _loadDepartmentsForDropdown() async {
    final list = await DepartmentController().getDep(SearchModel(page: 1));
    if (!mounted) return;
    setState(() {
      departmentList = list
          .where((d) => d.txtKey != null && d.txtKey!.isNotEmpty)
          .map(
            (d) {
              final name = (d.txtDescription != null &&
                      d.txtDescription!.trim().isNotEmpty)
                  ? d.txtDescription!.trim()
                  : (d.txtShortcode != null &&
                          d.txtShortcode!.trim().isNotEmpty)
                      ? d.txtShortcode!.trim()
                      : d.txtKey;
              return DepartmentUserModel(
                txtDeptkey: d.txtKey,
                txtDeptName: name,
                txtUsercode: null,
                bolSelected: null,
                canWrite: null,
              );
            },
          )
          .toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AppDialog(
      width: isDesktop ? width * 0.68 : width * 0.96,
      height: isDesktop ? height * 0.86 : height * 0.8,
      title: _locale.createTrackingDoc,
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
              onPressed: save,
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
        ),
      ],
    );
  }

  Widget formSection() {
    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNotesPanel(),
          const SizedBox(height: 10),
          Expanded(child: _buildStepsPanel()),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildNotesPanel()),
        const SizedBox(width: 12),
        Expanded(flex: 7, child: _buildStepsPanel()),
      ],
    );
  }

  Widget _buildNotesPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _locale.createTrackingDoc,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _locale.pleaseAddAllRequiredFields,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField2(
                  readOnly: false,
                  isReport: true,
                  isMandetory: true,
                  width: double.infinity,
                  height: height * 0.058,
                  text: Text(_locale.notes),
                  controller: notesController,
                  onSubmitted: (_) {},
                  onChanged: (_) {},
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    text: _locale.addStep,
                    color: primary,
                    icon: Icons.add_task,
                    width: double.infinity,
                    height: height * 0.046,
                    fontSize: 13,
                    onPressed: addStep,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                return buildStepCard(steps[index], index, Key("$index"));
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildStepCard(TrackingStepModel step, int index, Key key) {
    TextEditingController descriptionController =
        TextEditingController(text: step.description);

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description field
                        CustomTextField2(
                          readOnly: false,
                          isReport: true,
                          isMandetory: true,
                          width: width * 0.2,
                          height: height * 0.048,
                          text: Text(_locale.stepDescription),
                          controller: descriptionController,
                          onSubmitted: (_) {},
                          onChanged: (value) {
                            step.description = value;
                          },
                        ),
                        const SizedBox(height: 8),
                        // Department dropdown
                        DropDown(
                          key: UniqueKey(),
                          isMandatory: true,
                          onChanged: (value) {
                            step.deptKey = value.txtDeptkey;
                          },
                          initialValue:
                              step.deptKey == null || step.deptKey!.isEmpty
                                  ? null
                                  : departmentList
                                      .firstWhere(
                                        (d) => d.txtDeptkey == step.deptKey,
                                        orElse: () => departmentList.first,
                                      )
                                      .txtDeptName,
                          bordeText: _locale.department,
                          width: double.infinity,
                          items: departmentList,
                          height: height * 0.058,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          steps.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
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

  void addStep() {
    setState(() {
      steps.add(TrackingStepModel(
        stepOrder: steps.length + 1,
        deptKey: null,
        description: "",
      ));
    });
  }

  void reorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final step = steps.removeAt(oldIndex);
      steps.insert(newIndex, step);
      for (int i = 0; i < steps.length; i++) {
        steps[i].stepOrder = i + 1;
      }
    });
  }

  void save() async {
    if (notesController.text.trim().isEmpty) {
      CustomToastMessage.error(context, _locale.pleaseAddAllRequiredFields);
      return;
    }

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      if (step.description == null ||
          step.description!.trim().isEmpty ||
          step.deptKey == null) {
        CustomToastMessage.error(
            context, "Please fill step number ${step.stepOrder} or delete it");
        return;
      }
    }

    final model = TrackingDocModel(
      documentKey: widget.documentKey,
      notes: notesController.text,
      steps: steps,
    );

    await workFlowTemplateContoller.createTrackingDoc(model).then((value) {
      if (value.statusCode == 200) {
        CustomToastMessage.success(context, _locale.addDoneSucess).then((_) {
          Navigator.pop(context, true);
        });
      }
    });
  }
}
