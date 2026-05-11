import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archiving_flutter_project/dialogs/document_dialogs/send_email_dialog.dart';
import 'package:archiving_flutter_project/dialogs/document_dialogs/whats_app_dialog.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/confirm_dialog.dart';
import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/dialogs/pdf_preview.dart';
import 'package:archiving_flutter_project/models/db/document_models/upload_file_mode.dart';
import 'package:archiving_flutter_project/service/controller/documents_controllers/documents_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/utils/func/save_excel_file.dart';
import 'package:archiving_flutter_project/widget/dashboard_components/custom_elevated_button.dart';
import 'package:archiving_flutter_project/widget/table_component/table_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../widget/custom_flutter_toast_message.dart';
import '../app_dialog.dart';

Uint8List? _decodeBlobFromCell(dynamic cellValue) {
  final s = cellValue?.toString();
  if (s == null || s.isEmpty) return null;
  final decoded = Converters.decodeDocumentImgBlob(s);
  if (decoded != null && decoded.isNotEmpty) return decoded;
  try {
    return base64Decode(s);
  } catch (_) {
    return null;
  }
}


class FileExplorerDeptTrackingExtras {
  FileExplorerDeptTrackingExtras({
    required this.onReceiveTap,
    required this.onSendTap,
    this.receiveOnlyLastStep = false,
    this.sendOnlyAfterReceived = false,
  });

  final Future<bool> Function() onReceiveTap;
  final Future<bool> Function(String notes) onSendTap;

  final bool receiveOnlyLastStep;
  final bool sendOnlyAfterReceived;
}

class FileExplorDialog extends StatefulWidget {
  List<FileUploadModel> listOfFiles;
  bool? isWorkFlowScreen;

  final FileExplorerDeptTrackingExtras? deptTrackingExtras;

  FileExplorDialog({
    super.key,
    required this.listOfFiles,
    this.isWorkFlowScreen = false,
    this.deptTrackingExtras,
  });

  @override
  State<FileExplorDialog> createState() => _FileExplorDialogState();
}

