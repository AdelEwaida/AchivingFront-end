import 'package:archiving_flutter_project/models/db/categories_models/document_category_tree.dart';
import 'package:archiving_flutter_project/models/dto/category_dto_model/insert_category_model.dart';
import 'package:archiving_flutter_project/service/controller/categories_controllers/categories_controller.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/styles.dart';
import '../../../utils/func/responsive.dart';
import '../../../widget/dialog_widgets/title_dialog_widget.dart';
import '../../../widget/text_field_widgets/custom_text_field2_.dart';

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

  double width = 0;
  double height = 0;
  bool isDesktop = false;
  CategoriesController categoriesController = CategoriesController();
  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    descriptionController.text = widget.category!.docCatParent!.txtDescription!;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
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
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      title: TitleDialogWidget(
        title: _locale.editCategory,
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: height * 0.07,
      ),
      contentPadding: EdgeInsets.zero,
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
            ),
            // CustomDropDown(
            //   width: width * 0.25,
            //   onChanged: (value) {},
            //   searchBox: true,
            //   valSelected: true,
            //   bordeText: _locale.department,
            //   // width: width * 0.21,
            //   heightVal: height * 0.3,
            // ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    save();
                  },
                  style: customButtonStyle1(Size(width * 0.08, height * 0.045),
                      16, const Color(0xff1F6E8C)),
                  child: Text(
                    _locale.save,
                    style: const TextStyle(color: whiteColor),
                  ),
                ),
                SizedBox(
                  width: width * 0.01,
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: customButtonStyle1(
                      Size(width * 0.1, height * 0.045), 16, redColor),
                  child: Text(
                    _locale.cancel,
                    style: const TextStyle(color: whiteColor),
                  ),
                )
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
    );
    categoriesController.updateCategory(updateModel).then((value) {
      if (value.statusCode == 200) {
        Navigator.pop(context, true);
      }
    });
  }
}
