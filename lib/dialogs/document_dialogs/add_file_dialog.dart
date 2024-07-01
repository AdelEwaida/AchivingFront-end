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
import '../../utils/func/responsive.dart';
import '../../widget/custom_drop_down.dart';
import '../../widget/custom_drop_down2.dart';
import '../../widget/date_time_component.dart';
import '../../widget/dialog_widgets/title_dialog_widget.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';

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
    return AlertDialog(
        titlePadding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        backgroundColor: dBackground,
        title: TitleDialogWidget(
          title: _locale.addDocument,
          width: isDesktop ? width * 0.4 : width * 0.8,
          height: height * 0.07,
        ),
        content: SizedBox(
          width: width * 0.25,
          height: height * 0.3,
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
                        onPressed: saveDocument,
                        style: customButtonStyle(
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
              pickFile();
            },
            style: customButtonStyle(
                Size(isDesktop ? width * 0.13 : width * 0.4, height * 0.045),
                14,
                primary3),
            child: Text(
              _locale.uploadFile,
              style: const TextStyle(color: whiteColor),
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
  Future<void> pickFile() async {
    setState(() {
      isFileLoading = true;
    });

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null && result.files.isNotEmpty) {
      List<PlatformFile> files1 = result.files;
      for (int i = 0; i < files1.length; i++) {
        filesName.add(files1[i].name);
        filesBlobs.add(base64Encode(files1[i].bytes!));
        sizes.add(files1[i].size);
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
          fileNameController.text = filesName.toString();
          txtFilename = filesName.toString();
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
