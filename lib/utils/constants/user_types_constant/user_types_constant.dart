import 'package:flutter_gen/gen_l10n/app_localizations.dart';

getNameOfUserType(AppLocalizations localizations, int type) {
  Map<int, String> userTypes = {
    0: localizations.manager,
    3: localizations.admin,
    2: localizations.user
  };
  return userTypes[type];
}

getCodeOfUserType(AppLocalizations localizations, String type) {
  Map<String, int> userTypes = {
    localizations.manager: 0,
    localizations.admin: 3,
    localizations.user: 2
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
