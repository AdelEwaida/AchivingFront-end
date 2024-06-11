import '../../../models/db/department_models/department_model.dart';
import '../../../models/db/document_models/document_request.dart';
import '../../../models/db/document_models/documnet_info_model.dart';
import '../../../models/db/document_models/upload_file_mode.dart';
import '../../../utils/constants/api_constants.dart';
import '../../handler/api_service.dart';

class DocumentsController {
  //modify this method
  Future addDocument7(DepartmentModel departmentModel) async {
    return await ApiService()
        .postRequest(inserttDocFile, departmentModel.toJsonAdd());
  }

  Future addDocument(DocumentFileRequest documentFileRequest) async {
    return await ApiService()
        .postRequest(inserttDocFile, documentFileRequest.toJson());
  }
}
