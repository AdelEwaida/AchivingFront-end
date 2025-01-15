import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:archiving_flutter_project/models/db/categories_models/doc_cat_parent.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/models/db/user_models/department_user_model.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:archiving_flutter_project/utils/constants/api_constants.dart';
import 'package:archiving_flutter_project/utils/constants/loading.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../dialogs/error_dialgos/show_error_dialog.dart';
import '../../models/db/document_models/document_request.dart';
import '../../models/db/document_models/documnet_info_model.dart';
import '../../models/db/document_models/upload_file_mode.dart';
import '../../service/controller/documents_controllers/documents_controller.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/storage_keys.dart';
import '../../utils/constants/styles.dart';
import '../../utils/constants/user_types_constant/user_types_constant.dart';
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
  UserController userController = UserController();
  DocumentsController documentsController = DocumentsController();
  // ValueNotifier isFileLoading = ValueNotifier(false);
  bool isFileLoading = false;
  String? txtFilename;
  String? imgBlob;
  int? dblFilesize;
  Uint8List? image;

  String selectedCat = "";
  String selectedCatDesc = "";
  bool saving = false;
  List<DocCatParent> catList = [];
  bool _isUploadFileSelected = true;
  String url = "";
  List<DepartmentUserModel> departmetList = [];
  String selectedDep = "";
  String selctedDepDesc = "";
  late DocumentListProvider documentListProvider;
  var storage = FlutterSecureStorage();
  String? userName = "";
  List<String> scanners = [];
  bool approval = false;
  String active = "0";
  late AppLocalizations _locale;

  @override
  Future<void> didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;

    documentListProvider = context.read<DocumentListProvider>();
    fileDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    arrivalDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    catList = await DocumentsController().getDocCategoryList();
    userName = await storage.read(key: "userName");

    departmetList = await UserController().getDepartmentSelectedUser(userName!);

    setState(() {});
    if (documentListProvider.description != null) {
      descriptionController.text = documentListProvider.description ?? "";
    }
    if (documentListProvider.issueNumber != null) {
      issueNoController.text = documentListProvider.issueNumber ?? "";
      DepartmentUserModel? departmentUserModel;
      var departmentUserModelResonse =
          await UserController().getDepartmentSelectedUser(userName!);
      for (int i = 0; i < departmentUserModelResonse.length; i++) {
        if (departmentUserModelResonse[i].bolSelected == 1) {
          selectedDep = departmentUserModelResonse[i].txtDeptkey!;
          selctedDepDesc = departmentUserModelResonse[i].txtDeptName!;
          if (catList.isNotEmpty) {
            selectedCat = catList[0].txtKey!;
            selectedCatDesc = catList[0].txtDescription!;
            setState(() {});
          }
          // setState(() {});
        }
      }
    }
    active = (await storage.read(key: StorageKeys.bolActive))!;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    documentListProvider.setDescription(null);
    documentListProvider.setIssueNumber(null);

    super.dispose();
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
                                selectedDep = value.txtDeptkey;
                                selctedDepDesc = value.txtDeptName;
                                // setState(() {});
                              },
                              initialValue:
                                  selctedDepDesc == "" ? null : selctedDepDesc,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          active == "1"
                              ? Row(
                                  children: [
                                    Checkbox(
                                      value: approval,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          approval = value!;
                                        });
                                      },
                                    ),
                                    Text(_locale.submitforWorkflowApproval),
                                  ],
                                )
                              : SizedBox.shrink(),
                          Checkbox(
                            value: _isUploadFileSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                _isUploadFileSelected = value!;
                              });
                            },
                          ),
                          Text(_locale.uploadFile),
                          Checkbox(
                            value: !_isUploadFileSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                _isUploadFileSelected = !value!;
                              });
                            },
                          ),
                          Text(_locale.scanFile),
                        ],
                      ),
                      if (_isUploadFileSelected) buildFileUpload(),
                      if (!_isUploadFileSelected) buildScanDropdown(),
                    ],
                  ),
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
      txtUsercode: userName,
      txtInsurance: "",
      txtLicense: "",
      txtMaintenance: "",
      txtOtherservices: "",
      bolHasfile: 1,
      datArrvialdate: arrivalDateController.text,
      txtOriginalfilekey: "",
    );
    List<FileUploadModel> filesUploadList = [];
    print("filesBlobs.length ${filesBlobs.length}");
    for (int i = 0; i < filesBlobs.length; i++) {
      filesUploadList.add(FileUploadModel(
        txtKey: "",
        txtHdrkey: "",
        txtFilename: filesName[i],
        imgBlob: filesBlobs[i],
        dblFilesize: dblFilesize ?? 0,
        txtUsercode: userName,
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
        submitForWfApproval: approval == true ? 1 : 0);

    // Check if all required fields are empty
    if (selectedDep.isEmpty ||
        selectedCat.isEmpty ||
        (fileNameController.text.isEmpty && _isUploadFileSelected) ||
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
    filesBlobs.clear();
    filesName.clear();
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
    approval = false;
    followingController.clear();
    otherRefController.clear();
    organizationController.clear();
    arrivalDateController.text =
        Converters.formatDate2(DateTime.now().toString());
    fileDateController.text = Converters.formatDate2(DateTime.now().toString());
    setState(() {});
  }

  int scannerIndex = 0;
  Widget buildScanDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropDown(
            key: UniqueKey(),
            isMandatory: true,
            onChanged: (value) {
              for (int i = 0; i < scanners.length; i++) {
                if (scanners[i] == value) {
                  scannerIndex = i;
                }
              }
            },
            initialValue: "",
            // items: scanners,
            bordeText: _locale.scanners,
            width: width * 0.2,
            height: height * 0.05,
            onSearch: (p0) async {
              scanners = await DocumentsController().getAllScannersMethod(url);
              return scanners;
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              scan();
            },
            style: customButtonStyle(
                Size(isDesktop ? width * 0.1 : width * 0.4, height * 0.055),
                14,
                primary3),
            child: Text(
              _locale.scanFile,
              style: const TextStyle(color: whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  scan() async {
    openLoadinDialog(context);
    var response =
        await documentsController.getSccanedImageMethod(url, scannerIndex);
    filesName.add("${issueNoController.text}.pdf");
    filesBlobs.add(response.scannedImage!);
    Navigator.pop(context);
  }
}
