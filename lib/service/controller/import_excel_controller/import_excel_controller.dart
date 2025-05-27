import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:http/http.dart' as http;

import '../../../utils/constants/api_constants.dart';

class ImportExcelController {
  Future<http.Response> importIssues(List<String> issuesList) async {

    final body = {
      "issuesList": issuesList,
    };

    final response = await ApiService().postRequestExcel(
      importIssuesApi,
      body,
    ) as http.Response;

    return response;
  }
}
