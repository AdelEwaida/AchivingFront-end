import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:archiving_flutter_project/utils/constants/loading.dart';
import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../dialogs/error_dialgos/show_error_dialog.dart';
import '../../models/db/document_models/document_request.dart';
import '../../models/db/document_models/documnet_info_model.dart';
import '../../models/db/document_models/upload_file_mode.dart';
import '../../models/dto/searchs_model/search_model.dart';
import '../../service/controller/department_controller/department_cotnroller.dart';
import '../../service/controller/documents_controllers/documents_controller.dart';
import '../../service/controller/import_excel_controller/import_excel_controller.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/styles.dart';
import '../../utils/func/responsive.dart';
import '../../widget/custom_drop_down.dart';
import '../../widget/custom_drop_down2.dart';
import '../../widget/date_time_component.dart';
import '../../widget/dialog_widgets/title_dialog_widget.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';
import 'dart:html' as html;

class ImportExcelDialog extends StatefulWidget {
  ImportExcelDialog({super.key});

  @override
  State<ImportExcelDialog> createState() => _ImportExcelDialogState();
}

class _ImportExcelDialogState extends State<ImportExcelDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;

  bool isDesktop = false;
  ImportExcelController importExcelController = ImportExcelController();
  bool isFileLoading = false;
  String? txtFilename;
  String? imgBlob;
  int? dblFilesize;
  Uint8List? image;
  bool saving = false;
  List<String> issuesList = [];

  TextEditingController fileNameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
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
          title: _locale.verifyDocuments,
          width: isDesktop ? width * 0.4 : width * 0.8,
          height: height * 0.07,
        ),
        content: SizedBox(
          width: width * 0.25,
          height: height * 0.35,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              buildFileUpload(),
                            ],
                          ),
                        )
                      ]),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          openLoadinDialog(context);
                          await importExcelController
                              .importIssues(issuesList)
                              .then((value) async {
                            if (value.statusCode == 200 &&
                                issuesList.isNotEmpty) {
                              final blob = html.Blob([value.bodyBytes]);
                              final url =
                                  html.Url.createObjectUrlFromBlob(blob);
                              final anchor = html.AnchorElement(href: url)
                                ..setAttribute(
                                    "download", "ImportedIssues.xlsx")
                                ..click();
                              html.Url.revokeObjectUrl(url);

                              Navigator.pop(context);

                              await showDialog(
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
                              );

                              // ignore: use_build_context_synchronously
                              Navigator.pop(context, true);
                            } else {
                              Navigator.pop(context);
                            }
                          });
                        },
                        style: customButtonStyle(    context,
                          Size(isDesktop ? width * 0.1 : width * 0.4,
                              height * 0.045),
                          14,
                          primary,
                        ),
                        child: Text(
                          _locale.save,
                          style: const TextStyle(color: whiteColor),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              if (saving)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              Center(
                child: Visibility(
                  visible: isFileLoading,
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
            ],
          ),
        ));
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
              pickAndReadExcel();
            },
            style: customButtonStyle(    context,
                Size(isDesktop ? width * 0.14 : width * 0.4, height * 0.045),
                16,
                primary3),
            child: Text(
              _locale.uploadExcelFile,
              style: const TextStyle(color: whiteColor),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: isDesktop ? width * 0.25 : width * 0.4,
            child: Text(
              _locale.pleaseAddExcel,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
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
                0.13,
                true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> filesBlobs = [];
  List<String> filesName = [];
  List<int> sizes = [];

  Future<void> pickAndReadExcel() async {
    setState(() {
      isFileLoading = true;
    });

    try {
      FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
      );

      if (pickedFile != null && pickedFile.files.single.bytes != null) {
        final bytes = pickedFile.files.single.bytes!;
        final excel = Excel.decodeBytes(bytes);
        final List<String> extractedValues = [];

        for (var table in excel.tables.keys) {
          for (var row in excel.tables[table]!.rows) {
            if (row.isNotEmpty) {
              final cell = row[0];
              final value = cell?.value.toString().trim();
              if (value != null && value.isNotEmpty) {
                extractedValues.add(value);
              }
            }
          }
          break;
        }

        setState(() {
          issuesList = extractedValues;

          fileNameController.text = pickedFile.files.single.name;
        });
      }
    } catch (e) {}

    setState(() {
      isFileLoading = false;
    });
  }

  Widget customTextField(String hint, TextEditingController controller,
      bool isDesktop, double width1, bool isMandetory) {
    double height = MediaQuery.of(context).size.height * 0.3;
    return CustomTextField2(
      readOnly: hint == _locale.fileName ? true : false,
      isReport: true,
      isMandetory: isMandetory,
      width: width * width1,
      height: height * 0.15,
      text: Text(hint),
      controller: controller,
      onSubmitted: (text) {},
      onChanged: (value) {},
    );
  }
}
