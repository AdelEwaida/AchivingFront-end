import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html; // Web specific

import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
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
import 'package:pluto_grid/pluto_grid.dart';

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
      actions: [
      
      ],
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
              plCols: polCols,
              download: download,
              polRows: [],
              mode: PlutoGridMode.selectWithOneTap,
              onSelected: (event) {
                selectedRow = event.row;
              },
              onLoaded: (event) {
                stateManager = event.stateManager;
                stateManager.setShowLoading(true);
                if (widget.listOfFiles.isNotEmpty) {
                  for (int i = 0; i < widget.listOfFiles.length; i++) {
                    stateManager
                        .appendRows([widget.listOfFiles[i].toPlutoRow(i + 1)]);
                  }
                }
                stateManager.setShowLoading(false);
              },
            )
          ],
        ),
      ],
    );
  }

  List<PlutoColumn> polCols = [];
  fillCols() {
    polCols.addAll([
      PlutoColumn(
        title: "#",
        field: "countNumber",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.05 : width * 0.15,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.fileName,
        field: "txtFilename",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.22 : width * 0.4,
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
        title: _locale.dateCreated,
        field: "datDate",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.13 : width * 0.2,
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

      // Step 2: Convert the List<int> to Uint8List
      // Uint8List uint8List = Uint8List.fromList(stringBytes);
      saveExcelFile(bytes, selectedRow!.cells['txtFilename']!.value);
    }
  }

  spaceWidth(double width1) {
    return SizedBox(
      width: width * width1,
    );
  }
}
