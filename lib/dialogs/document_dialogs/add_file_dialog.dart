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
    return Dialog(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: width * 0.4,
        height: height * 0.45,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  _locale.addDocument,
                  style: const TextStyle(fontSize: 25),
                ),
                Container(
                  width: width * 0.35,
                  height: height * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildFileUpload(),
                              ],
                            ),
                          )
                        ]),
                  ),
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
                        18,
                        primary3,
                      ),
                      child: Text(
                        _locale.save,
                        style: const TextStyle(color: whiteColor),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.01,
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
                Size(isDesktop ? width * 0.1 : width * 0.4, height * 0.045),
                18,
                primary3),
            child: Text(
              _locale.uploadFile,
              style: const TextStyle(color: whiteColor),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: width * 0.3,
            child: customTextField(
              _locale.fileName,
              fileNameController,
              isDesktop,
              0.13,
              true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickFile() async {
    setState(() {
      isFileLoading = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      PlatformFile selectedFile = result.files.first;

      try {
        List<int> fileBytes = selectedFile.bytes!;

        // Check if bytes are null or empty
        if (fileBytes.isEmpty) {
          throw Exception("File bytes are empty or null");
        }

        // Encode file bytes to base64
        String encodedFile = base64Encode(fileBytes);

        setState(() {
          fileNameController.text = selectedFile.name;
          txtFilename = selectedFile.name;
          imgBlob = encodedFile; // Assign the encoded base64 string
          dblFilesize = selectedFile.size;
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
      readOnly: hint == _locale.uploadFile ? true : false,
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
    FileUploadModel fileUploadModel = FileUploadModel(
      txtKey: "",
      txtHdrkey: "",
      txtFilename: fileNameController.text,
      imgBlob: imgBlob ?? "",
      dblFilesize: dblFilesize ?? 0,
      txtUsercode: "",
      datDate: "",
      txtMimetype: "",
      intLinenum: 1,
      intType: 1,
    );

    DocumentFileRequest documentFileRequest = DocumentFileRequest(
      documentInfo: documentModel,
      documentFile: fileUploadModel,
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
