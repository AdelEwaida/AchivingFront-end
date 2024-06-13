import 'dart:typed_data';

import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/constants/user_types_constant/user_types_constant.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:archiving_flutter_project/widget/dialog_widgets/title_dialog_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widget/text_field_widgets/custom_text_field2_.dart';

class AddUserDialog extends StatefulWidget {
  UserModel? userModel;
  AddUserDialog({super.key, this.userModel});

  @override
  State<AddUserDialog> createState() => _DepartmentDialogState();
}

class _DepartmentDialogState extends State<AddUserDialog> {
  late AppLocalizations _locale;
  double width = 0;
  double height = 0;
  double radius = 7;

  TextEditingController userCodeController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  int? selectedUserType;
  int? userActive;
  UserController userController = UserController();
  bool isActive = false;
  UserModel? userModel;
  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;

    if (widget.userModel != null) {
      userModel = widget.userModel!;
      userCodeController.text = userModel!.txtCode ?? "";
      userNameController.text = userModel!.txtNamee ?? "";
      selectedUserType = userModel!.intType;
      isActive = userModel!.bolActive == 1 ? true : false;
      userActive = isActive ? 1 : 0;
    }

    super.didChangeDependencies();
  }

  bool isDesktop = false;

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
        title: _locale.addUser,
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: height * 0.07,
      ),
      content: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: isDesktop ? height * 0.4 : height * 0.5,
        child: SingleChildScrollView(
          child: formSection(),
        ),
      ),
      actions: [
        isDesktop
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      addUser();
                    },
                    style: customButtonStyle(
                        Size(isDesktop ? width * 0.1 : width * 0.4,
                            height * 0.045),
                        18,
                        greenColor),
                    child: Text(
                      _locale.save,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: customButtonStyle(
                        Size(isDesktop ? width * 0.1 : width * 0.4,
                            height * 0.045),
                        18,
                        redColor),
                    child: Text(
                      _locale.cancel,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          addUser();
                        },
                        style: customButtonStyle(
                            Size(isDesktop ? width * 0.1 : width * 0.4,
                                height * 0.045),
                            18,
                            greenColor),
                        child: Text(
                          _locale.save,
                          style: const TextStyle(color: whiteColor),
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: customButtonStyle(
                            Size(isDesktop ? width * 0.1 : width * 0.4,
                                height * 0.045),
                            18,
                            redColor),
                        child: Text(
                          _locale.cancel,
                          style: const TextStyle(color: whiteColor),
                        ),
                      ),
                    ],
                  ),
                ],
              )
      ],
    );
  }

  Widget formSection() {
    return Column(
      children: [
        if (isDesktop)
          customTextField(
              _locale.userCode, userCodeController, isDesktop, 0.2, true),
        customTextField(
            _locale.userName, userNameController, isDesktop, 0.2, true),
        DropDown(
          width: width * 0.2,
          height: height * 0.05,
          bordeText: _locale.userType,
          initialValue: userModel != null
              ? getNameOfUserType(_locale, selectedUserType!)
              : null,
          onChanged: (value) {
            selectedUserType = getCodeOfUserType(_locale, value);
          },
          items: getUserTypesList(_locale),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              activeColor: primary2,
              value: isActive,
              onChanged: (value) {
                setState(() {
                  isActive = value!;
                  userActive = isActive ? 1 : 0;
                });
              },
            ),
            Text(_locale.active),
          ],
        ),
        if (!isDesktop) ...[
          customTextField(
              _locale.userCode, userCodeController, isDesktop, 0.8, true),
          customTextField(
              _locale.userName, userCodeController, isDesktop, 0.8, true),
        ],
      ],
    );
  }

  Widget row(Widget widget1, Widget widget2) {
    return Row(
      children: [
        widget1,
        SizedBox(
          width: width * 0.003,
        ),
        widget2
      ],
    );
  }

  Widget customTextField(String hint, TextEditingController controller,
      bool isDesktop, double width1, bool isMandetory) {
    return CustomTextField2(
      readOnly: false,
      // inputFormatters: hint == _locale.phoneNumber
      //     ? [
      //         FilteringTextInputFormatter.digitsOnly,
      //         LengthLimitingTextInputFormatter(14),
      //         PhoneNumberFormatter(),
      //       ]
      //     : null,
      isReport: true,
      isMandetory: isMandetory,
      width: width * width1,
      height: hint == _locale.notes ? height * 0.1 : height * 0.05,
      text: Text(hint),
      controller: controller,
      onSubmitted: (text) {},
      onChanged: (value) {},
    );
  }

  void addUser() async {
    if (userCodeController.text.trim().isEmpty ||
        userNameController.text.trim().isEmpty ||
        userActive == null ||
        selectedUserType == null) {
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
              icon: Icons.error,
              errorDetails: _locale.error,
              errorTitle: _locale.pleaseAddAllRequiredFields,
              color: Colors.red,
              statusCode: 400);
        },
      );
    } else if (userModel != null) {
      editMethod();
    } else {
      UserModel userModel = UserModel(
          txtCode: userCodeController.text,
          txtNamee: userNameController.text,
          bolActive: userActive,
          intType: selectedUserType);
      await userController.addUser(userModel).then((value) {
        print("statusCode ${value.statusCode}");
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
    }
  }

  void editMethod() async {
    // print(
    //     "widget.departmentModel!.txtKey!widget.departmentModel!.txtKey!:${widget.departmentModel!.txtKey!}");
    UserModel userModel = UserModel(
        txtCode: userCodeController.text,
        txtNamee: userNameController.text,
        bolActive: userActive,
        intType: selectedUserType);
    await userController.updateUser(userModel).then((value) {
      if (value.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
                icon: Icons.done_all,
                errorDetails: _locale.done,
                errorTitle: _locale.editDoneSucess,
                color: Colors.green,
                statusCode: 200);
          },
        ).then((value) {
          Navigator.pop(context, true);
        });
      }
    });
  }
}
