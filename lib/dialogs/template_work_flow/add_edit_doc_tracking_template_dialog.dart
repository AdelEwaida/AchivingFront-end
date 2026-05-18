import 'package:archiving_flutter_project/models/db/work_flow/doc_tracking_template_model.dart';
import 'package:archiving_flutter_project/models/db/user_models/department_user_model.dart';
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
import '../../models/db/work_flow/doc_tracking_template_step_odel.dart';
import '../app_dialog.dart';

class AddEditDocTrackingTemplateDialog extends StatefulWidget {
  final DocTrackingTemplateModel? model;
  final bool isEdit;

  const AddEditDocTrackingTemplateDialog({
    super.key,
    this.model,
    required this.isEdit,
  });

  @override
  State<AddEditDocTrackingTemplateDialog> createState() =>
      _AddEditDocTrackingTemplateDialogState();
}

class _AddEditDocTrackingTemplateDialogState
    extends State<AddEditDocTrackingTemplateDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  List<DepartmentUserModel> departmentList = [];
  List<DocTrackingTemplateStepModel> steps = [];

  final WorkFlowTemplateContoller _controller = WorkFlowTemplateContoller();

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;

    final departments = await DepartmentController().getDep(SearchModel());
    departmentList = departments
        .map((d) => DepartmentUserModel(
              txtDeptName: d.txtDescription,
              txtDeptkey: d.txtKey,
              txtUsercode: null,
              bolSelected: 0,
              canWrite: 0,
            ))
        .toList();

    if (widget.isEdit && widget.model != null) {
      nameController.text = widget.model!.name ?? '';
      noteController.text = widget.model!.name ?? widget.model!.note ?? '';
      steps = (widget.model!.steps ?? [])
          .map((s) => DocTrackingTemplateStepModel(
                stepOrder: s.stepOrder,
                deptKey: s.deptKey,
                description: s.description,
              ))
          .toList();
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);

    if (isLoading) return const Center(child: CircularProgressIndicator());

    return AppDialog(
      width: isDesktop ? width * 0.68 : width * 0.96,
      height: isDesktop ? height * 0.86 : height * 0.8,
      title: widget.isEdit
          ? _locale.editDepartmentWorkFlow
          : _locale.addDepartmentWorkFlow,
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF8FAFC),
        ),
        width: isDesktop ? width * 0.68 : width * 0.96,
        height: isDesktop ? height * 0.82 : height * 0.8,
        padding: const EdgeInsets.all(12),
        child: _formSection(),
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
              onPressed: _save,
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

  Widget _formSection() {
    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoPanel(),
          const SizedBox(height: 10),
          Expanded(child: _buildStepsPanel()),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildInfoPanel()),
        const SizedBox(width: 12),
        Expanded(flex: 7, child: _buildStepsPanel()),
      ],
    );
  }

  Widget _buildInfoPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isEdit
              ? _locale.editDepartmentWorkFlow
              : _locale.addDepartmentWorkFlow,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF334155)),
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
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                CustomTextField2(
                  readOnly: false,
                  isReport: true,
                  isMandetory: true,
                  width: double.infinity,
                  height: height * 0.058,
                  text: Text(_locale.docName),
                  controller: nameController,
                  onSubmitted: (_) {},
                  onChanged: (_) {},
                ),
                const SizedBox(height: 8),
                CustomTextField2(
                  readOnly: false,
                  isReport: true,
                  isMandetory: false,
                  width: double.infinity,
                  height: height * 0.058,
                  text: Text(_locale.notes),
                  controller: noteController,
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
                    onPressed: _addStep,
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
              color: Color(0xFF334155)),
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
              onReorder: _reorderSteps,
              itemBuilder: (context, index) =>
                  _buildStepCard(steps[index], index, Key('step_$index')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(DocTrackingTemplateStepModel step, int index, Key key) {
    final descCtrl = TextEditingController(text: step.description);

    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 26,
          alignment: Alignment.center,
          child: Text(
            '${index + 1}.',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2563EB)),
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
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField2(
                          readOnly: false,
                          isReport: true,
                          isMandetory: true,
                          width: double.infinity,
                          height: height * 0.048,
                          text: Text(_locale.stepDescription),
                          controller: descCtrl,
                          onSubmitted: (_) {},
                          onChanged: (v) => step.description = v,
                        ),
                        const SizedBox(height: 8),
                        DropDown(
                          key: UniqueKey(),
                          isMandatory: true,
                          onChanged: (value) => step.deptKey = value.txtDeptkey,
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
                  IconButton(
                    onPressed: () => setState(() => steps.removeAt(index)),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addStep() {
    setState(() {
      steps.add(DocTrackingTemplateStepModel(
        stepOrder: steps.length + 1,
        deptKey: null,
        description: '',
      ));
    });
  }

  void _reorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final step = steps.removeAt(oldIndex);
      steps.insert(newIndex, step);
      for (int i = 0; i < steps.length; i++) {
        steps[i].stepOrder = i + 1;
      }
    });
  }

  Future<void> _save() async {
    if (nameController.text.trim().isEmpty) {
      CustomToastMessage.error(context, _locale.pleaseAddAllRequiredFields);
      return;
    }

    for (int i = 0; i < steps.length; i++) {
      final s = steps[i];
      if (s.description == null ||
          s.description!.trim().isEmpty ||
          s.deptKey == null) {
       CustomToastMessage.error(
          context,
          _locale.pleaseFillStepOrDelete(s.stepOrder!),
        );
        return;
      }
    }

    final model = DocTrackingTemplateModel(
      key: widget.model?.key,
      name: nameController.text.trim(),
      note: noteController.text.trim(),
      steps: steps,
    );

    if (widget.isEdit) {
      final res = await _controller.updateDocTrackingTemplateReq(model);
      if (!mounted) return;
      if (res.statusCode == 200) {
        CustomToastMessage.success(context, _locale.editDoneSucess)
            .then((_) => Navigator.pop(context, true));
      } else {
        CustomToastMessage.error(context, _locale.error);
      }
    } else {
      final res = await _controller.insertDocTrackingTemplateReq(model);
      if (!mounted) return;
      if (res.statusCode == 200) {
        CustomToastMessage.success(context, _locale.addDoneSucess)
            .then((_) => Navigator.pop(context, true));
      } else {
        CustomToastMessage.error(context, _locale.error);
      }
    }
  }
}
