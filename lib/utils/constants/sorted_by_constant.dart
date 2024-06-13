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

getStatusName(AppLocalizations localizations) {
  return [localizations.active, localizations.notActive];
}

getStatusCode(AppLocalizations localizations, String type) {
  Map<String, int> types = {
    localizations.active: 1,
    localizations.notActive: 2
  };
  return types[type];
}

getStatusByCode(AppLocalizations localizations, int type) {
  Map<int, String> types = {
    1: localizations.active,
    2: localizations.notActive
  };
  return types[type];
}

getRecurringName(AppLocalizations localizations) {
  return [localizations.monthly, localizations.weekly];
}

getRecurringCode(AppLocalizations localizations, String type) {
  Map<String, int> types = {localizations.monthly: 1, localizations.weekly: 2};
  return types[type];
}

getRecurringByCode(AppLocalizations localizations, int type) {
  Map<int, String> types = {1: localizations.monthly, 2: localizations.weekly};
  return types[type];
}
