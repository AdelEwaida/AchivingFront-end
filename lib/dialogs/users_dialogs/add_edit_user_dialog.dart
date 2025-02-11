import 'dart:typed_data';
import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/service/controller/department_controller/department_cotnroller.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/constants/user_types_constant/user_types_constant.dart';
import 'package:archiving_flutter_project/utils/encrypt/encryption.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/custom_drop_down.dart';
import 'package:archiving_flutter_project/widget/dialog_widgets/title_dialog_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/db/user_models/department_user_model.dart';
import '../../models/db/user_models/user_dept_model.dart';
import '../../models/dto/searchs_model/search_model.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';
import '../../widget/text_field_widgets/test_drop_down.dart';

class AddUserDialog extends StatefulWidget {
  UserModel? userModel;
  bool isChangePassword;
  AddUserDialog({super.key, this.userModel, required this.isChangePassword});

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
  TextEditingController txtReferenceUsernameController =
      TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  FocusNode codeFocusNode = FocusNode();
  List<DepartmentModel>? userDeptsList;
  int? selectedUserType;
  int? userActive;
  UserController userController = UserController();
  bool isActive = true;
  UserModel? userModel;
  bool obscureOldPassword = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      codeFocusNode.requestFocus();
    });
  }

  @override
  Future<void> didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;

    if (widget.userModel != null) {
      userModel = widget.userModel!;
      userCodeController.text = userModel!.txtCode ?? "";
      userNameController.text = userModel!.txtNamee ?? "";
      selectedUserType = userModel!.intType;
      txtReferenceUsernameController.text =
          widget.userModel!.txtReferenceUsername ?? "";
      isActive = userModel!.bolActive == 1 ? true : false;
      userActive = isActive ? 1 : 0;
      passwordController.text = widget.userModel!.txtPwd!;
      urlController.text = userModel!.url ?? "";
    }
    userCodeController.addListener(() {
      setState(() {
        userNameController.text = userCodeController.text;
      });
    });
    if (userModel != null) {
      List<DepartmentUserModel> response =
          await userController.getDepartmentUser(widget.userModel!.txtCode!);
      setState(() {
        hintUsers = response.map((e) => e.toString()).join(", ");
      });
    }
    if (userModel != null) {
      List<DepartmentUserModel> response =
          await userController.getDepartmentUser(widget.userModel!.txtCode!);

      setState(() {
        userDeptsList = convertUserDeptToDeptModel(response); // ✅ Convert here
        hintUsers = userDeptsList!.map((e) => e.toString()).join(", ");
      });
    }

    print("hintUsershintUsershintUsers :${hintUsers}");
    super.didChangeDependencies();
  }

  List<DepartmentModel> convertUserDeptToDeptModel(
      List<DepartmentUserModel> userDepts) {
    return userDepts.map((userDept) {
      return DepartmentModel(
        txtKey: userDept.txtDeptkey, // Map department key
        txtDescription: userDept.txtDeptName, // Map department name
        txtShortcode: null, // Assuming no equivalent in DepartmentUserModel
      );
    }).toList();
  }

  bool isDesktop = false;
  String hintUsers = "";
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
        title: userModel != null && widget.isChangePassword
            ? _locale.changePassword
            : userModel != null && !widget.isChangePassword
                ? _locale.editUser
                : _locale.addUser,
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: height * 0.07,
      ),
      content: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0)),
        width: isDesktop ? width * 0.25 : width * 0.8,
        height: isDesktop ? height * 0.43 : height * 0.5,
        child: formSection(),
      ),
      actions: [
        isDesktop
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      addUser();
                    },
                    style: customButtonStyle(
                        Size(isDesktop ? width * 0.1 : width * 0.4,
                            height * 0.045),
                        18,
                        primary),
                    child: Text(
                      _locale.save,
                      style: const TextStyle(color: whiteColor),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.01,
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isDesktop)
          userModel != null
              ? const SizedBox.shrink()
              : customTextField(_locale.userCode, userCodeController, isDesktop,
                  0.2, true, widget.isChangePassword,
                  focusNode: codeFocusNode),
        customTextField(_locale.userName, userNameController, isDesktop, 0.2,
            true, widget.isChangePassword),
        customTextField(_locale.userRefName, txtReferenceUsernameController,
            isDesktop, 0.2, true, widget.isChangePassword),
        DropDown(
          isEnabled: !widget.isChangePassword,
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
        userModel != null && widget.isChangePassword
            ? passwordField(_locale.newPass, passwordController, true,
                isDesktop, obscureOldPassword)
            : const SizedBox.shrink(),
        customTextField(_locale.url, urlController, isDesktop, 0.2, true,
            widget.isChangePassword),
        dropDownUsers(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
                activeColor: primary2,
                value: isActive,
                onChanged: !widget.isChangePassword
                    ? (value) {
                        setState(() {
                          isActive = value!;
                          userActive = isActive ? 1 : 0;
                        });
                      }
                    : null),
            Text(_locale.active),
          ],
        ),
        if (!isDesktop) ...[
          customTextField(_locale.userCode, userCodeController, isDesktop, 0.8,
              true, widget.isChangePassword),
          customTextField(_locale.userName, userCodeController, isDesktop, 0.8,
              true, widget.isChangePassword),
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
      bool isDesktop, double width1, bool isMandetory, bool readOnly,
      {bool isPassword = false, FocusNode? focusNode}) {
    bool obscureText = isPassword; // Start with hidden password
    return StatefulBuilder(
      builder: (context, setState) {
        return CustomTextField2(
          readOnly: readOnly,
          isReport: true,
          isMandetory: isMandetory,
          width: width * width1,
          focusNode: focusNode,
          height: hint == _locale.notes ? height * 0.1 : height * 0.05,
          text: Text(hint),
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: isPassword
                ? IconButton(
                    alignment: Alignment.centerLeft,
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText; // Toggle visibility
                      });
                    },
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      size: 25,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(10),
            hintText: hint,
          ),
          obscureText: isPassword ? obscureText : false, // Apply obscureText
        );
      },
    );
  }

  Widget passwordField(String hint, TextEditingController controller,
      bool isPassword, bool isDesktop, bool obscureText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        width: isDesktop ? width * 0.2 : width * 0.8,
        height: hint == _locale.notes ? height * 0.1 : height * 0.05,
        child: TextFormField(
          // focusNode: focus,
          onFieldSubmitted: (value) {},
          controller: controller,
          style: const TextStyle(
            fontSize: 18,
          ),
          obscureText: isPassword ? obscureText : false,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
          ],
          decoration: InputDecoration(
            suffixIcon: isPassword
                ? obscureText
                    ? IconButton(
                        alignment: Alignment.centerLeft,
                        onPressed: () {
                          setState(() {
                            if (controller == passwordController) {
                              obscureOldPassword = !obscureOldPassword;
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.visibility_off,
                          size: 25,
                        ),
                      )
                    : IconButton(
                        alignment: Alignment.centerLeft,
                        onPressed: () {
                          setState(() {
                            if (controller == passwordController) {
                              obscureOldPassword = !obscureOldPassword;
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.visibility,
                          size: 25,
                        ),
                      )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(10),
            hintText: hint,
          ),
        ),
      ),
    );
  }

  Widget customTextField11(String hint, TextEditingController controller,
      bool isDesktop, double width1, bool isMandetory, bool readOnly,
      {bool isPassword = false, bool obscureText = false}) {
    return CustomTextField2(
      readOnly: readOnly,
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
      decoration: InputDecoration(
        suffixIcon: isPassword
            ? obscureText
                ? IconButton(
                    alignment: Alignment.centerLeft,
                    onPressed: () {
                      setState(() {
                        if (controller == passwordController) {
                          obscureOldPassword = !obscureOldPassword;
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.visibility_off,
                      size: 25,
                    ),
                  )
                : IconButton(
                    alignment: Alignment.centerLeft,
                    onPressed: () {
                      setState(() {
                        if (controller == passwordController) {
                          obscureOldPassword = !obscureOldPassword;
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.visibility,
                      size: 25,
                    ),
                  )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(10),
        hintText: hint,
      ),
    );
  }

  void addUser() async {
    if (userCodeController.text.trim().isEmpty ||
        userNameController.text.trim().isEmpty ||
        txtReferenceUsernameController.text.isEmpty ||
        urlController.text.trim().isEmpty ||
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
    } else if (userModel != null && widget.isChangePassword == false) {
      editMethod();
    } else if (userModel != null && widget.isChangePassword) {
      cahngePasswordMethod();
    } else {
      UserModel userModel = UserModel(
          txtCode: userCodeController.text,
          txtNamee: userNameController.text,
          url: urlController.text,
          bolActive: userActive ?? 1,
          txtReferenceUsername: txtReferenceUsernameController.text,
          intType: selectedUserType);

      UserDeptModel userDeptModel =
          UserDeptModel(user: userModel, depts: userDeptsList);

      try {
        final response = await userController.addUser(userDeptModel);

        print("statusCode ${response.statusCode}");

        if (response.statusCode == 200) {
          // ignore: use_build_context_synchronously
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
      } catch (e) {
        print("Error adding user: $e");
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
                icon: Icons.error,
                errorDetails: _locale.error,
                errorTitle: "error",
                color: Colors.red,
                statusCode: 500);
          },
        );
      }
    }
  }

  void addUser1() async {
    if (userCodeController.text.trim().isEmpty ||
        userNameController.text.trim().isEmpty ||
        txtReferenceUsernameController.text.isEmpty ||
        urlController.text.trim().isEmpty ||
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
    } else if (userModel != null && widget.isChangePassword == false) {
      editMethod();
    } else if (userModel != null && widget.isChangePassword) {
      cahngePasswordMethod();
    } else {
      UserModel userModel = UserModel(
          txtCode: userCodeController.text,
          txtNamee: userNameController.text,
          url: urlController.text,
          bolActive: userActive ?? 1,
          txtReferenceUsername: txtReferenceUsernameController.text,
          intType: selectedUserType);
      await userController
          .addUser(UserDeptModel(user: userModel, depts: userDeptsList))
          .then((value) {
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

  void cahngePasswordMethod() async {
    String key = "archiveProj@s2024ASD/Key@team.CT";
    final iv = [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1];
    final byteArray =
        Uint8List.fromList(iv.map((bit) => bit == 1 ? 0x01 : 0x00).toList());
    String passEncrypted = Encryption.performAesEncryption(
        passwordController.text, key, byteArray);
    UserModel tempUserModel =
        UserModel(txtCode: userModel!.txtCode, txtPwd: passEncrypted);
    var response = await userController.updateOtherUserPassword(tempUserModel);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
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
  }

  void editMethod() async {
    // print(
    //     "widget.departmentModel!.txtKey!widget.departmentModel!.txtKey!:${widget.departmentModel!.txtKey!}");
    UserModel userModel = UserModel(
        txtCode: userCodeController.text,
        url: urlController.text,
        txtNamee: userNameController.text,
        bolActive: userActive ?? 0,
        txtReferenceUsername: txtReferenceUsernameController.text,
        intType: selectedUserType);

    UserDeptModel userDeptModel =
        UserDeptModel(user: userModel, depts: userDeptsList);

    await userController.updateUser(userDeptModel).then((value) {
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

  Widget dropDownUsers() {
    return SizedBox(
      width: width * 0.2,
      height: height * 0.045,
      child: Tooltip(
        message: hintUsers,
        child: TestDropdown(
          cleanPrevSelectedItem: false, // Keep previous selections
          isEnabled: true,
          icon: const Icon(Icons.search),
          onClearIconPressed: () {
            setState(() {
              userDeptsList = []; // Initialize to an empty list instead of null
              hintUsers = "";
            });
          },
          onChanged: (value) {
            setState(() {
              // Ensure userDeptsList is initialized
              userDeptsList ??= [];

              // Check for null value in selection
              if (value == null || value.isEmpty) return;

              for (var user in value) {
                if (user != null &&
                    !userDeptsList!.any((item) => item.txtKey == user.txtKey)) {
                  userDeptsList!.add(user);
                }
              }

              // Update tooltip/hint text
              hintUsers = userDeptsList!.isNotEmpty
                  ? userDeptsList!.map((e) => e.txtDescription).join(", ")
                  : "";
            });
          },
          stringValue: hintUsers,
          borderText: _locale.department,
          onSearch: (text) async {
            return DepartmentController().getDep(SearchModel(page: 1));
          },
        ),
      ),
    );
  }
}
