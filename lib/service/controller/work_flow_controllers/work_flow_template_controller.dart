import 'dart:convert';

import 'package:archiving_flutter_project/models/db/work_flow/template_model.dart';

import '../../../models/db/work_flow/setup_model.dart';
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

  Future<List<UserWorkflowSteps>> getUserWorkFlowSteps() async {
    const api = userWorkFlowSteps;
    List<UserWorkflowSteps> templateList = [];

    var response = await ApiService().postRequest(api, {});

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
}
