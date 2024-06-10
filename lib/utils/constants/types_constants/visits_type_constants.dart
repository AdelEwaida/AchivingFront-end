import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<String> typesOfVisitsStatus(AppLocalizations localizations) {
  List<String> visitsTypes = [
    localizations.visitDone,
    localizations.visitsCancelled,
    localizations.visitAtALaterDate
  ];
  return visitsTypes;
}
