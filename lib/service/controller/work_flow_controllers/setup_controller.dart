import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../models/db/work_flow/setup_model.dart';
import '../../../utils/constants/api_constants.dart';
import '../../../utils/constants/setup_constants.dart';
import '../../../utils/constants/storage_keys.dart';
import '../../../utils/func/setup_utils.dart';
import '../../handler/api_service.dart';

class SetupController {
  Future<SetupModel?> getSetupByProperty(String propertyName) async {
    final list = await getSetupList();
    try {
      return list.firstWhere((item) => item.txtPropertyname == propertyName);
    } catch (_) {
      return null;
    }
  }

  Future<SetupModel?> getSetup() async {
    return getSetupByProperty(SetupPropertyNames.workflow);
  }

  Future<List<SetupModel>> getSetupList() async {
    var api = setup;
    List<SetupModel> setupModels = [];
    try {
      var response = await ApiService().getRequest(api);

      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));

        setupModels = jsonData
            .map<SetupModel>((item) => SetupModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      print("Error fetching setup list: $e");
    }
    return setupModels;
  }

  Future<void> cacheSetupFlags(FlutterSecureStorage storage) async {
    final list = await getSetupList();
    final workflow = workflowBolActive(list).toString();
    final docTracking = docTrackingBolActive(list).toString();

    await storage.write(key: StorageKeys.workflowActive, value: workflow);
    await storage.write(key: StorageKeys.docTrackingActive, value: docTracking);
    await storage.write(key: StorageKeys.bolActive, value: workflow);
  }

  Future<bool> updateSetupMethod(SetupModel setupModel) async {
    try {
      var response =
          await ApiService().postRequest(updateSetup, setupModel.toJson());
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to update setup: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error updating setup: $e");
      return false;
    }
  }
}
