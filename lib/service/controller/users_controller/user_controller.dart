import 'dart:convert';

import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:archiving_flutter_project/utils/constants/api_constants.dart';

import '../../../models/dto/searchs_model/search_model.dart';

class UserController {
  Future<List<UserModel>> getUsers(SearchModel searchModel) async {
    List<UserModel> list = [];

    var response =
        await ApiService().postRequest(getUserSearchApi, searchModel);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      for (var users in jsonData) {
        list.add(UserModel.fromJson(users));
      }
    }
    return list;
  }

  Future addUser(UserModel userModel) async {
    return await ApiService().postRequest(addUserApi, userModel);
  }

  Future deleteUser(UserModel userModel) async {
    return await ApiService().postRequest(deleteUserApi, userModel);
  }

  Future updateUser(UserModel userModel) async {
    return await ApiService().postRequest(updateUserApi, userModel);
  }
}
