import 'dart:convert';

import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/archived_pages_utils.dart';
import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import 'package:archiving_flutter_project/widget/date_time_component.dart';
import 'package:archiving_flutter_project/widget/dialog_widgets/title_dialog_widget.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/dto/searchs_model/search_model.dart';
import '../../service/controller/department_controller/department_cotnroller.dart';
import '../../widget/custom_drop_down.dart';
import '../../widget/custom_flutter_toast_message.dart';
import '../app_dialog.dart';

class InfoDocumentDialog extends StatefulWidget {
  DocumentModel documentModel;
  bool isEdit;
  final bool showArchivedPagesCount;

  InfoDocumentDialog({
    super.key,
    required this.isEdit,
    required this.documentModel,
    this.showArchivedPagesCount = false,
  });

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
  TextEditingController fileBarcodeController = TextEditingController();
  TextEditingController issueDateController = TextEditingController();
  TextEditingController refrence2Controller = TextEditingController();
  TextEditingController otherReferences = TextEditingController();
  TextEditingController organization = TextEditingController();
  TextEditingController following = TextEditingController();
  DocumentsController documentsController = DocumentsController();
  TextEditingController arrivalDate = TextEditingController();
  final TextEditingController archivedPagesController = TextEditingController();
  DocumentModel? documentModel;

  String selectedDep = "";
  String selectedCat = "";
  String selectedDepName = "";
  String selectedCatName = "";
  bool _loadingArchivedPages = false;
  bool _archivedPagesLoadStarted = false;

  @override
  void dispose() {
    archivedPagesController.dispose();
    super.dispose();
  }

  Future<void> _loadArchivedPagesCount() async {
    final hdrKey = widget.documentModel.txtKey?.trim() ?? '';
    if (hdrKey.isEmpty) {
      archivedPagesController.text = '0';
      return;
    }

    final fromSearch = widget.documentModel.archivedPagesCount;
    if (fromSearch != null) {
      archivedPagesController.text = fromSearch.toString();
      return;
    }

    setState(() => _loadingArchivedPages = true);
    try {
      final files = await documentsController.getFilesByHdrKey(hdrKey);
      final count = ArchivedPagesUtils.countArchivedPages(files);
      if (!mounted) return;
      archivedPagesController.text = count.toString();
    } catch (_) {
      if (!mounted) return;
      archivedPagesController.text = '0';
    } finally {
      if (mounted) setState(() => _loadingArchivedPages = false);
    }
  }

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
    selectedDep = documentModel!.deptKey ?? "";
    // selectedDepKey=documentModel!.txtD
    selectedCat = documentModel!.catKey ?? "";
    selectedDepName = documentModel!.txtDept ?? "";
    selectedCatName = documentModel!.txtCategory ?? "";

    issueNoController.text = documentModel!.txtIssueno ?? "";

    fileBarcodeController.text = documentModel!.txtBarcode ?? "";

    issueDateController.text = (documentModel!.datIssuedate!.isEmpty ||
            documentModel!.datIssuedate == null
        ? Converters.formatDate2(DateTime.now().toString())
        : documentModel!.datIssuedate)!;
    refrence2Controller.text = documentModel!.txtReference2 ?? "";
    otherReferences.text = documentModel!.txtOtherRef ?? "";
    organization.text = documentModel!.txtOrganization ?? "";
    print("organizationorganization ${documentModel!.txtOrganization}");
    following.text = documentModel!.txtFollowing ?? "";
    arrivalDate.text = (documentModel!.datArrvialdate!.isEmpty ||
            documentModel!.datArrvialdate == null
        ? Converters.formatDate2(DateTime.now().toString())
        : documentModel!.datArrvialdate)!;

