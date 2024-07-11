import 'dart:typed_data';

import 'package:archiving_flutter_project/models/db/user_models/update_user_password_model.dart';
import 'package:archiving_flutter_project/service/controller/users_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart'; // Import this for TextInputFormatter

import '../dialogs/error_dialgos/show_error_dialog.dart';
import '../service/controller/error_controllers/error_controller.dart';
import '../utils/constants/colors.dart';
import '../utils/encrypt/encryption.dart';
import '../utils/func/responsive.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  double width = 0;
  double height = 0;
  bool isDesktop = false;
  late AppLocalizations _locale;
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();

  double radius = 7;
  FocusNode userNameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  bool obscureOldPassword = true;
  bool obscureNewPassword = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
    isDesktop = Responsive.isDesktop(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_locale.changePassword),
      ),
      body: Center(
        child: Container(
          width: isDesktop ? width * 0.5 : width * 0.9,
          height: height * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height * 0.032),
                customTextField(_locale.oldPass, oldPasswordController,
                    passwordFocus, true, isDesktop, obscureOldPassword),
                SizedBox(height: height * 0.032),
                customTextField(_locale.newPass, newPasswordController,
                    passwordFocus, true, isDesktop, obscureNewPassword),
                SizedBox(height: height * 0.032),
                customSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox space() {
    return SizedBox(
      height: height * 0.032,
    );
  }

  Widget customSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        fixedSize: Size(isDesktop ? width * 0.28 : width * 0.8, 45),
        backgroundColor: primary,
        foregroundColor: whiteColor,
        textStyle: const TextStyle(fontSize: 18),
      ),
      onPressed: () {
        save();
      },
      child: Center(
        child: Text(
          _locale.save,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void save() async {
    if (newPasswordController.text.contains(' ') ||
        oldPasswordController.text.contains(' ')) {
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
              icon: Icons.error,
              errorDetails: _locale.noSpacesAllowed,
              errorTitle: _locale.error,
              color: Colors.red,
              statusCode: 400);
        },
      );
      return;
    }

    String key = "archiveProj@s2024ASD/Key@team.CT";
    final iv = [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1];
    final byteArray =
        Uint8List.fromList(iv.map((bit) => bit == 1 ? 0x01 : 0x00).toList());
    String passEncrypted = Encryption.performAesEncryption(
        oldPasswordController.text.trim(), key, byteArray);
    String passEncryptedNew = Encryption.performAesEncryption(
        newPasswordController.text.trim(), key, byteArray);
    UpdateUserPassword updateUserPassword = UpdateUserPassword(
        oldPassword: passEncrypted, password: passEncryptedNew);
    var response =
        await UserController().updateCurrentUserPassword(updateUserPassword);
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
        oldPasswordController.clear();
        newPasswordController.clear();
      });
    }
    // else if (response.statusCode == 400 || response.statusCode == 406) {
    //   // Navigator.pop(context);

    //   ErrorController.dialogBasedonResponseStatus(
    //       Icons.warning, _locale.wrongPass, _locale.wrongPass, Colors.red, 400);
    // }
  }

  Widget customTextField(String hint, TextEditingController controller,
      FocusNode focus, bool isPassword, bool isDesktop, bool obscureText) {
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
        width: isDesktop ? width * 0.28 : width * 0.8,
        height: height * 0.07,
        child: TextFormField(
          autofocus: focus == userNameFocus ? true : false,
          // focusNode: focus,
          onFieldSubmitted: (value) {
            if (userNameFocus.hasFocus) {
              passwordFocus.requestFocus();
            } else {}
          },
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
                            if (controller == oldPasswordController) {
                              obscureOldPassword = !obscureOldPassword;
                            } else if (controller == newPasswordController) {
                              obscureNewPassword = !obscureNewPassword;
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
                            if (controller == oldPasswordController) {
                              obscureOldPassword = !obscureOldPassword;
                            } else if (controller == newPasswordController) {
                              obscureNewPassword = !obscureNewPassword;
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
}
