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

  Future<List<SetupModel>> getSetupList() async {
    var api = setup; // Replace `setup` with your actual API endpoint.
    List<SetupModel> setupModels = [];
    try {
      var response = await ApiService().getRequest(api);

      // Debugging: Print the response for verification.
      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));

        // Convert each item in the list to a SetupModel object.
        setupModels = jsonData
            .map<SetupModel>((item) => SetupModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      print("Error fetching setup list: $e");
    }
    return setupModels;
  }

  Future<bool> updateSetupMethod(SetupModel setupModel) async {
    try {
      var response =
          await ApiService().postRequest(updateSetup, setupModel.toJson());
      if (response.statusCode == 200) {
        return true; // Success
      } else {
        print("Failed to update setup: ${response.body}");
        return false; // Failure
      }
    } catch (e) {
      print("Error updating setup: $e");
      return false; // Failure
    }
  }
}
