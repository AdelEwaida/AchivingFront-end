import 'dart:convert';

import 'package:archiving_flutter_project/models/dto/login_model.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/screens/home_page.dart';
import 'package:archiving_flutter_project/screens/log_in.dart';
import 'package:archiving_flutter_project/service/controller/login_controllers/login_controller.dart';
import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:archiving_flutter_project/utils/constants/assets_path_constants.dart';
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
import 'dart:html' as html;

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
      ]);

  static Future<String?> _redirect(BuildContext context, String path) async {
    final checkResult = await checkUrlParameters(context);

    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'jwt');
    String? expDate = await storage.read(key: "expDate");
    if (expDate != null) {
      DateTime tempExpDate = DateTime.parse(expDate!);
      if (DateTime.now().isAfter(tempExpDate)) {
        return loginScreenRoute;
      }
    }

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
      if (type == 1) {
        await viewMethod(context, queryParams);
      } else if (type == 0) {
        await scanMethod(context, queryParams);
      }
    }
    return null;
  }

  static scanMethod(
      BuildContext context, Map<String, String> queryParams) async {
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
    const storage = FlutterSecureStorage();

    Uri uri = Uri.parse(url);

    String? desc = uri.queryParameters['DOCN_NAME_EN'];
    fileListProvider.setDescription(desc ?? "");

    String? fld1Param = uri.queryParameters['FLD_1'];
    fileListProvider.setIssueNumber(fld1Param ?? "");

    String? userName = uri.queryParameters['DUN'];
    String emailEncrypted =
        Encryption.performAesEncryption(userName ?? '', key, byteArray);
    storage.write(key: "userName", value: userName ?? "");

    var response = await LoginController().logInWithOutPass(
        LogInModel(emailEncrypted, ""), AppLocalizations.of(context)!);

    if (response) {
      fileListProvider.setIsViewFile(true);
      screenContentProvider.setPage1(7);
      return mainScreenRoute;
    } else {
      fileListProvider.setIsViewFile(true);
      screenContentProvider.setPage1(20);
    }
  }

  static viewMethod(
      BuildContext context, Map<String, String> queryParams) async {
    await loadApi();
    late ScreenContentProvider screenContentProvider;
    late DocumentListProvider fileListProvider;
    // ignore: use_build_context_synchronously
    screenContentProvider = context.read<ScreenContentProvider>();
    // ignore: use_build_context_synchronously
    fileListProvider = context.read<DocumentListProvider>();

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

    const storage = FlutterSecureStorage();

    storage.write(key: "userName", value: userName);

    var response = await LoginController().logInWithOutPass(
        LogInModel(emailEncrypted, ""), AppLocalizations.of(context)!);
    print("responseresponse ${response}");
    if (response) {
      fileListProvider.setIsViewFile(true);

      fileListProvider.setIssueNumber(fld1Param ?? "");

      screenContentProvider.setPage1(6);

      return mainScreenRoute;
    } else {
      fileListProvider.setIsViewFile(true);

      screenContentProvider.setPage1(20);

      return;
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

  Future<void> loadApiConfig() async {
    const storage = FlutterSecureStorage();

    await rootBundle.loadString(centralApiPathConstant).then((value) async {
      ApiService.urlServer = value.trim();
      print("✅ ApiService.urlServer loaded: ${ApiService.urlServer}");
      await storage.write(key: 'url', value: ApiService.urlServer);
    });

    await rootBundle.loadString(centralApiPDFPathConstant).then((value) async {
      await storage.write(key: 'urlPdf', value: value.trim());
    });

    await rootBundle
        .loadString(centralApiWhatsAppPathConstant)
        .then((value) async {
      ApiService.whatsAppServer = value.trim();
      print("✅ ApiService.whatsAppServer loaded: ${ApiService.whatsAppServer}");
      await storage.write(key: 'whatsAppService', value: value.trim());
    });

    await rootBundle
        .loadString(centralApiEmailPathConstant)
        .then((value) async {
      ApiService.emailServer = value.trim();
      await storage.write(key: 'email', value: value.trim());
    });
  }

  static Future<String?> _redirect2(BuildContext context, String path) async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'jwt');
    // String? token = html.window.sessionStorage['jwt'];
    return mainScreenRoute;
  }
}