class _FileExplorDialogState extends State<FileExplorDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  bool isDesktop = false;

  late PlutoGridStateManager stateManager;

  bool _dtReceiveBusy = false;
  bool _dtReceiveSendBusy = false;
  bool _dtSendOnlyBusy = false;

  late final UniqueKey _filesPlutoKey;
  TextEditingController? _deptNotesController;

  @override
  void initState() {
    super.initState();
    _filesPlutoKey = UniqueKey();
    if (widget.deptTrackingExtras != null) {
      _deptNotesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _deptNotesController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context);
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
    return AppDialog(
      height: height * 0.89,
      width: isDesktop ? width * 0.63 : width * 0.9,
      title: _locale.documents,
      content: formSection(),
      actions: [],
    );
  }

  PlutoRow? selectedRow;

  double _tableHeight() =>
      widget.deptTrackingExtras != null ? height * 0.52 : height * 0.66;

  Widget formSection() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KeyedSubtree(
                key: _filesPlutoKey,
                child: TableComponent(
                  tableWidth: width * 0.6,
                  tableHeigt: _tableHeight(),
                  rowsHeight: 50,
                  sendEmail: widget.isWorkFlowScreen == true ? null : sendEmail,
                  delete: widget.isWorkFlowScreen == true ? null : deleteFile,
                  plCols: polCols,
                  sendWhatspp:
                      widget.isWorkFlowScreen == true ? null : sendWhatsapp,
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
                        stateManager.appendRows(
                            [widget.listOfFiles[i].toPlutoRow(i + 1)]);
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
                ),
              ),
            ],
          ),
          if (widget.deptTrackingExtras != null) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            if (!widget.deptTrackingExtras!.receiveOnlyLastStep) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    _locale.deptTrackingSendNotesLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: TextField(
                  controller: _deptNotesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: _locale.deptTrackingSendNotesHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ] else ...[
              const SizedBox(height: 4),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _deptTrackingActionButtons(),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  List<Widget> _deptTrackingActionButtons() {
    final x = widget.deptTrackingExtras!;
    if (x.receiveOnlyLastStep) {
      return [
        CustomElevatedButton(
          text: _locale.deptTrackingReceive,
          color: greenColor,
          icon: Icons.inbox_rounded,
          width: isDesktop ? width * 0.14 : width * 0.42,
          height: height * 0.046,
          fontSize: 14,
          isLoading: _dtReceiveBusy,
          onPressed: () {
            if (!_dtReceiveBusy &&
                !_dtReceiveSendBusy &&
                !_dtSendOnlyBusy) {
              _onDeptReceive();
            }
          },
        ),
      ];
    }
    if (x.sendOnlyAfterReceived) {
      return [
        CustomElevatedButton(
          text: _locale.deptTrackingSendOnly,
          color: const Color(0xFF1565C0),
          icon: Icons.send_rounded,
          width: isDesktop ? width * 0.14 : width * 0.42,
          height: height * 0.046,
          fontSize: 14,
          isLoading: _dtSendOnlyBusy,
          onPressed: () {
            if (!_dtSendOnlyBusy) {
              _onDeptSendOnly();
            }
          },
        ),
      ];
    }
    return [
      CustomElevatedButton(
        text: _locale.deptTrackingReceive,
        color: greenColor,
        icon: Icons.inbox_rounded,
        width: isDesktop ? width * 0.12 : width * 0.34,
        height: height * 0.046,
        fontSize: 14,
        isLoading: _dtReceiveBusy,
        onPressed: () {
          if (!_dtReceiveBusy && !_dtReceiveSendBusy && !_dtSendOnlyBusy) {
            _onDeptReceive();
          }
        },
      ),
      SizedBox(width: isDesktop ? 14 : 8),
      CustomElevatedButton(
        text: _locale.deptTrackingReceiveAndSend,
        color: const Color(0xFF1565C0),
        icon: Icons.sync_alt_rounded,
        width: isDesktop ? width * 0.18 : width * 0.44,
        height: height * 0.046,
        fontSize: 13,
        isLoading: _dtReceiveSendBusy,
        onPressed: () {
          if (!_dtReceiveBusy && !_dtReceiveSendBusy && !_dtSendOnlyBusy) {
            _onDeptReceiveThenSend();
          }
        },
      ),
    ];
  }

  Future<void> _onDeptReceive() async {
    final x = widget.deptTrackingExtras;
    if (x == null ||
        _dtReceiveBusy ||
        _dtReceiveSendBusy ||
        _dtSendOnlyBusy) {
      return;
    }
    setState(() => _dtReceiveBusy = true);
    var clearBusyAfterPop = true;
    try {
      final ok = await x.onReceiveTap();
      if (!mounted) return;
      if (ok) {
        CustomToastMessage.success(context, _locale.updatedSuccess);
        clearBusyAfterPop = false;
        Navigator.of(context).pop(true);
        return;
      }
      CustomToastMessage.error(context, _locale.error);
    } finally {
      if (mounted && clearBusyAfterPop) {
        setState(() => _dtReceiveBusy = false);
      }
    }
  }

  Future<void> _onDeptReceiveThenSend() async {
    final x = widget.deptTrackingExtras;
    if (x == null ||
        _dtReceiveBusy ||
        _dtReceiveSendBusy ||
        _dtSendOnlyBusy) {
      return;
    }
    setState(() => _dtReceiveSendBusy = true);
    var clearBusyAfterPop = true;
    try {
      final okReceive = await x.onReceiveTap();
      if (!mounted) return;
      if (!okReceive) {
        CustomToastMessage.error(context, _locale.error);
        return;
      }
      final notes = (_deptNotesController?.text ?? '').trim();
      final okSend = await x.onSendTap(notes);
      if (!mounted) return;
      if (okSend) {
        CustomToastMessage.success(context, _locale.updatedSuccess);
        clearBusyAfterPop = false;
        Navigator.of(context).pop(true);
        return;
      }
      CustomToastMessage.error(context, _locale.error);
    } finally {
      if (mounted && clearBusyAfterPop) {
        setState(() => _dtReceiveSendBusy = false);
      }
    }
  }

  Future<void> _onDeptSendOnly() async {
    final x = widget.deptTrackingExtras;
    if (x == null || _dtSendOnlyBusy) return;
    setState(() => _dtSendOnlyBusy = true);
    var clearBusyAfterPop = true;
    try {
      final notes = (_deptNotesController?.text ?? '').trim();
      final okSend = await x.onSendTap(notes);
      if (!mounted) return;
      if (okSend) {
        CustomToastMessage.success(context, _locale.updatedSuccess);
        clearBusyAfterPop = false;
        Navigator.of(context).pop(true);
        return;
      }
      CustomToastMessage.error(context, _locale.error);
    } finally {
      if (mounted && clearBusyAfterPop) {
        setState(() => _dtSendOnlyBusy = false);
      }
    }
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
              widget.listOfFiles.removeAt(selectedRow!.sortIdx);
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
    } else {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
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
    } else {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
    }
  }

  List<PlutoColumn> polCols = [];
  fillCols() {
    polCols.addAll([
      PlutoColumn(
        title: "#",
        field: "countNumber",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.06 : width * 0.15,
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
        width: isDesktop ? width * 0.15 : width * 0.2,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.category,
        field: "categoryName",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.10 : width * 0.2,
        backgroundColor: columnColors,
      ),
      PlutoColumn(
        title: _locale.dateCreated,
        field: "datDate",
        type: PlutoColumnType.text(),
        width: isDesktop ? width * 0.12 : width * 0.2,
        backgroundColor: columnColors,
      ),
    ]);
  }

  Future<void> download() async {
    if (selectedRow != null) {
      final bytes =
          _decodeBlobFromCell(selectedRow!.cells['imgBlob']?.value);
      if (bytes == null) {
        CustomToastMessage.error(context, _locale.error);
        return;
      }
      saveExcelFile(bytes, selectedRow!.cells['txtFilename']!.value);
    } else {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
    }
  }

  Future<void> saveAndOpenFile(String base64String, String fileName) async {
    try {
      Uint8List fileBytes = base64Decode(base64String);

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      File file = File('$tempPath/$fileName');
      await file.writeAsBytes(fileBytes);

      await OpenFilex.open(file.path);
    } catch (e) {
      print("Error: $e");
    } finally {}
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
    } else {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
    }
  }

  void view() {
    if (selectedRow != null) {
      final bytes =
          _decodeBlobFromCell(selectedRow!.cells['imgBlob']?.value);
      if (bytes == null) {
        CustomToastMessage.warning(context, _locale.error);
        return;
      }
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
    } else {
      CustomToastMessage.warning(context, _locale.pleaseSelectRow);
    }
  }

  spaceWidth(double width1) {
    return SizedBox(
      width: width * width1,
    );
  }
}
