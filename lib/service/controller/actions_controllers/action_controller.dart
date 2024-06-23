import 'dart:convert';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_model.dart';
import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:archiving_flutter_project/utils/constants/api_constants.dart';
import '../../../models/db/actions_models/action_model.dart';
import '../../../models/db/count_model.dart';

class ActionController {
  Future<List<ActionModel>> getAllActions(SearchModel searchModel) async {
    List<ActionModel> list = [];
    await ApiService().postRequest(getActionApi, searchModel).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        for (var stock in jsonData) {
          list.add(ActionModel.fromJson(stock));
        }
      }
    });
    return list;
  }

  Future<List<ActionModel>> getActionByDateMethod(String date) async {
    List<ActionModel> list = [];
    await ApiService()
        .postRequest(getActionByDate, {"date": date}).then((response) {
      print("responseresponseresponse:${response.statusCode}");
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        for (var stock in jsonData) {
          list.add(ActionModel.fromJson(stock));
        }
      }
    });
    return list;
  }

  Future addAction(ActionModel actionModel) async {
    return await ApiService()
        .postRequest(addActionApi, actionModel.toJsonAdd());
  }

  Future updateAction(ActionModel actionModel) async {
    return await ApiService()
        .postRequest(updateActionApi, actionModel.toJsonEdit());
  }

  Future deleteAction(ActionModel actionModel) async {
    return await ApiService()
        .postRequest(deleteActionApi, actionModel.toJsonDelete());
  }

  Future<int> getActionCount() async {
    var api = getActionCountApi;

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
