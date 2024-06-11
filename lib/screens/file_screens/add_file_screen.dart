import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/styles.dart';
import '../../utils/func/responsive.dart';
import '../../widget/custom_drop_down.dart';
import '../../widget/custom_drop_down2.dart';
import '../../widget/date_time_component.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';

class AddFileScreen extends StatefulWidget {
  const AddFileScreen({super.key});

  @override
  State<AddFileScreen> createState() => _AddFileScreenState();
}

class _AddFileScreenState extends State<AddFileScreen> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  TextEditingController fileDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController issueNoController = TextEditingController();
  TextEditingController arrivalDateController = TextEditingController();

  TextEditingController keyWordsController = TextEditingController();
  TextEditingController ref1Controller = TextEditingController();
  TextEditingController ref2Controller = TextEditingController();
  TextEditingController otherRefController = TextEditingController();
  TextEditingController organizationController = TextEditingController();
  TextEditingController followingController = TextEditingController();
  TextEditingController fileNameController = TextEditingController();
  bool isDesktop = false;

  String? txtFilename;
  String? imgBlob;
  int? dblFilesize;
  Uint8List? image;
  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    fileDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    arrivalDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          _locale.addDocument,
          style: TextStyle(fontSize: 25),
        ),
        Container(
          width: width * 0.45,
          height: height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CustomDropDown2(
                          width: width * 0.13,
                          onChanged: (value) {},
                          searchBox: true,
                          valSelected: true,
                          bordeText: _locale.department,
                          // width: width * 0.21,
                          heightVal: height * 0.3,
                        ),
                        SizedBox(
                          width: width * 0.015,
                        ),
                        CustomDropDown2(
                          width: width * 0.13,
                          onChanged: (value) {},
                          searchBox: true,
                          valSelected: true,
                          bordeText: _locale.category,
                          // width: width * 0.21,
                          heightVal: height * 0.3,
                        ),
                        SizedBox(
                          width: width * 0.015,
                        ),
                        DateTimeComponent(
                          label: _locale.issueDate,
                          dateController: fileDateController,
                          dateWidth: width * 0.13,
                          dateControllerToCompareWith: null,
                          readOnly: false,
                          isInitiaDate: true,
                          onValue: (isValid, value) {
                            if (isValid) {
                              fileDateController.text = value;
                            }
                          },
                          timeControllerToCompareWith: null,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      customTextField(
                        _locale.txtDescription,
                        descriptionController,
                        isDesktop,
                        0.13,
                        false,
                      ),
                      SizedBox(
                        width: width * 0.015,
                      ),
                      customTextField(
                        _locale.issueNo,
                        issueNoController,
                        isDesktop,
                        0.13,
                        false,
                      ),
                      SizedBox(
                        width: width * 0.015,
                      ),
                      DateTimeComponent(
                        label: _locale.issueDate,
                        dateController: arrivalDateController,
                        dateWidth: width * 0.13,
                        dateControllerToCompareWith: null,
                        readOnly: false,
                        isInitiaDate: true,
                        onValue: (isValid, value) {
                          if (isValid) {
                            arrivalDateController.text = value;
                          }
                        },
                        timeControllerToCompareWith: null,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      customTextField(
                        _locale.keyWords,
                        keyWordsController,
                        isDesktop,
                        0.13,
                        false,
                      ),
                      SizedBox(
                        width: width * 0.015,
                      ),
                      CustomDropDown2(
                        width: width * 0.13,
                        onChanged: (value) {},
                        searchBox: true,
                        valSelected: true,
                        bordeText: _locale.contractType,
                        // width: width * 0.21,
                        heightVal: height * 0.3,
                      ),
                      SizedBox(
                        width: width * 0.015,
                      ),
                      customTextField(
                        _locale.ref1,
                        ref1Controller,
                        isDesktop,
                        0.13,
                        false,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      customTextField(
                        _locale.ref2,
                        ref2Controller,
                        isDesktop,
                        0.13,
                        false,
                      ),
                      SizedBox(
                        width: width * 0.015,
                      ),
                      customTextField(
                        _locale.otherRef,
                        otherRefController,
                        isDesktop,
                        0.13,
                        false,
                      ),
                      SizedBox(
                        width: width * 0.015,
                      ),
                      customTextField(
                        _locale.organization,
                        organizationController,
                        isDesktop,
                        0.13,
                        false,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      customTextField(
                        _locale.following,
                        followingController,
                        isDesktop,
                        0.13,
                        false,
                      ),
                      SizedBox(
                        width: width * 0.015,
                      ),
                      SizedBox(
                        width: width * 0.13,
                      ),
                      SizedBox(
                        width: width * 0.015,
                      ),
                      SizedBox(
                        width: width * 0.13,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildFileUpload(),
                    ],
                  ),
                ]),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                prepareDataForBackend();
              },
              style: customButtonStyle(
                  Size(isDesktop ? width * 0.1 : width * 0.4, height * 0.045),
                  18,
                  primary3),
              child: Text(
                _locale.save,
                style: const TextStyle(color: whiteColor),
              ),
            ),
          ],
        )
      ],
    );
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
              false,
            ),
          ),
        ],
      ),
    );
  }

  Future pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      PlatformFile selectedFile = result.files.first;

      setState(() {
        fileNameController.text = selectedFile.name;
        txtFilename = selectedFile.name;
        imgBlob = base64Encode(selectedFile.bytes!);
        dblFilesize = selectedFile.size;
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

  void prepareDataForBackend() {
    if (txtFilename != null && imgBlob != null && dblFilesize != null) {
      Map<String, dynamic> data = {
        "txtFilename": txtFilename,
        "imgBlob": imgBlob,
        "dblFilesize": dblFilesize,
      };

      print("Data : $data");
    } else {}
  }
}
