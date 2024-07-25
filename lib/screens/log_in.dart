import 'dart:typed_data';
import 'dart:ui';

import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/dto/login_model.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/providers/local_provider.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/service/controller/login_controllers/login_controller.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/routes_constant.dart';
import 'package:archiving_flutter_project/utils/encrypt/encryption.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/widget/language_widget/language_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

import '../widget/curve_clipper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double width = 0;
  double height = 0;
  late AppLocalizations _locale;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  double radius = 7;
  FocusNode userNameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  bool obsecureText = true;
  late LocaleProvider localeProvider;

  @override
  void didChangeDependencies() {
    _locale = AppLocalizations.of(context)!;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isDesktop = false;

  @override
  Widget build(BuildContext context) {
    isDesktop = Responsive.isDesktop(context);
    localeProvider = Provider.of<LocaleProvider>(context);

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    // checkUrlParameters();

    return Scaffold(
      body: Responsive(
        mobile: mobileView(),
        tablet: tabletView(),
        desktop: desktopView(),
      ),
    );
  }

  Widget imageBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            // shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/images/folders.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Positioned.fill(
        //   child: BackdropFilter(
        //     filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        //     child: Container(
        //       color: Colors.transparent,
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget imageSection() {
    return ClipPath(
      clipper: CurveClipper(),
      child: Stack(
        children: [
          SizedBox(
            width: width * 0.5,
            height: height * 1,
            child: imageBackground(),
          ),
          // Container(
          //   width: width * 0.25,
          //   height: height * 1,
          //   color: Colors.white,
          // )
        ],
      ),
    );
  }

  Widget formSection(double widthFactor, double heightFactor) {
    return Container(
      width: width * widthFactor,
      height: height * heightFactor,
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
            logo(),
            space(),
            Text(
              _locale.archivingSystem,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            space(),
            customTextField(_locale.userCode, _userNameController,
                userNameFocus, false, isDesktop),
            space(),
            customTextField(_locale.password, _passwordController,
                passwordFocus, true, isDesktop),
            space(),
            customSubmitButton()
          ],
        ),
      ),
    );
  }

  SizedBox space() {
    return SizedBox(
      height: height * 0.032,
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
        width: isDesktop ? width * 0.28 : width * 0.8,
        height: height * 0.07,
        child: TextFormField(
          autofocus: focus == userNameFocus ? true : false,
          focusNode: focus,
          onFieldSubmitted: (value) {
            if (userNameFocus.hasFocus) {
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
                        alignment: Alignment.centerLeft,
                        onPressed: () {
                          setState(() {
                            obsecureText = !obsecureText;
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
                            obsecureText = !obsecureText;
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

  languageWidget() {
    return LanguageWidget(
      color: Colors.white,
      onLocaleChanged: (locale) {
        localeProvider.setLocale(locale);
      },
    );
  }

  Container logo() {
    return Container(
      alignment: Alignment.topCenter,
      child: Image.asset(
        'assets/images/logo.png',
        width: width * 0.15,
        height: height * 0.13,
      ),
    );
  }

  Widget customSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        fixedSize: Size(isDesktop ? width * 0.28 : width * 0.8, 50),
        backgroundColor: primary3,
        foregroundColor: whiteColor,
        textStyle: const TextStyle(fontSize: 18),
      ),
      onPressed: () {
        passwordAndEmailCheck();
      },
      child: Center(
        child: Text(
          _locale.signIn,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  passwordAndEmailCheck() {
    if (_userNameController.text.trim().isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              icon: Icons.error,
              errorTitle: _locale.error,
              errorDetails: _locale.emailReq,
              color: Colors.red,
              statusCode: 100,
            );
          }).then((value) {
        userNameFocus.requestFocus();
      });
    } else if (_passwordController.text.trim().isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              icon: Icons.error,
              errorTitle: _locale.error,
              errorDetails: _locale.passReqField,
              color: Colors.red,
              statusCode: 100,
            );
          }).then((value) {
        passwordFocus.requestFocus();
      });
    } else {
      logIn();
    }
  }

  logIn() async {
    // GoRouter.of(context).go(mainScreenRoute);

    openLoadinDialog();
    String key = "archiveProj@s2024ASD/Key@team.CT";
    final iv = [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1];
    final byteArray =
        Uint8List.fromList(iv.map((bit) => bit == 1 ? 0x01 : 0x00).toList());
    String passEncrypted = Encryption.performAesEncryption(
        _passwordController.text, key, byteArray);
    String emailEncrypted = Encryption.performAesEncryption(
        _userNameController.text, key, byteArray);
    print(passEncrypted);
    print(emailEncrypted);
    LogInModel userModel = LogInModel(emailEncrypted, passEncrypted);
    const storage = FlutterSecureStorage();

    storage.write(key: "userName", value: _userNameController.text);

    await LoginController()
        .logInPost(userModel, AppLocalizations.of(context)!)
        .then((value) async {
      if (value) {
        Navigator.pop(context);
        GoRouter.of(context).go(mainScreenRoute);
      } else {
        Navigator.pop(context);
      }
    });
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

  Widget mobileView() {
    return Stack(
      children: [
        imageBackground(),
        Center(
          child: formSection(0.7, 0.48),
        ),
      ],
    );
  }

  Widget tabletView() {
    return Stack(
      children: [
        imageBackground(),
        Center(
          child: formSection(0.5, 0.48),
        ),
      ],
    );
  }

  Widget desktopView() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          imageSection(),
          Expanded(
            child: Center(
              child: formSection(0.34, 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
