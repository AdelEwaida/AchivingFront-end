import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:archiving_flutter_project/utils/func/converters.dart';
import 'package:cool_alert/cool_alert.dart';
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
import '../../utils/constants/colors.dart';
import '../../utils/constants/styles.dart';
import '../../utils/func/document_file_utils.dart';
import '../../utils/func/responsive.dart';
import '../../widget/custom_flutter_toast_message.dart';
import '../../widget/custom_drop_down.dart';
import '../../widget/custom_drop_down2.dart';
import '../../widget/date_time_component.dart';
import '../../widget/dialog_widgets/title_dialog_widget.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';
import '../app_dialog.dart';

class AddFileDialog extends StatefulWidget {
  DocumentModel documentModel;
  AddFileDialog({super.key, required this.documentModel});

  @override
  State<AddFileDialog> createState() => _AddFileDialogState();
}

class _AddFileDialogState extends State<AddFileDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;

  bool isDesktop = false;
  DocumentsController documentsController = DocumentsController();
  bool isFileLoading = false;
  String? txtFilename;
  String? imgBlob;
  int? dblFilesize;
  Uint8List? image;
  bool saving = false;

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

    return AppDialog(
      width: isDesktop ? width * 0.4 : width * 0.9,
      height: height * 0.45,
      title: _locale.addDocument,
      content: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                buildFileUpload(),
                const Spacer(),
                SizedBox(
                  width: isDesktop ? width * 0.12 : width * 0.5,
                  height: height * 0.05,
                  child: ElevatedButton(
                    onPressed: saveDocument,
                    style: customButtonStyle(
                      context,
                      Size(double.infinity, double.infinity),
                      14,
                      primary,
                    ),
                    child: Text(
                      _locale.save,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Saving overlay
          if (saving) const Center(child: CircularProgressIndicator()),

          // File loading overlay
          if (isFileLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                child: const ColoredBox(
                  color: Colors.transparent,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildFileUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: isDesktop ? width * 0.12 : width * 0.5,
          height: height * 0.05,
          child: ElevatedButton(
            onPressed: pickFile,
            style: customButtonStyle(
              context,
              Size(double.infinity, double.infinity),
              14,
              primary3,
            ),
            child: Text(
              _locale.uploadFile,
              style: const TextStyle(color: whiteColor),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Tooltip(
          message: fileNameController.text,
          child: customTextField(
            _locale.fileName,
            fileNameController,
            isDesktop,
            isDesktop ? 0.28 : 0.7,
            true,
          ),
        ),
      ],
    );
  }

  List<String> filesBlobs = [];
  List<String> filesName = [];
  List<int> sizes = [];
  Future<void> pickFile() async {
    setState(() {
      isFileLoading = true;
    });

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null && result.files.isNotEmpty) {
      List<PlatformFile> files1 = result.files;
      var rejectedFile = false;
      for (int i = 0; i < files1.length; i++) {
        if (DocumentFileUtils.isBlockedUploadFileName(files1[i].name) ||
            !DocumentFileUtils.isFileSizeAllowed(files1[i].size)) {
          rejectedFile = true;
          continue;
        }
        filesName.add(files1[i].name);
        filesBlobs.add(base64Encode(files1[i].bytes!));
        sizes.add(files1[i].size);
      }
      if (rejectedFile) {
        CustomToastMessage.warning(context, _locale.cannotUploadVideo);
      }

      try {
        // List<int> fileBytes = selectedFile.bytes!;

        // Check if bytes are null or empty
        // if (fileBytes.isEmpty) {
        //   throw Exception("File bytes are empty or null");
        // }

        // Encode file bytes to base64
        // String encodedFile = base64Encode(fileBytes);

        setState(() {
          fileNameController.text =
              DocumentFileUtils.formatSelectedFileNames(filesName);
          txtFilename = DocumentFileUtils.formatSelectedFileNames(filesName);
          // imgBlob = encodedFile; // Assign the encoded base64 string
          // dblFilesize = selectedFile.size;
          isFileLoading = false;
        });
      } catch (e) {
        print("Error encoding file: $e");
        setState(() {
          isFileLoading = false;
        });
      }
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
      height: height * 0.15,
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
    DocumentModel documentModel = widget.documentModel;
    print("documentModeldocumentModel:${documentModel.txtKey}");
    // Create the FileUploadModel using the file data
    List<FileUploadModel> filesUploadList = [];
    for (int i = 0; i < filesBlobs.length; i++) {
      filesUploadList.add(FileUploadModel(
        txtKey: "",
        txtHdrkey: "",
        txtFilename: filesName[i],
        imgBlob: filesBlobs[i],
        dblFilesize: sizes[i],
        txtUsercode: "",
        datDate: "",
        txtMimetype: "",
        intLinenum: 1,
        intType: 1,
      ));
    }

    DocumentFileRequest documentFileRequest = DocumentFileRequest(
      documentInfo: documentModel,
      documentFile: filesUploadList,
    );

    await documentsController
        .uplodFileInDocument(documentFileRequest)
        .then((value) {
      if (value.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
                icon: Icons.done_all,
                errorDetails: _locale.done,
                errorTitle: _locale.addDoneSucess,
                color: Colors.green,
                statusCode: 200);
          },
        ).then((value) {
          Navigator.pop(context, true);
        });
      }
    });
    setState(() {
      saving = false;
    });
  }
}
