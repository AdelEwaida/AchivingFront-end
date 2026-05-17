import 'dart:typed_data';

import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/utils/func/save_excel_file.dart';
import 'package:archiving_flutter_project/widget/dialog_widgets/title_dialog_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../models/db/user_models/user_category.dart';
import '../../models/db/user_models/user_update_req.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';
import '../../widget/text_field_widgets/test_drop_down.dart';
import 'app_dialog.dart';

class PdfPreview1 extends StatefulWidget {
  Uint8List pdfFile;
  String fileName;
  PdfPreview1({super.key, required this.fileName, required this.pdfFile});

  @override
  State<PdfPreview1> createState() => _PdfPreviewDialogState();
}

class _PdfPreviewDialogState extends State<PdfPreview1> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  double radius1 = 7;
  TextEditingController userListController = TextEditingController();
  UserController userController = UserController();

  String hintUsers = "";
  List<String>? usersList = [];
  List<String>? usersListNames = [];
  List<UserCategory>? usersListModel = [];
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;

    super.didChangeDependencies();
  }

  bool isDesktop = false;
  double _scale = 1.0; // Initial scale factor
  void _zoomIn() {
    setState(() {
      _scale += 0.1; // Increment the scale by 0.1
    });
  }

  void _zoomOut() {
    setState(() {
      if (_scale > 0.1) {
        _scale -=
            0.1; // Decrement the scale, ensuring it doesn't go below a reasonable value
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    return AppDialog(
      width: isDesktop ? width * 0.4 : width * 0.8,
      height: height * 0.8,
      title: Row(
        children: [
          Text(
            _locale.previewFile,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          // const SizedBox(),
          Row(
            children: [
              IconButton(
                  onPressed: () async {
                    // await Printing.layoutPdf(
                    //     onLayout: (PdfPageFormat format) async => widget.pdfFile);
                    saveExcelFile(widget.pdfFile, widget.fileName);
                  },
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 17,
                  )),
              widget.fileName.contains('.pdf')
                  ? Tooltip(
                      message: _locale.print,
                      child: IconButton(
                          onPressed: () async {
                            await Printing.layoutPdf(
                                onLayout: (PdfPageFormat format) async =>
                                    widget.pdfFile);
                          },
                          icon: const Icon(
                            Icons.print,
                            color: Colors.white,
                            size: 17,
                          )),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ],
      ),
      content: Column(
        children: [
          widget.fileName.contains('.pdf')
              ? SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: height * 0.55,
                      width: width * 0.4, //,
                      child: SfPdfViewer.memory(widget.pdfFile,
                          initialZoomLevel: 1,
                          interactionMode: PdfInteractionMode.pan,
                          controller: _pdfViewerController,
                          canShowScrollHead: true,
                          scrollDirection: PdfScrollDirection.vertical,
                          enableDoubleTapZooming: true,
                          canShowScrollStatus: true,
                          pageLayoutMode: PdfPageLayoutMode.continuous),
                    ),
                  ),
                )
              : SizedBox(
                  height: height * 0.5,
                  width: width * 0.4, //,
                  child: Transform.scale(
                    scale: _scale,
                    child: InteractiveViewer(
                      panEnabled:
                          true, // Set to true if you want to allow panning
                      minScale: 1.0, // Minimum zoom scale
                      maxScale: 4.0,
                      child: Image.memory(
                        widget.pdfFile,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
          SizedBox(
            height: height * 0.1,
            width: width * 0.1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: height * 0.03,
                  icon: const Icon(
                    Icons.zoom_in,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  onPressed: () {
                    if (widget.fileName.contains(".pdf")) {
                      _pdfViewerController.zoomLevel += 0.3;
                    } else {
                      _zoomIn();
                    }
                  },
                ),
                IconButton(
                  iconSize: height * 0.03,
                  icon: const Icon(
                    Icons.zoom_out,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  onPressed: () {
                    if (widget.fileName.contains('.pdf')) {
                      _pdfViewerController.zoomLevel -= 0.3;
                    } else {
                      _zoomOut();
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
