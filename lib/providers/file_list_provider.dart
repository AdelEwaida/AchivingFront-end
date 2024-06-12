import 'package:archiving_flutter_project/models/dto/searchs_model/search_document_criterea.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class DocumentListProvider with ChangeNotifier {
  List<PlutoRow> _documentListCritereaRows = [];
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
