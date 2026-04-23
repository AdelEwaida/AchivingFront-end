import 'package:archiving_flutter_project/models/db/categories_models/document_category_tree.dart';
import 'package:archiving_flutter_project/models/dto/category_dto_model/insert_category_model.dart';
import 'package:archiving_flutter_project/service/controller/categories_controllers/categories_controller.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../utils/constants/colors.dart';
import '../../utils/func/responsive.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';
import '../app_dialog.dart';

class EditCategoryDialog extends StatefulWidget {
  DocumentCategory? category;
  EditCategoryDialog({super.key, this.category});
  @override
  State<EditCategoryDialog> createState() => _AdvanceSearchLogsDialogState();
}

class _AdvanceSearchLogsDialogState extends State<EditCategoryDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AppLocalizations _locale;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController refNumberController = TextEditingController();
  FocusNode descriptionFocusNode = FocusNode();

  double width = 0;
  double height = 0;
  bool isDesktop = false;
  CategoriesController categoriesController = CategoriesController();
  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    descriptionController.text = widget.category!.docCatParent!.txtDescription!;
    refNumberController.text =
        widget.category!.docCatParent!.txtReference ?? "";
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      descriptionFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);

    final double dialogWidth = width * 0.3;
    final double dialogheight = height * 0.13;
    return AppDialog(
      width: isDesktop ? width * 0.3 : width * 0.8,
      height: height * 0.8,
      title: _locale.editCategory,
      // contentPadding: EdgeInsets.zero,
      content: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const SizedBox(height: 20),
            CustomTextField2(
              text: Text(_locale.description),
              width: width * 0.25,
              height: height * 0.045,
              controller: descriptionController,
              onSubmitted: (text) {},
              onChanged: (value) {},
              focusNode: descriptionFocusNode,
            ),
            const SizedBox(height: 20),
            CustomTextField2(
              text: Text(_locale.refNumber),
              width: width * 0.25,
              height: height * 0.045,
              controller: refNumberController,
              onSubmitted: (text) {},
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomElevatedButton(
                    height: height * 0.045,
                    width: isDesktop ? width * 0.1 : width * 0.4,
                    text: _locale.save,
                    color: primary,
                    onPressed: () {
                      save();
                    }),
                SizedBox(
                  width: width * 0.01,
                ),
                CustomElevatedButton(
                    height: height * 0.045,
                    width: isDesktop ? width * 0.1 : width * 0.4,
                    text: _locale.cancel,
                    color: redColor,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void save() {
    InsertCategoryModel updateModel = InsertCategoryModel(
        deptCode: widget.category!.docCatParent!.txtDeptcode!,
        description: descriptionController.text,
        shortCode: widget.category!.docCatParent!.txtShortcode,
        txtReference: refNumberController.text);
    categoriesController.updateCategory(updateModel).then((value) {
      if (value.statusCode == 200) {
        Navigator.pop(context, true);
      }
    });
  }
}
