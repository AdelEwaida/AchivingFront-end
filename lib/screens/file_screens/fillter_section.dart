import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_document_criterea.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';
import 'package:archiving_flutter_project/providers/classification_name_and_code_provider.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/utils/constants/api_constants.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/sorted_by_constant.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:archiving_flutter_project/widget/date_time_component.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

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
  String selectedDep = "";
  int selectedSortedType = -1;
  DocumentsController documentsController = DocumentsController();
  late DocumentListProvider documentListProvider;
  late CalssificatonNameAndCodeProvider calssificatonNameAndCodeProvider;
  List<DepartmentModel> listOfDep = [];
  @override
  Future<void> didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    documentListProvider = context.read<DocumentListProvider>();
    calssificatonNameAndCodeProvider =
        context.read<CalssificatonNameAndCodeProvider>();
    if (documentListProvider.issueNumber != null) {
      issueNoController.text = documentListProvider.issueNumber ?? "";
      documentListProvider.setDocumentSearchCriterea(
          SearchDocumentCriteria(issueNo: issueNoController.text));
    }
    listOfDep = await DepartmentController().getDep(SearchModel(page: 1));
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    documentListProvider.setIssueNumber(null);
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isDesktop = Responsive.isDesktop(context);

    return Container(
      width: width * 0.44,
      height: height * 0.34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DateTimeComponent(
                          height: height * 0.04,
                          dateControllerToCompareWith: null,
                          isInitiaDate: true,
                          dateWidth: width * 0.1,
                          dateController: fromDateController,
                          label: _locale.fromDate,
                          onValue: (isValid, value) {
                            if (isValid) {
                              // setState(() {
                              fromDateController.text = value;
                              // });
                            }
                          },
                          timeControllerToCompareWith: null),
                      space(0.01),
                      DateTimeComponent(
                          dateControllerToCompareWith: null,
                          isInitiaDate: true,
                          height: height * 0.04,
                          dateWidth: width * 0.1,
                          dateController: toDateController,
                          label: _locale.toDate,
                          onValue: (isValid, value) {
                            if (isValid) {
                              // setState(() {
                              toDateController.text = value;
                              // });
                            }
                          },
                          timeControllerToCompareWith: null),
                    ],
                  ),
                  space(0.01),
                  DropDown(
                    key: UniqueKey(),
                    onChanged: (value) {
                      selectedDep = value.txtKey;
                      // setState(() {});
                    },
                    initialValue: selectedDep.isEmpty ? null : selectedDep,
                    bordeText: _locale.department,
                    width: width * 0.1,
                    height: height * 0.04,
                    items: listOfDep,
                    // onSearch: (p0) async {
                    //   return await DepartmentController()
                    //       .getDep(SearchModel(page: 1));
                    // },
                  ),
                  space(0.01),
                  DropDown(
                    key: UniqueKey(),
                    onChanged: (value) {
                      selectedSortedType = getSortedByTyepsCode(_locale, value);
                    },
                    initialValue: selectedSortedType == -1
                        ? null
                        : getSortedByTyepsByCode(_locale, selectedSortedType),
                    bordeText: _locale.sortedBy,
                    items: getSortedByTyeps(_locale),
                    width: width * 0.1,
                    height: height * 0.04,
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.00001,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomTextField2(
                    width: width * 0.1,
                    height: height * 0.04,
                    text: Text(_locale.description),
                    controller: descreptionController,
                  ),
                  space(0.01),
                  Consumer<CalssificatonNameAndCodeProvider>(
                    builder: (context, value, child) {
                      classificationController.text = value.classificatonName;

                      return CustomTextField2(
                        text: Text(_locale.classification),
                        controller: classificationController,
                        width: width * 0.1,
                        height: height * 0.04,
                        readOnly: true,
                      );
                    },
                  ),
                  space(0.01),
                  CustomTextField2(
                    text: Text(_locale.keyword),
                    controller: keyWordController,
                    width: width * 0.1,
                    height: height * 0.04,
                  ),
                  space(0.01),
                  CustomTextField2(
                    text: Text(_locale.ref1),
                    controller: ref1Controller,
                    width: width * 0.1,
                    height: height * 0.04,
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.00001,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                  space(0.01),
                  CustomTextField2(
                    text: Text(_locale.following),
                    controller: followingController,
                    width: width * 0.1,
                    height: height * 0.04,
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.00001,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    CustomTextField2(
                      width: width * 0.1,
                      height: height * 0.04,
                      text: Text(_locale.issueNo),
                      controller: issueNoController,
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: height * 0.00001,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  search();
                },
                style: customButtonStyle(
                    Size(isDesktop ? width * 0.1 : width * 0.4, height * 0.043),
                    14,
                    primary),
                child: Text(
                  _locale.search,
                  style: const TextStyle(color: whiteColor),
                ),
              ),
              SizedBox(
                width: width * 0.01,
              ),
              ElevatedButton(
                onPressed: () {
                  resetForm();
                },
                style: customButtonStyle(
                    Size(
                        isDesktop ? width * 0.12 : width * 0.4, height * 0.043),
                    14,
                    Colors.red),
                child: Text(
                  _locale.resetFilter,
                  style: const TextStyle(color: whiteColor),
                ),
              ),
            ],
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

  void resetForm() {
    fromDateController.text = Converters.getDateBeforeMonth();
    toDateController.text = Converters.formatDate2(DateTime.now().toString());
    descreptionController.clear();
    issueNoController.clear();
    classificationController.clear();
    keyWordController.clear();
    ref1Controller.clear();
    ref2Controller.clear();
    otherRefController.clear();
    organizationController.clear();
    followingController.clear();
    selectedDep = "";
    selectedSortedType = -1;
    calssificatonNameAndCodeProvider.setSelectedClassificatonKey("");
    calssificatonNameAndCodeProvider.setSelectedClassificatonName("");
    documentListProvider.setIsSearch(false);
    documentListProvider.setPage(1);
    documentListProvider.setDocumentSearchCriterea(SearchDocumentCriteria());
    setState(() {});
  }

  Future<void> search() async {
    SearchDocumentCriteria searchDocumentCriteria = SearchDocumentCriteria();
    searchDocumentCriteria.fromIssueDate = fromDateController.text;
    searchDocumentCriteria.toIssueDate = toDateController.text;
    searchDocumentCriteria.desc = descreptionController.text;
    searchDocumentCriteria.issueNo = issueNoController.text;
    searchDocumentCriteria.dept = selectedDep;
    searchDocumentCriteria.keywords = keyWordController.text;
    searchDocumentCriteria.ref1 = ref1Controller.text;
    searchDocumentCriteria.ref2 = ref2Controller.text;
    searchDocumentCriteria.otherRef = otherRefController.text;
    searchDocumentCriteria.cat =
        calssificatonNameAndCodeProvider.classificatonKey;
    searchDocumentCriteria.organization = organizationController.text;
    searchDocumentCriteria.following = followingController.text;
    searchDocumentCriteria.sortedBy = selectedSortedType;
    searchDocumentCriteria.page = 0;
    documentListProvider.setIsSearch(true);
    documentListProvider.setDocumentSearchCriterea(searchDocumentCriteria);
  }
}
