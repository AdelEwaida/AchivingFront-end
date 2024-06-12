import 'package:flutter_gen/gen_l10n/app_localizations.dart';

getSortedByTyeps(AppLocalizations localizations) {
  return [localizations.date, localizations.description];
}

getSortedByTyepsCode(AppLocalizations localizations, String type) {
  Map<String, int> types = {
    localizations.date: 1,
    localizations.description: 2
  };
  return types[type];
}

getSortedByTyepsByCode(AppLocalizations localizations, int type) {
  Map<int, String> types = {
    1: localizations.date,
    2: localizations.description
  };
  return types[type];
}
