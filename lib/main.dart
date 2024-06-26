import 'dart:async';
import 'dart:js';
import 'dart:js_interop';
import 'dart:ui';
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

// void onBrowserClose() {
//   const storage = FlutterSecureStorage();
//   storage.delete(key: "jwt");
//   final context2 = navigatorKey.currentState!.overlay!.context;

//   // Perform logout and token deletion
//   GoRouter.of(context2).go(loginScreenRoute);
// }

// class MyApp extends StatelessWidget {
//   MyApp({super.key});
//   final sessionStateStream = StreamController<SessionState>();

//   // This widget is the root of your application.
//   Widget build(BuildContext context) {
//     final sessionConfig = SessionConfig(
//       invalidateSessionForAppLostFocus: const Duration(minutes: 60),
//       invalidateSessionForUserInactivity: const Duration(minutes: 60),
//     );

//     final provider = Provider.of<LocaleProvider>(context);
//     loadApi();
//     return SessionTimeoutManager(
//       sessionConfig: sessionConfig,
//       child: MaterialApp.router(
//         // key: UniqueKey\\(),
//         scrollBehavior: MyCustomScrollBehavior(),
//         title: 'Scope',
//         debugShowCheckedModeBanner: false,
//         localizationsDelegates: const [
//           AppLocalizations.delegate,
//           GlobalMaterialLocalizations.delegate,
//           GlobalCupertinoLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate,
//         ],
//         locale: provider.locale,
//         supportedLocales: lang,
//         // theme: ThemeData.light()
//         //     .copyWith(textTheme: getFontFamily(context), useMaterial3: false),
//         routerConfig: AppRoutes.routes,

//         // home: const LoginScreen(),
//       ),
//     );
//   }

//   Future loadApi() async {
//     const storage = FlutterSecureStorage();

//     await rootBundle.loadString(centralApiPathConstant).then((value) async {
//       ApiService.urlServer = value.trim();

//       await storage.write(key: 'url', value: ApiService.urlServer);
//     });
//     await rootBundle.loadString(centralApiPDFPathConstant).then((value) async {
//       await storage.write(key: 'urlPdf', value: value.trim());
//     });
//     // await storage.write(key: 'logOutApi', value: logOutApi);
//   }
// }
class MyApp extends StatelessWidget {
  MyApp({super.key});
  final sessionStateStream = StreamController<SessionState>();

  // This widget is the root of your application.
  Widget build(BuildContext context) {
    final sessionConfig = SessionConfig(
      invalidateSessionForAppLostFocus: const Duration(minutes: 60),
      invalidateSessionForUserInactivity: const Duration(minutes: 60),
    );

    final provider = Provider.of<LocaleProvider>(context);
    loadApi();
    return SessionTimeoutManager(
      sessionConfig: sessionConfig,
      child: MaterialApp.router(
        // key: UniqueKey\\(),
        scrollBehavior: MyCustomScrollBehavior(),
        title: 'Scope',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: provider.locale,
        supportedLocales: lang,
        // theme: ThemeData(
        //   textTheme: GoogleFonts.almaraiTextTheme(
        //     Theme.of(context).textTheme,
        //   ),
        // ),
        theme: _buildTheme(context, provider.locale),

        routerConfig: AppRoutes.routes,

        // home: const LoginScreen(),
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context, Locale? locale) {
    if (locale != null && locale.languageCode == 'ar') {
      return ThemeData(
        textTheme: GoogleFonts.almaraiTextTheme(
          Theme.of(context).textTheme,
        ),
      );
    } else {
      return ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
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
