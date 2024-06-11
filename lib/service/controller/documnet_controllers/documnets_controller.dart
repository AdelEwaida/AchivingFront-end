import '../../../models/db/department_models/department_model.dart';
import '../../../utils/constants/api_constants.dart';
import '../../handler/api_service.dart';

class DocumnetsController {
  Future addDep(DepartmentModel departmentModel) async {
    return await ApiService()
        .postRequest(inserttDocFile, departmentModel.toJsonAdd());
  }
}
