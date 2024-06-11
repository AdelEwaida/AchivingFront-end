import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:archiving_flutter_project/widget/date_time_component.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FillterFileSection extends StatefulWidget {
  const FillterFileSection({super.key});

  @override
  State<FillterFileSection> createState() => _FillterFileSectionState();
}

class _FillterFileSectionState extends State<FillterFileSection> {
  late AppLocalizations _locale;
  double width = 0;
  bool isDesktop = false;

  double height = 0;
  TextEditingController fromDateController =
      TextEditingController(text: Converters.getDateBeforeMonth());
  TextEditingController toDateController = TextEditingController(
      text: Converters.formatDate2(DateTime.now().toString()));
  TextEditingController descreptionController = TextEditingController();
  TextEditingController issueNoController = TextEditingController();
  TextEditingController classificationController = TextEditingController();
  TextEditingController keyWordController = TextEditingController();
  TextEditingController ref1Controller = TextEditingController();
  TextEditingController ref2Controller = TextEditingController();
  TextEditingController otherRefController = TextEditingController();
  TextEditingController organizationController = TextEditingController();
  TextEditingController followingController = TextEditingController();
  TextEditingController sortedByController = TextEditingController();
  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    isDesktop = Responsive.isDesktop(context);

    return Container(
      width: width * 0.44,
      height: height * 0.6,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
              children: [
                DateTimeComponent(
                    dateControllerToCompareWith: null,
                    isInitiaDate: true,
                    dateWidth: width * 0.1,
                    dateController: fromDateController,
                    label: _locale.fromDate,
                    timeControllerToCompareWith: null),
                space(0.01),
                DateTimeComponent(
                    dateControllerToCompareWith: null,
                    isInitiaDate: true,
                    height: height * 0.04,
                    dateWidth: width * 0.1,
                    dateController: toDateController,
                    label: _locale.toDate,
                    timeControllerToCompareWith: null),
                space(0.01),
                CustomTextField2(
                  width: width * 0.1,
                  height: height * 0.04,
                  text: Text(_locale.description),
                  controller: descreptionController,
                ),
                space(0.01),
                CustomTextField2(
                  width: width * 0.1,
                  height: height * 0.04,
                  text: Text(_locale.issueNo),
                  controller: issueNoController,
                )
              ],
            ),
          ),
          SizedBox(
            height: height * 0.01,
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
              children: [
                DropDown(
                  onChanged: (value) {},
                  bordeText: _locale.department,
                  width: width * 0.1,
                  height: height * 0.04,
                  onSearch: (p0) async {
                    return await DepartmentController()
                        .getDep(SearchModel(page: 1));
                  },
                ),
                space(0.01),
                CustomTextField2(
                  text: Text(_locale.classification),
                  controller: classificationController,
                  width: width * 0.1,
                  height: height * 0.04,
                ),
                space(0.01),
                CustomTextField2(
                  text: Text(_locale.keyword),
                  controller: keyWordController,
                  width: width * 0.1,
                  height: height * 0.04,
                ),
                space(0.01),
                DropDown(
                  onChanged: (value) {},
                  bordeText: _locale.contractType,
                  width: width * 0.1,
                  height: height * 0.04,
                  items: ["1", "2"],
                  // onSearch: (p0) async {
                  //   return await DepartmentController()
                  //       .getDep(SearchModel(page: 1));
                  // },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
              children: [
                CustomTextField2(
                  text: Text(_locale.ref1),
                  controller: ref1Controller,
                  width: width * 0.1,
                  height: height * 0.04,
                ),
                space(0.01),
                CustomTextField2(
                  text: Text(_locale.ref2),
                  controller: ref2Controller,
                  width: width * 0.1,
                  height: height * 0.04,
                ),
                space(0.01),
                CustomTextField2(
                  text: Text(_locale.otherRef),
                  controller: otherRefController,
                  width: width * 0.1,
                  height: height * 0.04,
                ),
                space(0.01),
                CustomTextField2(
                  text: Text(_locale.organization),
                  controller: organizationController,
                  width: width * 0.1,
                  height: height * 0.04,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
              children: [
                // space(0.01),
                CustomTextField2(
                  text: Text(_locale.following),
                  controller: followingController,
                  width: width * 0.1,
                  height: height * 0.04,
                ),
                space(0.01),
                //sortedByController
                CustomTextField2(
                  text: Text(_locale.sortedBy),
                  controller: sortedByController,
                  width: width * 0.1,
                  height: height * 0.04,
                ),
              ],
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // addAction();
              },
              style: customButtonStyle(
                  Size(isDesktop ? width * 0.1 : width * 0.4, height * 0.045),
                  18,
                  greenColor),
              child: Text(
                _locale.search,
                style: const TextStyle(color: whiteColor),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget space(double width1) {
    return SizedBox(
      width: width * width1,
    );
  }
}
