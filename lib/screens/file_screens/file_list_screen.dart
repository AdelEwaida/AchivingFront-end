import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:archiving_flutter_project/dialogs/actions_dialogs/add_edit_action_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/add_file_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/file_explor_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/info_document_dialogs.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/dialogs/pdf_preview.dart';
import 'package:archiving_flutter_project/models/db/actions_models/action_model.dart';
import 'package:archiving_flutter_project/models/db/categories_models/document_category_tree.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/models/db/document_models/upload_file_mode.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_document_criterea.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';
import 'package:archiving_flutter_project/models/tree_model/my_node.dart';
import 'package:archiving_flutter_project/models/tree_model/tree_tile.dart';
import 'package:archiving_flutter_project/providers/classification_name_and_code_provider.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/screens/file_screens/fillter_section.dart';
import 'package:archiving_flutter_project/screens/file_screens/table_file_list_section.dart';
import 'package:archiving_flutter_project/service/controller/categories_controllers/categories_controller.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/loading.dart';
import 'package:archiving_flutter_project/utils/constants/sorted_by_constant.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/utils/func/save_excel_file.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:archiving_flutter_project/widget/date_time_component.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_searchField.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import '../../dialogs/template_work_flow/edit_template_document_dialog.dart';
import '../../models/db/categories_models/doc_cat_parent.dart';
import '../../models/db/user_models/department_user_model.dart';
import '../../models/db/user_models/user_model.dart';
import '../../models/db/work_flow/work_flow_doc_model.dart';
import '../../models/db/work_flow/work_flow_document_info.dart';
import '../../service/controller/users_controller/user_controller.dart';
import '../../service/controller/work_flow_controllers/setup_controller.dart';
import '../../service/controller/work_flow_controllers/work_flow_template_controller.dart';
import '../../utils/constants/storage_keys.dart';
import '../../utils/constants/user_types_constant/user_types_constant.dart';
import '../../utils/func/lists.dart';
import '../../widget/custom_drop_down_new.dart';
import '../../widget/custom_flutter_toast_message.dart';
import '../../widget/dashboard_components/custom_elevated_button.dart';

class FileListScreen extends StatefulWidget {
  const FileListScreen({super.key});

  @override
  State<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  List<MyNode> treeNodes = [];
  List<PlutoColumn> polCols = [];

  // bool isLoading = false;
  ValueNotifier selectedCamp = ValueNotifier("");
  ValueNotifier selectedValue = ValueNotifier("");
  Color currentColor = Color.fromARGB(255, 225, 65, 65);
  Color selectedColor = Colors.grey;
  bool isDesktop = false;
  DocumentCategory? selectedCategory;
  late final TreeController<MyNode> treeController;
  List<MyNode> roots = [];
  CategoriesController categoriesController = CategoriesController();
  TextEditingController searchController = TextEditingController();
  TextEditingController fromDateController =
      TextEditingController(text: Converters.startOfCurrentYearAsString());
  TextEditingController toDateController = TextEditingController(
      text: Converters.formatDate2(DateTime.now().toString()));
  late DocumentListProvider documentListProvider;
  late CalssificatonNameAndCodeProvider calssificatonNameAndCodeProvider;
  DocumentsController documentsController = DocumentsController();
  PlutoRow? selectedRow;
  TextEditingController descreptionController = TextEditingController();
  TextEditingController issueNoController = TextEditingController();
  TextEditingController classificationController = TextEditingController();
  TextEditingController keyWordController = TextEditingController();
  TextEditingController ref1Controller = TextEditingController();
  TextEditingController ref2Controller = TextEditingController();
  TextEditingController otherRefController = TextEditingController();
  TextEditingController organizationController = TextEditingController();
  TextEditingController followingController = TextEditingController();
  TextEditingController userCodeController = TextEditingController();

  TextEditingController sortedByController = TextEditingController();
  String selectedDep = "";
  int selectedSortedType = -1;
  List<DepartmentModel> listOfDep = [];
  late PlutoGridStateManager stateManager;
  DocumentModel? documentModel;
  bool approval = false;
  UserController userController = UserController();
  ValueNotifier isTableLoading = ValueNotifier(true);

  String? active;
  List<UserModel> result = [];
  String userCode = "";
  ValueNotifier fileNumberDisplayed = ValueNotifier(0);

  // String? userName = "";
  var storage = FlutterSecureStorage();
  ValueNotifier totalDocCount = ValueNotifier(0);

  getCountOnLoaded() {
    documentsController
        .getTotalSearchDocCountFile(SearchDocumentCriteria(page: -1))
        .then((value) {
      totalDocCount.value = value;
    });
  }

  getCount() {
    final baseJson = documentListProvider.searchDocumentCriteria
        .toJson(); // Map<String, dynamic>
    final countCriteria = SearchDocumentCriteria.fromJson(baseJson);

    countCriteria.page = -1;
    // documentListProvider.searchDocumentCriteria.page = -1;

    countCriteria.fromIssueDate = documentListProvider.issueNumber != null
        ? null
        : fromDateController.text;
    countCriteria.toIssueDate =
        documentListProvider.issueNumber != null ? null : toDateController.text;
    countCriteria.desc = descreptionController.text;
    countCriteria.issueNo = issueNoController.text;
    countCriteria.dept = selectedDep;
    countCriteria.keywords = keyWordController.text;
    countCriteria.ref1 = ref1Controller.text;
    countCriteria.ref2 = ref2Controller.text;
    countCriteria.otherRef = otherRefController.text;
    countCriteria.cat = calssificatonNameAndCodeProvider.classificatonKey;
    countCriteria.organization = organizationController.text;
    countCriteria.following = followingController.text;
    countCriteria.sortedBy = selectedSortedType;

    documentsController.getTotalSearchDocCountFile(countCriteria).then((value) {
      totalDocCount.value = value;
    });
  }

  bool _isInitialized = false;

  @override
  void dispose() {
    calssificatonNameAndCodeProvider.clearProvider();
    documentListProvider.setDocumentSearchCriterea(SearchDocumentCriteria());
    documentListProvider.searchDocumentCriteria.page = 1;
    documentListProvider.setPage(1);
    super.dispose();
  }

  bool isFetchExecuted = false; // Track fetch execution
  int? limitAction;
  @override
  Future<void> didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    // Execute only if it hasn't run before
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    fillColumnTable();

    if (!isFetchExecuted) {
      // fillColumnTable();

      documentListProvider = context.read<DocumentListProvider>();
      calssificatonNameAndCodeProvider =
          context.read<CalssificatonNameAndCodeProvider>();

      if (treeNodes.isEmpty) {
        roots = <MyNode>[
          MyNode(title: '/', children: treeNodes, extra: null, isRoot: true),
        ];
        treeController = TreeController<MyNode>(
          roots: roots,
          childrenProvider: (MyNode node) => node.children,
        );
        await fetchData();
        await fetchDropDownTree();
      }

      if (documentListProvider.issueNumber != null) {
        issueNoController.text = documentListProvider.issueNumber ?? "";
        documentListProvider.setDocumentSearchCriterea(SearchDocumentCriteria(
            issueNo: issueNoController.text,
            fromIssueDate: "",
            toIssueDate: "",
            page: -1));
      }
      await SetupController().getSetupList().then((value) async {
        setState(() {
          active = value!.first.bolActive.toString()!;
        });
      });

      isFetchExecuted = true;
    }

