import 'package:flutter/material.dart';
import '../models/db/user_models/user_model.dart';

class UserProvider with ChangeNotifier {
  // List<UserModel> _selectedUsers = [];

  // List<UserModel> get selectedUsers => _selectedUsers;
  final Set<String> _selectedCodes = {};
  List<UserModel> _selectedUsers = [];

  List<UserModel> get selectedUsers => List.unmodifiable(_selectedUsers);
  Set<String> get selectedCodes => _selectedCodes;
  int get count => _selectedUsers.length;

  bool containsCode(String? code) {
    if (code == null) return false;
    return _selectedUsers.any((u) => u.txtCode == code);
  }

  void setSelectedUsers(List<UserModel> users) {
    // استبدال القائمة كاملة مع إزالة التكرارات حسب txtCode
    final seen = <String>{};
    _selectedUsers = users.where((u) {
      final code = u.txtCode ?? '';
      if (code.isEmpty || seen.contains(code)) return false;
      seen.add(code);
      return true;
    }).toList();
    notifyListeners();
  }

  void addUsers(List<UserModel> users) {
    for (var user in users) {
      if (!containsCode(user.txtCode)) {
        _selectedUsers.add(user);
      }
    }
    notifyListeners();
  }

  void removeUser(UserModel user) {
    // إزالة حسب txtCode لثبات السلوك
    _selectedUsers.removeWhere((u) => u.txtCode == user.txtCode);
    notifyListeners();
  }

  // ✅ جديدة: استبدال القائمة بالكامل (تزيل التكرارات تلقائياً)
  void replaceWith(List<UserModel> users) {
    setSelectedUsers(users);
  }

  void addUser(UserModel user) {
    if (user.txtCode != null && _selectedCodes.add(user.txtCode!)) {
      _selectedUsers.add(user);
      notifyListeners();
    }
  }

  void removeByCode(String code) {
    _selectedCodes.remove(code);
    _selectedUsers.removeWhere((u) => u.txtCode == code);
    notifyListeners();
  }

  void toggleUser(UserModel user) {
    if (user.txtCode == null) return;
    if (_selectedCodes.contains(user.txtCode!)) {
      removeByCode(user.txtCode!);
    } else {
      addUser(user);
    }
  }

  void clearUsers() {
    _selectedCodes.clear();
    _selectedUsers.clear();
    notifyListeners();
  }
}
