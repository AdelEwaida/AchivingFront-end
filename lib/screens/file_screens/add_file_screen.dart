import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:archiving_flutter_project/models/db/categories_models/doc_cat_parent.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../dialogs/error_dialgos/show_error_dialog.dart';
import '../../models/db/document_models/document_request.dart';
import '../../models/db/document_models/documnet_info_model.dart';
import '../../models/db/document_models/upload_file_mode.dart';
import '../../service/controller/documents_controllers/documents_controller.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/styles.dart';
import '../../utils/func/converters.dart';
import '../../utils/func/responsive.dart';
import '../../widget/custom_drop_down.dart';
import '../../widget/custom_drop_down2.dart';
import '../../widget/date_time_component.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';

class AddFileScreen extends StatefulWidget {
  const AddFileScreen({super.key});

  @override
  State<AddFileScreen> createState() => _AddFileScreenState();
}

class _AddFileScreenState extends State<AddFileScreen> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  TextEditingController fileDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController issueNoController = TextEditingController();
  TextEditingController arrivalDateController = TextEditingController();

  TextEditingController keyWordsController = TextEditingController();
  TextEditingController ref1Controller = TextEditingController();
  TextEditingController ref2Controller = TextEditingController();
  TextEditingController otherRefController = TextEditingController();
  TextEditingController organizationController = TextEditingController();
  TextEditingController followingController = TextEditingController();
  TextEditingController fileNameController = TextEditingController();
  bool isDesktop = false;
  DocumentsController documentsController = DocumentsController();
  // ValueNotifier isFileLoading = ValueNotifier(false);
  bool isFileLoading = false;
  String? txtFilename;
  String? imgBlob;
  int? dblFilesize;
  Uint8List? image;
  String selectedDep = "";
  String selctedDepDesc = "";
  String selectedCat = "";
  String selectedCatDesc = "";
  bool saving = false;
  List<DocCatParent> catList = [];

  List<DepartmentModel> departmetList = [];
  late DocumentListProvider documentListProvider;
  @override
  Future<void> didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    documentListProvider = context.read<DocumentListProvider>();
    fileDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    arrivalDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    catList = await DocumentsController().getDocCategoryList();
    departmetList = await DepartmentController()
        .getDep(SearchModel(page: -1, searchField: "", status: -1));

    setState(() {});
    if (documentListProvider.description != null) {
      descriptionController.text = documentListProvider.description ?? "";
    }
    if (documentListProvider.issueNumber != null) {
      issueNoController.text = documentListProvider.issueNumber ?? "";
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_locale.addDocument),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Text(
              //   _locale.addDocument,
              //   style: TextStyle(fontSize: 25),
              // ),
              Container(
                width: width * 0.73,
                height: height * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              DropDown(
                                key: UniqueKey(),
                                isMandatory: true,
                                onChanged: (value) {
                                  selectedDep = value.txtKey;
                                  selctedDepDesc = value.txtDescription;
                                  // setState(() {});
                                },
                                initialValue: selctedDepDesc == ""
                                    ? null
                                    : selctedDepDesc,
                                bordeText: _locale.department,
                                width: width * 0.2,
                                items: departmetList,
                                height: height * 0.05,
                                // onSearch: (p0) async {
                                //   return await DepartmentController()
                                //       .getDep(
                                //       SearchModel(
                                //           page: -1,
                                //           searchField: p0.trim(),
                                //           status: -1));
                                // },
                              ),
                              SizedBox(
                                width: width * 0.015,
                              ),
                              DateTimeComponent(
                                height: height * 0.05,
                                label: _locale.arrivalDate,
                                dateController: arrivalDateController,
                                dateWidth: width * 0.2,
                                dateControllerToCompareWith: null,
                                readOnly: false,
                                isInitiaDate: true,
                                onValue: (isValid, value) {
                                  if (isValid) {
                                    arrivalDateController.text = value;
                                  }
                                },
                                timeControllerToCompareWith: null,
                              ),
                              SizedBox(
                                width: width * 0.015,
                              ),
                              DateTimeComponent(
                                height: height * 0.05,
                                label: _locale.issueDate,
                                dateController: fileDateController,
                                dateWidth: width * 0.2,
                                dateControllerToCompareWith: null,
                                readOnly: false,
                                isInitiaDate: true,
                                onValue: (isValid, value) {
                                  if (isValid) {
                                    fileDateController.text = value;
                                  }
                                },
                                timeControllerToCompareWith: null,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            customTextField(
                              _locale.txtDescription,
                              descriptionController,
                              isDesktop,
                              0.2,
                              true,
                            ),
                            SizedBox(
                              width: width * 0.015,
                            ),
                            customTextField(
                              _locale.issueNo,
                              issueNoController,
                              isDesktop,
                              0.2,
                              false,
                            ),
                            SizedBox(
                              width: width * 0.015,
                            ),
                            DropDown(
                              key: UniqueKey(),
                              isMandatory: true,
                              initialValue: selectedCatDesc.isEmpty
                                  ? null
                                  : selectedCatDesc,
                              width: width * 0.2,
                              height: height * 0.05,
                              onChanged: (value) {
                                selectedCat = value.txtKey;
                                selectedCatDesc = value.txtDescription;
                              },
                              items: catList,
                              searchBox: true,
                              valSelected: true,
                              bordeText: _locale.category,
                              // width: width * 0.21,

                              // onSearch: (p0) async {
                              //   return await DocumentsController()
                              //       .getDocCategoryList();
                              // },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            customTextField(
                              _locale.keyWords,
                              keyWordsController,
                              isDesktop,
                              0.2,
                              false,
                            ),
                            SizedBox(
                              width: width * 0.015,
                            ),
                            customTextField(
                              _locale.following,
                              followingController,
                              isDesktop,
                              0.2,
                              false,
                            ),
                            SizedBox(
                              width: width * 0.015,
                            ),
                            customTextField(
                              _locale.ref1,
                              ref1Controller,
                              isDesktop,
                              0.2,
                              false,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            customTextField(
                              _locale.ref2,
                              ref2Controller,
                              isDesktop,
                              0.2,
                              false,
                            ),
                            SizedBox(
                              width: width * 0.015,
                            ),
                            customTextField(
                              _locale.otherRef,
                              otherRefController,
                              isDesktop,
                              0.2,
                              false,
                            ),
                            SizedBox(
                              width: width * 0.015,
                            ),
                            customTextField(
                              _locale.organization,
                              organizationController,
                              isDesktop,
                              0.2,
                              false,
                            ),
                          ],
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   children: [
                        //     customTextField(
                        //       _locale.following,
                        //       followingController,
                        //       isDesktop,
                        //       0.2,
                        //       false,
                        //     ),
                        //     SizedBox(
                        //       width: width * 0.015,
                        //     ),
                        //     SizedBox(
                        //       width: width * 0.2,
                        //     ),
                        //     SizedBox(
                        //       width: width * 0.015,
                        //     ),
                        //     SizedBox(
                        //       width: width * 0.2,
                        //     )
                        //   ],
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildFileUpload(),
                          ],
                        ),
                      ]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: saveDocument,
                    style: customButtonStyle(
                      Size(isDesktop ? width * 0.1 : width * 0.4,
                          height * 0.055),
                      18,
                      primary,
                    ),
                    child: Text(
                      _locale.save,
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
                        Size(isDesktop ? width * 0.1 : width * 0.4,
                            height * 0.055),
                        18,
                        redColor),
                    child: Text(
                      _locale.resetFilter,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                ],
              )
            ],
          ),
          if (saving)
            Center(
              child: CircularProgressIndicator(),
            ),
          Center(
            child: Visibility(
              visible: isFileLoading,
              child: Container(
                // color: Colors.black.withOpacity(
                //     0.08), // Semi-transparent black background for the blur effect
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 2.0,
                      sigmaY: 2.0), // Adjust the blur amount as needed
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFileUpload() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              pickFile();
            },
            style: customButtonStyle(
                Size(isDesktop ? width * 0.1 : width * 0.4, height * 0.055),
                18,
                primary3),
            child: Text(
              _locale.uploadFile,
              style: const TextStyle(color: whiteColor),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: width * 0.3,
            child: Tooltip(
              message: fileNameController.text,
              child: customTextField(
                _locale.fileName,
                fileNameController,
                isDesktop,
                0.2,
                true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> filesName = [];
  List<String> filesBlobs = [];
  Future pickFile() async {
    setState(() {
      isFileLoading = true;
    });
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null && result.files.isNotEmpty) {
      List<PlatformFile> files = result.files;

      for (int i = 0; i < files.length; i++) {
        filesName.add(files[i].name);
        filesBlobs.add(base64Encode(files[i].bytes!));
      }
      // PlatformFile selectedFile = result.files.first;

      setState(() {
        fileNameController.text = filesName.toString();
        // fileNameController.text = selectedFile.name;
        // txtFilename = selectedFile.name;
        // imgBlob = base64Encode(selectedFile.bytes!);
        // dblFilesize = selectedFile.size;
        isFileLoading = false;
      });
    } else {
      setState(() {
        isFileLoading = false;
      });
    }
  }

  Widget customTextField(String hint, TextEditingController controller,
      bool isDesktop, double width1, bool isMandetory) {
    double height = MediaQuery.of(context).size.height * 0.3;
    return CustomTextField2(
      readOnly: hint == _locale.fileName ? true : false,
      isReport: true,
      isMandetory: isMandetory,
      width: width * width1,
      height: height * 0.18,
      text: Text(hint),
      controller: controller,
      onSubmitted: (text) {},
      onChanged: (value) {},
    );
  }

  void saveDocument() async {
    if (saving) return;

    setState(() {
      saving = true;
    });

    // Create DocumentModel instance
    DocumentModel documentModel = DocumentModel(
      txtKey: "",
      txtDescription: descriptionController.text,
      txtKeywords: keyWordsController.text,
      txtReference1: ref1Controller.text,
      txtReference2: ref2Controller.text,
      intType: 1,
      txtFollowing: followingController.text,
      txtOrganization: organizationController.text,
      txtOtherRef: otherRefController.text,
      datCreationdate: fileDateController.text,
      txtLastupdateduser: "",
      txtMimetype: "",
      intVouchtype: 1,
      intVouchnum: 0,
      txtJcode: "",
      txtCategory: selectedCat,
      txtDept: selectedDep,
      txtIssueno: issueNoController.text,
      datIssuedate: arrivalDateController.text,
      txtUsercode: "",
      txtInsurance: "",
      txtLicense: "",
      txtMaintenance: "",
      txtOtherservices: "",
      bolHasfile: 1,
      datArrvialdate: arrivalDateController.text,
      txtOriginalfilekey: "",
    );
    List<FileUploadModel> filesUploadList = [];
    for (int i = 0; i < filesBlobs.length; i++) {
      filesUploadList.add(FileUploadModel(
        txtKey: "",
        txtHdrkey: "",
        txtFilename: filesName[i],
        imgBlob: filesBlobs[i],
        dblFilesize: dblFilesize ?? 0,
        txtUsercode: "",
        datDate: "",
        txtMimetype: "",
        intLinenum: 1,
        intType: 1,
      ));
    }
    // Create FileUploadModel instance
    

    // Create DocumentFileRequest instance
    DocumentFileRequest documentFileRequest = DocumentFileRequest(
      documentInfo: documentModel,
      documentFile: filesUploadList,
    );

    // Check if all required fields are empty
    if (selectedDep.isEmpty ||
        selectedCat.isEmpty ||
        fileNameController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      CoolAlert.show(
        width: width * 0.4,
        context: context,
        type: CoolAlertType.error,
        title: _locale.fillRequiredFields,
        text: _locale.fillRequiredFields,
        confirmBtnText: _locale.ok,
        onConfirmBtnTap: () {},
      );
      setState(() {
        saving = false;
      });
      return;
    }

    await documentsController.addDocument(documentFileRequest).then((value) {
      if (value.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              icon: Icons.done_all,
              errorDetails: _locale.done,
              errorTitle: _locale.addDoneSucess,
              color: Colors.green,
              statusCode: 200,
            );
          },
        ).then((value) {
          resetForm();
        });
      }
    });
    setState(() {
      saving = false;
    });
  }

  void resetForm() {
    descriptionController.clear();
    keyWordsController.clear();
    ref1Controller.clear();
    ref2Controller.clear();
    fileDateController.clear();
    issueNoController.clear();
    arrivalDateController.clear();
    fileNameController.clear();
    selectedDep = "";
    selectedCat = "";
    selectedCatDesc = "";
    selctedDepDesc = "";
    followingController.clear();
    otherRefController.clear();
    organizationController.clear();
    arrivalDateController.text =
        Converters.formatDate2(DateTime.now().toString());
    fileDateController.text = Converters.formatDate2(DateTime.now().toString());
    setState(() {});
  }
}
