import 'dart:convert';
import 'dart:js';

import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/payload_model.dart';
import 'package:archiving_flutter_project/models/dto/login_model.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/service/controller/error_controllers/error_controller.dart';
import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:archiving_flutter_project/utils/constants/api_constants.dart';
import 'package:archiving_flutter_project/utils/constants/key.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class LoginController {
  final storage = const FlutterSecureStorage();

  Future<bool> logInWithOutPass(
      LogInModel userModel, AppLocalizations local) async {
    String? token = await storage.read(key: 'jwt');
    String? url = await storage.read(key: 'url');
    String api = "$url/${logInWitoutPassApi}";
    print("userModel.toJson() ${userModel.toJson()}");
    var response = await http.post(
      Uri.parse(api),
      headers: {
        "Accept": "application/json",
        "Content-type": "application/json",
        // "Authorization": "Bearer $token"
      },
      body: json.encode(userModel.toJson()),
    );
    bool responseStatus = false;
    if (response.statusCode == 200) {
      String token = response.body.substring(8, response.body.length - 2);
      const storage = FlutterSecureStorage();
      await storage.write(key: 'jwt', value: token);

      final encodedPayload = token.split('.')[1];
      final payloadData =
          utf8.fuse(base64).decode(base64.normalize(encodedPayload));
      // final context2 = navigatorKey.currentState!.overlay!.context;

      final payLoad = PayloadModel.fromJson(jsonDecode(payloadData));

      storage.write(key: 'roles', value: payLoad.roles![0]);
      if (payLoad.roles![1] == "refUser") {
        // ignore: use_build_context_synchronously
        storage.write(key: 'isView', value: "true");
      }
      // SideMenuDate.userType = int.parse(payLoad.roles!.first);
      // storage.write(key: 'roles', value: SideMenuDate.userType.toString());
      responseStatus = true;
      return responseStatus;
    } else if (response.statusCode == 406) {
      // final context = navigatorKey.currentState!.overlay!.context;
      // // ignore: use_build_context_synchronously
      // // ignore: use_build_context_synchronously
      // await showDialog(
      //   barrierDismissible: false,
      //   context: context,
      //   builder: (builder) {
      //     return ErrorDialog(
      //       icon: Icons.warning,
      //       errorDetails: "",
      //       errorTitle: AppLocalizations.of(context)!.accountAlreadyLoggedIn,
      //       color: Colors.red,
      //       statusCode: 402,
      //     );
      //   },
      // ).then((value) async {
      //   if (value) {
      //     userModel.force = 1;
      //     responseStatus = await logInPost(userModel, local);
      //   } else {
      //     final context = navigatorKey.currentState!.overlay!.context;

      //     // Navigator.pop(context);
      //   }
      // });
    } else {
      // final context = navigatorKey.currentState!.overlay!.context;
      // // Navigator.pop(context);

      // if (response.statusCode == 400 || response.statusCode == 406) {
      //   // Navigator.pop(context);

      //   ErrorController.dialogBasedonResponseStatus(Icons.warning,
      //       local.worningPassOrEmeail, local.wrongInput, Colors.red, 400);
      // }
    }
    return responseStatus;
  }

  Future<bool> logInPost(LogInModel userModel, AppLocalizations local) async {
    String api = logInApi;
    var response = await ApiService().postRequest(api, userModel.toJson());
    bool responseStatus = false;
    if (response.statusCode == 200) {
      String token = response.body.substring(8, response.body.length - 2);
      const storage = FlutterSecureStorage();
      await storage.write(key: 'jwt', value: token);

      final encodedPayload = token.split('.')[1];
      final payloadData =
          utf8.fuse(base64).decode(base64.normalize(encodedPayload));

      final payLoad = PayloadModel.fromJson(jsonDecode(payloadData));
      DateTime expDateTime =
          DateTime.fromMillisecondsSinceEpoch(payLoad.exp! * 1000);
      await storage.write(key: "expDate", value: expDateTime.toString());
      await storage.write(key: 'roles', value: payLoad.roles![0]);

      // SideMenuDate.userType = int.parse(payLoad.roles!.first);
      // storage.write(key: 'roles', value: SideMenuDate.userType.toString());
      print(payLoad.toJson());
      responseStatus = true;
      return responseStatus;
    } else if (response.statusCode == 402) {
      final context = navigatorKey.currentState!.overlay!.context;
      // ignore: use_build_context_synchronously
      // ignore: use_build_context_synchronously
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (builder) {
          return ErrorDialog(
            icon: Icons.warning,
            errorDetails: "",
            errorTitle: AppLocalizations.of(context)!.accountAlreadyLoggedIn,
            color: Colors.red,
            statusCode: 402,
          );
        },
      ).then((value) async {
        if (value) {
          userModel.force = 1;
          responseStatus = await logInPost(userModel, local);
        } else {
          final context = navigatorKey.currentState!.overlay!.context;

          // Navigator.pop(context);
        }
      });
    } else {
      final context = navigatorKey.currentState!.overlay!.context;
      // Navigator.pop(context);

      if (response.statusCode == 400 || response.statusCode == 406) {
        // Navigator.pop(context);

        ErrorController.dialogBasedonResponseStatus(Icons.warning,
            local.worningPassOrEmeail, local.wrongInput, Colors.red, 400);
      }
    }
    return responseStatus;
  }

  // Future logOutPost(LogoutModel userModel, AppLocalizations local) async {
  //   String api = logOutApi;

  //   return await ApiService().putRequest(api, userModel.toJson());
  //   // var response = await ApiService().putRequest(api, userModel.toJson());
  //   // if (response == 200) {
  //   //   return true;
  //   // }
  //   // return false;
  // }

  // Future<void> logOut(AppLocalizations locale) async {
  //   final context = navigatorKey.currentState!.overlay!.context;
  //   const storage = FlutterSecureStorage();

  //   LogInModel userModel = LogInModel("", "");
  //   // await LoginController().logOutPost(userModel, locale).then((value) async {
  //   //   await storage.delete(key: "jwt").then((value) {
  //   //     if (kIsWeb) {
  //   //       context.read<TabsProvider>().emptyAll();
  //   //       GoRouter.of(context).go(loginScreenRoute);
  //   //     } else {
  //   //       context.read<TabsProvider>().emptyAll();
  //   //       Navigator.pushReplacementNamed(context, loginScreenRoute);
  //   //     }
  //   //   });
  //   // });
  // }
}
