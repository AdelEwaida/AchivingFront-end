import 'dart:convert';

import 'package:archiving_flutter_project/models/dto/searchs_model/search_document_criterea.dart';

import '../../../models/db/categories_models/doc_cat_parent.dart';
import '../../../models/db/department_models/department_model.dart';
import '../../../models/db/document_models/document_request.dart';
import '../../../models/db/document_models/documnet_info_model.dart';
import '../../../models/db/document_models/upload_file_mode.dart';
import '../../../utils/constants/api_constants.dart';
import '../../handler/api_service.dart';

class DocumentsController {
  Future addDocument(DocumentFileRequest documentFileRequest) async {
    return await ApiService()
        .postRequest(inserttDocFile, documentFileRequest.toJson());
  }

  Future updateDocument(DocumentModel documentFileRequest) async {
    return await ApiService()
        .postRequest(updateDoc, documentFileRequest.toJson());
  }

  Future<List<DocumentModel>> searchDocCriterea(
      SearchDocumentCriteria searchDocumentCriteria) async {
    List<DocumentModel> list = [];
    var response = await ApiService()
        .postRequest(searchDocCritereaFile, searchDocumentCriteria);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      for (var stock in jsonData) {
        list.add(DocumentModel.fromJson(stock));
      }
    }
    return list;
  }

  Future<List<FileUploadModel>> getFilesByHdrKey(String hdrKey) async {
    List<FileUploadModel> list = [];
    var response =
        await ApiService().postRequest(getFilesByHdrApi, {'hdrKey': hdrKey});
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      for (var stock in jsonData) {
        list.add(FileUploadModel.fromJson(stock));
      }
    }
    return list;
  }

  Future<List<DocCatParent>> getDocCategoryList() async {
    List<DocCatParent> list = [];
    await ApiService().getRequest(getDocCategory).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        for (var stock in jsonData) {
          list.add(DocCatParent.fromJson(stock));
        }
      }
    });
    return list;
  }
}
