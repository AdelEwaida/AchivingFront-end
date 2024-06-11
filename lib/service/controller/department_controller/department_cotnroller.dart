import 'dart:convert';

import 'package:archiving_flutter_project/models/db/count_model.dart';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';
import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:archiving_flutter_project/utils/constants/api_constants.dart';

class DepartmentController {
  Future<List<DepartmentModel>> getDep(SearchModel searchModel) async {
    List<DepartmentModel> list = [];
    await ApiService().postRequest(getDepPageApi, searchModel).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        for (var stock in jsonData) {
          list.add(DepartmentModel.fromJson(stock));
        }
      }
    });
    return list;
  }

  Future addDep(DepartmentModel departmentModel) async {
    return await ApiService()
        .postRequest(insertDepApi, departmentModel.toJsonAdd());
  }

  Future updateDep(DepartmentModel departmentModel) async {
    return await ApiService()
        .postRequest(updateDepApi, departmentModel.toJsonEdit());
  }

  Future deleteDep(DepartmentModel departmentModel) async {
    return await ApiService()
        .postRequest(deleteDepApi, departmentModel.toJsonDelete());
  }

  Future<int> getOfficeCount() async {
    var api = getDepCountApi;

    int itemCount = 0;
    await ApiService().getRequest(api).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(value.bodyBytes));
        itemCount = CountModel.fromJson(jsonData).count!;
      }
    });
    // await ApiService()
    //     .postRequest(api, searchCriteria.toJson())
    //     .then((response) {
    //   if (response.statusCode == 200) {
    //     var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
    //     itemCount = CountModel.fromJson(jsonData).count!;
    //   }
    // });
    return itemCount;
  }
}
