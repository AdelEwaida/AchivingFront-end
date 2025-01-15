import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListConstants {
  static String? getStatusName(int statusName, AppLocalizations localizations) {
    Map<int, String> staus = {
      0: localizations.readyToApprove,
      1: localizations.approved,
      2: localizations.rejected,
      -1: localizations.all
    };
    return staus[statusName];
  }

  static int? getStatusCode(String statusCode, AppLocalizations localizations) {
    Map<String, int> staus = {
      localizations.readyToApprove: 0,
      localizations.approved: 1,
      localizations.rejected: 2,
      localizations.all: -1
    };
    return staus[statusCode];
  }

  static List<String> getStatus(AppLocalizations localizations) {
    return [
      localizations.all,
      localizations.readyToApprove,
      localizations.approved,
      localizations.rejected,
    ];
  }

  //work flow document
  static String? getStatusNameWorkFlow(
      int statusName, AppLocalizations localizations) {
    Map<int, String> staus = {
      0: localizations.pending,
      1: localizations.approved,
      2: localizations.rejected,
      -1: ""
    };
    return staus[statusName];
  }

  static int? getStatusCodeWorkFlow(
      String statusCode, AppLocalizations localizations) {
    Map<String, int> staus = {
      localizations.pending: 0,
      localizations.approved: 1,
      localizations.rejected: 2,
      "": -1
    };
    return staus[statusCode];
  }

  static List<String> getStatusWorkFlow(AppLocalizations localizations) {
    return [
      localizations.pending,
      localizations.approved,
      localizations.rejected
    ];
  }

  static List<String> getStatusWorkFlowAllOption(
      AppLocalizations localizations) {
    return [
      localizations.all,
      localizations.pending,
      localizations.approved,
      localizations.rejected,
    ];
  }

  static String? getStatusNameWorkFlowDoc(
      int statusName, AppLocalizations localizations) {
    Map<int, String> staus = {
      0: localizations.pending,
      1: localizations.approved,
      2: localizations.rejected,
      -1: localizations.all
    };
    return staus[statusName];
  }

  static int? getStatusCodeWorkFlowDoc(
      String statusCode, AppLocalizations localizations) {
    Map<String, int> staus = {
      localizations.pending: 0,
      localizations.approved: 1,
      localizations.rejected: 2,
      localizations.all: -1
    };
    return staus[statusCode];
  }
}
