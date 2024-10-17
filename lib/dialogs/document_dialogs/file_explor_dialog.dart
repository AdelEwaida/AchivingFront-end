import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:html' as html; // Web specific

import 'package:archiving_flutter_project/dialogs/document_dialogs/send_email_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/whats_app_dialog.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/dialogs/pdf_preview.dart';
import 'package:archiving_flutter_project/models/db/document_models/documnet_info_model.dart';
import 'package:archiving_flutter_project/models/db/document_models/upload_file_mode.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/utils/func/save_excel_file.dart';
import 'package:archiving_flutter_project/widget/date_time_component.dart';
import 'package:archiving_flutter_project/widget/dialog_widgets/title_dialog_widget.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:printing/printing.dart';

class FileExplorDialog extends StatefulWidget {
  List<FileUploadModel> listOfFiles;
  FileExplorDialog({super.key, required this.listOfFiles});

  @override
  State<FileExplorDialog> createState() => _FileExplorDialogState();
}

class _FileExplorDialogState extends State<FileExplorDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  late PlutoGridStateManager stateManager;
  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    fillCols();
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
        title: _locale.documents,
        width: isDesktop ? width * 0.4 : width * 0.8,
        height: height * 0.07,
      ),
      content: Container(
        width: width * 0.5,
        height: height * 0.5,
        child: formSection(),
      ),
      actions: [],
    );
  }

  PlutoRow? selectedRow;
  Widget formSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            TableComponent(
              tableWidth: width * 0.5,
              tableHeigt: height * 0.4,
              rowsHeight: 50,
              sendEmail: sendEmail,
              delete: deleteFile,
              plCols: polCols,
              sendWhatspp: sendWhatsapp,
              download: download,
              view: view,
              polRows: [],
              mode: PlutoGridMode.selectWithOneTap,
              onSelected: (event) {
                selectedRow = event.row;
              },
              onLoaded: (event) {
                stateManager = event.stateManager;
                stateManager.setShowLoading(true);
                stateManager.setShowColumnFilter(true);
                if (widget.listOfFiles.isNotEmpty) {
                  for (int i = 0; i < widget.listOfFiles.length; i++) {
                    stateManager
                        .appendRows([widget.listOfFiles[i].toPlutoRow(i + 1)]);
                  }
                }
                if (stateManager.rows.isNotEmpty) {
                  selectedRow = stateManager.rows[0];
                }
                stateManager.setShowLoading(false);
              },
              doubleTab: (event) {
                view();
              },
            )
          ],
        ),
      ],
    );
  }

  void deleteFile() {
    if (selectedRow != null) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomConfirmDialog(
              confirmMessage: _locale.areYouSureToDelete(
                  selectedRow!.cells['txtFilename']!.value));
        },
      ).then((value) async {
        if (value == true) {
          var response = await DocumentsController()
              .deleteFile(selectedRow!.cells['txtKey']!.value);
          if (response.statusCode == 200) {
            setState(() {
              widget.listOfFiles.removeAt(selectedRow!.sortIdx!);
              stateManager.removeRows([selectedRow!]);
              if (stateManager.rows.isNotEmpty) {
                selectedRow = stateManager.rows[0];
              } else {
                selectedRow = null;
              }
            });
          }
        }
      });
    }
  }

  void sendWhatsapp() {
    if (selectedRow != null) {
      showDialog(
        context: context,
        builder: (context) {
          return WhatsAppDialog(
            base64String: selectedRow!.cells['imgBlob']!.value,
          );
        },
      );
    }
  }

  List<PlutoColumn> polCols = [];
  fillCols() {
    polCols.addAll([
      PlutoColumn(
        title: "#",
        field: "countNumber",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.03 : width * 0.15,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.fileName,
        field: "txtFilename",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.18 : width * 0.4,
        renderer: (rendererContext) {
          return Tooltip(
            message: rendererContext.cell.value,
            child: Text(rendererContext.cell.value),
          );
        },
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.userName,
        field: "txtUsercode",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.1 : width * 0.2,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.category,
        field: "categoryName",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.08 : width * 0.2,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.dateCreated,
        field: "datDate",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.1 : width * 0.2,
        backgroundColor: columnColors,
      ),
    ]);
  }

  Future<void> download() async {
    if (selectedRow != null) {
      // final blob = html.Blob(utf8.encode(selectedRow!.cells['imgBlob']!.value));

      // Convert Blob to Uint8List
      // Uint8List uint8List = await blobToUint8List(blob);
      Uint8List bytes = base64Decode(selectedRow!.cells['imgBlob']!.value);

      // Uint8List uint8List = Uint8List.fromList(stringBytes);
      saveExcelFile(bytes, selectedRow!.cells['txtFilename']!.value);
    }
  }

  Future<void> saveAndOpenFile(String base64String, String fileName) async {
    try {
      // Decode the Base64 string
      Uint8List fileBytes = base64Decode(base64String);

      // Get the directory to save the file
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      // Save the file locally
      File file = File('$tempPath/$fileName');
      await file.writeAsBytes(fileBytes);

      // Open the file using open_filex
      await OpenFilex.open(file.path);
    } catch (e) {
      print("Error: $e");
    } finally {
      // setState(() {
      //   isLoading = false;
      // });
    }
  }

  void sendEmail() {
    if (selectedRow != null) {
      showDialog(
        context: context,
        builder: (context) {
          return SendEmailDialog(
              fileName: selectedRow!.cells['txtFilename']!.value,
              base64String: selectedRow!.cells['imgBlob']!.value);
        },
      );
    }
  }

  view() {
    if (selectedRow != null) {
      Uint8List bytes = base64Decode(selectedRow!.cells['imgBlob']!.value);
      if (selectedRow!.cells['txtFilename']!.value.contains(".pdf") ||
          selectedRow!.cells['txtFilename']!.value.contains(".jpeg") ||
          selectedRow!.cells['txtFilename']!.value.contains(".png") ||
          selectedRow!.cells['txtFilename']!.value.contains(".jpg")) {
        showDialog(
          context: context,
          builder: (context) {
            return PdfPreview1(
                pdfFile: bytes,
                fileName: selectedRow!.cells['txtFilename']!.value);
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
                icon: Icons.error_outlined,
                errorDetails: _locale.previewNotAvilable,
                errorTitle: _locale.error,
                color: Colors.red,
                statusCode: 500);
          },
        );
      }
    }
  }

  spaceWidth(double width1) {
    return SizedBox(
      width: width * width1,
    );
  }
}
