class SearchModel {
  int? page;
  String? searchField;
  int? status;
  SearchModel({this.page, this.searchField, this.status});
  Map<String, dynamic> toJson() {
    return {"page": page, "searchField": searchField, "status": status};
  }
}