    polCols = [];
    fillColumnTable();
    if (stateManager != null) {
      for (int i = 0; i < polCols.length; i++) {
        String title = polCols[i].title;
        polCols[i].titleSpan = TextSpan(
          children: [
            WidgetSpan(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        );
        polCols[i].titleTextAlign = PlutoColumnTextAlign.center;
        polCols[i].textAlign = PlutoColumnTextAlign.center;

        stateManager.columns[i].title = polCols[i].title;
        stateManager.columns[i].width = polCols[i].width;
        stateManager.columns[i].titleTextAlign = polCols[i].titleTextAlign;
        stateManager.columns[i].textAlign = polCols[i].textAlign;
        stateManager.columns[i].titleSpan = polCols[i].titleSpan;
      }
    }
    userCode = (await storage.read(key: "userName")) ?? "";
    result = await userController.getUsers(
      SearchModel(searchField: userCode, page: -1, status: -1),
    );
    print("documentListProvider.page :${documentListProvider.page}");

    limitAction = result.first!.bolLimitActions;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adding some spacing between search field and tree
            // In build(), replace the top Padding Row with:
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  context.read<DocumentListProvider>().isViewFile == true
                      ? const SizedBox.shrink()
                      : _treeCard(),
                  if (context.read<DocumentListProvider>().isViewFile != true)
                    const SizedBox(width: 8),
                  Expanded(child: fillterSection()),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    if (active == "1")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomElevatedButton(
                              text: _locale.submitforWorkflowApproval,
                              color: greenColor,
                              icon: Icons.approval_rounded,
                              width: isDesktop ? width * 0.13 : width * 0.19,
                              height: height * 0.043,
                              fontSize: 13,
                              onPressed: () async {
                                if (documentModel != null) {
                                  var response = await documentsController
                                      .createWorkFlowDocument(documentModel!);
                                  if (response.statusCode == 200) {
                                    showDialog(
                                      // ignore: use_build_context_synchronously
                                      context: context,
                                      builder: (context) {
                                        return ErrorDialog(
                                          icon: Icons.done_all,
                                          errorDetails: _locale.done,
                                          errorTitle: _locale.editDoneSucess,
                                          color: Colors.green,
                                          statusCode: 200,
                                        );
                                      },
                                    ).then((value) {
                                      if (value) setState(() {});
                                    });
                                  }
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            CustomElevatedButton(
                              text: _locale.viewApprovals,
                              color: primary,
                              icon: Icons.visibility_rounded,
                              width: isDesktop ? width * 0.1 : width * 0.19,
                              height: height * 0.043,
                              fontSize: 13,
                              onPressed: () async {
                                if (documentModel != null) {
                                  List<WorkFlowDocumentInfo> result =
                                      await WorkFlowTemplateContoller()
                                          .getWorkFlowDocumentInfo(
                                              WorkFlowDocumentModel(
                                                  documentCode:
                                                      documentModel!.txtKey));

                                  if (result.isEmpty) {
                                    // ignore: use_build_context_synchronously
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return const ErrorDialog(
                                          icon: Icons.error,
                                          errorDetails: "Error",
                                          errorTitle:
                                              "No workflow template data available.",
                                          color: Colors.red,
                                          statusCode: 400,
                                        );
                                      },
                                    );
                                    return;
                                  }

                                  // ignore: use_build_context_synchronously
                                  await showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return EditTemplateDocumentDialog(
                                        workFlowTemplateBody: result,
                                      );
                                    },
                                  ).then((value) {
                                    if (value == true) {}
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    tableSection(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  void explorFiels() {
    if (selectedRow != null) {
      openLoadinDialog(context);
      documentsController
          .getFilesByHdrKey(selectedRow!.cells['txtKey']!.value)
          .then((value) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return FileExplorDialog(listOfFiles: value);
          },
        );
      }).then((value) {
        // log("valuevaluevaluevaluevaluevaluevalue:${value}");
        // if (value != null) {
        //   // log("DONE");
        //   documentListProvider.setDocumentSearchCriterea(
        //       documentListProvider.searchDocumentCriteria);
        //   Navigator.pop(context);
        //   Navigator.pop(context);
        // }
      });
    } else {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
    }
  }

  Future<void> download() async {
    if (selectedRow == null) return;

    openLoadinDialog(context);
    try {
      final files = await documentsController
          .getFilesByHdrKey(selectedRow!.cells['txtKey']!.value);

      if (files.isEmpty) {
        Navigator.pop(context);
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            icon: Icons.error_outline,
            errorDetails: _locale.noFilesFoundForThisDocument,
            errorTitle: _locale.downloadFailed,
            color: Colors.red,
            statusCode: 400,
          ),
        );
        return;
      }

      // Build the archive
      final archive = Archive();
      final seen = <String, int>{};
      int added = 0;

      for (final f in files) {
        try {
          final bytes = base64Decode(f.imgBlob ?? '');
          var name = (f.txtFilename ?? 'file').trim();
          if (name.isEmpty) name = 'file_${added + 1}';
          name = _uniqueName(name, seen);

          archive.addFile(ArchiveFile(name, bytes.length, bytes));
          added++;
        } catch (e) {
          log("Skipping a file due to decode error: $e");
        }
      }

      if (added == 0) {
        Navigator.pop(context);
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            icon: Icons.error_outline,
            errorDetails: _locale.noValidFilesToZip,
            errorTitle: _locale.downloadFailed,
            color: Colors.red,
            statusCode: 400,
          ),
        );
        return;
      }

      // Encode ZIP
      final zipBytes = ZipEncoder().encode(archive)!;

      // Name the zip
      final zipName =
          "${Converters.formatDate(DateTime.now().toString())}_files.zip";

      // Download
      _saveZip(zipBytes, zipName);

      Navigator.pop(context);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => ErrorDialog(
          icon: Icons.done_all,
          errorDetails: _locale.filesPackedIntoZip(added, zipName),
          errorTitle: _locale.downloadReady,
          color: Colors.green,
          statusCode: 200,
        ),
      );
    } catch (e) {
      log("Error zipping/downloading files: $e");
      Navigator.pop(context);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => ErrorDialog(
          icon: Icons.error_outline,
          errorDetails: _locale.zippingError,
          errorTitle: _locale.downloadFailed,
          color: Colors.red,
          statusCode: 400,
        ),
      );
    }
  }

