import 'dart:convert';

import '../../../models/db/work_flow/setup_model.dart';
import '../../../utils/constants/api_constants.dart';
import '../../handler/api_service.dart';

class SetupController {
  Future<SetupModel?> getSetup() async {
    var api = setup;
    SetupModel? setupModel;
    try {
      var response = await ApiService().getRequest(api);
      print(response);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        for (var stock in jsonData) {
          setupModel = SetupModel.fromJson(stock);
        }
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
    return setupModel;
  }
}
