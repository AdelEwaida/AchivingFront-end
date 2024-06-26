import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: non_constant_identifier_names
String USERTYPEADMIN = "ROLE_ADMIN";
String USERTYPEMANEGER = "ROLE_MANAGEMENT";
String NORMALUSER = "ROLE_USER";
getNameOfUserType(AppLocalizations localizations, int type) {
  Map<int, String> userTypes = {
    3: localizations.admin,
    0: localizations.manager,
    2: localizations.user
  };
  return userTypes[type];
}

getCodeOfUserType(AppLocalizations localizations, String type) {
  Map<String, int> userTypes = {
    localizations.manager: 0,
    localizations.user: 2,
    localizations.admin: 3,
  };
  return userTypes[type];
}

getUserTypesList(AppLocalizations localizations) {
  List<String> userTypes = [
    localizations.manager,
    localizations.admin,
    localizations.user
  ];
  return userTypes;
}
