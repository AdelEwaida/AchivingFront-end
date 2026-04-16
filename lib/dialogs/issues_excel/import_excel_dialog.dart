import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:archive/archive.dart';
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
import 'package:xml/xml.dart' as xml;

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
                        style: customButtonStyle(
                          context,
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
            style: customButtonStyle(
                context,
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

  double excelProgress = 0;
  int countNonEmptyColumns(Sheet sheet, {int scanRows = 50}) {
    final rowsToScan = sheet.maxRows < scanRows ? sheet.maxRows : scanRows;
    int nonEmptyCols = 0;

    for (int c = 0; c < sheet.maxCols; c++) {
      bool hasData = false;

      for (int r = 0; r < rowsToScan; r++) {
        final cell =
            sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r));
        final v = cell.value?.toString().trim();
        if (v != null && v.isNotEmpty && v.toLowerCase() != "null") {
          hasData = true;
          break;
        }
      }

      if (hasData) nonEmptyCols++;
      if (nonEmptyCols > 1) break; // أسرع: أول ما يصير أكثر من 1 نوقف
    }

    return nonEmptyCols;
  }

  Future<int> fastCheckExcelColumns(Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes, verify: false);

    ArchiveFile? sheetFile;
    for (final f in archive) {
      if (f.name.startsWith('xl/worksheets/sheet')) {
        sheetFile = f;
        break;
      }
    }
    if (sheetFile == null) throw Exception("No worksheet found");

    final sheetXml = utf8.decode(sheetFile.content as List<int>);
    final doc = xml.XmlDocument.parse(sheetXml);

    final dims = doc.findAllElements('dimension');
    if (dims.isEmpty) return 0;

    final ref = dims.first.getAttribute('ref'); // A1:H500
    if (ref == null || ref.isEmpty) return 0;
    if (!ref.contains(':')) return 1;

    final endCell = ref.split(':').last; // H500
    final colLetters = endCell.replaceAll(RegExp(r'\d'), ''); // H
    return _excelColumnLettersToNumber(colLetters);
  }

  int _excelColumnLettersToNumber(String letters) {
    int result = 0;
    for (int i = 0; i < letters.length; i++) {
      result = result * 26 + (letters.codeUnitAt(i) - 64);
    }
    return result;
  }

  Future<List<String>> fastReadColumnA(Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes, verify: false);

    ArchiveFile? sheetFile;
    ArchiveFile? sharedStringsFile;

    for (final f in archive) {
      if (f.name == 'xl/sharedStrings.xml') sharedStringsFile = f;
      if (f.name.startsWith('xl/worksheets/sheet')) {
        sheetFile = f;
        break;
      }
    }
    if (sheetFile == null) throw Exception("No worksheet found");

    // sharedStrings
    List<String> shared = [];
    if (sharedStringsFile != null) {
      final ssXml = utf8.decode(sharedStringsFile.content as List<int>);
      final ssDoc = xml.XmlDocument.parse(ssXml);
      shared = ssDoc
          .findAllElements('si')
          .map((si) => si.findAllElements('t').map((t) => t.innerText).join())
          .toList();
    }

    // sheet xml
    final sheetXml = utf8.decode(sheetFile.content as List<int>);
    final doc = xml.XmlDocument.parse(sheetXml);

    final values = <String>[];

    for (final c in doc.findAllElements('c')) {
      final r = c.getAttribute('r'); // A1,B1...
      if (r == null || !r.startsWith('A')) continue; // ✅ العمود A فقط

      final vNodes = c.findElements('v');
      if (vNodes.isEmpty) continue;

      final raw = vNodes.first.innerText.trim();
      if (raw.isEmpty) continue;

      final t = c.getAttribute('t'); // t="s" => shared string
      String value;
      if (t == 's') {
        final idx = int.tryParse(raw);
        if (idx == null || idx < 0 || idx >= shared.length) continue;
        value = shared[idx].trim();
      } else {
        value = raw;
      }

      if (value.isEmpty || value.toLowerCase() == 'null') continue;
      values.add(value);
    }

    return values;
  }

  Future<void> pickAndReadExcel() async {
    setState(() {
      isFileLoading = true;
      excelProgress = 0;
    });

    try {
      final pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );
      if (pickedFile == null) {
        setState(() => isFileLoading = false);
        return;
      }

      final file = pickedFile.files.single;
      if (file.bytes == null) {
        setState(() => isFileLoading = false);
        return;
      }

      // ✅ SUPER FAST: Check columns directly from XML without full decode
      setState(() => excelProgress = 0.2);

      final usedCols = await fastCheckExcelColumns(file.bytes!);

      setState(() => excelProgress = 0.4);

      // ✅ Show error immediately if not 1 column
      if (usedCols != 1 && usedCols != -1) {
        if (mounted) setState(() => isFileLoading = false);
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return ErrorDialog(
              icon: Icons.error_outline,
              errorDetails:
                  'Please upload an Excel file with only one column (found $usedCols columns)',
              errorTitle: _locale.invalidFile ?? 'Invalid File',
              color: Colors.red,
              statusCode: 400,
            );
          },
        );
        return;
      }

      // ✅ Now decode and extract data
      setState(() => excelProgress = 0.5);

      final excel = Excel.decodeBytes(file.bytes!);
      final sheet = excel.tables[excel.tables.keys.first];

      if (sheet == null) {
        setState(() => isFileLoading = false);
        return;
      }

      // ✅ Double-check with actual data if fast check failed
      if (usedCols == -1) {
        final actualCols = countNonEmptyColumns(sheet, scanRows: 10);
        if (actualCols != 1) {
          if (mounted) setState(() => isFileLoading = false);
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return ErrorDialog(
                icon: Icons.error_outline,
                errorDetails:
                    'Please upload an Excel file with only one column (found $actualCols columns)',
                errorTitle: _locale.invalidFile ?? 'Invalid File',
                color: Colors.red,
                statusCode: 400,
              );
            },
          );
          return;
        }
      }

      setState(() => excelProgress = 0.7);

      final List<String> extractedValues = [];
      final totalRows = sheet.maxRows;
      const chunkSize = 1000; // ✅ زيادة حجم الـ chunk

      for (int start = 0; start < totalRows; start += chunkSize) {
        final end =
            (start + chunkSize < totalRows) ? start + chunkSize : totalRows;

        for (int r = start; r < end; r++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r),
          );
          final raw = cell.value;
          if (raw == null) continue;

          final v = raw.toString().trim();
          if (v.isEmpty || v.toLowerCase() == "null") continue;

          extractedValues.add(v);
        }

        setState(() => excelProgress = 0.7 + (0.3 * (end / totalRows)));
        await Future.delayed(
            const Duration(milliseconds: 1)); // ✅ تقليل التأخير
      }

      setState(() {
        issuesList = extractedValues;
        fileNameController.text = file.name;
        excelProgress = 1;
      });
    } catch (e, s) {
      print("🔥 ERROR: $e\n$s");
      if (mounted) {
        setState(() => isFileLoading = false);
        await showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              icon: Icons.error_outline,
              errorDetails: 'Failed to process Excel file: ${e.toString()}',
              errorTitle: _locale.invalidFile ?? 'Invalid File',
              color: Colors.red,
              statusCode: 500,
            );
          },
        );
      }
    } finally {
      if (mounted) setState(() => isFileLoading = false);
    }
  }

  Future<void> pickAndReadExcelOLD() async {
    setState(() {
      isFileLoading = true;
      excelProgress = 0;
    });

    try {
      final pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );
      if (pickedFile == null) return;

      final file = pickedFile.files.single;
      if (file.bytes == null) return;

      final excel = Excel.decodeBytes(file.bytes!);
      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) return;

      final usedCols = countNonEmptyColumns(sheet);

      if (usedCols != 1) {
        if (mounted) setState(() => isFileLoading = false);
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return ErrorDialog(
              icon: Icons.error_outline,
              errorDetails: _locale.pleaseUploadExcelWithOneColumn ??
                  'Please upload an Excel file with only one column',
              errorTitle: _locale.invalidFile ?? 'Invalid File',
              color: Colors.red,
              statusCode: 400,
            );
          },
        );
        return;
      }
      final List<String> extractedValues = [];

      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table];

        if (sheet == null) continue;

        final totalRows = sheet.maxRows;
        const chunkSize = 500; // Smaller chunks for web

        for (int start = 0; start < totalRows; start += chunkSize) {
          final end =
              (start + chunkSize < totalRows) ? start + chunkSize : totalRows;

          for (int r = start; r < end; r++) {
            final cell = sheet.cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r),
            );
            final raw = cell.value;
            if (raw == null) continue;

            final v = raw.toString().trim();
            if (v.isEmpty || v.toLowerCase() == "null") continue;

            extractedValues.add(v);
          }

          // Update UI after each chunk
          setState(() => excelProgress = end / totalRows);
          await Future.delayed(
              const Duration(milliseconds: 10)); // Let UI breathe
        }
        break;
      }

      setState(() {
        issuesList = extractedValues;
        fileNameController.text = file.name;
        excelProgress = 1;
      });
    } catch (e, s) {
      print("🔥 ERROR: $e\n$s");
    } finally {
      setState(() => isFileLoading = false);
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
      height: height * 0.15,
      text: Text(hint),
      controller: controller,
      onSubmitted: (text) {},
      onChanged: (value) {},
    );
  }
}