// Ensure unique filenames inside the zip (avoid overwrites)
  String _uniqueName(String name, Map<String, int> seen) {
    final dot = name.lastIndexOf('.');
    final base = dot > 0 ? name.substring(0, dot) : name;
    final ext = dot > 0 ? name.substring(dot) : '';
    if (!seen.containsKey(name)) {
      seen[name] = 1;
      return name;
    }
    final n = (seen[name]! + 1);
    seen[name] = n;
    return '$base ($n)$ext';
  }

  void _saveZip(List<int> bytes, String fileName) {
    final blob = html.Blob([Uint8List.fromList(bytes)], 'application/zip');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final a = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = fileName
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Widget tableSection() {
    return Column(
      children: [
        TableComponent(
          tableHeigt: height * 0.42,
          tableWidth: width * 0.98, // ← full width minus page padding
          addReminder: context.read<DocumentListProvider>().isViewFile == true
              ? null
              : addRemider,
          upload: context.read<DocumentListProvider>().isViewFile == true
              ? null
              : uploadFile,
          copy: context.read<DocumentListProvider>().isViewFile == true
              ? null
              : copyFile,
          delete: context.read<DocumentListProvider>().isViewFile == true
              ? null
              : deleteFile,
          genranlEdit: context.read<DocumentListProvider>().isViewFile == true
              ? null
              : editDocumentInfo,
          plCols: polCols,
          mode: PlutoGridMode.selectWithOneTap,
          polRows: [],
          footerBuilder: (stateManager) {
            return lazyLoadingfooter(stateManager);
          },
          explor: explorFiels,
          view: viewDocumentInfo,
          download: download,
          filesList: context.read<DocumentListProvider>().isViewFile == true
              ? fileViewScreen
              : null,
          exportToExcel: exportExcel,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
            if (isLoading.value) {
              stateManager.setShowLoading(true);
            }
            stateManager.setShowColumnFilter(true);
            getCount();
          },
          doubleTab: (event) async {
            PlutoRow? tappedRow = event.row;
            documentModel = DocumentModel.fromPlutoRow(tappedRow!, _locale);
            if (context.read<DocumentListProvider>().isViewFile == true) {
              return null;
            } else {
              DocumentModel documentModel =
                  DocumentModel.fromPlutoRow(tappedRow!, _locale);
              showDialog(
                context: context,
                builder: (context) {
                  return InfoDocumentDialog(
                    isEdit: true,
                    documentModel: documentModel,
                  );
                },
              ).then((value) {
                if (value) {
                  documentListProvider.searchDocumentCriteria.page = 0;
                  selectedRow = null;
                  setState(() {});
                  documentListProvider.setDocumentSearchCriterea(
                      documentListProvider.searchDocumentCriteria);
                  resetForm();
                }
              });
            }
          },
          onSelected: (event) async {
            PlutoRow? tappedRow = event.row;
            selectedRow = tappedRow;
            documentModel = DocumentModel.fromPlutoRow(selectedRow!, _locale);
          },
        ),

        // ── Footer: file count + total count ──────────────────
        SizedBox(
          width: width * 0.98,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // File count badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF185FA5).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        color: const Color(0xFF185FA5).withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.file_present_rounded,
                          size: 13, color: Color(0xFF185FA5)),
                      const SizedBox(width: 5),
                      Text(
                        '${_locale.numOfFilesNum}: ',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A94A6),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: fileNumberDisplayed,
                        builder: (context, value, child) => Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF185FA5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Total count badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9B8A).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        color: const Color(0xFF0D9B8A).withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.numbers_rounded,
                          size: 13, color: Color(0xFF0D9B8A)),
                      const SizedBox(width: 5),
                      Text(
                        '${_locale.totalCount}: ',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A94A6),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: totalDocCount,
                        builder: (context, value, child) => Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D9B8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  editDocumentInfo() async {
    if (selectedRow == null) return;

    final String? selectedDept = selectedRow!.cells['txtDept']?.value;
    if (selectedDept == null) return;

    DocumentModel documentModel =
        DocumentModel.fromPlutoRow(selectedRow!, _locale);

    if (limitAction != 1) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoDocumentDialog(
            isEdit: true,
            documentModel: documentModel,
          );
        },
      ).then((value) {
        if (value) {
          documentListProvider.searchDocumentCriteria.page = 0;
          selectedRow = null;
          setState(() {});
          documentListProvider.setDocumentSearchCriterea(
              documentListProvider.searchDocumentCriteria);
        }
      });
      return;
    }

    final List<DepartmentUserModel> userDepartments =
        await userController.getDepartmentSelectedUser(userCode);

    bool hasMatch = false;

    for (final dept in userDepartments) {
      final deptName = dept.txtDeptName?.toLowerCase().trim();
      if (deptName == selectedDept.toLowerCase().trim()) {
        hasMatch = true;
        break;
      }
    }

    if (hasMatch) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return InfoDocumentDialog(
            isEdit: true,
            documentModel: documentModel,
          );
        },
      ).then((value) {
        if (value) {
          documentListProvider.searchDocumentCriteria.page = 0;
          selectedRow = null;
          setState(() {});
          documentListProvider.setDocumentSearchCriterea(
              documentListProvider.searchDocumentCriteria);
        }
      });
    } else {
      CustomToastMessage.error(context, _locale.notAllowedToEditDept);
      // ignore: use_build_context_synchronously
      // showDialog(
      //   context: context,
      //   builder: (context) => ErrorDialog(
      //     icon: Icons.warning,
      //     errorDetails: _locale.notAllowedToEditDept,
      //     errorTitle: 'Unauthorized',
      //     color: Colors.red,
      //     statusCode: 403,
      //   ),
      // );
    }
  }

  Future<void> exportExcel() async {
    openLoadinDialog(context);

    try {
      documentListProvider.searchDocumentCriteria.page = -1;
      print(
          "searchDocumentCriteria for excel: ${documentListProvider.searchDocumentCriteria.toJson()}");
      Uint8List excelData = await documentsController.exportToExcel(
          documentListProvider.searchDocumentCriteria!, context);

      saveExcelFile(excelData,
          "${"Finance  - Report"} ${Converters.formatDate(DateTime.now().toString())}.xlsx");

      Navigator.of(context, rootNavigator: true).pop(true);
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(true);
    }
  }

  bool _isExportingExcel = false;

  Future<void> exportToExec111l() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: SizedBox(
          width: 100,
          height: 100,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

    try {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      if (stateManager == null) return;

      List<String> headers = stateManager!.columns.map((column) {
        return column.title ?? '';
      }).toList();

      sheet.appendRow(headers);
      List<PlutoRow> temp = [];

      // SearchDocumentCriteria searchDocumentCriteria = SearchDocumentCriteria();
      // if (documentListProvider.issueNumber != null) {
      //   searchDocumentCriteria.fromIssueDate =
      //       documentListProvider.issueNumber != null
      //           ? null
      //           : fromDateController.text;
      //   searchDocumentCriteria.toIssueDate =
      //       documentListProvider.issueNumber != null
      //           ? null
      //           : toDateController.text;
      // } else {
      //   searchDocumentCriteria.fromIssueDate = null;
      //   searchDocumentCriteria.toIssueDate = null;
      // }

      // searchDocumentCriteria.desc = descreptionController.text;
      // searchDocumentCriteria.issueNo = issueNoController.text;
      // searchDocumentCriteria.dept = selectedDep;
      // searchDocumentCriteria.keywords = keyWordController.text;
      // searchDocumentCriteria.ref1 = ref1Controller.text;
      // searchDocumentCriteria.ref2 = ref2Controller.text;
      // searchDocumentCriteria.otherRef = otherRefController.text;
      // searchDocumentCriteria.cat =
      //     calssificatonNameAndCodeProvider.classificatonKey;
      // searchDocumentCriteria.organization = organizationController.text;
      // searchDocumentCriteria.following = followingController.text;
      // searchDocumentCriteria.sortedBy = selectedSortedType;
      documentListProvider.searchDocumentCriteria.page = -1;
      print(
          "searchDocumentCriteria for excel: ${documentListProvider.searchDocumentCriteria.toJson()}");
      List<DocumentModel> result = await documentsController
          .searchDocCriterea(documentListProvider.searchDocumentCriteria);

      for (int i = 0; i < result.length; i++) {
        temp.add(result[i].toPlutoRow(i, _locale));
      }

      List<List<String>> rows = temp.map((row) {
        return stateManager.columns.map((column) {
          return row.cells[column.field]?.value.toString() ?? '';
        }).toList();
      }).toList();

      for (var row in rows) {
        sheet.appendRow(row);
      }

      final excelBytes = excel.encode();
      final blob = html.Blob([excelBytes!],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download',
            'exported_files${Converters.formatDate(DateTime.now().toString())}.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      log("Export error: $e");
    } finally {
      // Close loading dialog
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  Widget space(double width1) {
    return SizedBox(
      width: width * width1,
    );
  }

  void fileViewScreen() {
    if (selectedRow == null) return;

    openLoadinDialog(context);

    documentsController
        .getFilesByHdrKey(selectedRow!.cells['txtKey']!.value)
        .then((files) {
      // close loader
      if (Navigator.canPop(context)) Navigator.pop(context);

      // 1) 200 but empty (or null) -> show message
      if (files == null || files.isEmpty) {
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            icon: Icons.info_outline,
            errorDetails: _locale.noFileAvailableToPreview,
            errorTitle: _locale.error,
            color: Colors.orange,
            statusCode: 200,
          ),
        );
        return;
      }

      final file = files.first;

      if ((file.imgBlob ?? '').isEmpty) {
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            icon: Icons.info_outline,
            errorDetails: _locale.noFileContentReturned,
            errorTitle: _locale.error,
            color: Colors.orange,
            statusCode: 200,
          ),
        );
        return;
      }

      // decode
      final bytes = Uint8List.fromList(base64Decode(file.imgBlob!));
      final name = (file.txtFilename ?? '').toLowerCase();

      // 3) preview
      if (name.endsWith('.pdf') ||
          name.endsWith('.jpeg') ||
          name.endsWith('.png') ||
          name.endsWith('.jpg')) {
        showDialog(
          context: context,
          builder: (_) => PdfPreview1(
            pdfFile: bytes,
            fileName: file.txtFilename ?? 'file',
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            icon: Icons.error_outlined,
            errorDetails: _locale.previewNotAvilable,
            errorTitle: _locale.error,
            color: Colors.red,
            statusCode: 500,
          ),
        );
      }
    }).catchError((e) {
      // close loader if still open
      if (Navigator.canPop(context)) Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => ErrorDialog(
          icon: Icons.error_outline,
          errorDetails: _locale.previewNotAvilable,
          errorTitle: _locale.error,
          color: Colors.red,
          statusCode: 500,
        ),
      );
    });
  }

  void addRemider() {
    if (selectedRow != null) {
      ActionModel actionModel = ActionModel();
      actionModel.txtDescription = selectedRow!.cells['txtDescription']!.value;
      showDialog(
        context: context,
        builder: (context) {
          return AddEditActionDialog(
            title: _locale.addReminder,
            actionModel: actionModel,
            isFromList: true,
          );
        },
      ).then((value) {
        selectedRow = null;
      });
    } else {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
    }
  }

  Widget fillterSection1() {
    return Container(
      width: context.read<DocumentListProvider>().isViewFile == true
          ? width * 0.81
          : width * 0.44,
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
                          dateWidth:
                              context.read<DocumentListProvider>().isViewFile ==
                                      true
                                  ? width * 0.19
                                  : width * 0.1,
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
                          dateWidth:
                              context.read<DocumentListProvider>().isViewFile ==
                                      true
                                  ? width * 0.19
                                  : width * 0.1,
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
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                    // items: listOfDep,
                    onSearch: (p0) async {
                      return await DepartmentController()
                          .search(SearchModel(page: 1, searchField: p0));
                    },
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
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
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
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
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
                        width:
                            context.read<DocumentListProvider>().isViewFile ==
                                    true
                                ? width * 0.19
                                : width * 0.1,
                        height: height * 0.04,
                        readOnly: true,
                      );
                    },
                  ),
                  space(0.01),
                  CustomTextField2(
                    text: Text(_locale.keyword),
                    controller: keyWordController,
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                  ),
                  space(0.01),
                  CustomTextField2(
                    text: Text(_locale.ref1),
                    controller: ref1Controller,
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
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
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                  ),
                  space(0.01),
                  CustomTextField2(
                    text: Text(_locale.otherRef),
                    controller: otherRefController,
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                  ),
                  space(0.01),
                  CustomTextField2(
                    text: Text(_locale.organization),
                    controller: organizationController,
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                  ),
                  space(0.01),
                  CustomTextField2(
                    text: Text(_locale.following),
                    controller: followingController,
                    width:
                        context.read<DocumentListProvider>().isViewFile == true
                            ? width * 0.19
                            : width * 0.1,
                    height: height * 0.04,
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.00001,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // space(0.02),
                    CustomTextField2(
                      width: context.read<DocumentListProvider>().isViewFile ==
                              true
                          ? width * 0.19
                          : width * 0.32,
                      height: height * 0.04,
                      text: Text(_locale.issueNo),
                      controller: issueNoController,
                    ),
                    space(0.01),
                    CustomTextField2(
                      text: Text(_locale.userCode),
                      controller: userCodeController,
                      width: context.read<DocumentListProvider>().isViewFile ==
                              true
                          ? width * 0.19
                          : width * 0.1,
                      height: height * 0.04,
                    ),
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
                  search().then((value) {
                    getCount();
                  });
                },
                style: customButtonStyle(
                    context,
                    Size(
                        isDesktop
                            ? context.read<DocumentListProvider>().isViewFile ==
                                    true
                                ? width * 0.14
                                : width * 0.1
                            : width * 0.19,
                        height * 0.043),
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
                onPressed: () async {
                  resetForm();
                },
                style: customButtonStyle(
                    context,
                    Size(
                        isDesktop
                            ? context.read<DocumentListProvider>().isViewFile ==
                                    true
                                ? width * 0.14
                                : width * 0.12
                            : width * 0.19,
                        height * 0.043),
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

  // Future<void> initializePage() async {
  //   // Reset tree state
  //   isFetchExecuted = false;
  //   treeNodes.clear();
  //   roots = <MyNode>[
  //     MyNode(title: '/', children: treeNodes, extra: null, isRoot: true),
  //   ];
  //   treeController.roots = roots;
  //   treeController.notifyListeners();

  //   // Reset filters
  //   documentListProvider.setPage(1);
  //   documentListProvider.setIsSearch(false);
  //   documentListProvider.setIssueNumber(null);
  //   documentListProvider.setDocumentSearchCriterea(SearchDocumentCriteria());

  //   // Fetch initial data
  //   await fetchDropDownTree();
  //   await fetchData();

  //   // Fetch initial document list
  //   stateManager.setShowLoading(true);
  //   stateManager.removeAllRows();
  //   List<DocumentModel> result = await documentsController
  //       .searchDocCriterea(SearchDocumentCriteria(page: 1));
  //   for (int i = 0; i < result.length; i++) {
  //     stateManager.appendRows([result[i].toPlutoRow(i + 1, _locale)]);
  //   }
  //   stateManager.setShowLoading(false);
  //   getCount();
  // }

  Future<void> resetForm() async {
    fromDateController.text = Converters.startOfCurrentYearAsString();
    toDateController.text = Converters.formatDate2(DateTime.now().toString());
    print(
        "fromDateController.textfromDateController.textfromDateController.text:${fromDateController.text}");
    descreptionController.clear();
    issueNoController.clear();
    classificationController.clear();
    keyWordController.clear();
    ref1Controller.clear();
    ref2Controller.clear();
    userCodeController.clear();
    otherRefController.clear();
    organizationController.clear();
    followingController.clear();
    selectedDep = "";
    selectedSortedType = -1;

    documentListProvider.setIssueNumber(null);
    documentListProvider.setIsSearch(false);
    documentListProvider.setPage(1);
    calssificatonNameAndCodeProvider.setSelectedClassificatonKey("");
    calssificatonNameAndCodeProvider.setSelectedClassificatonName("");
    final initialCriteria = SearchDocumentCriteria(
      page: 1,
      fromIssueDate: fromDateController.text,
      toIssueDate: toDateController.text,
    );
    print(initialCriteria.toJson());

    documentListProvider.setDocumentSearchCriterea(initialCriteria);

    stateManager.removeAllRows();
    stateManager.setShowLoading(true);

    List<DocumentModel> result = await documentsController
        .searchDocCriterea(documentListProvider.searchDocumentCriteria);

    for (int i = 0; i < result.length; i++) {
      stateManager.appendRows([result[i].toPlutoRow(i + 1, _locale)]);
    }
    fileNumberDisplayed.value = stateManager.refRows.length;
    documentListProvider.setPage(2);

    stateManager.setShowLoading(false);
    getCount();
    setState(() {});
  }

  Future<void> search() async {
    stateManager.setShowLoading(true);

    documentListProvider.setIsSearch(true);
    documentListProvider.setPage(1);

    documentListProvider.searchDocumentCriteria.page = 1;
    documentListProvider.searchDocumentCriteria.fromIssueDate =
        documentListProvider.issueNumber != null
            ? null
            : fromDateController.text;
    documentListProvider.searchDocumentCriteria.toIssueDate =
        documentListProvider.issueNumber != null ? null : toDateController.text;
    documentListProvider.searchDocumentCriteria.desc =
        descreptionController.text;
    documentListProvider.searchDocumentCriteria.issueNo =
        issueNoController.text;
    documentListProvider.searchDocumentCriteria.usercode =
        userCodeController.text;
    documentListProvider.searchDocumentCriteria.dept = selectedDep;
    documentListProvider.searchDocumentCriteria.keywords =
        keyWordController.text;
    documentListProvider.searchDocumentCriteria.ref1 = ref1Controller.text;
    documentListProvider.searchDocumentCriteria.ref2 = ref2Controller.text;
    documentListProvider.searchDocumentCriteria.otherRef =
        otherRefController.text;
    documentListProvider.searchDocumentCriteria.cat =
        calssificatonNameAndCodeProvider.classificatonKey;
    documentListProvider.searchDocumentCriteria.organization =
        organizationController.text;
    documentListProvider.searchDocumentCriteria.following =
        followingController.text;
    documentListProvider.searchDocumentCriteria.sortedBy = selectedSortedType;

    List<DocumentModel> result = await documentsController
        .searchDocCriterea(documentListProvider.searchDocumentCriteria);

    stateManager.removeAllRows();

    for (int i = 0; i < result.length; i++) {
      stateManager.appendRows([result[i].toPlutoRow(i + 1, _locale)]);
    }
    fileNumberDisplayed.value = stateManager.refRows.length;

    documentListProvider.setPage(2);

    stateManager.setShowLoading(false);
  }

  void uploadFile() async {
    if (selectedRow == null) return;

    final String? selectedDept = selectedRow!.cells['txtDept']?.value;
    if (selectedDept == null) return;

    DocumentModel documentModel =
        DocumentModel.fromPlutoRow(selectedRow!, _locale);
    print("documentModeldocumentModel :${documentModel.toJson()}");
    if (limitAction != 1) {
      showUploadDialog(documentModel);
      return;
    }

    final List<DepartmentUserModel> userDepartments =
        await userController.getDepartmentSelectedUser(userCode);

    bool hasMatch = false;

    for (final dept in userDepartments) {
      final deptName = dept.txtDeptName?.toLowerCase().trim();
      if (deptName == selectedDept.toLowerCase().trim()) {
        hasMatch = true;
        break;
      }
    }

    if (hasMatch) {
      showUploadDialog(documentModel);
    } else {
      CustomToastMessage.error(context, _locale.notAllowedToEditDept);
      // // ignore: use_build_context_synchronously
      // showDialog(
      //   context: context,
      //   builder: (context) => ErrorDialog(
      //     icon: Icons.warning,
      //     errorDetails: _locale.notAllowedToEditDept,
      //     errorTitle: 'Unauthorized',
      //     color: Colors.red,
      //     statusCode: 403,
      //   ),
      // );
    }
  }

  void showUploadDialog(DocumentModel documentModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AddFileDialog(documentModel: documentModel);
      },
    ).then((value) {
      if (value) {
        documentListProvider.searchDocumentCriteria.page = 0;
        documentListProvider.setDocumentSearchCriterea(
            documentListProvider.searchDocumentCriteria);
      }
    });
  }

  viewDocumentInfo() {
    if (selectedRow != null) {
      DocumentModel documentModel =
          DocumentModel.fromPlutoRow(selectedRow!, _locale);
      showDialog(
        context: context,
        builder: (context) {
          return InfoDocumentDialog(
            isEdit: false,
            documentModel: documentModel,
          );
        },
      ).then((value) {
        // selectedRow = null;
      });
    } else {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
    }
  }

  Future<void> deleteFile() async {
    if (selectedRow != null) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomConfirmDialog(
              confirmMessage: _locale.areYouSureToDelete(
                  selectedRow!.cells['txtDescription']!.value));
        },
      ).then((value) async {
        if (value) {
          DocumentModel documentModel =
              DocumentModel.fromPlutoRow(selectedRow!, _locale);
          var response =
              await documentsController.deleteDocument(documentModel);
          if (response.statusCode == 200) {
            await search();
            getCount();
            selectedRow = null;
          }
        }
      });
    } else {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
    }
  }

  void copyFile() async {
    if (selectedRow != null) {
      DocumentModel documentModel =
          DocumentModel.fromPlutoRow(selectedRow!, _locale);
      var response = await documentsController.copyDocument(documentModel);
      if (response.statusCode == 200) {
        // log("DONE");
        documentListProvider.searchDocumentCriteria.page = 0;
        setState(() {});
      }
    } else {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
    }
  }

  void fillColumnTable() {
    polCols.addAll([
      PlutoColumn(
        title: "#",
        field: "countNumber",
        enableFilterMenuItem: true,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.05 : width * 0.15,
        backgroundColor: columnColors,
        readOnly: true,
        renderer: (rendererContext) {
          return Center(child: Text((rendererContext.rowIdx + 1).toString()));
        },
      ),
      PlutoColumn(
        title: _locale.description,
        field: "txtDescription",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.18 : width * 0.4,
        backgroundColor: columnColors,
        enableFilterMenuItem: true,
        readOnly: true,
      ),
      PlutoColumn(
        title: _locale.issueNo,
        field: "txtIssueno",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.15 : width * 0.2,
        backgroundColor: columnColors,
        enableFilterMenuItem: true,
        readOnly: true,
      ),
      PlutoColumn(
        title: _locale.status,
        field: "workflowStatus",
        readOnly: true,
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.1 : width * 0.2,
        backgroundColor: columnColors,
        renderer: (rendererContext) {
          final String statusText = rendererContext.cell.value;

          // ── Status config ──────────────────────────────────
          Color bgColor = Colors.transparent;
          Color darkColor = Colors.transparent;
          IconData icon = Icons.circle_outlined;

          if (statusText == _locale.approved) {
            bgColor = const Color(0xFF22C55E);
            darkColor = const Color(0xFF16A34A);
            icon = Icons.check_circle_rounded;
          } else if (statusText == _locale.rejected) {
            bgColor = const Color(0xFFEF4444);
            darkColor = const Color(0xFFDC2626);
            icon = Icons.cancel_rounded;
          } else if (statusText == _locale.pending) {
            bgColor = const Color(0xFFF97316);
            darkColor = const Color(0xFFEA580C);
            icon = Icons.hourglass_top_rounded;
          }

          if (statusText.isEmpty || bgColor == Colors.transparent) {
            return const SizedBox.shrink();
          }

          return Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bgColor, darkColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(
                    color: bgColor.withOpacity(0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 11),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      statusText,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: _locale.issueDate,
        field: "datIssuedate",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.13 : width * 0.2,
        backgroundColor: columnColors,
        enableFilterMenuItem: true,
        readOnly: true,
      ),
      PlutoColumn(
        title: _locale.userCode,
        field: "txtUsercode",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.15 : width * 0.2,
        backgroundColor: columnColors,
        readOnly: true,
      ),
      PlutoColumn(
        title: _locale.department,
        field: "txtDept",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.12 : width * 0.2,
        backgroundColor: columnColors,
        readOnly: true,
      ),
      PlutoColumn(
        title: _locale.category,
        field: "txtCategory",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.08 : width * 0.2,
        backgroundColor: columnColors,
        readOnly: true,
      ),
    ]);
  }

  PlutoInfinityScrollRows lazyLoadingfooter(
      PlutoGridStateManager stateManager) {
    return PlutoInfinityScrollRows(
      initialFetch: true,
      fetchWithSorting: false,
      fetchWithFiltering: false,
      fetch: fetch,
      stateManager: stateManager,
    );
  }

  List<PlutoRow> rowList = [];
  Future<PlutoInfinityScrollRowsResponse> fetch(
      PlutoInfinityScrollRowsRequest request) async {
    stateManager.setShowLoading(true);
    List<PlutoRow> resultRows = [];

    if (documentListProvider.issueNumber == null) {
      if (documentListProvider.isSearch) {
        documentListProvider.searchDocumentCriteria.page =
            documentListProvider.page ?? 1;

        documentListProvider.searchDocumentCriteria.fromIssueDate =
            fromDateController.text;
        documentListProvider.searchDocumentCriteria.toIssueDate =
            toDateController.text;
        documentListProvider.searchDocumentCriteria.desc =
            descreptionController.text;
        documentListProvider.searchDocumentCriteria.issueNo =
            issueNoController.text;
        documentListProvider.searchDocumentCriteria.dept = selectedDep;
        documentListProvider.searchDocumentCriteria.keywords =
            keyWordController.text;
        documentListProvider.searchDocumentCriteria.ref1 = ref1Controller.text;
        documentListProvider.searchDocumentCriteria.ref2 = ref2Controller.text;
        documentListProvider.searchDocumentCriteria.otherRef =
            otherRefController.text;
        documentListProvider.searchDocumentCriteria.cat =
            calssificatonNameAndCodeProvider.classificatonKey;
        documentListProvider.searchDocumentCriteria.organization =
            organizationController.text;
        documentListProvider.searchDocumentCriteria.following =
            followingController.text;
        documentListProvider.searchDocumentCriteria.sortedBy =
            selectedSortedType;

        List<DocumentModel> result = await documentsController
            .searchDocCriterea(documentListProvider.searchDocumentCriteria);

        for (int i = 0; i < result.length; i++) {
          resultRows.add(result[i].toPlutoRow(
              (documentListProvider.page! - 1) * 50 + (i + 1), _locale));
        }

        documentListProvider.setPage(documentListProvider.page! + 1);
        final currentLoaded = stateManager.refRows.length;
        final newlyFetched = resultRows.length;
        fileNumberDisplayed.value = currentLoaded + newlyFetched;

        await Future.delayed(const Duration(milliseconds: 300));
        stateManager.setShowLoading(false);
        return PlutoInfinityScrollRowsResponse(
          isLast: result.isEmpty,
          rows: resultRows,
        );
      } else {
        print("tkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
        documentListProvider.searchDocumentCriteria.page =
            documentListProvider.page ?? -1;
        documentListProvider.searchDocumentCriteria.fromIssueDate =
            documentListProvider.issueNumber != null
                ? null
                : fromDateController.text;
        documentListProvider.searchDocumentCriteria.toIssueDate =
            documentListProvider.issueNumber != null
                ? null
                : toDateController.text;
        List<DocumentModel> result = await documentsController
            .searchDocCriterea(documentListProvider.searchDocumentCriteria);

        for (int i = 0; i < result.length; i++) {
          resultRows.add(result[i].toPlutoRow(
              (documentListProvider.page! - 1) * 50 + (i + 1), _locale));
        }

        documentListProvider.setPage(documentListProvider.page! + 1);
        final currentLoaded = stateManager.refRows.length; //
        final newlyFetched = resultRows.length; //
        fileNumberDisplayed.value = currentLoaded + newlyFetched;
        await Future.delayed(const Duration(milliseconds: 300));
        stateManager.setShowLoading(false);
        return PlutoInfinityScrollRowsResponse(
          isLast: result.isEmpty,
          rows: resultRows,
        );
      }
    } else {
      documentListProvider.searchDocumentCriteria.page =
          documentListProvider.page ?? 1;
      documentListProvider.searchDocumentCriteria.fromIssueDate = null;
      documentListProvider.searchDocumentCriteria.toIssueDate = null;
      documentListProvider.searchDocumentCriteria.issueNo =
          documentListProvider.issueNumber;

      List<DocumentModel> result = await documentsController
          .searchDocCriterea(documentListProvider.searchDocumentCriteria);

      for (int i = 0; i < result.length; i++) {
        resultRows.add(result[i].toPlutoRow(
            (documentListProvider.page! - 1) * 50 + (i + 1), _locale));
      }

      documentListProvider.setPage(documentListProvider.page! + 1);
      final currentLoaded = stateManager.refRows.length; //
      final newlyFetched = resultRows.length; //
      fileNumberDisplayed.value = currentLoaded + newlyFetched;
      await Future.delayed(const Duration(milliseconds: 300));
      stateManager.setShowLoading(false);
      return PlutoInfinityScrollRowsResponse(
        isLast: result.isEmpty,
        rows: resultRows,
      );
    }
  }

  Widget treeSection() {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, value, child) {
        return isLoading.value
            ? Center(
                child: SpinKitCircle(
                  color: const Color(0xFF185FA5),
                  size: 40,
                ),
              )
            : TreeView<MyNode>(
                key: ValueKey(treeController),
                shrinkWrap: true,
                treeController: treeController,
                nodeBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
                  return MyTreeTile(
                    onPointerDown: (p0) {},
                    key: ValueKey(entry.node),
                    entry: entry,
                    folderOnTap: () {
                      if (entry.node.children.isNotEmpty) {
                        selectedCategory = entry.node.extra;
                        selectedCamp.value =
                            selectedCategory!.docCatParent!.txtDescription!;
                        selectedValue.value =
                            selectedCategory!.docCatParent!.txtShortcode;
                        calssificatonNameAndCodeProvider
                            .setSelectedClassificatonName(selectedCamp.value);
                        calssificatonNameAndCodeProvider
                            .setSelectedClassificatonKey(
                                selectedCategory!.docCatParent!.txtKey!);
                        treeController.toggleExpansion(entry.node);
                      } else {
                        selectedCategory = entry.node.extra;
                        selectedCamp.value =
                            selectedCategory!.docCatParent!.txtDescription!;
                        selectedValue.value =
                            selectedCategory!.docCatParent!.txtShortcode;
                      }
                    },
                    textWidget: nodeDesign(entry.node),
                  );
                },
              );
      },
    );
  }

  Widget _treeCard() {
    return Container(
      width: width * 0.28, // fixed tree width
      height: height * 0.34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE3EE), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF185FA5).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF185FA5).withOpacity(0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFDDE3EE), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF185FA5).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_tree_outlined,
                      color: Color(0xFF185FA5), size: 15),
                ),
                const SizedBox(width: 8),
                Text(
                  _locale.category,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2340),
                  ),
                ),
              ],
            ),
          ),
          // ── Dropdown ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(8),
            child: NewCustomDropDown(
              searchBox: true,
              bordeText: _locale.search,
              initialValue: _locale.search,
              items: dropDownChildren,
              onChanged: (value) => searchTree(value),
              heightVal: height * 0.4,
              width: width * .18,
            ),
          ),
          // ── Tree ──────────────────────────────────────────────
          Expanded(child: treeSection()),
        ],
      ),
    );
  }

  Widget fillterSection() {
    final bool isViewFile =
        context.read<DocumentListProvider>().isViewFile == true;

    return Container(
      // ← no fixed width — parent Expanded handles it
      height: height * 0.34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE3EE), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF185FA5).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF185FA5).withOpacity(0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFDDE3EE), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF185FA5).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.filter_alt_outlined,
                      color: Color(0xFF185FA5), size: 15),
                ),
                const SizedBox(width: 8),
                Text(
                  _locale.search,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A2340),
                  ),
                ),
              ],
            ),
          ),

          // ── Fields ────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Row 1: dates + dropdowns
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: DateTimeComponent(
                          height: height * 0.04,
                          dateControllerToCompareWith: null,
                          isInitiaDate: true,
                          dateWidth: double.infinity,
                          dateController: fromDateController,
                          label: _locale.fromDate,
                          onValue: (isValid, value) {
                            if (isValid) fromDateController.text = value;
                          },
                          timeControllerToCompareWith: null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: DateTimeComponent(
                          dateControllerToCompareWith: null,
                          isInitiaDate: true,
                          height: height * 0.04,
                          dateWidth: double.infinity,
                          dateController: toDateController,
                          label: _locale.toDate,
                          onValue: (isValid, value) {
                            if (isValid) toDateController.text = value;
                          },
                          timeControllerToCompareWith: null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: DropDown(
                          key: const ValueKey('filter_dept_dropdown'),
                          onChanged: (value) => selectedDep = value.txtKey,
                          initialValue:
                              selectedDep.isEmpty ? null : selectedDep,
                          bordeText: _locale.department,
                          width: double.infinity,
                          height: height * 0.04,
                          onSearch: (p0) async {
                            return await DepartmentController()
                                .search(SearchModel(page: 1, searchField: p0));
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: DropDown(
                          key: const ValueKey('filter_sort_dropdown'),
                          onChanged: (value) => selectedSortedType =
                              getSortedByTyepsCode(_locale, value),
                          initialValue: selectedSortedType == -1
                              ? null
                              : getSortedByTyepsByCode(
                                  _locale, selectedSortedType),
                          bordeText: _locale.sortedBy,
                          items: getSortedByTyeps(_locale),
                          width: double.infinity,
                          height: height * 0.04,
                        ),
                      ),
                    ],
                  ),

                  // Row 2: description, classification, keyword, ref1
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField2(
                          width: double.infinity,
                          height: height * 0.04,
                          text: Text(_locale.description),
                          controller: descreptionController,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Consumer<CalssificatonNameAndCodeProvider>(
                          builder: (context, value, child) {
                            classificationController.text =
                                value.classificatonName;
                            return CustomTextField2(
                              text: Text(_locale.classification),
                              controller: classificationController,
                              width: double.infinity,
                              height: height * 0.04,
                              readOnly: true,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CustomTextField2(
                          text: Text(_locale.keyword),
                          controller: keyWordController,
                          width: double.infinity,
                          height: height * 0.04,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CustomTextField2(
                          text: Text(_locale.ref1),
                          controller: ref1Controller,
                          width: double.infinity,
                          height: height * 0.04,
                        ),
                      ),
                    ],
                  ),

                  // Row 3: ref2, otherRef, organization, following
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField2(
                          text: Text(_locale.ref2),
                          controller: ref2Controller,
                          width: double.infinity,
                          height: height * 0.04,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CustomTextField2(
                          text: Text(_locale.otherRef),
                          controller: otherRefController,
                          width: double.infinity,
                          height: height * 0.04,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CustomTextField2(
                          text: Text(_locale.organization),
                          controller: organizationController,
                          width: double.infinity,
                          height: height * 0.04,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CustomTextField2(
                          text: Text(_locale.following),
                          controller: followingController,
                          width: double.infinity,
                          height: height * 0.04,
                        ),
                      ),
                    ],
                  ),

                  // Row 4: issueNo + userCode
                  Row(
                    children: [
                      Expanded(
                        flex: isViewFile ? 1 : 3,
                        child: CustomTextField2(
                          width: double.infinity,
                          height: height * 0.04,
                          text: Text(_locale.issueNo),
                          controller: issueNoController,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CustomTextField2(
                          text: Text(_locale.userCode),
                          controller: userCodeController,
                          width: double.infinity,
                          height: height * 0.04,
                        ),
                      ),
                    ],
                  ),

                  // ── Buttons ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomElevatedButton(
                        text: _locale.search,
                        color: const Color(0xFF185FA5),
                        icon: Icons.search_rounded,
                        width: width * 0.1,
                        height: height * 0.043,
                        fontSize: 13,
                        onPressed: () => search().then((_) => getCount()),
                      ),
                      const SizedBox(width: 8),
                      CustomElevatedButton(
                        text: _locale.resetFilter,
                        color: Colors.red,
                        icon: Icons.refresh_rounded,
                        width: width * 0.1,
                        height: height * 0.043,
                        fontSize: 13,
                        onPressed: resetForm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget treeSection1() {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, value, child) {
        return isLoading.value
            ? Center(
                child: SpinKitCircle(
                  color: Theme.of(context).primaryColor,
                  size: 50.0,
                ),
              )
            : TreeView<MyNode>(
                key: ValueKey(treeController),
                shrinkWrap: true,
                treeController: treeController,
                nodeBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
                  return MyTreeTile(
                    onPointerDown: (p0) {},
                    key: ValueKey(entry.node),
                    entry: entry,
                    folderOnTap: () {
                      if (entry.node.children.isNotEmpty) {
                        selectedCategory = entry.node.extra;
                        selectedCamp.value =
                            selectedCategory!.docCatParent!.txtDescription!;

                        selectedValue.value =
                            selectedCategory!.docCatParent!.txtShortcode;
                        calssificatonNameAndCodeProvider
                            .setSelectedClassificatonName(selectedCamp.value);
                        calssificatonNameAndCodeProvider
                            .setSelectedClassificatonKey(
                                selectedCategory!.docCatParent!.txtKey!);
                        treeController.toggleExpansion(entry.node);
                      } else {
                        selectedCategory = entry.node.extra;
                        selectedCamp.value =
                            selectedCategory!.docCatParent!.txtDescription!;
                        selectedValue.value =
                            selectedCategory!.docCatParent!.txtShortcode;
                      }
                    },
                    textWidget: nodeDesign(entry.node),
                  );
                },
              );
      },
    );
  }

  void searchTree(DocumentCategory selectedDocCategory) {
    if (selectedDocCategory.docCatParent!.txtKey!.isEmpty) {
      // Reset selection
      selectedCamp.value = "";
      selectedValue.value = "";
      calssificatonNameAndCodeProvider.setSelectedClassificatonKey("");
      calssificatonNameAndCodeProvider.setSelectedClassificatonName("");

      treeController.notifyListeners();
      return;
    }

    // Update selected category
    selectedCamp.value = selectedDocCategory.docCatParent!.txtDescription!;
    selectedValue.value = selectedDocCategory.docCatParent!.txtShortcode!;
    selectedCategory = selectedDocCategory;

    // Set classification in provider
    calssificatonNameAndCodeProvider
        .setSelectedClassificatonKey(selectedDocCategory.docCatParent!.txtKey!);
    calssificatonNameAndCodeProvider.setSelectedClassificatonName(
        selectedDocCategory.docCatParent!.txtDescription!);

    // Find and highlight the selected node
    highlightSelectedNode(treeController.roots.first);
    treeController.notifyListeners();
  }

  /// **Highlight the selected node in the tree without collapsing other nodes**
  void highlightSelectedNode(MyNode node) {
    if (node.extra != null &&
        (node.extra as DocumentCategory).docCatParent!.txtKey ==
            selectedCategory!.docCatParent!.txtKey) {
      selectedCamp.value = node.title;
      return;
    }

    for (MyNode child in node.children) {
      highlightSelectedNode(child);
    }
  }

  /// Expands the tree until the selected node is visible
  void expandSelectedNode(MyNode node) {
    if (node.extra != null &&
        (node.extra as DocumentCategory).docCatParent!.txtKey ==
            selectedCategory!.docCatParent!.txtKey) {
      treeController.toggleExpansion(node);
      return;
    }

    for (MyNode child in node.children) {
      expandSelectedNode(child);
    }
  }

  bool searchNode(MyNode node, String query) {
    if (node.title.contains(query)) {
      selectedCategory = node.extra;
      selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
      selectedValue.value = selectedCategory!.docCatParent!.txtShortcode;
      return true;
    }
    for (final child in node.children) {
      if (searchNode(child, query)) {
        return true;
      }
    }
    return false;
  }

  Widget nodeDesign(MyNode node) {
    return SizedBox(
      width: node.isRoot ? 200 : 200,
      child: InkWell(
        onTap: () {
          // documentListProvider
          //     .setDocumentSearchCriterea(SearchDocumentCriteria());

          selectedCategory = node.extra;
          selectedCamp.value = selectedCategory!.docCatParent!.txtDescription!;
          selectedValue.value = selectedCategory!.docCatParent!.txtShortcode;
          calssificatonNameAndCodeProvider
              .setSelectedClassificatonName(selectedCamp.value);
          calssificatonNameAndCodeProvider.setSelectedClassificatonKey(
              selectedCategory!.docCatParent!.txtKey!);
          treeController.notifyListeners();
          documentListProvider.setDocumentSearchCriterea(SearchDocumentCriteria(
              page: -1, cat: selectedCategory!.docCatParent!.txtKey!));

          treeController.toggleExpansion(node);
          // setState(() {});
        },
        onDoubleTap: () {
          if (!node.isRoot && node.children.isEmpty) {
            selectedCategory = node.extra;
            selectedCamp.value =
                selectedCategory!.docCatParent!.txtDescription!;
          }
        },
        child: ValueListenableBuilder(
          valueListenable: selectedValue,
          builder: (context, value, child) {
            return Text(
              node.title,
              style: TextStyle(
                fontSize: 14,
                color: getColor(node.extra, value.toString())
                    ? currentColor
                    : Colors.black,
              ),
            );
          },
        ),
      ),
    );
  }

  List<DocumentCategory> campClassificationList = [];
  List<DocumentCategory> children = [];
  Future<void> fetchData() async {
    // setState(() {
    //   isLoading = true;
    // });
    isLoading.value = true;
    campClassificationList = await categoriesController.getCategoriesTree();

    convertToTreeList(campClassificationList);

    children = [];
    for (int i = 0; i < campClassificationList.length; i++) {
      children.addAll(getChildren(campClassificationList[i]));
    }
    treeController.toggleExpansion(roots.first);
  }

  List<DocumentCategory> dropDownChildren = [];
  Future<void> fetchDropDownTree() async {
    List<DocumentCategory> result =
        await categoriesController.getCategoriesTree();
    dropDownChildren.clear();

    for (var category in result) {
      dropDownChildren.add(category);
      dropDownChildren.addAll(getChildren(category));
    }

    // Add an empty option to reset selection
    dropDownChildren.insert(
      0,
      DocumentCategory(
        docCatParent:
            DocCatParent(txtKey: "", txtDescription: "Select Category"),
        docCatChildren: [],
      ),
    );
  }

  Future<void> fetchDropDownTree1() async {
    List<DocumentCategory> result =
        await categoriesController.getCategoriesTree();
    dropDownChildren.clear();

    for (var category in result) {
      dropDownChildren.add(category);
      dropDownChildren.addAll(getChildren(category));
    }

    // Add an empty option for reset
    dropDownChildren.insert(
        0,
        DocumentCategory(
          docCatParent:
              DocCatParent(txtKey: "", txtDescription: "Select Category"),
          docCatChildren: [],
        ));
  }

  Future<void> fetchDropDownTree12() async {
    List<DocumentCategory> result =
        await categoriesController.getCategoriesTree();
    for (int i = 0; i < result.length; i++) {
      // all.add(result[i].sc!);
      dropDownChildren.add(result[i]);
      if (result[i].docCatChildren!.isNotEmpty ||
          result[i].docCatChildren != null) {
        for (int j = 0; j < result[i].docCatChildren!.length; j++) {
          // children.add(value)
          if (j == 0) {
            dropDownChildren.add(result[i].docCatChildren![j]);
          }
          dropDownChildren.addAll(getChildren(result[i].docCatChildren![j]));
        }
      }
    }
    dropDownChildren.insert(
        0,
        DocumentCategory(
            docCatParent: DocCatParent(txtKey: "", txtDescription: ""),
            docCatChildren: []));

    // convertToTreeList(stkCategList);
    // treeController.toggleExpansion(roots.first);
  }

  ValueNotifier isLoading = ValueNotifier(false);
  void convertToTreeList(List<DocumentCategory> result) {
    for (int i = 0; i < result.length; i++) {
      treeNodes.add(getNodes(result[i]));
    }
    isLoading.value = false;
  }

  MyNode getNodes(DocumentCategory data) {
    MyNode node = MyNode(
      title:
          "${data.docCatParent!.txtShortcode}@${data.docCatParent!.txtDescription!}",
      extra: data,
      isRoot: false,
      children: List.from(data.docCatChildren!.map((x) => getNodes(x))),
    );
    treeController.setExpansionState(node, checkChildren(data));
    return node;
  }

  bool checkChildren(DocumentCategory data) {
    if (selectedCategory != null &&
        selectedCategory!.docCatParent!.txtShortcode ==
            data.docCatParent!.txtShortcode) {
      return true;
    }
    if (data.docCatChildren != null) {
      for (int i = 0; i < data.docCatChildren!.length; i++) {
        if (checkChildren(data.docCatChildren![i])) {
          return true;
        }
      }
    }
    return false;
  }

  List<DocumentCategory> getChildren(DocumentCategory data) {
    List<DocumentCategory> discountList = [];
    if (data.docCatChildren!.isEmpty) {
      discountList.add(data);
      return discountList;
    }
    if (data.docCatChildren != null) {
      for (int i = 0; i < data.docCatChildren!.length; i++) {
        List<DocumentCategory> childList = getChildren(data.docCatChildren![i]);
        discountList.addAll(childList);
      }
    }
    return discountList;
  }

  bool getColor(DocumentCategory? current, String value) {
    if (current != null) {
      String code = current.docCatParent!.txtShortcode!;
      return value.compareTo(code) == 0;
    }
    return false;
  }
}
