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
import '../../widget/dashboard_components/custom_elevated_button.dart';
import '../../widget/date_time_component.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';

// ── Design tokens ─────────────────────────────────────────────────
const Color _primary = Color(0xFF185FA5);
const Color _accent = Color(0xFF0D9B8A);
const Color _bgPage = Color(0xFFF0F4F8);
const Color _cardBg = Colors.white;
const Color _border = Color(0xFFDDE3EE);
const Color _textPrimary = Color(0xFF1A2340);
const Color _textSecondary = Color(0xFF8A94A6);

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
  TextEditingController scannedFile = TextEditingController();

  bool isDesktop = false;
  UserController userController = UserController();
  DocumentsController documentsController = DocumentsController();
  bool isFileLoading = false;
  String? txtFilename;
  String? imgBlob;
  int? dblFilesize;
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
  bool approval = false;
  String active = "0";
  late AppLocalizations _locale;
  FocusNode issueNameFocusNode = FocusNode();
  String? _scanStatusText;
  List<String> filesName = [];
  List<String> filesBlobs = [];
  List<dynamic> _cachedScanners = [];
  bool _loadedScanners = false;
  int scannerIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      issueNameFocusNode.requestFocus();
    });
  }

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
      backgroundColor: _bgPage,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _sectionCard(
              icon: Icons.note_add_rounded,
              title: _locale.addDocument,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── Row 1: Issue No + Arrival Date + Issue Date ──
                  _fieldRow([
                    _fieldItem(customTextField(
                        _locale.issueNo, issueNoController, isDesktop, 1, true,
                        focusNode: issueNameFocusNode)),
                    _fieldItem(DateTimeComponent(
                      height: height * 0.05,
                      label: _locale.arrivalDate,
                      dateController: arrivalDateController,
                      dateWidth: double.infinity,
                      dateControllerToCompareWith: null,
                      readOnly: false,
                      isInitiaDate: true,
                      onValue: (isValid, value) {
                        if (isValid) arrivalDateController.text = value;
                      },
                      timeControllerToCompareWith: null,
                    )),
                    _fieldItem(DateTimeComponent(
                      height: height * 0.05,
                      label: _locale.issueDate,
                      dateController: fileDateController,
                      dateWidth: double.infinity,
                      dateControllerToCompareWith: null,
                      readOnly: false,
                      isInitiaDate: true,
                      onValue: (isValid, value) {
                        if (isValid) fileDateController.text = value;
                      },
                      timeControllerToCompareWith: null,
                    )),
                  ]),

                  // ── Row 2: Description + Department + Category ───
                  _fieldRow([
                    _fieldItem(customTextField(_locale.txtDescription,
                        descriptionController, isDesktop, 1, true)),
                    _fieldItem(DropDown(
                      key: const ValueKey('dept_dropdown'),
                      isMandatory: true,
                      onChanged: (value) {
                        selectedDep = value.txtDeptkey;
                        selctedDepDesc = value.txtDeptName;
                      },
                      initialValue:
                          selctedDepDesc == "" ? null : selctedDepDesc,
                      bordeText: _locale.department,
                      width: double.infinity,
                      items: departmetList,
                      height: height * 0.055,
                    )),
                    _fieldItem(DropDown(
                      key: const ValueKey('cat_dropdown'),
                      isMandatory: true,
                      initialValue:
                          selectedCatDesc.isEmpty ? null : selectedCatDesc,
                      width: double.infinity,
                      height: height * 0.055,
                      onChanged: (value) {
                        selectedCat = value.txtKey;
                        selectedCatDesc = value.txtDescription;
                      },
                      items: catList,
                      searchBox: true,
                      valSelected: true,
                      bordeText: _locale.category,
                    )),
                  ]),

                  // ── Row 3: Keywords + Following + Ref1 ───────────
                  _fieldRow([
                    _fieldItem(customTextField(_locale.keyWords,
                        keyWordsController, isDesktop, 1, false)),
                    _fieldItem(customTextField(_locale.following,
                        followingController, isDesktop, 1, false)),
                    _fieldItem(customTextField(
                        _locale.ref1, ref1Controller, isDesktop, 1, false)),
                  ]),

                  // ── Row 4: Ref2 + OtherRef + Organization ────────
                  _fieldRow([
                    _fieldItem(customTextField(
                        _locale.ref2, ref2Controller, isDesktop, 1, false)),
                    _fieldItem(customTextField(_locale.otherRef,
                        otherRefController, isDesktop, 1, false)),
                    _fieldItem(customTextField(_locale.organization,
                        organizationController, isDesktop, 1, false)),
                  ]),

                  // ── Row 5: Toggles ────────────────────────────────
                  Row(
                    children: [
                      if (active == "1") ...[
                        _toggleChip(
                          label: _locale.submitforWorkflowApproval,
                          value: approval,
                          onChanged: (v) => setState(() => approval = v!),
                          color: _accent,
                        ),
                        const SizedBox(width: 12),
                      ],
                      _toggleChip(
                        label: _locale.uploadFile,
                        value: _isUploadFileSelected,
                        onChanged: (v) =>
                            setState(() => _isUploadFileSelected = v!),
                        color: _primary,
                      ),
                      const SizedBox(width: 12),
                      _toggleChip(
                        label: _locale.scanFile,
                        value: !_isUploadFileSelected,
                        onChanged: (v) =>
                            setState(() => _isUploadFileSelected = !v!),
                        color: _primary,
                      ),
                    ],
                  ),

                  // ── Row 6: File / Scan ────────────────────────────
                  if (_isUploadFileSelected) _buildFileUploadSection(),
                  if (!_isUploadFileSelected) _buildScanSection(),

                  // ── Row 7: Action buttons ─────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomElevatedButton(
                        text: _locale.save,
                        color: _primary,
                        icon: Icons.save_rounded,
                        width: width * 0.12,
                        height: height * 0.052,
                        fontSize: 14,
                        isLoading: saving,
                        onPressed: saveDocument,
                      ),
                      const SizedBox(width: 12),
                      CustomElevatedButton(
                        text: _locale.resetFilter,
                        color: redColor,
                        icon: Icons.refresh_rounded,
                        width: width * 0.12,
                        height: height * 0.052,
                        fontSize: 14,
                        onPressed: resetForm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Loading overlay ───────────────────────────────────────
          if (isFileLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      height: height - 32, // ← fill screen minus padding
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border(bottom: BorderSide(color: _border, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: _primary, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Content — fills remaining height evenly
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  // ── 3-column field row ────────────────────────────────────────────
  Widget _fieldRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .map((c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: c,
                ),
              ))
          .toList(),
    );
  }

  Widget _fieldItem(Widget child) => child;

  // ── Toggle chip ───────────────────────────────────────────────────
  Widget _toggleChip({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: value ? color.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: value ? color : _border,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? color : Colors.transparent,
                border: Border.all(
                  color: value ? color : _textSecondary,
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 10)
                  : null,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                color: value ? color : _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── File upload section ───────────────────────────────────────────
  Widget _buildFileUploadSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomElevatedButton(
          text: _locale.uploadFile,
          color: _accent,
          icon: Icons.upload_rounded,
          width: isDesktop ? width * 0.12 : width * 0.35,
          height: height * 0.05,
          fontSize: 13,
          onPressed: pickFile,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Tooltip(
            message: fileNameController.text,
            child: customTextField(
              _locale.fileName,
              fileNameController,
              isDesktop,
              1,
              true,
            ),
          ),
        ),
      ],
    );
  }

  // ── Scan section ──────────────────────────────────────────────────
  Widget _buildScanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: DropDown(
                isMandatory: true,
                onChanged: (value) {
                  if (value != null) {
                    scannerIndex = _cachedScanners.indexOf(value as String);
                  }
                },
                noDataString: "⚠️ No scanners found",
                initialValue: "",
                bordeText: _locale.scanners,
                width: double.infinity,
                height: height * 0.05,
                onSearch: _getScanners,
              ),
            ),
            const SizedBox(width: 16),
            CustomElevatedButton(
              text: _locale.scanFile,
              color: _accent,
              icon: Icons.document_scanner_rounded,
              width: isDesktop ? width * 0.12 : width * 0.35,
              height: height * 0.05,
              fontSize: 13,
              onPressed: () async {
                openLoadinDialog(context);
                await DocumentsController()
                    .getAllScannersMethod(url)
                    .then((value) {
                  Navigator.pop(context);
                  if (value.isNotEmpty) {
                    scan();
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => ErrorDialog(
                        icon: Icons.error_outline,
                        errorTitle: _locale.error,
                        errorDetails: _locale.noScannersFound,
                        color: Colors.red,
                        statusCode: 406,
                      ),
                    );
                  }
                }).catchError((e) {
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
        if (_scanStatusText != null && _scanStatusText!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  "${_locale.sucessScanFile} $_scanStatusText",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Helpers (unchanged logic) ─────────────────────────────────────
  Widget customTextField(
    String hint,
    TextEditingController controller,
    bool isDesktop,
    double widthFactor,
    bool isMandetory, {
    FocusNode? focusNode,
  }) {
    return CustomTextField2(
      readOnly: hint == _locale.fileName ? true : false,
      isReport: true,
      isMandetory: isMandetory,
      width: widthFactor == 1 ? double.infinity : width * widthFactor,
      height: height * 0.055, // ← consistent with dropdowns
      text: Text(hint),
      controller: controller,
      onSubmitted: (text) {},
      onChanged: (value) {},
      focusNode: focusNode,
    );
  }

  Future<List<dynamic>> _getScanners(String filter) async {
    if (_loadedScanners && filter.isEmpty) return _cachedScanners;
    final result = await DocumentsController().getAllScannersMethod(url);
    if (filter.isEmpty) {
      _cachedScanners = result;
      _loadedScanners = true;
    }
    return result;
  }

  Future pickFile() async {
    setState(() => isFileLoading = true);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      for (final f in result.files) {
        filesName.add(f.name);
        filesBlobs.add(base64Encode(f.bytes!));
      }
      setState(() {
        fileNameController.text = filesName.toString();
        isFileLoading = false;
      });
    } else {
      setState(() => isFileLoading = false);
    }
  }

  scan() async {
    openLoadinDialog(context);
    try {
      final response =
          await documentsController.getSccanedImageMethod(url, scannerIndex);
      final String base64Data = response.scannedImage ?? "";
      if (base64Data.isNotEmpty) {
        final fileName = "${issueNoController.text}.pdf";
        final bytes = base64Decode(base64Data);
        final sizeMB = bytes.length / 1000000;
        filesName.add(fileName);
        filesBlobs.add(base64Data);
        setState(() {
          scannedFile.text = fileName;
          _scanStatusText = "${sizeMB.toStringAsFixed(2)} MB";
        });
      } else {
        setState(() => _scanStatusText = _locale.noFileAvailableToPreview);
      }
    } finally {
      Navigator.pop(context);
    }
  }

  void saveDocument() async {
    if (saving) return;
    setState(() => saving = true);

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

    DocumentFileRequest documentFileRequest = DocumentFileRequest(
      documentInfo: documentModel,
      documentFile: filesUploadList,
      submitForWfApproval: approval == true ? 1 : 0,
    );

    if (selectedDep.isEmpty ||
        selectedCat.isEmpty ||
        (fileNameController.text.isEmpty && _isUploadFileSelected) ||
        descriptionController.text.isEmpty ||
        issueNoController.text.isEmpty) {
      CoolAlert.show(
        width: width * 0.4,
        context: context,
        type: CoolAlertType.error,
        title: _locale.fillRequiredFields,
        text: _locale.fillRequiredFields,
        confirmBtnText: _locale.ok,
        onConfirmBtnTap: () {},
      );
      setState(() => saving = false);
      return;
    }

    await documentsController.addDocument(documentFileRequest).then((value) {
      if (value.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            icon: Icons.done_all,
            errorDetails: _locale.done,
            errorTitle: _locale.addDoneSucess,
            color: Colors.green,
            statusCode: 200,
          ),
        ).then((_) => resetForm());
      }
    });

    setState(() => saving = false);
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
    _scanStatusText = null;
    arrivalDateController.text =
        Converters.formatDate2(DateTime.now().toString());
    fileDateController.text = Converters.formatDate2(DateTime.now().toString());
    setState(() {});
  }
}
