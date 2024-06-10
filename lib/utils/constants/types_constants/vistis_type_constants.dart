import 'package:flutter_gen/gen_l10n/app_localizations.dart';

getTypeNameOfVisit(int type, AppLocalizations localizations) {
  Map<int, String> getVisitTypeName = {
    -2: localizations.notTrans,
    -1: localizations.draft,
    0: localizations.trans,
    1: localizations.cancelled,
  };
  return getVisitTypeName[type];
}
getTypeCodeOfVisit(String type, AppLocalizations localizations) {
  Map<String, int> getVisitTypeName = {
    localizations.notTrans: -2,
    localizations.draft: -1,
    localizations.trans: 0,
    localizations.cancelled: 1,
  };
  return getVisitTypeName[type];
}

listOfTypes(AppLocalizations localizations) {
  List<String> list = [
    localizations.notTrans,
    localizations.trans,
    localizations.draft,
    localizations.cancelled,
  ];
  return list;
}
