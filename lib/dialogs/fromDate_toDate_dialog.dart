import 'dart:typed_data';
import 'package:archiving_flutter_project/dialogs/app_dialog.dart';
import 'package:archiving_flutter_project/models/dto/reports_criteria.dart';
import 'package:archiving_flutter_project/service/controller/actions_controllers/action_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widget/date_time_component.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';
import '../widget/dashboard_components/custom_elevated_button.dart';

class FromDateToDateDialog extends StatefulWidget {
  ReportsCriteria? searchCriteria;
  FromDateToDateDialog({super.key, this.searchCriteria});

  @override
  State<FromDateToDateDialog> createState() => _FromDateToDateDialogState();
}

class _FromDateToDateDialogState extends State<FromDateToDateDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  double radius = 7;

  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();

  ActionController actionController = ActionController();
  String isRecurring = "";

  int selectedRecurring = -1;
  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    fromDateController.text = widget.searchCriteria!.fromDate!;
    toDateController.text = widget.searchCriteria!.toDate!;
    super.didChangeDependencies();
  }

  bool isDesktop = false;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);

    return AppDialog(
      title: _locale.search,
      width: isDesktop ? width * 0.3 : width * 0.8,
      height: height * 0.8,
      content: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: isDesktop ? height * 0.2 : height * 0.5,
        child: SingleChildScrollView(
          child: formSection(),
        ),
      ),
      actions: [
        isDesktop
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomElevatedButton(
                    text: _locale.save,
                    color: primary,
                    // icon: Icons.check_rounded,
                    width: isDesktop ? width * 0.1 : width * 0.4,
                    height: height * 0.045,
                    fontSize: isDesktop ? 14 : 18,
                    onPressed: () => addAction(),
                  ),
                  SizedBox(width: isDesktop ? width * 0.01 : 0),
                  SizedBox(height: isDesktop ? 0 : height * 0.01),
                  CustomElevatedButton(
                    text: _locale.cancel,
                    color: redColor,
                    // icon: Icons.close_rounded,
                    width: isDesktop ? width * 0.1 : width * 0.4,
                    height: height * 0.045,
                    fontSize: isDesktop ? 14 : 18,
                    onPressed: () => Navigator.pop(context, false),
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
                          addAction();
                        },
                        style: customButtonStyle(
                            context,
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
                            context,
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isDesktop)
          DateTimeComponent(
            label: _locale.fromDate,
            dateController: fromDateController,
            dateWidth: width * 0.15,
            dateControllerToCompareWith: null,
            readOnly: false,
            isInitiaDate: true,
            onValue: (isValid, value) {
              if (isValid) {
                fromDateController.text = value;
              }
            },
            timeControllerToCompareWith: null,
          ),
        DateTimeComponent(
          label: _locale.toDate,
          dateController: toDateController,
          dateWidth: width * 0.15,
          dateControllerToCompareWith: null,
          readOnly: false,
          isInitiaDate: true,
          onValue: (isValid, value) {
            if (isValid) {
              toDateController.text = value;
            }
          },
          timeControllerToCompareWith: null,
        ),
      ],
    );
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
      bool isDesktop, double width1, bool isMandetory) {
    return CustomTextField2(
      readOnly: false,
      isReport: true,
      isMandetory: isMandetory,
      width: width * width1,
      height: height * 0.05,
      text: Text(hint),
      controller: controller,
      onSubmitted: (text) {},
      onChanged: (value) {},
    );
  }

  void addAction() async {
    ReportsCriteria searchCriteria = ReportsCriteria(
        fromDate: fromDateController.text, toDate: toDateController.text);
    Navigator.pop(context, searchCriteria);
  }
}
