import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/models/dto/login_model.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/screens/home_page.dart';
import 'package:archiving_flutter_project/screens/log_in.dart';
import 'package:archiving_flutter_project/service/controller/login_controllers/login_controller.dart';
import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:archiving_flutter_project/utils/constants/assets_path_constants.dart';
import 'package:archiving_flutter_project/utils/constants/loading.dart';
import 'package:archiving_flutter_project/utils/encrypt/encryption.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/constants/key.dart';
import '../../utils/constants/routes_constant.dart';

class AppRoutes {
  static String currentRoute = "/";
  static final GoRouter routes = GoRouter(
      onException: (BuildContext context, state, goRouter) =>
          const LoginScreen(),
      navigatorKey: navigatorKey,
      initialLocation: loginScreenRoute,
      routes: <GoRoute>[
        GoRoute(
          path: loginScreenRoute,
          builder: (BuildContext context, state) => const LoginScreen(),
          redirect: (context, state) => _redirect(context, loginScreenRoute),
        ),
        GoRoute(
          path: mainScreenRoute,
          builder: (_, state) => const HomePage(),
          redirect: (context, state) => _redirect(context, mainScreenRoute),
        ),
        // GoRoute(
        //   path: officesScreenRoute,
        //   builder: (context, state) => const OfficeScreen(),
        //   redirect: (context, state) => _redirect(context, officesScreenRoute),
        // ),
        // GoRoute(
        //   path: usersScreenRoute,
        //   builder: (context, state) => const UsersScreen(),
        //   redirect: (context, state) => _redirect(context, usersScreenRoute),
        // )
      ]);

  static Future<String?> _redirect(BuildContext context, String path) async {
    final checkResult = await checkUrlParameters(context);
    // if (checkResult != null) {
    //   const storage = FlutterSecureStorage();

    //   String? tok = await storage.read(key: "jwt");
    //   print("toooooooooookkkk ${tok}");
    //   return checkResult;
    // }

    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'jwt');

    return token != null ? mainScreenRoute : loginScreenRoute;
  }

  static Future<String?> checkUrlParameters(BuildContext context) async {
    String url = html.window.location.href;
    Uri uri = Uri.parse(url);

    const storage = FlutterSecureStorage();

    if (uri.queryParameters.isNotEmpty) {
      Map<String, String> queryParams = uri.queryParameters;

      queryParams.forEach((key, value) {
        print('Query Parameter: $key = $value');
      });

      int? type = int.parse(uri.queryParameters['op'] ?? "0");
      // if (fld1Param != null && fld1Param.isNotEmpty) {
      if (type == 1) {
        await viewMethod(context, queryParams);
        // String? tok = await storage.read(key: "jwt");
        // print("toooooooooookkkk ${tok}");
      } else if (type == 0) {
        await scanMethod(context, queryParams);
      }
      // print('L Parameter: $lParam');
      // print('FLD_1 Parameter: $fld1Param');
      // }
    }
    return null;
  }

  static scanMethod(
      BuildContext context, Map<String, String> queryParams) async {
    // openLoadinDialog(context);
    await loadApi();
    late ScreenContentProvider screenContentProvider;
    late DocumentListProvider fileListProvider;
    screenContentProvider = context.read<ScreenContentProvider>();
    fileListProvider = context.read<DocumentListProvider>();
    String key = "archiveProj@s2024ASD/Key@team.CT";
    final iv = [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1];
    final byteArray =
        Uint8List.fromList(iv.map((bit) => bit == 1 ? 0x01 : 0x00).toList());
    String url = html.window.location.href;

    Uri uri = Uri.parse(url);
    String? desc = uri.queryParameters['DOCN_NAME_EN'];
    String? lParam = uri.queryParameters['L'];
    String? fld1Param = uri.queryParameters['FLD_1'];
    String? userName = uri.queryParameters['DUN'];
    String emailEncrypted =
        Encryption.performAesEncryption(userName ?? '', key, byteArray);

    var response = await LoginController().logInWithOutPass(
        LogInModel(emailEncrypted, ""), AppLocalizations.of(context)!);
    if (response) {
      fileListProvider.setDescription(desc!);
      fileListProvider.setIssueNumber(fld1Param!);
      screenContentProvider.setPage1(7);
      // ignore: use_build_context_synchronously
      // Navigator.pop(context);
      // GoRouter.of(context).go(mainScreenRoute);
      return mainScreenRoute;
    }
  }

  static viewMethod(
      BuildContext context, Map<String, String> queryParams) async {
    await loadApi();
    late ScreenContentProvider screenContentProvider;
    late DocumentListProvider fileListProvider;
    screenContentProvider = context.read<ScreenContentProvider>();
    fileListProvider = context.read<DocumentListProvider>();
    fileListProvider.setIsViewFile(true);

    String key = "archiveProj@s2024ASD/Key@team.CT";
    final iv = [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1];
    final byteArray =
        Uint8List.fromList(iv.map((bit) => bit == 1 ? 0x01 : 0x00).toList());
    String url = html.window.location.href;

    Uri uri = Uri.parse(url);

    String? lParam = uri.queryParameters['L'];
    String? fld1Param = uri.queryParameters['FLD_1'];
    String? userName = uri.queryParameters['DUN'];
    String emailEncrypted =
        Encryption.performAesEncryption(userName ?? '', key, byteArray);

    var response = await LoginController().logInWithOutPass(
        LogInModel(emailEncrypted, ""), AppLocalizations.of(context)!);

    if (response) {
      fileListProvider.setIssueNumber(fld1Param!);
      screenContentProvider.setPage1(16);

      // GoRouter.of(context).go(mainScreenRoute);

      return mainScreenRoute;
    }
  }

  static Future<void> loadApi() async {
    const storage = FlutterSecureStorage();

    await rootBundle.loadString(centralApiPathConstant).then((value) async {
      ApiService.urlServer = value.trim();
      await storage.write(key: 'url', value: ApiService.urlServer);
    });
    await rootBundle.loadString(centralApiPDFPathConstant).then((value) async {
      await storage.write(key: 'urlPdf', value: value.trim());
    });
  }

  static Future<String?> _redirect2(BuildContext context, String path) async {
    const storage = FlutterSecureStorage();
    // String? token = await storage.read(key: 'jwt');
    String? token = await storage.read(key: 'jwt');
    print("INREEDIRCTT");
    return mainScreenRoute;
  }
}
