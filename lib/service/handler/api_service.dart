// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/dialogs/login_dialog.dart';
import 'package:archiving_flutter_project/utils/constants/api_constants.dart';
import 'package:archiving_flutter_project/utils/constants/key.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controller/error_controllers/error_controller.dart';

class ApiService {
  final storage = const FlutterSecureStorage();
  static String urlServer = "";
  static String whatsAppServer = "";
  // static String scannerURL = "http://localhost:5000";
  static String emailServer = "";
  Future getScannersRequest(String ip, String api) async {
    String? token = await storage.read(key: 'jwt');

    var requestUrl = "$ip/$api";
    print("requestUrlrequestUrl ${requestUrl}");
    try {
      var response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          "Accept": "*/*",
          "content-type": "*/*",
          // "Authorization": "Bearer $token",
        },
      );
      print("--------------------------------------------");
      // print("token $token");
      print("urlll $requestUrl");
      print("responseCode ${response.statusCode}");
      if (response.statusCode == 417 || response.statusCode == 401) {
        final context = navigatorKey.currentState!.overlay!.context;
        await storage.delete(key: "jwt").then((value) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (builder) {
              return ErrorDialog(
                icon: Icons.error_outline,
                errorDetails: "1",
                errorTitle: AppLocalizations.of(context)!.error,
                color: Colors.red,
                statusCode: 401,
              );
            },
          );
          // showDialog(
          //   context: context,
          //   builder: (context) {
          //     return const LoginDialog();
          //   },
          // ).then((value) async {
          //   if (value) {
          //     var response = await http.post(
          //       Uri.parse(requestUrl),
          //       headers: {
          //         "Accept": "application/json",
          //         "Content-type": "application/json",
          //         "Authorization": "Bearer $token"
          //       },
          //       body: json.encode(toJson),
          //     );
          //     return response;
          //   }
          //   print("object  ${value}");
          // });
          // if (kIsWeb) {
          //   GoRouter.of(context).go(loginScreenRoute);
          // } else {
          //   Navigator.pushReplacementNamed(context, loginScreenRoute);
          // }
        });
        // ErrorController.openErrorDialog(
        //   response.statusCode,
        //   response.body,
        // );
      } else if (response.statusCode != 200) {
        if (response.body == "Wrong Credentials") {
          return response;
        }
        ErrorController.openErrorDialog(
          response.statusCode,
          response.body,
        );
        checkErrorDec(response);
      }
      return response;
    } catch (e) {
      print("exceptions $e");
      // Handle network-related exceptions (e.g., no internet connection)
      // You can show an error message to the user or log the error.
    }
  }

  Future getRequest(String api) async {
    String? token = await storage.read(key: 'jwt');

    var requestUrl = "$urlServer/$api";
    print("requestUrlrequestUrl ${requestUrl}");
    try {
      var response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      print("--------------------------------------------");
      // print("token $token");
      print("urlll $requestUrl");
      print("responseCode ${response.statusCode}");
      if (response.statusCode == 417 || response.statusCode == 401) {
        final context = navigatorKey.currentState!.overlay!.context;
        await storage.delete(key: "jwt").then((value) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (builder) {
              return ErrorDialog(
                icon: Icons.error_outline,
                errorDetails:
                    AppLocalizations.of(context)!.expiredSessionLoginDialog,
                errorTitle: AppLocalizations.of(context)!.error,
                color: Colors.red,
                statusCode: 401,
              );
            },
          );
          // showDialog(
          //   context: context,
          //   builder: (context) {
          //     return const LoginDialog();
          //   },
          // ).then((value) async {
          //   if (value) {
          //     var response = await http.post(
          //       Uri.parse(requestUrl),
          //       headers: {
          //         "Accept": "application/json",
          //         "Content-type": "application/json",
          //         "Authorization": "Bearer $token"
          //       },
          //       body: json.encode(toJson),
          //     );
          //     return response;
          //   }
          //   print("object  ${value}");
          // });
          // if (kIsWeb) {
          //   GoRouter.of(context).go(loginScreenRoute);
          // } else {
          //   Navigator.pushReplacementNamed(context, loginScreenRoute);
          // }
        });
        // ErrorController.openErrorDialog(
        //   response.statusCode,
        //   response.body,
        // );
      } else if (response.statusCode != 200) {
        if (response.body == "Wrong Credentials") {
          return response;
        }
        ErrorController.openErrorDialog(
          response.statusCode,
          response.body,
        );
        checkErrorDec(response);
      }
      return response;
    } catch (e) {
      print("exceptions $e");
      // Handle network-related exceptions (e.g., no internet connection)
      // You can show an error message to the user or log the error.
    }
  }

  Future putRequest(String api, dynamic toJson) async {
    String? token = await storage.read(key: 'jwt');
    var requestUrl = "$urlServer/$api";
    var response = await http.put(
      Uri.parse(requestUrl),
      headers: {
        "Accept": "application/json",
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode(toJson),
    );
    print("--------------------------------------------");
    print("token $token");
    print("urlll $requestUrl");
    print("urlllbody ${json.encode(toJson)}");
    print("responseCode ${response.statusCode}");
    if (response.statusCode == 417 || response.statusCode == 401) {
      final context = navigatorKey.currentState!.overlay!.context;
      await storage.delete(key: "jwt").then((value) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (builder) {
            return ErrorDialog(
              icon: Icons.error_outline,
              errorDetails:
                  AppLocalizations.of(context)!.expiredSessionLoginDialog,
              errorTitle: AppLocalizations.of(context)!.error,
              color: Colors.red,
              statusCode: 401,
            );
          },
        );
        // showDialog(
        //   context: context,
        //   builder: (context) {
        //     return const LoginDialog();
        //   },
        // ).then((value) async {
        //   if (value) {
        //     var response = await http.post(
        //       Uri.parse(requestUrl),
        //       headers: {
        //         "Accept": "application/json",
        //         "Content-type": "application/json",
        //         "Authorization": "Bearer $token"
        //       },
        //       body: json.encode(toJson),
        //     );
        //     return response;
        //   }
        //   print("object  ${value}");
        // });
        // if (kIsWeb) {
        //   GoRouter.of(context).go(loginScreenRoute);
        // } else {
        //   Navigator.pushReplacementNamed(context, loginScreenRoute);
        // }
      });
      // ErrorController.openErrorDialog(
      //   response.statusCode,
      //   response.body,
      // );
    } else if (api == logInApi &&
        (response.statusCode == 400 || response.statusCode == 406)) {
      ErrorController.openErrorDialog(
        response.statusCode,
        response.body,
      );
      return response;
    } else if (response.statusCode != 200) {
      if (response.body == "Wrong Credentials") {
        return response;
      }
      ErrorController.openErrorDialog(
        response.statusCode,
        response.body,
      );

      checkErrorDec(response);
    }
    return response;
  }

  Future deleteRequest(String api, dynamic toJson) async {
    String? token = await storage.read(key: 'jwt');

    var requestUrl = "$urlServer/$api";
    var response = await http.delete(
      Uri.parse(requestUrl),
      headers: {
        "Accept": "application/json",
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode(toJson),
    );

    print("--------------------------------------------");
    // print("token $token");
    print("urlll $requestUrl");
    print("urlllbody ${json.encode(toJson)}");
    print("responseCode ${response.statusCode}");
    if (response.statusCode == 417 || response.statusCode == 401) {
      final context = navigatorKey.currentState!.overlay!.context;
      await storage.delete(key: "jwt").then((value) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (builder) {
            return ErrorDialog(
              icon: Icons.error_outline,
              errorDetails:
                  AppLocalizations.of(context)!.expiredSessionLoginDialog,
              errorTitle: AppLocalizations.of(context)!.error,
              color: Colors.red,
              statusCode: 401,
            );
          },
        );
        // showDialog(
        //   context: context,
        //   builder: (context) {
        //     return const LoginDialog();
        //   },
        // ).then((value) async {
        //   if (value) {
        //     var response = await http.post(
        //       Uri.parse(requestUrl),
        //       headers: {
        //         "Accept": "application/json",
        //         "Content-type": "application/json",
        //         "Authorization": "Bearer $token"
        //       },
        //       body: json.encode(toJson),
        //     );
        //     return response;
        //   }
        //   print("object  ${value}");
        // });
        // if (kIsWeb) {
        //   GoRouter.of(context).go(loginScreenRoute);
        // } else {
        //   Navigator.pushReplacementNamed(context, loginScreenRoute);
        // }
      });
      // ErrorController.openErrorDialog(
      //   response.statusCode,
      //   response.body,
      // );
    } else if (api == logInApi &&
        (response.statusCode == 400 || response.statusCode == 406)) {
      return response;
    } else if (response.statusCode != 200) {
      if (response.body == "Wrong Credentials") {
        return response;
      }

      checkErrorDec(response);
    }
    return response;
  }

  Future postRequestExcel(String api, dynamic toJson, {bool? isStart}) async {
    String? token = await storage.read(key: 'jwt');
    final context2 = navigatorKey.currentState!.overlay!.context;
    var requestUrl = "";

    requestUrl = "$urlServer/$api";

    try {
      var response = await http.post(
        Uri.parse(requestUrl),
        headers: {
          "Accept": "application/json",
          "Content-type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(toJson),
      );

      print("--------------------------------------------");
      // print("token $token");
      print("urlll $requestUrl");
      print("urlllbody ${json.encode(toJson)}");
      print("responseCode ${response.statusCode}");
      if (response.statusCode == 417 || response.statusCode == 401) {
        final context = navigatorKey.currentState!.overlay!.context;
        await storage.delete(key: "jwt").then((value) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (builder) {
              return ErrorDialog(
                icon: Icons.error_outline,
                errorDetails:
                    AppLocalizations.of(context)!.expiredSessionLoginDialog,
                errorTitle: AppLocalizations.of(context)!.error,
                color: Colors.red,
                statusCode: 401,
              );
            },
          );
          // showDialog(
          //   context: context,
          //   builder: (context) {
          //     return const LoginDialog();
          //   },
          // ).then((value) async {
          //   if (value) {
          //     var response = await http.post(
          //       Uri.parse(requestUrl),
          //       headers: {
          //         "Accept": "application/json",
          //         "Content-type": "application/json",
          //         "Authorization": "Bearer $token"
          //       },
          //       body: json.encode(toJson),
          //     );
          //     return response;
          //   }
          //   print("object  ${value}");
          // });
          // if (kIsWeb) {
          //   GoRouter.of(context).go(loginScreenRoute);
          // } else {
          //   Navigator.pushReplacementNamed(context, loginScreenRoute);
          // }
        });
        // ErrorController.openErrorDialog(
        //   response.statusCode,
        //   response.body,
        // );
      } else if (response.statusCode == 417 || response.statusCode == 401) {
        final context = navigatorKey.currentState!.overlay!.context;
        await storage.delete(key: "jwt").then((value) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (builder) {
              return ErrorDialog(
                icon: Icons.error_outline,
                errorDetails:
                    AppLocalizations.of(context)!.expiredSessionLoginDialog,
                errorTitle: AppLocalizations.of(context)!.error,
                color: Colors.red,
                statusCode: 401,
              );
            },
          );
          // showDialog(
          //   context: context,
          //   builder: (context) {
          //     return const LoginDialog();
          //   },
          // ).then((value) async {
          //   if (value) {
          //     var response = await http.post(
          //       Uri.parse(requestUrl),
          //       headers: {
          //         "Accept": "application/json",
          //         "Content-type": "application/json",
          //         "Authorization": "Bearer $token"
          //       },
          //       body: json.encode(toJson),
          //     );
          //     return response;
          //   }
          //   print("object  ${value}");
          // });
          // if (kIsWeb) {
          //   GoRouter.of(context).go(loginScreenRoute);
          // } else {
          //   Navigator.pushReplacementNamed(context, loginScreenRoute);
          // }
        });
        // ErrorController.openErrorDialog(
        //   response.statusCode,
        //   response.body,
        // );
      } else if (api == logInApi &&
          (response.statusCode == 400 ||
              response.statusCode == 406 ||
              response.statusCode == 402)) {
        // ErrorController.openErrorDialog(
        //   response.statusCode,
        //   response.body,
        // );
        return response;
      } else if (response.statusCode != 200) {
        if (response.body == "Wrong Credentials") {
          return response;
        }

        ErrorController.openErrorDialog(
          response.statusCode,
          response.body,
        );
      }

      return response;
    } // postRequestExcel catch block - fixed ✅
    catch (e) {
      print("e.toString() ${e.toString()}");
      final context = navigatorKey.currentState!.overlay!.context;

      if (api == logInApi) {
        if (navigatorKey.currentState!.canPop()) {
          Navigator.pop(context);
        }
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              icon: Icons.error_sharp,
              errorDetails: AppLocalizations.of(context)!.error500,
              errorTitle: AppLocalizations.of(context)!.error,
              color: Colors.red,
              statusCode: 500,
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              icon: Icons.error_sharp,
              errorDetails: AppLocalizations.of(context)!.error500,
              errorTitle: AppLocalizations.of(context)!.error,
              color: Colors.red,
              statusCode: 500,
            );
          },
        );
      }
    }
  }

  Future postRequest(String api, dynamic toJson, {bool? isStart}) async {
    String? token = await storage.read(key: 'jwt');
    final context2 = navigatorKey.currentState!.overlay!.context;
    var requestUrl = "";
    final headers = api == logInApi
        ? {
            "Accept": "application/json",
            "Content-type": "application/json",
          }
        : {
            "Accept": "application/json",
            "Content-type": "application/json",
            "Authorization": "Bearer $token",
          };
    requestUrl = "$urlServer/$api";
    try {
      var response = await http.post(
        Uri.parse(requestUrl),
        headers: headers,
        body: json.encode(toJson),
      );

      print("--------------------------------------------");
      print("token $token");
      print("urlll request $requestUrl");
      print("urlllbody ${json.encode(toJson)}");
      print("responseCode ${response.statusCode}");
      if (response.statusCode == 417 || response.statusCode == 401) {
        final context = navigatorKey.currentState!.overlay!.context;
        await storage.delete(key: "jwt").then((value) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (builder) {
              return ErrorDialog(
                icon: Icons.error_outline,
                errorDetails:
                    AppLocalizations.of(context)!.expiredSessionLoginDialog,
                errorTitle: AppLocalizations.of(context)!.error,
                color: Colors.red,
                statusCode: 401,
              );
            },
          );
          // showDialog(
          //   context: context,
          //   builder: (context) {
          //     return const LoginDialog();
          //   },
          // ).then((value) async {
          //   if (value) {
          //     var response = await http.post(
          //       Uri.parse(requestUrl),
          //       headers: {
          //         "Accept": "application/json",
          //         "Content-type": "application/json",
          //         "Authorization": "Bearer $token"
          //       },
          //       body: json.encode(toJson),
          //     );
          //     return response;
          //   }
          //   print("object  ${value}");
          // });
          // if (kIsWeb) {
          //   GoRouter.of(context).go(loginScreenRoute);
          // } else {
          //   Navigator.pushReplacementNamed(context, loginScreenRoute);
          // }
        });
        // ErrorController.openErrorDialog(
        //   response.statusCode,
        //   response.body,
        // );
      } else if (response.statusCode == 417 || response.statusCode == 401) {
        final context = navigatorKey.currentState!.overlay!.context;
        await storage.delete(key: "jwt").then((value) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (builder) {
              return ErrorDialog(
                icon: Icons.error_outline,
                errorDetails:
                    AppLocalizations.of(context)!.expiredSessionLoginDialog,
                errorTitle: AppLocalizations.of(context)!.error,
                color: Colors.red,
                statusCode: 401,
              );
            },
          );
          // showDialog(
          //   context: context,
          //   builder: (context) {
          //     return const LoginDialog();
          //   },
          // ).then((value) async {
          //   if (value) {
          //     var response = await http.post(
          //       Uri.parse(requestUrl),
          //       headers: {
          //         "Accept": "application/json",
          //         "Content-type": "application/json",
          //         "Authorization": "Bearer $token"
          //       },
          //       body: json.encode(toJson),
          //     );
          //     return response;
          //   }
          //   print("object  ${value}");
          // });
          // if (kIsWeb) {
          //   GoRouter.of(context).go(loginScreenRoute);
          // } else {
          //   Navigator.pushReplacementNamed(context, loginScreenRoute);
          // }
        });
        // ErrorController.openErrorDialog(
        //   response.statusCode,
        //   response.body,
        // );
      } else if (api == logInApi &&
          (response.statusCode == 400 ||
              response.statusCode == 406 ||
              response.statusCode == 402)) {
        // ErrorController.openErrorDialog(
        //   response.statusCode,
        //   response.body,
        // );
        return response;
      } else if (api == createTrackingDocs && response.statusCode == 406) {
        return response;
      } else if (response.statusCode != 200) {
        if (response.body == "Wrong Credentials") {
          return response;
        }

        ErrorController.openErrorDialog(
          response.statusCode,
          response.body,
        );
      }

      return response;
    } catch (e) {
      print("e.toString() ${e.toString()}");
      final context = navigatorKey.currentState!.overlay!.context;

      if (api == logInApi) {
        // Only pop if there's something to pop (e.g. a loading dialog)
        if (navigatorKey.currentState!.canPop()) {
          Navigator.pop(context);
        }
        // Show the error dialog instead of silently failing
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              icon: Icons.error_sharp,
              errorDetails: AppLocalizations.of(context)!.error500,
              errorTitle: AppLocalizations.of(context)!.error,
              color: Colors.red,
              statusCode: 500,
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              icon: Icons.error_sharp,
              errorDetails: AppLocalizations.of(context)!.error500,
              errorTitle: AppLocalizations.of(context)!.error,
              color: Colors.red,
              statusCode: 500,
            );
          },
        );
      }
    }
  }

  Future<http.Response> postRequestPdf(String api, dynamic toJson) async {
    String? token = await storage.read(key: 'jwt');
    final requestUrl = "$urlServer/$api";
    try {
      final response = await http.post(
        Uri.parse(requestUrl),
        headers: {
          "Accept": "application/pdf, */*",
          "Content-type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(toJson),
      );

      if (response.statusCode == 417 || response.statusCode == 401) {
        final context = navigatorKey.currentState!.overlay!.context;
        await storage.delete(key: "jwt").then((value) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (builder) {
              return ErrorDialog(
                icon: Icons.error_outline,
                errorDetails:
                    AppLocalizations.of(context)!.expiredSessionLoginDialog,
                errorTitle: AppLocalizations.of(context)!.error,
                color: Colors.red,
                statusCode: 401,
              );
            },
          );
        });
      }

      return response;
    } catch (e) {
      print("e.toString() ${e.toString()}");
      rethrow;
    }
  }

  checkErrorDec(http.Response response) {}
}
