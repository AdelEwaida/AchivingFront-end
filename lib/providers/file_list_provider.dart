import 'package:archiving_flutter_project/models/db/user_models/department_user_model.dart';
import 'package:archiving_flutter_project/models/dto/searchs_model/search_document_criterea.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class DocumentListProvider with ChangeNotifier {
  List<PlutoRow> _documentListCritereaRows = [];
  String? _issueNumber;
  String? _desc;
  bool? isViewFile;
  DepartmentUserModel? _departmentUserModel;
  void setDepartmentUserModel(DepartmentUserModel dept) {
    _departmentUserModel = dept;
    notifyListeners();
  }

  DepartmentUserModel? get departmentUserModel => _departmentUserModel;
  void setIsViewFile(bool isView) {
    isViewFile = isView;
    notifyListeners();
  }

  void setDescription(String? s) {
    _desc = s;
  }

  String? get description => _desc;
  void setIssueNumber(String? s) {
    _issueNumber = s;
  }

  String? get issueNumber => _issueNumber;
  int? _page = 1;
  void setPage(int page) {
    _page = page;
    notifyListeners();
  }

  int? get page => _page;
  bool _isSearch = false;
  void setIsSearch(bool isSearch) {
    _isSearch = isSearch;
    notifyListeners();
  }

  bool get isSearch => _isSearch;
  SearchDocumentCriteria _searchDocumentCriteria = SearchDocumentCriteria();

  void setFileListCritereaRows(List<PlutoRow> fileListCritereaRows) {
    _documentListCritereaRows = fileListCritereaRows;
    notifyListeners();
  }

  List<PlutoRow> get documentListCritereaRows => _documentListCritereaRows;

  void setDocumentSearchCriterea(
      SearchDocumentCriteria searchDocumentCriteria) {
    _searchDocumentCriteria = searchDocumentCriteria;
    notifyListeners();
  }

  SearchDocumentCriteria get searchDocumentCriteria => _searchDocumentCriteria;
  void notifay() {
    notifyListeners();
  }
}
