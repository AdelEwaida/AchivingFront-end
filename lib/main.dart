import 'dart:async';
import 'dart:js';
import 'dart:js_interop';
import 'dart:ui';
import 'package:archiving_flutter_project/dialogs/login_dialog.dart';
import 'package:archiving_flutter_project/service/controller/login_controllers/login_controller.dart';
import 'package:excel/excel.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:archiving_flutter_project/app/auth/session_model/session_config.dart';
import 'package:archiving_flutter_project/app/auth/session_model/session_time_out_manager.dart';
import 'package:archiving_flutter_project/app/routes/routes.dart';
import 'package:archiving_flutter_project/providers/classification_name_and_code_provider.dart';
import 'package:archiving_flutter_project/providers/dates_provider.dart';
import 'package:archiving_flutter_project/providers/file_list_provider.dart';
import 'package:archiving_flutter_project/providers/local_provider.dart';
import 'package:archiving_flutter_project/providers/screen_content_provider.dart';
import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:archiving_flutter_project/utils/constants/assets_path_constants.dart';
import 'package:archiving_flutter_project/utils/constants/key.dart';
import 'package:archiving_flutter_project/utils/constants/routes_constant.dart';
import 'package:archiving_flutter_project/utils/constants/supported_lang.dart';
import 'package:archiving_flutter_project/utils/encrypt/encryption.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:js' as js;

void main() {
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (create) => LocaleProvider()),
      ChangeNotifierProvider(create: (create) => ScreenContentProvider()),
      ChangeNotifierProvider(create: (create) => DatesProvider()),
      ChangeNotifierProvider(create: (create) => DocumentListProvider()),
      ChangeNotifierProvider(
          create: (create) => CalssificatonNameAndCodeProvider())
    ], child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final sessionStateStream = StreamController<SessionState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final sessionConfig = SessionConfig(
      invalidateSessionForAppLostFocus: const Duration(minutes: 60),
      invalidateSessionForUserInactivity: const Duration(minutes: 60),
    );

    final provider = Provider.of<LocaleProvider>(context);
    final baseTheme = ThemeData.light().copyWith(
      useMaterial3: false,
    );
    sessionConfig.stream.listen((SessionTimeoutState timeoutEvent) async {
      const storage = FlutterSecureStorage();
      final context2 = navigatorKey.currentState!.overlay!.context;
      sessionStateStream.add(SessionState.stopListening);

      if (timeoutEvent == SessionTimeoutState.userInactivityTimeout &&
          GoRouter.of(context2)
                  .routeInformationProvider
                  .value
                  .uri
                  .toString()
                  .compareTo(loginScreenRoute) !=
              0) {
        const storage = FlutterSecureStorage();
        String userCode = storage.read(key: "userName").toString();

        await storage.delete(key: "jwt").then((value) {
          // isLoginDialog = true;

          showDialog(
              context: context2,
              barrierDismissible: false,
              builder: (builder) {
                return const LoginDialog();
              });
        });

        // const storage = FlutterSecureStorage();
        // String userCode = storage.read(key: "userName").toString();

        // String key = "scope@e2024A/key@team.CT";
        // final iv = [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1];
        // final byteArray = Uint8List.fromList(
        //     iv.map((bit) => bit == 1 ? 0x01 : 0x00).toList());
        // String userCodeEnc =
        //     Encryption.performAesEncryption(userCode, key, byteArray);
        // await LoginController()
        //     .logOutPost(LogoutModel(txtCode: userCodeEnc),
        //         AppLocalizations.of(context2)!)
        //     .then((value) {
        //   if (value.statusCode == 200) {
        //     if (kIsWeb) {
        //       storage.deleteAll();
        //       storage.delete(key: "jwt");
        //       // GoRouter.of(context).pushReplacementNamed(loginScreenRoute);
        //       GoRouter.of(context2).go(loginScreenRoute);
        //     } else {
        //       Navigator.pushReplacementNamed(context, loginScreenRoute);
        //     }
        //   }
        // });
      } else if (timeoutEvent == SessionTimeoutState.appFocusTimeout) {
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        const storage = FlutterSecureStorage();
        String userCode = storage.read(key: "userName").toString();

        String key = "scope@e2024A/key@team.CT";
        final iv = [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1];
        final byteArray = Uint8List.fromList(
            iv.map((bit) => bit == 1 ? 0x01 : 0x00).toList());
        String userCodeEnc =
            Encryption.performAesEncryption(userCode, key, byteArray);

        if (kIsWeb) {
          storage.deleteAll();
          storage.delete(key: "jwt");
          // GoRouter.of(context).pushReplacementNamed(loginScreenRoute);
          GoRouter.of(context2).go(loginScreenRoute);
        } else {
          Navigator.pushReplacementNamed(context, loginScreenRoute);
        }
      }
    });

    // Merge the base theme with the custom theme
    final customTheme = _buildTheme(context, provider.locale);
    loadApi();
    return SessionTimeoutManager(
      sessionConfig: sessionConfig,
      child: MaterialApp.router(
        // key: UniqueKey\\(),
        scrollBehavior: MyCustomScrollBehavior(),
        title: 'ARCHIVING',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: provider.locale,
        supportedLocales: lang,
        theme: baseTheme.copyWith(
          textTheme: customTheme.textTheme,
          dialogBackgroundColor: customTheme.dialogBackgroundColor,
          appBarTheme: customTheme.appBarTheme,
        ),
        routerConfig: AppRoutes.routes,

        // home: const LoginScreen(),
      ),
    );
  }

  // ThemeData _buildTheme(BuildContext context, Locale? locale) {
  //   if (locale != null && locale.languageCode == 'ar') {
  //     return ThemeData(
  //       dialogBackgroundColor: Colors.white,
  //       textTheme: GoogleFonts.almaraiTextTheme(
  //         Theme.of(context).textTheme,
  //       ),
  //     );
  //   } else {
  //     return ThemeData(
  //       dialogBackgroundColor: Colors.white,
  //       textTheme: GoogleFonts.nunitoTextTheme(
  //         Theme.of(context).textTheme,
  //       ),
  //     );
  //   }
  // }
  ThemeData _buildTheme(BuildContext context, Locale? locale) {
    if (locale != null && locale.languageCode == 'ar') {
      return ThemeData(
        dialogBackgroundColor: Colors.white,
        textTheme: GoogleFonts.almaraiTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(239, 255, 255, 255),
          foregroundColor: Colors.black,
        ),
      );
    } else {
      return ThemeData(
        dialogBackgroundColor: Colors.white,
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(249, 255, 255, 255),
          foregroundColor: Colors.black,
        ),
      );
    }
  }

  Future loadApi() async {
    const storage = FlutterSecureStorage();

    await rootBundle.loadString(centralApiPathConstant).then((value) async {
      ApiService.urlServer = value.trim();

      await storage.write(key: 'url', value: ApiService.urlServer);
    });
    await rootBundle.loadString(centralApiPDFPathConstant).then((value) async {
      await storage.write(key: 'urlPdf', value: value.trim());
    });
    // await storage.write(key: 'logOutApi', value: logOutApi);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
