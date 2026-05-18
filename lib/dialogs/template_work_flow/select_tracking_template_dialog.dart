import 'package:archiving_flutter_project/models/db/work_flow/doc_tracking_template_model.dart';
import 'package:archiving_flutter_project/models/db/work_flow/tracking_doc_model.dart';
import 'package:archiving_flutter_project/service/controller/work_flow_controllers/work_flow_template_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_flutter_toast_message.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/db/work_flow/tracking_response_model.dart';
import '../../widget/custom_drop_down.dart';
import '../app_dialog.dart';

class SelectTrackingTemplateDialog extends StatefulWidget {
  final String documentKey;

  const SelectTrackingTemplateDialog({super.key, required this.documentKey});

  @override
  State<SelectTrackingTemplateDialog> createState() =>
      _SelectTrackingTemplateDialogState();
}

class _SelectTrackingTemplateDialogState
    extends State<SelectTrackingTemplateDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  bool isLoading = true;
  bool isSaving = false;

  List<DocTrackingTemplateModel> templates = [];
  DocTrackingTemplateModel? selectedTemplate;

  final WorkFlowTemplateContoller _controller = WorkFlowTemplateContoller();

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
    templates = await _controller.getDocTrackingTemplates();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);

    if (isLoading) return const Center(child: CircularProgressIndicator());

    return AppDialog(
      width: isDesktop ? width * 0.36 : width * 0.92,
      height: isDesktop ? height * 0.38 : height * 0.44,
      title: _locale.departmentWorkFlow,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _locale.pleaseAddAllRequiredFields,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            DropDown(
              key: UniqueKey(),
              isMandatory: true,
              bordeText: _locale.departmentWorkFlow,
              width: double.infinity,
              height: height * 0.058,
              items: templates,
              initialValue: selectedTemplate == null
                  ? null
                  : templates
                      .firstWhere(
                        (t) => t.key == selectedTemplate!.key,
                        orElse: () => templates.first,
                      )
                      .name,
              onChanged: (value) {
                setState(
                    () => selectedTemplate = value as DocTrackingTemplateModel);
              },
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isSaving
                ? const CircularProgressIndicator()
                : CustomElevatedButton(
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

  Future<void> _save() async {
    if (selectedTemplate == null) {
      CustomToastMessage.error(context, _locale.pleaseAddAllRequiredFields);
      return;
    }

    setState(() => isSaving = true);

    // ── Re-validate: fetch latest tracking state ──────────────────────
    final List<TrackingResponseModel> existingTrackings =
        await _controller.getTrackingByDocument(widget.documentKey);

    if (existingTrackings.isNotEmpty) {
      final bool canCreate = existingTrackings.any((t) {
        final steps = t.steps ?? [];
        if (steps.isEmpty) return false;
        return steps.every((s) => s.intStatus == 4);
      });

      if (!canCreate) {
        if (!mounted) return;
        setState(() => isSaving = false);
        CustomToastMessage.error(
          context,
          _locale.cannotCreateNewTrackingUntilAllStepsComplete,
        );
        return;
      }
    }
    // ─────────────────────────────────────────────────────────────────

    final model = TrackingDocModel(
      documentKey: widget.documentKey,
      templateKey: selectedTemplate!.key,
      name: selectedTemplate!.name,
      notes: null,
      steps: null,
    );

    final res = await _controller.createTrackingDoc(model);

    if (!mounted) return;
    setState(() => isSaving = false);

    if (res.statusCode == 200) {
      CustomToastMessage.success(context, _locale.addDoneSucess)
          .then((_) => Navigator.pop(context, true));
    } else if (res.statusCode == 406) {
      CustomToastMessage.error(context, _locale.createTrackingDocDeptMismatch);
    } else {
      CustomToastMessage.error(context, _locale.error);
    }
  }

  Future<void> _save1() async {
    if (selectedTemplate == null) {
      CustomToastMessage.error(context, _locale.pleaseAddAllRequiredFields);
      return;
    }

    setState(() => isSaving = true);

    final model = TrackingDocModel(
      documentKey: widget.documentKey,
      templateKey: selectedTemplate!.key,
      name: selectedTemplate!.name,
      notes: null,
      steps: null,
    );

    final res = await _controller.createTrackingDoc(model);

    if (!mounted) return;
    setState(() => isSaving = false);

    if (res.statusCode == 200) {
      CustomToastMessage.success(context, _locale.addDoneSucess)
          .then((_) => Navigator.pop(context, true));
    } else if (res.statusCode == 406) {
      CustomToastMessage.error(context, _locale.createTrackingDocDeptMismatch);
    } else {
      CustomToastMessage.error(context, _locale.error);
    }
  }
}
