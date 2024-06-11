import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/styles.dart';
import '../../../widget/text_field_widgets/custom_text_field2_.dart';

class EditCategoryDialog extends StatefulWidget {
  const EditCategoryDialog({super.key});
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

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;

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
    final double dialogWidth = width * 0.3;
    final double dialogheight = height * 0.13;
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          Text(_locale.editCategory),
          Container(
            decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                color: Color.fromARGB(255, 237, 34, 20)),
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                )),
          ),
        ],
      ),
      content: SizedBox(
        height: dialogheight,
        width: dialogWidth,
        child: Column(
          children: [
            CustomTextField2(
              text: Text(_locale.description),
              width: width * 0.25,
              height: height * 0.045,
              controller: descriptionController,
              onSubmitted: (text) {},
              onChanged: (value) {},
            ),
            CustomDropDown(
              width: width * 0.25,
              onChanged: (value) {},
              searchBox: true,
              valSelected: true,
              bordeText: _locale.department,
              // width: width * 0.21,
              heightVal: height * 0.3,
            )
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: customButtonStyle1(Size(width * 0.08, height * 0.045),
                    16, const Color(0xff1F6E8C)),
                child: Text(
                  _locale.search,
                  style: const TextStyle(color: whiteColor),
                ),
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
        )
      ],
    );
  }
}
