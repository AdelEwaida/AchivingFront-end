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

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    return AlertDialog(
      title: Container(
        width: isDesktop ? width * 0.4 : width * 0.8,
        height: height * 0.065,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
                      color: Colors.black,
                      size: 14,
                    )),
                Tooltip(
                  message: _locale.print,
                  child: IconButton(
                      onPressed: () async {
                        await Printing.layoutPdf(
                            onLayout: (PdfPageFormat format) async =>
                                widget.pdfFile);
                        // saveExcelFile(widget.pdfFile, widget.fileName);
                      },
                      icon: const Icon(
                        Icons.print,
                        color: Colors.black,
                        size: 14,
                      )),
                ),
              ],
            ),

            Text(
              _locale.previewFile,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Color.fromARGB(255, 237, 34, 20)),
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 14,
                    )),
              ),
            ),
          ],
        ),
      ),
      // title: Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     // Text("", style: TextStyle(fontSize: height * 0.03)),
      //     IconButton(
      //         icon: Icon(
      //           Icons.file_download,
      //           size: height * 0.035,
      //         ),
      //         onPressed: () {
      //           saveExcelFile(widget.pdfFile, widget.fileName);
      //         }
      //         //  _downloadPdf().then((value) {
      //         //   if (value) {
      //         //     CoolAlert.show(
      //         //         barrierDismissible: false,
      //         //         cancelBtnText: _local.cancel,
      //         //         confirmBtnText: _local.ok,
      //         //         width: width * 0.3,
      //         //         context: context,
      //         //         type: CoolAlertType.success,
      //         //         title: "",
      //         //         widget: Column(
      //         //           children: [
      //         //             Text(
      //         //               textAlign: TextAlign.center,
      //         //               "${_local.success}\nDocuments: Scope-pos arabic manual.pdf",
      //         //               style: const TextStyle(fontSize: 30),
      //         //             ),
      //         //             const SizedBox(
      //         //               height: 25,
      //         //             )
      //         //           ],
      //         //         ),
      //         //         confirmBtnTextStyle:
      //         //             const TextStyle(fontSize: 30, color: Colors.white),
      //         //         cancelBtnTextStyle: const TextStyle(fontSize: 30),
      //         //         onConfirmBtnTap: () {
      //         //           Navigator.pop(context);
      //         //           Navigator.pop(context);
      //         //         });
      //         //   }
      //         // }),
      //         ),
      //   ],
      // ),
      content: Column(
        children: [
          SizedBox(
            width: width * 0.46,
            height: height * 0.65,
            child: SfPdfViewer.memory(

              widget.pdfFile,
              initialZoomLevel: 1,
              controller: _pdfViewerController,
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
                    _pdfViewerController.zoomLevel += 0.25;
                  },
                ),
                IconButton(
                  iconSize: height * 0.03,
                  icon: const Icon(
                    Icons.zoom_out,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  onPressed: () {
                    _pdfViewerController.zoomLevel -= 0.25;
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('Syncfusion Flutter PDF Viewer'),
    //     actions: <Widget>[
    //       IconButton(
    //         icon: const Icon(
    //           Icons.arrow_drop_down_circle,
    //           color: Colors.white,
    //         ),
    //         onPressed: () {
    //           _pdfViewerController.jumpToPage(3);
    //           print(_pdfViewerController.scrollOffset.dy);
    //           print(_pdfViewerController.scrollOffset.dx);
    //         },
    //       ),
    //     ],
    //   ),
    //   body: SfPdfViewer.memory(
    //     widget.pdfFile,
    //     controller: _pdfViewerController,
    //   ),
    // );
  }
}
