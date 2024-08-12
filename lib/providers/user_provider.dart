import 'package:flutter/material.dart';
import '../models/db/user_models/user_model.dart';

class UserProvider with ChangeNotifier {
  List<UserModel> _selectedUsers = [];

  List<UserModel> get selectedUsers => _selectedUsers;

  void addUser(UserModel user) {
    if (!_selectedUsers.contains(user)) {
      _selectedUsers.add(user);
      notifyListeners();
    }
  }

  void addUsers(List<UserModel> users) {
    for (var user in users) {
      if (!_selectedUsers.any((item) => item.txtCode == user.txtCode)) {
        _selectedUsers.add(user);
      }
      print("userssssssssssssss :${user.toJson()}");
    }
    notifyListeners();
  }

  void removeUser(UserModel user) {
    _selectedUsers.remove(user);
    notifyListeners();
  }

  void clearUsers() {
    _selectedUsers.clear();
    notifyListeners();
  }
}
