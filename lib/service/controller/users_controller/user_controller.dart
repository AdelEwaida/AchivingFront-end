import 'dart:convert';

import 'package:archiving_flutter_project/models/db/user_models/department_user_model.dart';
import 'package:archiving_flutter_project/models/db/user_models/update_user_password_model.dart';
import 'package:archiving_flutter_project/models/db/user_models/user_model.dart';
import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:archiving_flutter_project/utils/constants/api_constants.dart';

import '../../../models/db/count_model.dart';
import '../../../models/db/user_models/user_category.dart';
import '../../../models/db/user_models/user_dept_model.dart';
import '../../../models/db/user_models/user_update_req.dart';
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

  Future<List<DepartmentUserModel>> getDepartmentUser(String userCode) async {
    List<DepartmentUserModel> list = [];
    var response = await ApiService()
        .postRequest(getUserDepartmentApi, {"user": userCode});
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      for (var dept in jsonData) {
        list.add(DepartmentUserModel.fromJson(dept));
      }
    }
    return list;
  }

  Future<List<DepartmentUserModel>> getDepartmentSelectedUser(
      String userCode) async {
    List<DepartmentUserModel> list = [];
    var response = await ApiService()
        .postRequest(getUserSelectedDepartmentApi, {"user": userCode});
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      for (var dept in jsonData) {
        list.add(DepartmentUserModel.fromJson(dept));
      }
    }
    return list;
  }

  Future updateCurrentUserPassword(UpdateUserPassword userModel) async {
    return await ApiService().postRequest(updateUserPasswordApi, userModel);
  }

  Future setUserDepartment(List<DepartmentUserModel> list) async {
    return await ApiService().postRequest(setUserDepartmentApi, list);
  }

  Future addUser(UserDeptModel userModel) async {
    return await ApiService().postRequest(addUserApi, userModel);
  }

  Future updateUserPassword(UserModel userModel) async {
    return await ApiService().postRequest(updateUserPasswordApi, userModel);
  }

  Future updateOtherUserPassword(UserModel userModel) async {
    return await ApiService().postRequest(updateOtherUserApi, userModel);
  }

  Future deleteUser(UserModel userModel) async {
    return await ApiService().postRequest(deleteUserApi, userModel);
  }

  Future updateUser(UserDeptModel userModel) async {
    return await ApiService().postRequest(updateUserApi, userModel);
  }

  Future<List<UserCategory>> getUserCategory(SearchModel searchModel) async {
    List<UserCategory> list = [];
    await ApiService()
        .postRequest(getUserCatPageAPI, searchModel)
        .then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        for (var stock in jsonData) {
          list.add(UserCategory.fromJson(stock));
        }
      }
    });
    return list;
  }

  Future<int> getUserCatCount() async {
    var api = getTotalUserCatCount;

    int itemCount = 0;
    await ApiService().getRequest(api).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(value.bodyBytes));
        itemCount = CountModel.fromJson(jsonData).count!;
      }
    });

    return itemCount;
  }

  Future<List<UserCategory>> getUsersByCatMethod(String userModel) async {
    List<UserCategory> list = [];

    await ApiService()
        .postRequest(getUsersByCat, {"categoryId": userModel}).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        for (var stock in jsonData) {
          list.add(UserCategory.fromJson(stock));
        }
      }
    });
    return list;
  }

  Future updateUserCatgeory(UserUpdateReq updateReq) async {
    return await ApiService().postRequest(updateUserCatApi, updateReq);
  }

  Future deleteUserCategory(UserCategory userModel) async {
    return await ApiService().postRequest(deleteUserCatApi, userModel);
  }

  Future<int> getUserCount() async {
    var api = getUsersCount;

    int itemCount = 0;
    await ApiService().getRequest(api).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(value.bodyBytes));
        itemCount = CountModel.fromJson(jsonData).count!;
      }
    });
    return itemCount;
  }
}
