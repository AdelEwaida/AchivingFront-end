import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

userStatus(BuildContext context) {
  List<String> typesOfUser = [
    AppLocalizations.of(context)!.active,
    AppLocalizations.of(context)!.notActive
  ];
  return typesOfUser;
}

int? getUserStatus(String type, AppLocalizations appLocalizations) {
  Map<String, int> types = {
    appLocalizations.active: 1,
    appLocalizations.notActive: 0
  };
  return types[type];
}
String? getUserStatusName(int type, AppLocalizations appLocalizations) {
  Map<int, String> types = {
    1: appLocalizations.active,
    0: appLocalizations.notActive,
  };
  return types[type];
}
userTypes(BuildContext context) {
  List<String> typesOfUser = [
    AppLocalizations.of(context)!.normalUser,
    AppLocalizations.of(context)!.userAdmin,
    AppLocalizations.of(context)!.userManger,
  ];
  return typesOfUser;
}

int? getUserType(String type, AppLocalizations appLocalizations) {
  Map<String, int> types = {
    appLocalizations.normalUser: 1,
    appLocalizations.userAdmin: 2,
    appLocalizations.userManger: 0,
  };
  return types[type];
}

String? getUserTypeName(int type, AppLocalizations appLocalizations) {
  Map<int, String> types = {
    1: appLocalizations.normalUser,
    2: appLocalizations.userAdmin,
    0: appLocalizations.userManger,
  };
  return types[type] ?? "";
}
