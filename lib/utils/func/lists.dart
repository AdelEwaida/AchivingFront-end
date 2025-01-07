import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListConstants {
  static String? getStatusName(int statusName, AppLocalizations localizations) {
    Map<int, String> paymentMethods = {
      0: localizations.pending,
      1: localizations.approved,
      2: localizations.rejected,
    };
    return paymentMethods[statusName];
  }

  static int? getStatusCode(String statusCode, AppLocalizations localizations) {
    Map<String, int> paymentMethods = {
      localizations.pending: 0,
      localizations.approved: 1,
      localizations.rejected: 2,
    };
    return paymentMethods[statusCode];
  }

  static List<String> getStatus(AppLocalizations localizations) {
    return [
      localizations.pending,
      localizations.approved,
      localizations.rejected
    ];
  }
}


  // 'intStatus': PlutoCell(
  //           value: workflow?.intStatus == 0
  //               ? localizations.pending
  //               : workflow?.intStatus == 1
  //                   ? localizations.approved
  //                   : localizations.rejected),