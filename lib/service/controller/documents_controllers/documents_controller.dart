import 'dart:convert';

import 'package:archiving_flutter_project/models/db/scaners_model.dart';
import 'package:archiving_flutter_project/models/db/scanned_image.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_document_criterea.dart';

import '../../../models/db/categories_models/doc_cat_parent.dart';
import '../../../models/db/count_model.dart';
import '../../../models/db/department_models/department_model.dart';
import '../../../models/db/document_models/document_request.dart';
import '../../../models/db/document_models/documnet_info_model.dart';
import '../../../models/db/document_models/upload_file_mode.dart';
import '../../../utils/constants/api_constants.dart';
import '../../handler/api_service.dart';

class DocumentsController {
  //modify this method
  // Future addDocument7(DepartmentModel departmentModel) async {
  //   return await ApiService()
  //       .postRequest(inserttDocFile, departmentModel.toJsonAdd());
  // }
  Future uplodFileInDocument(DocumentFileRequest documentFileRequest) async {
    return await ApiService()
        .postRequest(uplodeFileInDocApi, documentFileRequest.toJson());
  }

  Future deleteFile(String txtKey) async {
    return await ApiService().postRequest(deleteFileApi, {"txtKey": txtKey});
  }

  Future addDocument(DocumentFileRequest documentFileRequest) async {
    return await ApiService()
        .postRequest(inserttDocFile, documentFileRequest.toJson());
  }

  Future copyDocument(DocumentModel documentFileRequest) async {
    print("copppppy ${documentFileRequest.toJson()}");
    return await ApiService()
        .postRequest(copyFileDocApi, documentFileRequest.toJson());
  }

  Future deleteDocument(DocumentModel documentFileRequest) async {
    return await ApiService().postRequest(
        deleteDocApi, {"documentInfo": documentFileRequest.toJson()});
  }

  Future updateDocument(DocumentModel documentFileRequest) async {
    return await ApiService()
        .postRequest(updateDoc, documentFileRequest.toJson());
  }

  Future createWorkFlowDocument(DocumentModel documentFileRequest) async {
    return await ApiService()
        .postRequest(createWorkFlowDoc, documentFileRequest.toJson());
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

  Future<int> getTotalSearchDocCountFile(
      SearchDocumentCriteria searchDocumentCriteria) async {
    var api = searchDocCountFile;

    int itemCount = 0;
    await ApiService().postRequest(api, searchDocumentCriteria).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(value.bodyBytes));
        itemCount = CountModel.fromJson(jsonData).count!;
      }
    });

    return itemCount;
  }

  Future<List<DocumentModel>> searchByContent(
      SearchDocumentCriteria searchDocumentCriteria) async {
    List<DocumentModel> list = [];
    var response = await ApiService()
        .postRequest(searchByContentApi, searchDocumentCriteria);
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

  Future<FileUploadModel?> getLatestFileMethod(String hdrKey) async {
    var response =
        await ApiService().postRequest(getLatestFile, {'hdrKey': hdrKey});

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));

      // Assuming jsonData is a single object
      return FileUploadModel.fromJson(jsonData);
    }

    // Return null if the response is not successful or jsonData is not a single object
    return null;
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

  Future<List<String>> getAllScannersMethod(String ip) async {
    List<String> list = [];
    var response = await ApiService().getRequest(getAllScanners);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      for (var scanner in jsonData['scanners']) {
        list.add(scanner);
      }
    }
    return list;
  }

  Future<ScannedImage> getSccanedImageMethod(String ip, int index) async {
    var response = await ApiService().getRequest("$getScanedImageApi/$index");
    var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
    // print(jsonData);
    ScannedImage scannedImage = ScannedImage.fromJson(jsonData);
    return scannedImage;
  }

  Future<int> getDocInfoCount(
      SearchDocumentCriteria searchDocumentCriteria) async {
    var api = getInfoCount;

    int itemCount = 0;
    await ApiService().postRequest(api, searchDocumentCriteria).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(value.bodyBytes));
        itemCount = CountModel.fromJson(jsonData).count!;
      }
    });
    return itemCount;
  }

//getTotalUserCatCount
  Future<int> getUserCatCount() async {
    var api = getTotalUserCatCount;

    int itemCount = 0;
    await ApiService().getRequest(api).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(value.bodyBytes));
        itemCount = CountModel.fromJson(jsonData).count!;
      }
    });

    return itemCount;
  }

  Future<int> getDocCatCount() async {
    var api = totlaFilesApi;

    int itemCount = 0;
    await ApiService().getRequest(api).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(value.bodyBytes));
        itemCount = CountModel.fromJson(jsonData).count!;
      }
    });

    return itemCount;
  }
}
