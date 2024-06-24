import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/date_time_component.dart';
import 'package:archiving_flutter_project/widget/dialog_widgets/title_dialog_widget.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/dto/searchs_model/search_model.dart';
import '../../service/controller/department_controller/department_cotnroller.dart';
import '../../widget/custom_drop_down.dart';

class InfoDocumentDialog extends StatefulWidget {
  DocumentModel documentModel;
  bool isEdit;
  InfoDocumentDialog(
      {super.key, required this.isEdit, required this.documentModel});

  @override
  State<InfoDocumentDialog> createState() => _InfoDocumentDialogState();
}

class _InfoDocumentDialogState extends State<InfoDocumentDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController keyWordController = TextEditingController();
  TextEditingController reference1 = TextEditingController();
  TextEditingController type = TextEditingController();
  // TextEditingController department = TextEditingController();
  // TextEditingController categoryController = TextEditingController();
  TextEditingController issueNoController = TextEditingController();
  TextEditingController issueDateController = TextEditingController();
  TextEditingController refrence2Controller = TextEditingController();
  TextEditingController otherReferences = TextEditingController();
  TextEditingController organization = TextEditingController();
  TextEditingController following = TextEditingController();
  DocumentsController documentsController = DocumentsController();
  TextEditingController arrivalDate = TextEditingController();
  DocumentModel? documentModel;

  String selectedDep = "";
  String selectedCat = "";

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    documentModel = widget.documentModel;
    descriptionController.text = documentModel!.txtDescription ?? "";

    keyWordController.text = documentModel!.txtKeywords ?? "";

    reference1.text = documentModel!.txtReference1 ?? "";

    type.text = documentModel!.intType.toString();

    // department.text = documentModel!.txtDept ?? "";
    selectedDep = documentModel!.txtDept ?? "";
    selectedCat = documentModel!.txtCategory ?? "";

    issueNoController.text = documentModel!.txtIssueno ?? "";

    issueDateController.text = (documentModel!.datIssuedate!.isEmpty ||
            documentModel!.datIssuedate == null
        ? Converters.formatDate2(DateTime.now().toString())
        : documentModel!.datIssuedate)!;
    refrence2Controller.text = documentModel!.txtReference2 ?? "";
    otherReferences.text = documentModel!.txtOtherRef ?? "";
    organization.text = documentModel!.txtOrganization ?? "";
    following.text = documentModel!.txtFollowing ?? "";
    arrivalDate.text = (documentModel!.datArrvialdate!.isEmpty ||
            documentModel!.datArrvialdate == null
        ? Converters.formatDate2(DateTime.now().toString())
        : documentModel!.datArrvialdate)!;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      backgroundColor: dBackground,
      title: TitleDialogWidget(
        title: widget.isEdit
            ? _locale.editDocumentDetails
            : _locale.documentDetails,
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: height * 0.07,
      ),
      content: Container(
        width: width * 0.45,
        height: height * 0.6,
        child: formSection(),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isDesktop
                ? widget.isEdit
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              updateDocument();
                            },
                            style: customButtonStyle(
                                Size(isDesktop ? width * 0.1 : width * 0.4,
                                    height * 0.045),
                                18,
                                greenColor),
                            child: Text(
                              _locale.save,
                              style: const TextStyle(color: whiteColor),
                            ),
                          ),
                          spaceWidth(0.01),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            style: customButtonStyle(
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
                      )
                    : Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          style: customButtonStyle(
                              Size(isDesktop ? width * 0.1 : width * 0.4,
                                  height * 0.045),
                              18,
                              redColor),
                          child: Text(
                            _locale.cancel,
                            style: const TextStyle(color: whiteColor),
                          ),
                        ),
                      )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: customButtonStyle(
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
        )
      ],
    );
  }

  Widget formSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomTextField2(
              controller: descriptionController,
              text: Text(_locale.description),
              height: height * 0.05,
              onChanged: (value) {
                documentModel!.txtDescription = value;
              },
              readOnly: !widget.isEdit,
              width: width * 0.1,
            ),
            spaceWidth(0.01),
            CustomTextField2(
              controller: keyWordController,
              readOnly: !widget.isEdit,
              onChanged: (value) {
                documentModel!.txtKeywords = value;
              },
              text: Text(_locale.keyword),
              height: height * 0.05,
              width: width * 0.1,
            ),
            spaceWidth(0.01),
            CustomTextField2(
              controller: organization,
              text: Text(_locale.organization),
              onChanged: (value) {
                documentModel!.txtOrganization = value;
              },
              height: height * 0.05,
              width: width * 0.1,
              readOnly: !widget.isEdit,
            ),
            spaceWidth(0.01),
            CustomTextField2(
              controller: reference1,
              text: Text(_locale.ref1),
              onChanged: (value) {
                documentModel!.txtReference1 = value;
              },
              height: height * 0.05,
              readOnly: !widget.isEdit,
              width: width * 0.1,
            ),
          ],
        ),
        SizedBox(height: height * 0.01),
        Row(
          children: [
            CustomTextField2(
              controller: type,
              text: Text(_locale.type),
              height: height * 0.05,
              readOnly: !widget.isEdit,
              onChanged: (value) {
                documentModel!.intType = int.parse(value);
              },
              width: width * 0.1,
            ),
            spaceWidth(0.01),
            // CustomTextField2(
            //   controller: department,
            //   text: Text(_locale.department),
            //   onChanged: (value) {
            //     documentModel!.txtDept = value;
            //   },
            //   height: height * 0.05,
            //   width: width * 0.1,
            //   readOnly: !widget.isEdit,
            // ),
            DropDown(
              key: UniqueKey(),
              onChanged: (value) {
                selectedDep = value.txtKey;
                documentModel!.txtDept = value.txtKey;

                print("selectedDepselectedDepselectedDep:${selectedDep}");
                // setState(() {});
              },
              initialValue: selectedDep.isEmpty ? null : selectedDep,
              bordeText: _locale.department,
              width: width * 0.1,
              height: height * 0.04,
              onSearch: (p0) async {
                return await DepartmentController()
                    .getDep(SearchModel(page: 1));
              },
            ),
            spaceWidth(0.01),
            // CustomTextField2(
            //   controller: categoryController,
            //   text: Text(_locale.category),
            //   onChanged: (value) {
            //     documentModel!.txtCategory = value;
            //   },
            //   height: height * 0.05,
            //   readOnly: !widget.isEdit,
            //   width: width * 0.1,
            // ),
            DropDown(
              key: UniqueKey(),

              initialValue: selectedCat.isEmpty ? null : selectedCat,
              width: width * 0.1,
              height: height * 0.04,
              onChanged: (value) {
                selectedCat = value.txtKey;
                documentModel!.txtCategory = value.txtKey;
              },
              searchBox: true,
              valSelected: true,
              bordeText: _locale.category,
              // width: width * 0.21,

              onSearch: (p0) async {
                return await DocumentsController().getDocCategoryList();
              },
            ),
            spaceWidth(0.01),
            CustomTextField2(
              controller: issueNoController,
              text: Text(_locale.issueNo),
              onChanged: (value) {
                documentModel!.txtIssueno = value;
              },
              height: height * 0.05,
              readOnly: !widget.isEdit,
              width: width * 0.1,
            ),
          ],
        ),
        SizedBox(height: height * 0.01),
        Row(
          children: [
            DateTimeComponent(
              isInitiaDate: false,
              timeControllerToCompareWith: null,
              dateController: issueDateController,
              label: _locale.issueDate,
              // onChanged: (value) {
              //   documentModel!.datIssuedate = value;
              // },
              readOnly: !widget.isEdit,
              height: height * 0.05,
              dateWidth: width * 0.1,
              dateControllerToCompareWith: null,
            ),
            spaceWidth(0.01),
            CustomTextField2(
              controller: refrence2Controller,
              text: Text(_locale.ref2),
              onChanged: (value) {
                documentModel!.txtReference2 = value;
              },
              height: height * 0.05,
              readOnly: !widget.isEdit,
              width: width * 0.1,
            ),
            spaceWidth(0.01),
            CustomTextField2(
              controller: otherReferences,
              text: Text(_locale.otherRef),
              onChanged: (value) {
                documentModel!.txtOtherRef = value;
              },
              height: height * 0.05,
              width: width * 0.1,
              readOnly: !widget.isEdit,
            ),
            spaceWidth(0.01),
            CustomTextField2(
              readOnly: !widget.isEdit,
              controller: following,
              text: Text(_locale.following),
              onChanged: (value) {
                documentModel!.txtFollowing = value;
              },
              height: height * 0.05,
              width: width * 0.1,
            ),
          ],
        ),
        SizedBox(height: height * 0.01),
        Row(
          children: [
            DateTimeComponent(
              dateController: arrivalDate,
              // controller: ,
              readOnly: !widget.isEdit,
              label: _locale.arrivalDate,

              height: height * 0.05,
              dateWidth: width * 0.1,
              dateControllerToCompareWith: null,
              isInitiaDate: false,
              timeControllerToCompareWith: null,
            ),
          ],
        ),
      ],
    );
  }

  spaceWidth(double width1) {
    return SizedBox(
      width: width * width1,
    );
  }

  Future<void> updateDocument() async {
    // DocumentModel tempDocumentModel = DocumentModel();
    documentModel!.datIssuedate = issueDateController.text;
    documentModel!.datArrvialdate = arrivalDate.text;
    print(documentModel!.toJson());
    var response = await documentsController.updateDocument(documentModel!);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
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
    // tempDocumentModel.txtKey = documentModel!.txtKey;
    // tempDocumentModel.bolHasfile = documentModel!.bolHasfile;
    // tempDocumentModel.datArrvialdate = documentModel!.datArrvialdate;
    // tempDocumentModel.datCreationdate = documentModel!.datCreationdate;
    // tempDocumentModel.datIssuedate = documentModel!.datIssuedate;
    // tempDocumentModel.txtDept = documentModel!.txtDept;
  }
}
