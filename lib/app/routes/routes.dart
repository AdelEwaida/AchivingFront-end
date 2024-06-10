import 'package:archiving_flutter_project/screens/home_page.dart';
import 'package:archiving_flutter_project/screens/log_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

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
          redirect: (context, state) => _redirect2(context, mainScreenRoute),
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
    const storage = FlutterSecureStorage();
    // String? token = await storage.read(key: 'jwt');
    String? token = await storage.read(key: 'jwt');

    return token != null ? mainScreenRoute : loginScreenRoute;
  }

  static Future<String?> _redirect2(BuildContext context, String path) async {
    const storage = FlutterSecureStorage();
    // String? token = await storage.read(key: 'jwt');
    String? token = await storage.read(key: 'jwt');
    print("INREEDIRCTT");
    return mainScreenRoute;
  }
}
