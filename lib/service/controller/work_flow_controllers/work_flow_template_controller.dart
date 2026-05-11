import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:archiving_flutter_project/models/db/work_flow/template_model.dart';

import '../../../models/db/count_model.dart';
import '../../../models/db/work_flow/tracking_doc_model.dart';
import '../../../models/db/work_flow/tracking_response_model.dart';
import '../../../models/db/work_flow/user_step_request_body.dart';
import '../../../models/db/work_flow/user_work_flow_steps.dart';
import '../../../models/db/work_flow/work_flow_doc_model.dart';
import '../../../models/db/work_flow/work_flow_document_info.dart';
import '../../../models/db/work_flow/work_flow_template_body.dart';
import '../../../utils/constants/api_constants.dart';
import '../../handler/api_service.dart';

class WorkFlowTemplateContoller {
  Future<List<WorkFlowTemplateBody>> getTemplatesList(
      TemplateModel searchCriteria) async {
    const api = getTemplates;
    List<WorkFlowTemplateBody> templateList = [];

    var response = await ApiService().postRequest(api, searchCriteria);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));

      // Assuming jsonData is a list of objects
      for (var stock in jsonData) {
        templateList.add(WorkFlowTemplateBody.fromJson(stock));
      }
    } else {
      print("Error: ${response.statusCode}, ${response.reasonPhrase}");
    }

    return templateList; // Return the populated list
  }

  Future<int> getTotalDep(TemplateModel searchCriteria) async {
    var api = totalDepApi;

    int itemCount = 0;
    await ApiService().postRequest(api, searchCriteria).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(value.bodyBytes));
        itemCount = CountModel.fromJson(jsonData).count!;
      }
    });

    return itemCount;
  }

  Future addTemplate(WorkFlowTemplateBody documentFileRequest) async {
    return await ApiService()
        .postRequest(createTemplate, documentFileRequest.toJson());
  }

  Future editTemplate(WorkFlowTemplateBody documentFileRequest) async {
    return await ApiService()
        .postRequest(updateTemplate, documentFileRequest.toJson());
  }

  Future removeTemplate(WorkFlowTemplateBody documentFileRequest) async {
    return await ApiService()
        .postRequest(deleteTemplate, documentFileRequest.toJson());
  }

  Future<List<WorkFlowDocumentInfo>> getWorkFlowDocumentInfo(
      WorkFlowDocumentModel searchCriteria) async {
    const api = getWorkFlowDoc;
    List<WorkFlowDocumentInfo> templateList = [];

    var response = await ApiService().postRequest(api, searchCriteria);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));

      // Assuming jsonData is a list of objects
      for (var stock in jsonData) {
        templateList.add(WorkFlowDocumentInfo.fromJson(stock));
      }
    } else {
      print("Error: ${response.statusCode}, ${response.reasonPhrase}");
    }

    return templateList; // Return the populated list
  }

  Future updateDocumentTemplate(
      WorkFlowDocumentInfo documentFileRequest) async {
    return await ApiService()
        .postRequest(updateWorkFlowDoc, documentFileRequest.toJson());
  }

  Future removeWorkflowDocument(
      WorkFlowDocumentInfo documentFileRequest) async {
    return await ApiService()
        .postRequest(deleteWorklowDoc, documentFileRequest.toJson());
  }

  Future<List<UserWorkflowSteps>> getUserWorkFlowSteps(
      UserStepRequestBody usetStepRequestBody) async {
    const api = userWorkFlowSteps;
    List<UserWorkflowSteps> templateList = [];

    var response = await ApiService().postRequest(api, usetStepRequestBody);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));

      // Assuming jsonData is a list of objects
      for (var stock in jsonData) {
        templateList.add(UserWorkflowSteps.fromJson(stock));
      }
    } else {
      print("Error: ${response.statusCode}, ${response.reasonPhrase}");
    }

    return templateList; // Return the populated list
  }

  Future updateUserStep(UserWorkflowSteps documentFileRequest) async {
    return await ApiService()
        .postRequest(updateWorkFlowStep, documentFileRequest.toJson());
  }

  Future<List<UserWorkflowSteps>> getAllUsersWorkFlowSteps(
      UserStepRequestBody usetStepRequestBody) async {
    const api = allUserWorkFlowSteps;
    List<UserWorkflowSteps> templateList = [];

    var response = await ApiService().postRequest(api, usetStepRequestBody);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));

      // Assuming jsonData is a list of objects
      for (var stock in jsonData) {
        templateList.add(UserWorkflowSteps.fromJson(stock));
      }
    } else {
      print("Error: ${response.statusCode}, ${response.reasonPhrase}");
    }

    return templateList; // Return the populated list
  }

  Future createTrackingDoc(TrackingDocModel trackingDocModel) async {
    return await ApiService()
        .postRequest(createTrackingDocs, trackingDocModel.toJson());
  }

  /// Backend may return a raw array, a single `{ tracking, steps }` object, or a wrapped list.
  List<TrackingResponseModel> _parseAwaitingReceiveBody(dynamic decoded) {
    List<dynamic>? list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map) {
      final m = Map<String, dynamic>.from(decoded);
      if (m['tracking'] != null) {
        list = [m];
      } else {
        for (final k in [
          'data',
          'content',
          'result',
          'items',
          'value',
          'payload',
        ]) {
          final v = m[k];
          if (v is List) {
            list = v;
            break;
          }
        }
      }
    }
    if (list == null || list.isEmpty) {
      return [];
    }
    return TrackingResponseModel.fromJsonList(list);
  }

  Future<List<TrackingResponseModel>> getAwaitingReceiveTracking() async {
    final response =
        await ApiService().getRequest(getAwaitingReceiveTrackingApi);
    if (response == null || response.statusCode != 200) {
      return [];
    }
    try {
      final raw = utf8.decode(response.bodyBytes);
      if (raw.trim().isEmpty) {
        return [];
      }
      final jsonData = jsonDecode(raw);
      final out = _parseAwaitingReceiveBody(jsonData);
      if (out.isEmpty && kDebugMode) {
        debugPrint(
          'getAwaitingReceiveTracking: 200 but 0 rows after parse. '
          'Top-level JSON type: ${jsonData.runtimeType}',
        );
      }
      return out;
    } catch (e, st) {
      debugPrint('getAwaitingReceiveTracking parse error: $e\n$st');
      return [];
    }
  }

  /// POST [stepKey] = current step row id ([TrackingStepInfoModel.txtKey]).
  Future postDocumentTrackingReceive({required String stepKey}) async {
    return ApiService().postRequest(trackingReceiveApi, {
      'stepKey': stepKey,
    });
  }

  Future postDocumentTrackingSend({
    required String stepKey,
    String notes = '',
  }) async {
    return ApiService().postRequest(trackingSendApi, {
      'stepKey': stepKey,
      'notes': notes,
    });
  }

  Future<List<TrackingResponseModel>> getTrackingByDocument(
      String documentCode) async {
    final api = "document-tracking/by-document/$documentCode"; // dynamic URL
    List<TrackingResponseModel> trackingList = [];

    var response = await ApiService().getRequest(api);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      trackingList = TrackingResponseModel.fromJsonList(jsonData);
    } else {
      print("Error: ${response.statusCode}, ${response.reasonPhrase}");
    }

    return trackingList;
  }
}