    if (widget.showArchivedPagesCount &&
        !widget.isEdit &&
        !_archivedPagesLoadStarted) {
      _archivedPagesLoadStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadArchivedPagesCount();
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Dialog background color: ${Theme.of(context).dialogBackgroundColor}');

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    return AppDialog(
      width: isDesktop ? width * 0.47 : width * 0.8,
      height: height * 0.65,
      // titlePadding: EdgeInsets.all(0),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      // backgroundColor: Theme.of(context).dialogBackgroundColor,
      title:
          widget.isEdit ? _locale.editDocumentDetails : _locale.documentDetails,
      content: SingleChildScrollView(child: formSection()),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isDesktop
                ? widget.isEdit
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomElevatedButton(
                              text: _locale.save,
                              color: primary,
                              width: isDesktop ? width * 0.1 : width * 0.4,
                              height: height * 0.045,
                              onPressed: () {
                                updateDocument();
                              }),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     updateDocument();
                          //   },
                          //   style: customButtonStyle(
                          //       context,
                          //       Size(isDesktop ? width * 0.1 : width * 0.4,
                          //           height * 0.045),
                          //       14,
                          //       primary),
                          //   child: Text(
                          //     _locale.save,
                          //     style: const TextStyle(color: whiteColor),
                          //   ),
                          // ),
                          spaceWidth(0.01),
                          CustomElevatedButton(
                              text: _locale.cancel,
                              color: redColor,
                              width: isDesktop ? width * 0.1 : width * 0.4,
                              height: height * 0.045,
                              onPressed: () {
                                Navigator.pop(context, false);
                              }),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     Navigator.pop(context, false);
                          //   },
                          //   style: customButtonStyle(
                          //       context,
                          //       Size(isDesktop ? width * 0.1 : width * 0.4,
                          //           height * 0.045),
                          //       14,
                          //       redColor),
                          //   child: Text(
                          //     _locale.cancel,
                          //     style: const TextStyle(color: whiteColor),
                          //   ),
                          // ),
                        ],
                      )
                    : Center(
                        child: CustomElevatedButton(
                            text: _locale.cancel,
                            color: redColor,
                            width: isDesktop ? width * 0.1 : width * 0.4,
                            height: height * 0.045,
                            onPressed: () {
                              Navigator.pop(context, false);
                            }),
                        // child: ElevatedButton(
                        //   onPressed: () {
                        //     Navigator.pop(context, false);
                        //   },
                        //   style: customButtonStyle(
                        //       context,
                        //       Size(isDesktop ? width * 0.1 : width * 0.4,
                        //           height * 0.045),
                        //       14,
                        //       redColor),
                        //   child: Text(
                        //     _locale.cancel,
                        //     style: const TextStyle(color: whiteColor),
                        //   ),
                        // ),
                      )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          CustomElevatedButton(
                              text: _locale.save,
                              color: primary,
                              width: isDesktop ? width * 0.1 : width * 0.4,
                              height: height * 0.045,
                              onPressed: () {}),
                          // ElevatedButton(
                          //   onPressed: () {},
                          //   style: customButtonStyle(
                          //       context,
                          //       Size(isDesktop ? width * 0.1 : width * 0.4,
                          //           height * 0.045),
                          //       14,
                          //       primary),
                          //   child: Text(
                          //     _locale.save,
                          //     style: const TextStyle(color: whiteColor),
                          //   ),
                          // ),
                          SizedBox(height: height * 0.01),
                          CustomElevatedButton(
                              text: _locale.cancel,
                              color: redColor,
                              width: isDesktop ? width * 0.1 : width * 0.4,
                              height: height * 0.045,
                              onPressed: () {
                                Navigator.pop(context, false);
                              }),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     Navigator.pop(context, false);
                          //   },
                          //   style: customButtonStyle(
                          //       context,
                          //       Size(isDesktop ? width * 0.1 : width * 0.4,
                          //           height * 0.045),
                          //       14,
                          //       redColor),
                          //   child: Text(
                          //     _locale.cancel,
                          //     style: const TextStyle(color: whiteColor),
                          //   ),
                          // ),
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
    final double fieldHeight = height * 0.05;
    const double colGap = 8;
    final double rowGap = height * 0.012;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _formRow(
          colGap: colGap,
          children: [
            _labeledField(
              label: _locale.department,
              fieldHeight: fieldHeight,
              child: DropDown(
                isEnabled: widget.isEdit,
                key: const ValueKey('info_doc_dept'),
                onChanged: (value) {
                  selectedDep = value.txtKey;
                  documentModel!.txtDept = value.txtKey;
                  selectedDepName = value.txtDescription;
                },
                initialValue:
                    selectedDepName.isEmpty ? null : selectedDepName,
                bordeText: '',
                width: double.infinity,
                height: fieldHeight,
                onSearch: (p0) async {
                  return await DepartmentController()
                      .getDep(SearchModel(page: 1));
                },
              ),
            ),
            DateTimeComponent(
              isInitiaDate: false,
              timeControllerToCompareWith: null,
              dateController: issueDateController,
              label: _locale.issueDate,
              onValue: (isValid, value) {
                if (isValid) issueDateController.text = value;
              },
              readOnly: !widget.isEdit,
              height: fieldHeight,
              dateWidth: double.infinity,
              dateControllerToCompareWith: null,
            ),
            DateTimeComponent(
              dateController: arrivalDate,
              readOnly: !widget.isEdit,
              label: _locale.arrivalDate,
              onValue: (isValid, value) {
                if (isValid) arrivalDate.text = value;
              },
              height: fieldHeight,
              dateWidth: double.infinity,
              dateControllerToCompareWith: null,
              isInitiaDate: false,
              timeControllerToCompareWith: null,
            ),
          ],
        ),
        SizedBox(height: rowGap),
        _formRow(
          colGap: colGap,
          children: [
            CustomTextField2(
              controller: reference1,
              text: Text(_locale.ref1),
              onChanged: (value) => documentModel!.txtReference1 = value,
              height: fieldHeight,
              readOnly: !widget.isEdit,
              width: double.infinity,
            ),
            CustomTextField2(
              controller: refrence2Controller,
              text: Text(_locale.ref2),
              onChanged: (value) => documentModel!.txtReference2 = value,
              height: fieldHeight,
              readOnly: !widget.isEdit,
              width: double.infinity,
            ),
            CustomTextField2(
              controller: otherReferences,
              text: Text(_locale.otherRef),
              onChanged: (value) => documentModel!.txtOtherRef = value,
              height: fieldHeight,
              width: double.infinity,
              readOnly: !widget.isEdit,
            ),
          ],
        ),
        SizedBox(height: rowGap),
        _formRow(
          colGap: colGap,
          children: [
            CustomTextField2(
              controller: descriptionController,
              text: Text(_locale.description),
              height: fieldHeight,
              onChanged: (value) => documentModel!.txtDescription = value,
              readOnly: !widget.isEdit,
              width: double.infinity,
            ),
            CustomTextField2(
              controller: keyWordController,
              readOnly: !widget.isEdit,
              onChanged: (value) => documentModel!.txtKeywords = value,
              text: Text(_locale.keyword),
              height: fieldHeight,
              width: double.infinity,
            ),
            CustomTextField2(
              controller: organization,
              text: Text(_locale.organization),
              onChanged: (value) => documentModel!.txtOrganization = value,
              height: fieldHeight,
              width: double.infinity,
              readOnly: !widget.isEdit,
            ),
          ],
        ),
        SizedBox(height: rowGap),
        _formRow(
          colGap: colGap,
          children: [
            CustomTextField2(
              controller: type,
              text: Text(_locale.type),
              height: fieldHeight,
              readOnly: !widget.isEdit,
              onChanged: (value) => documentModel!.intType = int.parse(value),
              width: double.infinity,
            ),
            CustomTextField2(
              controller: issueNoController,
              text: Text(_locale.issueNo),
              onChanged: (value) => documentModel!.txtIssueno = value,
              height: fieldHeight,
              readOnly: !widget.isEdit,
              isMandetory: true,
              width: double.infinity,
            ),
            CustomTextField2(
              readOnly: !widget.isEdit,
              controller: following,
              text: Text(_locale.following),
              onChanged: (value) => documentModel!.txtFollowing = value,
              height: fieldHeight,
              width: double.infinity,
            ),
          ],
        ),
        SizedBox(height: rowGap),
        widget.showArchivedPagesCount && !widget.isEdit
            ? _formRow(
                colGap: colGap,
                children: [
                  CustomTextField2(
                    controller: fileBarcodeController,
                    text: Text(_locale.fileBarcode),
                    onChanged: (value) => documentModel!.txtBarcode = value,
                    height: fieldHeight,
                    readOnly: true,
                    width: double.infinity,
                  ),
                  CustomTextField2(
                    controller: archivedPagesController,
                    text: Text(_locale.archivedPagesCount),
                    readOnly: true,
                    height: fieldHeight,
                    width: double.infinity,
                    customIconSuffix: _loadingArchivedPages
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: Padding(
                              padding: EdgeInsets.all(2),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                ],
              )
            : _formFullRow(
                CustomTextField2(
                  controller: fileBarcodeController,
                  text: Text(_locale.fileBarcode),
                  onChanged: (value) => documentModel!.txtBarcode = value,
                  height: fieldHeight,
                  readOnly: !widget.isEdit,
                  width: double.infinity,
                ),
              ),
        SizedBox(height: rowGap),
        _formFullRow(
          _labeledField(
            label: _locale.category,
            fieldHeight: fieldHeight,
            child: DropDown(
              isEnabled: widget.isEdit,
              key: const ValueKey('info_doc_category'),
              initialValue: selectedCatName.isEmpty ? null : selectedCatName,
              width: double.infinity,
              height: fieldHeight,
              onChanged: (value) {
                selectedCat = value.txtKey;
                documentModel!.txtCategory = value.txtKey;
                selectedCatName = value.txtDescription;
              },
              searchBox: true,
              valSelected: true,
              bordeText: '',
              onSearch: (p0) async {
                return await DocumentsController().getDocCategoryList();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _labeledField({
    required String label,
    required double fieldHeight,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        SizedBox(
          height: fieldHeight,
          child: child,
        ),
      ],
    );
  }

  Widget _formRow({
    required double colGap,
    required List<Widget> children,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(width: colGap),
            Expanded(
              child: i < children.length
                  ? children[i]
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _formFullRow(Widget child) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: child),
      ],
    );
  }

  spaceWidth(double width1) {
    return SizedBox(
      width: width * width1,
    );
  }

  Future<void> updateDocument() async {
    if (issueNoController.text.trim().isEmpty) {
      CustomToastMessage.error(context, _locale.pleaseAddAllRequiredFields);
      // showDialog(
      //   context: context,
      //   builder: (context) {
      //     return ErrorDialog(
      //       icon: Icons.error,
      //       errorDetails: _locale.pleaseAddAllRequiredFields,
      //       errorTitle: _locale.error,
      //       color: Colors.red,
      //       statusCode: 400,
      //     );
      //   },
      // );
      return;
    }

    documentModel!.datIssuedate = issueDateController.text;
    documentModel!.datArrvialdate = arrivalDate.text;
    documentModel!.txtDept = selectedDep;
    documentModel!.txtCategory = selectedCat;
    documentModel!.txtBarcode = fileBarcodeController.text.trim();

    var response = await documentsController.updateDocument(documentModel!).then((value) {
      if (value.statusCode == 200) {
        CustomToastMessage.success(context, _locale.editDoneSucess)
            .then((value) {
          Navigator.pop(context, true);
        });
      } else if (value.statusCode == 406) {
        final message = utf8.decode(value.bodyBytes).trim();
        CustomToastMessage.error(
          context,
          message.isNotEmpty ? message : _locale.barcodeAlreadyExists,
        );
      }
    });

    
  }
}
