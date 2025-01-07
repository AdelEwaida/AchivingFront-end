import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListConstants {
  static String? getStatusName(int statusName, AppLocalizations localizations) {
    Map<int, String> paymentMethods = {
      0: "Pending",
      1: "Approval",
      2: "Rejected",
    };
    return paymentMethods[statusName];
  }

  static int? getStatusCode(String statusCode, AppLocalizations localizations) {
    Map<String, int> paymentMethods = {
      "Pending": 0,
      "Approval": 1,
      "Rejected": 2,
    };
    return paymentMethods[statusCode];
  }

  static List<String> getStatus(AppLocalizations localizations) {
    return ["Pending", "Approval", "Rejected"];
  }
}


  // 'intStatus': PlutoCell(
  //           value: workflow?.intStatus == 0
  //               ? "Pending"
  //               : workflow?.intStatus == 1
  //                   ? "Approval"
  //                   : "Rejected"),