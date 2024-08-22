import 'dart:convert';
import 'package:archiving_flutter_project/models/db/department_models/department_model.dart';
import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:archiving_flutter_project/utils/constants/api_constants.dart';
import '../../models/db/doc_cat_report_model.dart';
import '../../models/db/doc_dept_report_model.dart';
import '../../models/db/user_doc_report_model.dart';
import '../../models/dto/reports_criteria.dart';

class ReportsController {
  Future<List<UserDocReportModel>> getUserDocuments(
      ReportsCriteria searchModel) async {
    List<UserDocReportModel> list = [];
    await ApiService()
        .postRequest(getUserDocsAPI, searchModel)
        .then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        for (var stock in jsonData) {
          list.add(UserDocReportModel.fromJson(stock));
        }
      }
    });
    return list;
  }

  Future<List<DocCatReportModel>> getDocByCat(
      ReportsCriteria searchModel) async {
    List<DocCatReportModel> list = [];
    await ApiService().postRequest(getDocsByCat, searchModel).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        for (var stock in jsonData) {
          list.add(DocCatReportModel.fromJson(stock));
        }
      }
    });
    return list;
  }

  Future<List<DocDeptReportModel>> getDocByDept(
      ReportsCriteria searchModel) async {
    List<DocDeptReportModel> list = [];
    await ApiService().postRequest(getDocsByDept, searchModel).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        for (var stock in jsonData) {
          list.add(DocDeptReportModel.fromJson(stock));
        }
      }
    });
    return list;
  }
}
