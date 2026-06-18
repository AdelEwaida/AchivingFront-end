import 'dart:math';
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
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import '../../models/db/user_models/department_user_model.dart';
import '../../models/db/user_models/user_dept_model.dart';
import '../../models/dto/searchs_model/search_model.dart';
import '../../widget/custom_flutter_toast_message.dart';
import '../../widget/dashboard_components/custom_elevated_button.dart';
import '../../widget/text_field_widgets/custom_text_field2_.dart';
import '../../widget/text_field_widgets/test_drop_down.dart';
import '../app_dialog.dart';
import '../error_dialgos/confirm_dialog.dart';

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
  bool isLimitAction = true;
  int? limitAction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      codeFocusNode.requestFocus();
    });

    urlController.addListener(() {
      final text = urlController.text;
      String fixedText = text;

      if (fixedText.contains(r'http:\\')) {
        fixedText = fixedText.replaceAll(r'http:\\', 'http://');
      }
      if (fixedText.contains(r'https:\\')) {
        fixedText = fixedText.replaceAll(r'https:\\', 'https://');
      }

      if (fixedText != text) {
        final selectionIndex = urlController.selection.baseOffset;
        urlController.value = TextEditingValue(
          text: fixedText,
          selection: TextSelection.collapsed(
            offset: selectionIndex - (text.length - fixedText.length),
          ),
        );
      }
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
      isLimitAction = userModel!.bolLimitActions == 1 ? true : false;

      try {
        passwordController.text =
            EncryptionPass.decryptBase64(widget.userModel!.txtPwd!);
      } catch (e) {
        passwordController.text = '';
      }

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
      final response =
          await userController.getDepartmentUser(widget.userModel!.txtCode!);

      // keep only selected
      final selected =
          response.where((e) => (e.bolSelected ?? 0) == 1).toList();

      setState(() {
        userDeptsList = convertUserDeptToDeptModel(selected);
        hintUsers = selected
            .map((e) => e.txtDeptName)
            .whereType<String>() // drop nulls safely
            .join(", ");
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

    final String dialogTitle = userModel != null && widget.isChangePassword
        ? _locale.changePassword
        : userModel != null && !widget.isChangePassword
            ? _locale.editUser
            : _locale.addUser;

    final double btnWidth = isDesktop ? 120.0 : width * 0.38;

    return AppDialog(
      width: isDesktop ? width * 0.42 : width * 0.92,
      title: dialogTitle,
      content: formSection(),
      actions: [
        CustomElevatedButton(
          width: btnWidth,
          height: 40,
          text: _locale.save,
          color: primary,
          icon: Icons.check_rounded,
          onPressed: addUser,
        ),
        const SizedBox(width: 10),
        CustomElevatedButton(
          width: btnWidth,
          height: 40,
          text: _locale.cancel,
          color: redColor,
          icon: Icons.close_rounded,
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    );
  }

  Widget _formColumn({required List<Widget> children}) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _twoFieldRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _userCodeBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD6E6F5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.badge_outlined, size: 18, color: Color(0xFF185FA5)),
          const SizedBox(width: 8),
          Text(
            '${_locale.userCode}: ',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8A94A6),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              userCodeController.text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1A2340),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkboxRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  activeColor: primary2,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: isActive,
                  onChanged: !widget.isChangePassword
                      ? (value) {
                          setState(() {
                            isActive = value!;
                            userActive = isActive ? 1 : 0;
                          });
                        }
                      : null,
                ),
                Flexible(
                  child: Text(
                    _locale.active,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  activeColor: primary2,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: isLimitAction,
                  onChanged: !widget.isChangePassword
                      ? (value) {
                          setState(() {
                            isLimitAction = value!;
                          });
                        }
                      : null,
                ),
                Flexible(
                  child: Text(
                    _locale.isLimitAction,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget formSection() {
    const double rowGap = 10;

    if (widget.isChangePassword && userModel != null) {
      return _formColumn(
        children: [
          _userCodeBadge(),
          passwordField(
            _locale.newPass,
            passwordController,
            true,
            isDesktop,
            obscureOldPassword,
          ),
        ],
      );
    }

    return _formColumn(
      children: [
        if (userModel != null) _userCodeBadge(),
        if (userModel == null)
          customTextField(
            _locale.userCode,
            userCodeController,
            true,
            widget.isChangePassword,
            focusNode: codeFocusNode,
          ),
        if (userModel == null) const SizedBox(height: rowGap),
        if (isDesktop) ...[
          _twoFieldRow(
            customTextField(
              _locale.userName,
              userNameController,
              true,
              widget.isChangePassword,
            ),
            customTextField(
              _locale.userRefName,
              txtReferenceUsernameController,
              true,
              widget.isChangePassword,
            ),
          ),
          const SizedBox(height: rowGap),
          _twoFieldRow(
            DropDown(
              isEnabled: !widget.isChangePassword,
              width: double.infinity,
              height: 44,
              bordeText: _locale.userType,
              initialValue: userModel != null
                  ? getNameOfUserType(_locale, selectedUserType!)
                  : null,
              onChanged: (value) {
                selectedUserType = getCodeOfUserType(_locale, value);
              },
              items: getUserTypesList(_locale),
            ),
            customTextField(
              _locale.url,
              urlController,
              true,
              widget.isChangePassword,
            ),
          ),
        ] else ...[
          customTextField(
            _locale.userName,
            userNameController,
            true,
            widget.isChangePassword,
          ),
          const SizedBox(height: rowGap),
          customTextField(
            _locale.userRefName,
            txtReferenceUsernameController,
            true,
            widget.isChangePassword,
          ),
          const SizedBox(height: rowGap),
          DropDown(
            isEnabled: !widget.isChangePassword,
            width: double.infinity,
            height: 44,
            bordeText: _locale.userType,
            initialValue: userModel != null
                ? getNameOfUserType(_locale, selectedUserType!)
                : null,
            onChanged: (value) {
              selectedUserType = getCodeOfUserType(_locale, value);
            },
            items: getUserTypesList(_locale),
          ),
          const SizedBox(height: rowGap),
          customTextField(
            _locale.url,
            urlController,
            true,
            widget.isChangePassword,
          ),
        ],
        const SizedBox(height: rowGap),
        dropDownUsers(),
        const SizedBox(height: rowGap),
        _checkboxRow(),
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

  Widget customTextField(
    String hint,
    TextEditingController controller,
    bool isMandetory,
    bool readOnly, {
    bool isPassword = false,
    FocusNode? focusNode,
  }) {
    bool obscureText = isPassword;
    return StatefulBuilder(
      builder: (context, setState) {
        return CustomTextField2(
          readOnly: readOnly,
          isReport: true,
          isMandetory: isMandetory,
          width: double.infinity,
          focusNode: focusNode,
          height: 44,
          text: Text(hint),
          controller: controller,
          obscureText: isPassword ? obscureText : false,
        );
      },
    );
  }

  Widget passwordField(String hint, TextEditingController controller,
      bool isPassword, bool isDesktop, bool obscureText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDE3EE)),
      ),
      width: double.infinity,
      height: 44,
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        obscureText: isPassword ? obscureText : false,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ],
        decoration: InputDecoration(
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      obscureOldPassword = !obscureOldPassword;
                    });
                  },
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: const Color(0xFF8A94A6),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF8A94A6), fontSize: 13),
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

  void addUserAPI() async {
    UserController()
        .getByUserURL(urlController.text.trim())
        .then((value) async {
      // if (value == null) {
      CoolAlert.show(
        width: width * 0.4,
        // ignore: use_build_context_synchronously
        context: context,
        type: CoolAlertType.confirm,
        title: _locale.error,
        text: _locale.urlError,
        confirmBtnText: _locale.ok,
        cancelBtnText: _locale.cancel,

        onConfirmBtnTap: () async {
          // Navigator.pop(context);
          if (userCodeController.text.trim().isEmpty ||
              userNameController.text.trim().isEmpty ||
              txtReferenceUsernameController.text.isEmpty ||
              urlController.text.trim().isEmpty ||
              selectedUserType == null) {
            CustomToastMessage.error(
                context, _locale.pleaseAddAllRequiredFields);
            // showDialog(
            //   context: context,
            //   builder: (context) {
            //     return ErrorDialog(
            //         icon: Icons.error,
            //         errorDetails: _locale.error,
            //         errorTitle: _locale.pleaseAddAllRequiredFields,
            //         color: Colors.red,
            //         statusCode: 400);
            //   },
            // );
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
                bolLimitActions: isLimitAction == true ? 1 : 0,
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
            }
          }
        },
      );
      // }
    });
  }

  void addUser() async {
    if (userCodeController.text.trim().isEmpty ||
        userNameController.text.trim().isEmpty ||
        txtReferenceUsernameController.text.isEmpty ||
        urlController.text.trim().isEmpty ||
        ((userDeptsList ?? []).isEmpty) ||
        selectedUserType == null) {
      //
      CustomToastMessage.error(context, _locale.pleaseAddAllRequiredFields);
      // showDialog(
      //   context: context,
      //   builder: (context) {
      //     return ErrorDialog(
      //         icon: Icons.error,
      //         errorDetails: _locale.error,
      //         errorTitle: _locale.pleaseAddAllRequiredFields,
      //         color: Colors.red,
      //         statusCode: 400);
      //   },
      // );
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
      UserController()
          .getByUserURL(urlController.text.trim())
          .then((value) async {
        if ((value?.txtCode ?? "").isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) {
              return CustomConfirmDialog(confirmMessage: _locale.urlError);
            },
          ).then((value) async {
            if (value == true) {
              await userController
                  .addUser(UserDeptModel(user: userModel, depts: userDeptsList))
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
            }
          });
        } else {
          await userController
              .addUser(UserDeptModel(user: userModel, depts: userDeptsList))
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
    UserModel user = UserModel(
        txtCode: userCodeController.text,
        url: urlController.text,
        txtNamee: userNameController.text,
        bolActive: userActive ?? 0,
        bolLimitActions: isLimitAction == true ? 1 : 0,
        txtReferenceUsername: txtReferenceUsernameController.text,
        intType: selectedUserType);

    UserDeptModel userDeptModel =
        UserDeptModel(user: user, depts: userDeptsList);

    String newUrl = urlController.text.trim();
    String oldUrl = userModel!.url ?? "";
    print("urlController.texturlController.text :${newUrl} ${oldUrl}");
    if (newUrl != oldUrl) {
      UserController()
          .getByUserURL(urlController.text.trim())
          .then((value) async {
        if ((value?.txtCode ?? "").isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) {
              return CustomConfirmDialog(confirmMessage: _locale.urlError);
            },
          ).then((value) async {
            if (value == true) {
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
          });
        } else {
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
      });
    } else {
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
  }

  Widget dropDownUsers() {
    return TestDropdown(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      cleanPrevSelectedItem: false,
      isEnabled: !widget.isChangePassword,
      showSearchBox: true,
      selectedList: userDeptsList ?? [],
      onClearIconPressed: () {
        setState(() {
          userDeptsList = [];
          hintUsers = "";
        });
      },
      onChanged: (value) {
        setState(() {
          userDeptsList = (value ?? [])
              .whereType<DepartmentModel>()
              .toList();

          hintUsers = userDeptsList!.isNotEmpty
              ? userDeptsList!.map((e) => e.txtDescription).join(", ")
              : "";
        });
      },
      stringValue: hintUsers,
      borderText: _locale.department,
      onSearch: (text) async {
        return DepartmentController()
            .getDep(SearchModel(page: 1, searchField: text));
      },
    );
  }
}
