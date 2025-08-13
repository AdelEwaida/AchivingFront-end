import 'dart:convert';

import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/user_models/department_user_model.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/models/dto/login_model.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/screens/home_page.dart';
import 'package:archiving_flutter_project/screens/log_in.dart';
import 'package:archiving_flutter_project/service/controller/login_controllers/login_controller.dart';
import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:archiving_flutter_project/utils/constants/api_constants.dart';
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

import '../../service/controller/work_flow_controllers/setup_controller.dart';
import '../../service/handler/token_store.dart';
import '../../utils/constants/key.dart';
import '../../utils/constants/routes_constant.dart';
import '../../utils/constants/storage_keys.dart';

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
    // 1) لو فيه بارامترات في الرابط (scan/view)، نفّذها أولاً
    final checked = await checkUrlParameters(context);
    if (checked != null) return checked;

    // 2) اقرأ التوكن من sessionStorage عبر TokenStore
    final String? token = TokenStore.read();

    // 3) اقرأ تاريخ الانتهاء (لو كنتِ تخزّنيه)
    final expDateStr = html.window.sessionStorage['expDate'];
    if (expDateStr != null && expDateStr.isNotEmpty) {
      final tempExpDate = DateTime.tryParse(expDateStr);
      if (tempExpDate != null && DateTime.now().isAfter(tempExpDate)) {
        // انتهت الجلسة
         TokenStore.clear();
        return loginScreenRoute;
      }
    }

    // 4) قرّري الوجهة
    return token != null ? mainScreenRoute : loginScreenRoute;
  }

  static Future<String?> checkUrlParameters(BuildContext context) async {
    final url = html.window.location.href;
    final uri = Uri.parse(url);

    if (uri.queryParameters.isEmpty) return null;

    final type = int.tryParse(uri.queryParameters['op'] ?? '');

    if (type == 1) {
      return await viewMethod(context, uri.queryParameters); // ⬅️ مهم: return
    } else if (type == 0) {
      return await scanMethod(context, uri.queryParameters); // ⬅️ مهم: return
    }
    return null;
  }

  static Future<String?> scanMethod(
      BuildContext context, Map<String, String> queryParams) async {
    await loadApi();

    final screenContentProvider = context.read<ScreenContentProvider>();
    final fileListProvider = context.read<DocumentListProvider>();

    final key = "archiveProj@s2024ASD/Key@team.CT";
    final iv = [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1];
    final byteArray =
        Uint8List.fromList(iv.map((b) => b == 1 ? 0x01 : 0x00).toList());

    final uri = Uri.parse(html.window.location.href);
    final desc = uri.queryParameters['DOCN_NAME_EN'];
    final fld1Param = uri.queryParameters['FLD_1'];
    final userName = uri.queryParameters['DUN'];

    final emailEncrypted =
        Encryption.performAesEncryption(userName ?? '', key, byteArray);

    // بدلاً من FlutterSecureStorage:
    html.window.sessionStorage['userName'] = userName ?? '';

    final ok = await LoginController().logInWithOutPass(
        LogInModel(emailEncrypted, ""), AppLocalizations.of(context)!);

    if (ok) {
      fileListProvider.setIsViewFile(true);
      fileListProvider.setDescription(desc ?? '');
      fileListProvider.setIssueNumber(fld1Param ?? '');
      screenContentProvider.setPage1(7);
      return mainScreenRoute; // ⬅️ مهم
    } else {
      fileListProvider.setIsViewFile(true);
      screenContentProvider.setPage1(20);
      return loginScreenRoute; // اختياريًا ارجعي للّوجين
    }
  }

  static Future<String?> viewMethod(
      BuildContext context, Map<String, String> queryParams) async {
    await loadApi();

    final screenContentProvider = context.read<ScreenContentProvider>();
    final fileListProvider = context.read<DocumentListProvider>();

    final key = "archiveProj@s2024ASD/Key@team.CT";
    final iv = [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1];
    final byteArray =
        Uint8List.fromList(iv.map((b) => b == 1 ? 0x01 : 0x00).toList());

    final uri = Uri.parse(html.window.location.href);
    final fld1Param = uri.queryParameters['FLD_1'];
    final userName = uri.queryParameters['DUN'];

    final emailEncrypted =
        Encryption.performAesEncryption(userName ?? '', key, byteArray);

    // بدلاً من FlutterSecureStorage:
    html.window.sessionStorage['userName'] = userName ?? '';

    final ok = await LoginController().logInWithOutPass(
        LogInModel(emailEncrypted, ""), AppLocalizations.of(context)!);

    if (ok) {
      fileListProvider.setIsViewFile(true);
      fileListProvider.setIssueNumber(fld1Param ?? '');
      screenContentProvider.setPage1(6);
      return mainScreenRoute; // ⬅️ مهم
    } else {
      fileListProvider.setIsViewFile(true);
      screenContentProvider.setPage1(20);
      return loginScreenRoute; // اختياري
    }
  }

  static Future<void> loadApi() async {
    final central = await rootBundle.loadString(centralApiPathConstant);
    ApiService.urlServer = central.trim();
    html.window.sessionStorage['url'] = ApiService.urlServer;

    final pdf = await rootBundle.loadString(centralApiPDFPathConstant);
    html.window.sessionStorage['urlPdf'] = pdf.trim();
  }

  static Future<String?> _redirect2(BuildContext context, String path) async {
    const storage = FlutterSecureStorage();
    String? token = TokenStore.read();
    print("INREEDIRCTT");
    return mainScreenRoute;
  }
}
