import 'dart:html' as html;
import 'package:uuid/uuid.dart';

class TokenManager {
  static const String tokenPrefix = "tab_token_";

  /// يولد TabId لكل تبويب ويحفظه في sessionStorage
  static String getTabId() {
    var tabId = html.window.sessionStorage['tabId'];
    if (tabId == null) {
      tabId = const Uuid().v4(); // يولد ID فريد
      html.window.sessionStorage['tabId'] = tabId;
    }
    return tabId;
  }

  /// حفظ التوكين للتبويب الحالي
  static void saveToken(String token) {
    final tabId = getTabId();
    html.window.localStorage["$tokenPrefix$tabId"] = token;
  }

  /// استرجاع التوكين للتبويب الحالي
  static String? getToken() {
    final tabId = getTabId();
    return html.window.localStorage["$tokenPrefix$tabId"];
  }

  /// مسح التوكين للتبويب الحالي
  static void clearToken() {
    final tabId = getTabId();
    html.window.localStorage.remove("$tokenPrefix$tabId");
  }
}
