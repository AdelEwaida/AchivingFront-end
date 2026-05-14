import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../../../utils/constants/api_constants.dart';
import '../../models/db/work_flow/lockup_location_model.dart';
import '../handler/api_service.dart';

class LockupLocationController {
  // GET ALL 
  Future<List<LockupLocationModel>> getAllLockupLocations() async {
    List<LockupLocationModel> list = [];
    try {
      final response = await ApiService().getRequest(lockupLocationGetAll);
      if (response == null || response.statusCode != 200) {
        debugPrint(
          'getAllLockupLocations error: '
          'status=${response?.statusCode}, reason=${response?.reasonPhrase}',
        );
        return list;
      }
      final raw = utf8.decode(response.bodyBytes);
      if (raw.trim().isEmpty) return list;
      final jsonData = jsonDecode(raw);
      if (jsonData is List) {
        for (final item in jsonData) {
          list.add(LockupLocationModel.fromJson(item));
        }
      }
    } catch (e, st) {
      debugPrint('getAllLockupLocations error: $e\n$st');
    }
    return list;
  }


  Future<String?> insertLockupLocation(LockupLocationModel model) async {
    try {
      final response = await ApiService()
          .postRequest(lockupLocationInsert, model.toInsertJson());
      if (response == null) return 'No response from server';
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null; // success
      }
      try {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body is Map && body['message'] != null) {
          return body['message'].toString();
        }
      } catch (_) {}
      return 'Error ${response.statusCode}: ${response.reasonPhrase}';
    } catch (e) {
      debugPrint('insertLockupLocation error: $e');
      return e.toString();
    }
  }

  //UPDATE
  Future<bool> updateLockupLocation(LockupLocationModel model) async {
    if (model.key == null || model.key!.isEmpty) return false;
    try {
      final api = '$lockupLocationUpdate/${model.key}';
      final response = await ApiService().putRequest(api, model.toUpdateJson());
      return response != null && response.statusCode == 200;
    } catch (e) {
      debugPrint('updateLockupLocation error: $e');
      return false;
    }
  }

  // DELETE
  Future<bool> deleteLockupLocation(String key) async {
    if (key.isEmpty) return false;
    try {
      final api = '$lockupLocationDelete/$key';
      final response = await ApiService().deleteRequest(api, null);
      return response != null && response.statusCode == 200;
    } catch (e) {
      debugPrint('deleteLockupLocation error: $e');
      return false;
    }
  }
}
