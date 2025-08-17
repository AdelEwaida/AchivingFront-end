// ignore_for_file: use_build_context_synchronously

import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/service/controller/login_controllers/login_controller.dart';
import 'package:archiving_flutter_project/utils/constants/key.dart';
import 'package:archiving_flutter_project/utils/encrypt/encryption.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';

class ErrorController {
  static bool temp = false;
  static openErrorDialog(
    int responseStatus,
    String errorDetails,
    // {ErorrDTO? erorrDto}
  ) async {
    final context = navigatorKey.currentState!.overlay!.context;
    AppLocalizations locale = AppLocalizations.of(context)!;
    // if (erorrDto != null) {
    //   errorDetails =
    //       getErorrDetailsByLang(locale.localeName, erorrDto.langDesc!);
    //   if (responseStatus == 401) {
    //     dialogBasedonResponseStatus(
    //         Icons.error, errorDetails, erorrDto.serialNumber!, Colors.red, 401);
    //   } else {
    //     dialogBasedonResponseStatus(
    //         Icons.error, errorDetails, erorrDto.serialNumber!, Colors.red, 407);
    //   }
    // }
    print("responseStatusresponseStatus ${responseStatus}");
    if (responseStatus == 400) {
      dialogBasedonResponseStatus(Icons.warning, errorDetails, errorDetails,
          const Color.fromARGB(255, 232, 232, 23), 400);
    } else if (responseStatus == 200) {
      dialogBasedonResponseStatus(Icons.done, errorDetails, errorDetails,
          const Color.fromARGB(255, 81, 237, 4), 200);
    } else if (responseStatus == 401) {
      dialogBasedonResponseStatus(Icons.warning, errorDetails, errorDetails,
          Color.fromARGB(255, 237, 4, 4), 401);
    } else if (responseStatus == 405) {
      dialogBasedonResponseStatus(Icons.warning, errorDetails, errorDetails,
          const Color.fromARGB(255, 232, 232, 23), 405);
    } else if (responseStatus == 500) {
      dialogBasedonResponseStatus(
          Icons.error, errorDetails, locale.error500, Colors.red, 500);
    } else if (responseStatus == 406) {
      dialogBasedonResponseStatus(
          Icons.error, errorDetails, locale.error406, Colors.red, 406);
    } else if (responseStatus == 204) {
      dialogBasedonResponseStatus(Icons.warning, errorDetails, errorDetails,
          const Color.fromARGB(255, 232, 232, 23), 204);
    } else if (responseStatus == 404) {
      dialogBasedonResponseStatus(Icons.warning, errorDetails, errorDetails,
          const Color.fromARGB(255, 232, 232, 23), 404);
    } else if (responseStatus == 3) {
      dialogBasedonResponseStatus(
          Icons.warning, '', locale.alreadyOppened, Colors.orange, 0);
    } else if (responseStatus == 0 && !ErrorController.temp) {
      ErrorController.temp = true;
      dialogBasedonResponseStatus(
          Icons.warning, errorDetails, locale.networkError, Colors.red, 0);
    } else if (responseStatus == 1) {
      dialogBasedonResponseStatus(
          Icons.warning, errorDetails, locale.dateConflict, Colors.red, 0);
    } else if (responseStatus == 2) {
      dialogBasedonResponseStatus(
          Icons.warning, errorDetails, locale.timeConflict, Colors.red, 0);
    } else if (responseStatus == 4) {
      dialogBasedonResponseStatus(
          Icons.warning, '', locale.alreadyOppened, Colors.orange, 0);
    }
  }

  // static String getErorrDetailsByLang(
  //     String lang, Map<String, ErrorDesc> erorr) {
  //   return erorr[lang]!.description ?? "";
  // }

  //dialog detail
  static dialogBasedonResponseStatus(IconData icon, String errorDetails,
      String errorTitle, Color color, int statusCode) async {
    final context = navigatorKey.currentState!.overlay!.context;
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'jwt');
    // String? token = html.window.sessionStorage['jwt'];

    if (statusCode == 401 && token != null ||
        (statusCode == 401 && token == null && !ErrorController.temp)) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (builder) {
          return ErrorDialog(
            icon: icon,
            errorDetails: errorDetails,
            errorTitle: errorTitle,
            color: color,
            statusCode: statusCode,
          );
        },
      ).then((value) async {
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // String userCode = prefs.get("userName").toString();
        // String key = "scope@e2024A/key@team.CT";
        // final iv = [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1];
        // final byteArray = Uint8List.fromList(
        //     iv.map((bit) => bit == 1 ? 0x01 : 0x00).toList());
        // String userCodeEnc =
        //     Encryption.performAesEncryption(userCode, key, byteArray);
        // await LoginController().logOutPost(
        //     LogoutModel(txtCode: userCodeEnc), AppLocalizations.of(context)!);

        ErrorController.temp = true;
      });
    } else if (statusCode != 401) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (builder) {
          return ErrorDialog(
            icon: icon,
            errorDetails: errorDetails,
            errorTitle: errorTitle,
            color: color,
            statusCode: statusCode,
          );
        },
      ).then((value) async {
        ErrorController.temp = false;
      });
    }
  }
}
