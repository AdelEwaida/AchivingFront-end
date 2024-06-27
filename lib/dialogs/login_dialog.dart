import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/dto/login_model.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/service/controller/login_controllers/login_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../utils/constants/routes_constant.dart';
import '../utils/encrypt/encryption.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({
    super.key,
  });

  @override
  State createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  late AppLocalizations _locale;
  double radius = 7;
  LoginController loginController = LoginController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  bool obsecureText = true;
  Color leftBackColor = const Color.fromRGBO(16, 184, 249, 1);
  Color rightBackColor = const Color.fromRGBO(64, 144, 247, 1);

  @override
  Future<void> didChangeDependencies() async {
    _locale = AppLocalizations.of(context)!;
    const storage = FlutterSecureStorage();
    await storage.read(key: "userName").then((value) {
      emailController.text = value!;
    });
    // storage.write(key: "userName", value: _userNameController.text);
    super.didChangeDependencies();
  }

  // void _handleKey(RawKeyEvent event) {
  //   if (event is RawKeyDownEvent) {
  //     if (event.logicalKey == LogicalKeyboardKey.enter) {
  //       Navigator.pop(context, true);
  //     }
  //   }
  // }

  double dialogWidth = 0;
  double dialogHeight = 0;
  @override
  Widget build(BuildContext context) {
    dialogWidth = MediaQuery.of(context).size.width;
    dialogHeight = MediaQuery.of(context).size.height;
    bool isDesktop = Responsive.isDesktop(context);

    return RawKeyboardListener(
      focusNode: FocusNode(),
      child: Dialog(
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: dialogWidth * 0.37,
          height: dialogHeight * 0.9,
          child: Column(
            children: [
              SizedBox(
                height: dialogHeight * 0.23,
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Color.fromARGB(255, 237, 34, 20)),
                            child: IconButton(
                                onPressed: () async {
                                  if (kIsWeb) {
                                    // context.read<TabsProvider>().emptyAll();
                                    GoRouter.of(context).go(loginScreenRoute);
                                  } else {
                                    // context.read<TabsProvider>().emptyAll();
                                    Navigator.pushReplacementNamed(
                                        context, loginScreenRoute);
                                  }
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Image.asset(
                            "assets/images/expired2.png",
                            width: isDesktop
                                ? dialogWidth * 0.076
                                : dialogWidth * 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: dialogHeight * 0.1,
              ),
              loginText(),
              SizedBox(
                height: dialogHeight * 0.04,
              ),
              customTextField(
                _locale.email,
                emailController,
                emailFocus,
                false,
                isDesktop,
              ),
              customTextField(
                _locale.password,
                passwordController,
                passwordFocus,
                true,
                isDesktop,
              ),
              SizedBox(
                height: dialogHeight * 0.05,
              ),
              customSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginText() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _locale.expiredSessionLoginDialog,
        style: const TextStyle(
          fontSize: 20,
          shadows: [Shadow(color: Colors.black, offset: Offset(0, -25))],
          color: Colors.transparent,
          decoration: TextDecoration.underline,
          decorationColor: primary,
          decorationThickness: 2,
        ),
      ),
    );
  }

  Widget customTextField(String hint, TextEditingController controller,
      FocusNode focus, bool isPassword, bool isDesktop) {
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
        width: isDesktop ? dialogWidth * 0.3 : dialogWidth * 0.8,
        height: 60,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: TextFormField(
            readOnly: !isPassword,
            autofocus: focus == passwordFocus ? true : false,
            focusNode: focus,
            onFieldSubmitted: (value) {
              if (emailFocus.hasFocus) {
                passwordFocus.requestFocus();
              } else {
                passwordAndEmailCheck();
              }
            },
            controller: controller,
            style: const TextStyle(
              fontSize: 18,
            ),
            obscureText: isPassword ? obsecureText : false,
            decoration: InputDecoration(
              suffixIcon: isPassword
                  ? obsecureText
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              obsecureText = obsecureText ? false : true;
                            });
                          },
                          icon: const Icon(
                            Icons.visibility_off,
                            color: primary,
                            size: 28,
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              obsecureText = obsecureText ? false : true;
                            });
                          },
                          icon: const Icon(
                            Icons.visibility,
                            color: primary,
                            size: 28,
                          ),
                        )
                  : null,
              border: InputBorder.none,
              hintText: hint,
            ),
          ),
        ),
      ),
    );
  }

  Widget customSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(200, 50),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 18),
      ),
      onPressed: () {
        passwordAndEmailCheck();
      },
      child: Center(
        child: Text(
          _locale.signIn,
        ),
      ),
    );
  }

  passwordAndEmailCheck() {
    if (emailController.text.trim().isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              icon: Icons.error,
              errorTitle: _locale.error,
              errorDetails: _locale.emailReq,
              color: Colors.red,
              statusCode: 100,
              // image: const AssetImage("assets/images/lock.gif"),
              // text: _locale.emailReq,
            );
          }).then((value) {
        emailFocus.requestFocus();
      });
    } else if (passwordController.text.trim().isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              icon: Icons.error,
              errorTitle: _locale.error,
              errorDetails: _locale.passReqField,
              color: Colors.red,
              statusCode: 100,
              // image: const AssetImage("assets/images/lock.gif"),
              // text: _locale.emailReq,
            );
          }).then((value) {
        passwordFocus.requestFocus();
      });
    } else {
      logIn();
    }
  }

  bool checkIfEmailEmpty() {
    if (emailController.text.isEmpty || emailController.text == "") {
      return true;
    }
    return false;
  }

  bool checkIfPasswordEmpty() {
    if (passwordController.text.isEmpty || passwordController.text == "") {
      return true;
    }
    return false;
  }

  logIn() async {
    openLoadinDialog();
    String key = "archiveProj@s2024ASD/Key@team.CT";
    final iv = [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1];
    final byteArray =
        Uint8List.fromList(iv.map((bit) => bit == 1 ? 0x01 : 0x00).toList());
    String passEncrypted = Encryption.performAesEncryption(
        passwordController.text, key, byteArray);
    String emailEncrypted =
        Encryption.performAesEncryption(emailController.text, key, byteArray);

    LogInModel userModel = LogInModel(emailEncrypted, passEncrypted);
    const storage = FlutterSecureStorage();
    storage.write(key: "userName", value: emailController.text);
    await LoginController()
        .logInPost(userModel, AppLocalizations.of(context)!)
        .then((value) async {
      if (value) {
        Navigator.pop(context, true);
        Navigator.pop(context, true);
        // context
        //     .read<ScreenContentProvider>()
        //     .setPage1(context.read<ScreenContentProvider>().getPage());
        // storage.setString("userName", _userNameController.text);
        GoRouter.of(context).go(mainScreenRoute);
      } else {
        Navigator.pop(context);
      }
    });
    // print(userModel.toJson());
    // GoRouter.of(context).go(mainScreenRoute);
    // openLoadinDialog();
    // await loginController.logInPost(userModel, _locale).then((value) async {
    //   if (value) {
    //     SharedPreferences prefs = await SharedPreferences.getInstance();
    //     prefs.setString("userName", emailController.text);
    //     if (kIsWeb) {
    //       GoRouter.of(context).go(mainScreenRoute);
    //       // tabsProvider.changeActiveWidget(1, _locale);
    //     } else {
    //       Navigator.pop(context);
    //       Navigator.pushReplacementNamed(context, mainScreenRoute);
    //       // tabsProvider.changeActiveWidget(1, _locale);
    //     }
    //     //  tabsProvider.changeActiveWidget(1, _locale);
    //   }
    // });
  }

  void openLoadinDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (builder) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            ],
          );
        });
  }
}
